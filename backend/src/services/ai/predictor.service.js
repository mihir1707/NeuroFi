import { getOpenAIClient, isAIEnabled, AI_MODEL } from "../../config/openai.js";
import Transaction from "../../models/Transaction.js";

// CONSTANTS
const ANALYSIS_MONTHS = 6;
const MIN_MONTHS_FOR_TREND = 3;

const MONTH_NAMES = [
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December",
];

// Indian seasonal spending patterns (month index 1–12)
const SEASONAL_PATTERNS = {
  "Food & Dining":   { 10: 1.3, 11: 1.35, 12: 1.4, 1: 1.1 },
  "Shopping":        { 10: 1.5, 11: 1.45, 12: 1.4, 8: 1.2, 1: 1.1 },
  "Travel":          { 5: 1.4, 6: 1.35, 12: 1.35, 1: 1.2, 10: 1.25 },
  "Utilities":       { 5: 1.25, 6: 1.35, 7: 1.3, 4: 1.1 },
  "Entertainment":   { 10: 1.3, 11: 1.3, 12: 1.35, 1: 1.1 },
  "Education":       { 6: 1.5, 7: 1.4, 1: 1.3, 4: 1.2 },
  "Health":          { 7: 1.2, 8: 1.2, 1: 1.15 },
};


// STEP 1 — FETCH MONTHLY SPENDING PER CATEGORY
const getMonthlySpendingByCategory = async (userId, months = ANALYSIS_MONTHS) => {
  const endDate = new Date();
  const startDate = new Date();
  startDate.setMonth(startDate.getMonth() - months);

  const rawData = await Transaction.aggregate([
    {
      $match: {
        user: userId,
        type: "expense",
        transactionDate: { $gte: startDate, $lte: endDate },
        category: { $ne: null },
      },
    },
    {
      $group: {
        _id: {
          category: "$category",
          year: { $year: "$transactionDate" },
          month: { $month: "$transactionDate" },
        },
        total: { $sum: "$amount" },
        count: { $sum: 1 },
      },
    },
    {
      $lookup: {
        from: "categories",
        localField: "_id.category",
        foreignField: "_id",
        as: "categoryInfo",
      },
    },
    { $unwind: "$categoryInfo" },
    {
      $project: {
        categoryId: "$_id.category",
        categoryName: "$categoryInfo.name",
        year: "$_id.year",
        month: "$_id.month",
        total: 1,
        count: 1,
      },
    },
    { $sort: { year: 1, month: 1 } },
  ]);

  // Group into: { categoryId: { name, monthlyTotals: [...], categoryId } }
  const grouped = {};
  for (const row of rawData) {
    const key = row.categoryId.toString();
    if (!grouped[key]) {
      grouped[key] = {
        categoryId: row.categoryId,
        categoryName: row.categoryName,
        monthlyData: [],
      };
    }
    grouped[key].monthlyData.push({
      year: row.year,
      month: row.month,
      total: row.total,
      count: row.count,
    });
  }

  return Object.values(grouped);
};


// STEP 2 — REMOVE OUTLIERS (IQR METHOD)
const removeOutliers = (values) => {
  if (values.length < 4) return values;

  const sorted = [...values].sort((a, b) => a - b);
  const q1 = sorted[Math.floor(sorted.length * 0.25)];
  const q3 = sorted[Math.floor(sorted.length * 0.75)];
  const iqr = q3 - q1;
  const lower = q1 - 1.5 * iqr;
  const upper = q3 + 1.5 * iqr;

  const filtered = values.filter((v) => v >= lower && v <= upper);
  return filtered.length >= 2 ? filtered : values;
};


// STEP 3 — LINEAR REGRESSION (TREND DETECTION)
const computeLinearRegression = (values) => {
  const n = values.length;
  if (n < 2) return { slope: 0, intercept: values[0] ?? 0, nextPredicted: values[0] ?? 0 };

  const x = values.map((_, i) => i);
  const y = values;

  const sumX = x.reduce((s, v) => s + v, 0);
  const sumY = y.reduce((s, v) => s + v, 0);
  const sumXY = x.reduce((s, v, i) => s + v * y[i], 0);
  const sumX2 = x.reduce((s, v) => s + v * v, 0);

  const slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
  const intercept = (sumY - slope * sumX) / n;
  const nextPredicted = slope * n + intercept;

  return { slope, intercept, nextPredicted: Math.max(0, nextPredicted) };
};


// STEP 4 — TREND LABEL
const getTrendLabel = (slope, avg) => {
  if (avg === 0) return { label: "stable", percent: 0 };
  const percentChange = (slope / avg) * 100;

  if (percentChange > 15) return { label: "rising fast", percent: Math.round(percentChange) };
  if (percentChange > 5)  return { label: "rising",      percent: Math.round(percentChange) };
  if (percentChange < -15) return { label: "dropping fast", percent: Math.round(percentChange) };
  if (percentChange < -5)  return { label: "dropping",      percent: Math.round(percentChange) };
  return { label: "stable", percent: Math.round(percentChange) };
};


