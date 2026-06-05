import mongoose from "mongoose";
import CategorizationEvent from "../../models/CategorizationEvent.js";

// GPT-4o-mini: ~$0.00003 per categorize call (used for savings estimate only)
const AI_COST_PER_CALL = 0.00003;

// Save event in background — doesn't block the API response
export const recordCategorizationEvent = (eventData) => {
  setImmediate(async () => {
    try {
      await CategorizationEvent.create({
        user: eventData.userId,
        merchantKey: eventData.merchantKey || null,
        rawDescription: (eventData.rawDescription || "").slice(0, 255),
        category: eventData.category,
        source: eventData.source,
        confidence: eventData.confidence ?? null,
        responseTimeMs: eventData.responseTimeMs ?? null,
        isBatch: eventData.isBatch ?? false,
      });
    } catch (err) {
      console.warn("[Analytics] Failed to record event:", err.message);
    }
  });
};

export const getAnalyticsSummary = async (userId, days = 30) => {
  const since = new Date();
  since.setDate(since.getDate() - days);

  const userObjId = new mongoose.Types.ObjectId(userId);

  const [sourceBreakdown, topMerchants, dailyTrend] = await Promise.all([
    CategorizationEvent.aggregate([
      { $match: { user: userObjId, createdAt: { $gte: since } } },
      {
        $group: {
          _id: "$source",
          count: { $sum: 1 },
          avgConfidence: { $avg: "$confidence" },
          avgResponseTimeMs: { $avg: "$responseTimeMs" },
        },
      },
      { $sort: { count: -1 } },
    ]),

    CategorizationEvent.aggregate([
      { $match: { user: userObjId, createdAt: { $gte: since }, merchantKey: { $ne: null } } },
      {
        $group: {
          _id: "$merchantKey",
          count: { $sum: 1 },
          category: { $last: "$category" },
          source: { $last: "$source" },
        },
      },
      { $sort: { count: -1 } },
      { $limit: 10 },
      { $project: { _id: 0, merchantKey: "$_id", count: 1, category: 1, source: 1 } },
    ]),

    CategorizationEvent.aggregate([
      { $match: { user: userObjId, createdAt: { $gte: since } } },
      {
        $group: {
          _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } },
          total: { $sum: 1 },
          aiCalls: { $sum: { $cond: [{ $eq: ["$source", "ai"] }, 1, 0] } },
          dbHits: {
            $sum: {
              $cond: [{ $in: ["$source", ["merchant_db", "user_preference"]] }, 1, 0],
            },
          },
        },
      },
      { $sort: { _id: 1 } },
      { $project: { _id: 0, date: "$_id", total: 1, aiCalls: 1, dbHits: 1 } },
    ]),
  ]);

  const total = sourceBreakdown.reduce((sum, s) => sum + s.count, 0);
  const aiCount = sourceBreakdown.find((s) => s._id === "ai")?.count ?? 0;
  const savedCount = total - aiCount;

  const sourceSummary = sourceBreakdown.map((s) => ({
    source: s._id,
    count: s.count,
    percentage: total > 0 ? +((s.count / total) * 100).toFixed(1) : 0,
    avgConfidence: s.avgConfidence != null ? +s.avgConfidence.toFixed(3) : null,
    avgResponseTimeMs: s.avgResponseTimeMs != null ? Math.round(s.avgResponseTimeMs) : null,
  }));

  return {
    periodDays: days,
    since: since.toISOString(),
    totalCategorizations: total,
    aiCallCount: aiCount,
    savedCallCount: savedCount,
    dbHitRate: total > 0 ? +((savedCount / total) * 100).toFixed(1) : 0,
    aiCallRate: total > 0 ? +((aiCount / total) * 100).toFixed(1) : 0,
    estimatedCostSavedUSD: +(savedCount * AI_COST_PER_CALL).toFixed(6),
    estimatedCostSavedINR: +(savedCount * AI_COST_PER_CALL * 83.5).toFixed(4),
    userCorrectionCount: sourceBreakdown.find((s) => s._id === "user_preference")?.count ?? 0,
    sourceSummary,
    topMerchants,
    dailyTrend,
    generatedAt: new Date().toISOString(),
  };
};
