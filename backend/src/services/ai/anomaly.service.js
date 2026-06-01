import Transaction from "../../models/Transaction.js";

const getCategoryStats = async (userId, categoryId, lookbackDays = 90) => {
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - lookbackDays);

  const transactions = await Transaction.find({
    user: userId,
    category: categoryId,
    type: "expense",
    transactionDate: { $gte: startDate },
  }).lean();

  if (transactions.length < 5) {
    return { mean: null, stdDev: null, sampleCount: transactions.length };
  }

  const amounts = transactions.map((t) => t.amount);
  const mean = amounts.reduce((sum, a) => sum + a, 0) / amounts.length;

  const variance = amounts.reduce((sum, a) => sum + Math.pow(a - mean, 2), 0) / amounts.length;
  const stdDev = Math.sqrt(variance);

  return { mean, stdDev, sampleCount: transactions.length };
};


export const detectAnomaly = async (transaction, userId) => {
  const { amount, category, type, transactionDate } = transaction;

  if (type !== "expense" || !category) {
    return { isAnomalous: false };
  }

  const stats = await getCategoryStats(userId, category);

  if (!stats.mean) {
    return { isAnomalous: false, reason: "Insufficient history" };
  }

  const { mean, stdDev } = stats;

  const zScore = stdDev > 0 ? (amount - mean) / stdDev : 0;

  let severity = "none";
  let isAnomalous = false;
  let reason = "";

  if (zScore > 3) {
    isAnomalous = true;
    severity = "high";
    reason = `This transaction (₹${amount}) is much higher than your usual spending in this category (avg: ₹${mean.toFixed(0)})`;
  } else if (zScore > 2) {
    isAnomalous = true;
    severity = "medium";
    reason = `This transaction (₹${amount}) is higher than usual for this category (avg: ₹${mean.toFixed(0)})`;
  } else if (zScore > 1.5) {
    isAnomalous = true;
    severity = "low";
    reason = `This is slightly above your typical spending in this category`;
  }

  return {
    isAnomalous,
    severity,
    reason,
    stats: {
      mean: mean.toFixed(2),
      zScore: zScore.toFixed(2),
      sampleCount: stats.sampleCount,
    },
  };
};

export const scanForAnomalies = async (userId) => {
  const recentTransactions = await Transaction.find({
    user: userId,
    type: "expense",
    transactionDate: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) },
  })
    .populate("category", "name")
    .lean();

  const anomalies = [];

  for (const transaction of recentTransactions) {
    const result = await detectAnomaly(transaction, userId);
    if (result.isAnomalous && (result.severity === "high" || result.severity === "medium")) {
      anomalies.push({
        transaction,
        ...result,
      });
    }
  }

  return anomalies;
};