// STEP 5 — CONFIDENCE SCORE
const getConfidence = (values) => {
  if (values.length < MIN_MONTHS_FOR_TREND) {
    return { level: "low", note: "Too few months of data for a reliable prediction" };
  }

  const avg = values.reduce((s, v) => s + v, 0) / values.length;
  if (avg === 0) return { level: "low", note: "No spending recorded in this category" };

  const variance = values.reduce((s, v) => s + Math.pow(v - avg, 2), 0) / values.length;
  const cv = Math.sqrt(variance) / avg; // coefficient of variation

  if (cv < 0.1) return { level: "high",   note: "Very consistent spending pattern" };
  if (cv < 0.25) return { level: "medium", note: "Somewhat consistent with minor variation" };
  if (cv < 0.5)  return { level: "medium", note: "Moderate variation in spending" };
  return { level: "low", note: "Highly variable — prediction may be inaccurate" };
};


// STEP 6 — SEASONAL MULTIPLIER
const getSeasonalMultiplier = (categoryName, targetMonth) => {
  const pattern = SEASONAL_PATTERNS[categoryName];
  if (!pattern) return 1.0;
  return pattern[targetMonth] ?? 1.0;
};


// STEP 7 — RULE-BASED PREDICTION (AI fallback)
const computeRuleBasedPrediction = (categoryData, targetMonth) => {
  const totals = categoryData.monthlyData.map((m) => m.total);
  const cleanTotals = removeOutliers(totals);
  const avg = cleanTotals.reduce((s, v) => s + v, 0) / cleanTotals.length;

  const { slope, nextPredicted } = computeLinearRegression(cleanTotals);
  const trend = getTrendLabel(slope, avg);
  const confidence = getConfidence(cleanTotals);
  const seasonalMultiplier = getSeasonalMultiplier(categoryData.categoryName, targetMonth);

  // Base: blend regression prediction (70%) with clean avg (30%) for stability
  const blendedBase = nextPredicted * 0.7 + avg * 0.3;

  const seasonallyAdjusted = blendedBase * seasonalMultiplier;

  const bufferMultiplier = trend.label.includes("rising") ? 1.12 : 1.07;
  const suggestedBudget = Math.ceil(seasonallyAdjusted * bufferMultiplier);

  const lastMonthSpend = totals[totals.length - 1] ?? 0;

  return {
    category: categoryData.categoryName,
    categoryId: categoryData.categoryId,
    suggestedBudget,
    currentAvg: Math.round(avg),
    lastMonthSpend: Math.round(lastMonthSpend),
    trend: trend.label,
    trendPercent: trend.percent,
    seasonalMultiplier,
    confidence: confidence.level,
    confidenceNote: confidence.note,
    reasoning: buildRuleReasoning(avg, trend, seasonalMultiplier, bufferMultiplier, categoryData.categoryName, targetMonth),
    dataPoints: cleanTotals.length,
  };
};

const buildRuleReasoning = (avg, trend, seasonalMultiplier, bufferMultiplier, categoryName, targetMonth) => {
  const parts = [`Based on ₹${Math.round(avg)}/month average`];
  if (trend.label !== "stable") parts.push(`spending is ${trend.label} (${Math.abs(trend.percent)}%)`);
  if (seasonalMultiplier !== 1.0) {
    const monthName = MONTH_NAMES[targetMonth - 1];
    parts.push(`${monthName} seasonal adjustment ×${seasonalMultiplier}`);
  }
  parts.push(`${Math.round((bufferMultiplier - 1) * 100)}% buffer added`);
  return parts.join("; ");
};


// STEP 8 — ENRICH DATA FOR AI PROMPT
const enrichCategoryForAI = (categoryData, targetMonth) => {
  const totals = categoryData.monthlyData.map((m) => m.total);
  const cleanTotals = removeOutliers(totals);
  const avg = cleanTotals.reduce((s, v) => s + v, 0) / cleanTotals.length;

  const { slope, nextPredicted } = computeLinearRegression(cleanTotals);
  const trend = getTrendLabel(slope, avg);
  const confidence = getConfidence(cleanTotals);
  const seasonalMultiplier = getSeasonalMultiplier(categoryData.categoryName, targetMonth);
  const lastMonthSpend = totals[totals.length - 1] ?? 0;

  return {
    categoryName: categoryData.categoryName,
    categoryId: categoryData.categoryId,
    avgMonthlySpend: Math.round(avg),
    lastMonthSpend: Math.round(lastMonthSpend),
    trendDirection: trend.label,
    trendPercent: trend.percent,
    regressionNextMonth: Math.round(nextPredicted),
    seasonalMultiplier,
    confidence: confidence.level,
    confidenceNote: confidence.note,
    dataPoints: cleanTotals.length,
  };
};


