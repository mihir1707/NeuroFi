import mongoose from 'mongoose';
import Transaction from '../../models/Transaction.js';
import { getOpenAIClient } from '../../config/openai.js';

export const detectAndAnalyzeSubscriptions = async (userId) => {
  // 1. Math (MongoDB): Aggregation Pipeline to find recurring subscriptions
  // We look back 6 months
  const sixMonthsAgo = new Date();
  sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

  const pipeline = [
    {
      $match: {
        user: new mongoose.Types.ObjectId(userId),
        type: 'expense',
        transactionDate: { $gte: sixMonthsAgo }
      }
    },
    // Sort by date ascending to calculate time differences
    { $sort: { transactionDate: 1 } },
    {
      $group: {
        _id: { $toLower: '$description' },
        count: { $sum: 1 },
        totalAmount: { $sum: '$amount' },
        avgAmount: { $avg: '$amount' },
        transactions: {
          $push: {
            date: '$transactionDate',
            amount: '$amount'
          }
        }
      }
    },
    // Filter out things that only happened once or twice
    {
      $match: {
        count: { $gte: 2 }
      }
    }
  ];

  const grouped = await Transaction.aggregate(pipeline);

  const detectedSubscriptions = [];

  // Post-process to check intervals
  for (const group of grouped) {
    if (group._id.trim() === '') continue;

    const txns = group.transactions;
    if (txns.length < 2) continue;

    // Check if the amount is roughly consistent (within 20% variation)
    const maxAmt = Math.max(...txns.map(t => t.amount));
    const minAmt = Math.min(...txns.map(t => t.amount));
    if (maxAmt > minAmt * 1.5) continue; // Too much variation, probably not a fixed sub

    // Calculate average days between transactions
    let totalDays = 0;
    for (let i = 1; i < txns.length; i++) {
      const diffMs = txns[i].date.getTime() - txns[i-1].date.getTime();
      totalDays += diffMs / (1000 * 60 * 60 * 24);
    }
    const avgDaysBetween = totalDays / (txns.length - 1);

    // A typical monthly subscription is 28-31 days. Weekly is 7.
    // Let's accept anything between 20 and 40 days as monthly.
    let frequency = 'unknown';
    if (avgDaysBetween >= 20 && avgDaysBetween <= 40) frequency = 'monthly';
    else if (avgDaysBetween >= 5 && avgDaysBetween <= 10) frequency = 'weekly';
    else if (avgDaysBetween >= 300 && avgDaysBetween <= 400) frequency = 'yearly';

    if (frequency !== 'unknown') {
      detectedSubscriptions.push({
        merchant: group._id,
        averageAmount: Math.round(group.avgAmount),
        frequency: frequency,
        lastBilled: txns[txns.length - 1].date,
        count: group.count
      });
    }
  }

  // 2. AI (OpenAI): Analyze for Zombie Bills
  if (detectedSubscriptions.length === 0) {
    return { subscriptions: [], alerts: [], totalMonthly: 0 };
  }

  const openai = getOpenAIClient();
  
  const prompt = `
You are an aggressive, highly intelligent personal finance auditor.
Analyze the following list of automatically detected recurring subscriptions for a user.

Your goal is to identify "Zombie Bills" (subscriptions people often forget about or don't use), duplicate services (e.g. having Spotify AND Apple Music), or opportunities to downgrade.

Subscriptions List:
${JSON.stringify(detectedSubscriptions, null, 2)}

Respond with a JSON object containing:
1. "alerts": An array of alert objects. Each object should have:
   - "title": A short catchy title (e.g. "Duplicate Streaming Service")
   - "message": Your personalized advice/warning.
   - "severity": "high", "medium", or "low". (Gyms, obscure SaaS, and duplicate media are 'high').
   - "merchant": The name of the merchant this relates to.
2. "insightsSummary": A 2-sentence summary of their subscription health.

ONLY output valid JSON.
  `;

  let analysis = { alerts: [], insightsSummary: "All looks good!" };
  
  try {
    const response = await openai.chat.completions.create({
      model: "gpt-3.5-turbo",
      messages: [
        { role: "system", content: "You are a JSON-only financial API." },
        { role: "user", content: prompt }
      ],
      temperature: 0.2,
    });

    let content = response.choices[0].message.content.trim();
    if (content.startsWith("\`\`\`json")) {
      content = content.replace(/\`\`\`json/g, "").replace(/\`\`\`/g, "").trim();
    }
    
    analysis = JSON.parse(content);
  } catch (error) {
    console.error("OpenAI Subscription Analysis Error:", error);
  }

  // Calculate total monthly
  let totalMonthly = 0;
  for (const sub of detectedSubscriptions) {
    if (sub.frequency === 'monthly') totalMonthly += sub.averageAmount;
    if (sub.frequency === 'weekly') totalMonthly += sub.averageAmount * 4;
    if (sub.frequency === 'yearly') totalMonthly += sub.averageAmount / 12;
  }

  return {
    totalMonthlyCost: Math.round(totalMonthly),
    subscriptions: detectedSubscriptions,
    alerts: analysis.alerts || [],
    insightsSummary: analysis.insightsSummary || "Analyzed your subscriptions."
  };
};