// STEP 9 — AI PREDICTION (ENHANCED PROMPT)
const getAIPredictions = async (enrichedCategories, targetMonth, targetYear) => {
  const client = getOpenAIClient();
  const monthName = MONTH_NAMES[targetMonth - 1];

  const categoryContext = enrichedCategories
    .map(
      (c) => `
Category: ${c.categoryName}
  - Monthly average (outliers removed): ₹${c.avgMonthlySpend}
  - Last month actual: ₹${c.lastMonthSpend}
  - Trend: ${c.trendDirection} (${c.trendPercent > 0 ? "+" : ""}${c.trendPercent}% per month)
  - Regression prediction for next month: ₹${c.regressionNextMonth}
  - Seasonal multiplier for ${monthName}: ×${c.seasonalMultiplier}
  - Prediction confidence: ${c.confidence} — ${c.confidenceNote}`
    )
    .join("\n");

  const prompt = `You are an expert financial planner for Indian users.

I have already done statistical analysis on the user's spending. Use this enriched data to suggest smart monthly budgets for ${monthName} ${targetYear}.

${categoryContext}

Rules:
1. Use the regression prediction and seasonal multiplier as the base — don't ignore them.
2. Add a buffer: 8–15% for rising/volatile categories, 5–8% for stable/dropping ones.
3. For low-confidence categories, suggest a conservative higher buffer and note the uncertainty.
4. For "dropping fast" categories, suggest a tighter budget to reinforce the positive trend.
5. Budgets should be realistic for Indian spending, rounded to nearest ₹50 or ₹100.

Respond ONLY with valid JSON, no markdown, no explanation outside JSON:
{
  "predictions": [
    {
      "category": "category name",
      "suggestedBudget": 4000,
      "currentAvg": 3500,
      "lastMonthSpend": 3800,
      "trend": "rising",
      "confidence": "medium",
      "reasoning": "Regression predicts ₹3900; seasonal multiplier ×1.1 for festivals; 10% buffer added for rising trend"
    }
  ],
  "totalSuggestedBudget": 18000,
  "aiNote": "one sentence overall observation about this user's spending health"
}`;

  const response = await client.chat.completions.create({
    model: AI_MODEL,
    messages: [{ role: "user", content: prompt }],
    max_tokens: 900,
    temperature: 0.2,
  });

  const raw = response.choices[0]?.message?.content?.trim() ?? "";
  const parsed = JSON.parse(raw);

  // Merge categoryId back in (AI doesn't know it)
  parsed.predictions = parsed.predictions.map((p) => {
    const match = enrichedCategories.find(
      (c) => c.categoryName.toLowerCase() === p.category.toLowerCase()
    );
    return { ...p, categoryId: match?.categoryId ?? null };
  });

  return parsed;
};


// MAIN EXPORT
export const predictBudgets = async (userId) => {
  const nextMonth = new Date();
  nextMonth.setMonth(nextMonth.getMonth() + 1);
  const targetMonth = nextMonth.getMonth() + 1; // 1–12
  const targetYear = nextMonth.getFullYear();
  const targetMonthName = MONTH_NAMES[targetMonth - 1];

  // Fetch raw monthly data per category (6 months)
  const categoryData = await getMonthlySpendingByCategory(userId, ANALYSIS_MONTHS);

  if (categoryData.length === 0) {
    return {
      predictions: [],
      totalSuggestedBudget: 0,
      message: "Not enough transaction history. Add at least 1 month of transactions for budget predictions.",
      source: "insufficient_data",
      targetMonth: targetMonthName,
      targetYear,
    };
  }

  if (isAIEnabled()) {
    try {
      const enriched = categoryData.map((c) => enrichCategoryForAI(c, targetMonth));
      const aiResult = await getAIPredictions(enriched, targetMonth, targetYear);

      return {
        ...aiResult,
        basedOnMonths: ANALYSIS_MONTHS,
        generatedAt: new Date().toISOString(),
        targetMonth: targetMonthName,
        targetYear,
        source: "ai",
      };
    } catch (error) {
      console.warn("[Budget Predictor] AI failed, falling back to rule-based:", error.message);
    }
  }

  const predictions = categoryData.map((c) =>
    computeRuleBasedPrediction(c, targetMonth)
  );

  const totalSuggestedBudget = predictions.reduce((sum, p) => sum + p.suggestedBudget, 0);

  // Summary stats for the response
  const risingCategories = predictions.filter((p) => p.trend.includes("rising")).map((p) => p.category);
  const lowConfidence = predictions.filter((p) => p.confidence === "low").map((p) => p.category);

  return {
    predictions,
    totalSuggestedBudget,
    basedOnMonths: ANALYSIS_MONTHS,
    generatedAt: new Date().toISOString(),
    targetMonth: targetMonthName,
    targetYear,
    source: "rules",
    summary: {
      risingCategories,
      lowConfidenceCategories: lowConfidence,
      note:
        risingCategories.length > 0
          ? `Watch out: spending is rising in ${risingCategories.join(", ")}.`
          : "Your spending looks stable across all categories.",
    },
  };
};