import Joi from "joi";
import {
  categorizeWithKnowledgeBase,
  batchCategorizeWithKnowledgeBase,
} from "../services/ai/categorizer.service.js";
import { generateInsights } from "../services/ai/insights.service.js";
import { predictBudgets } from "../services/ai/predictor.service.js";
import { chat } from "../services/ai/chatbot.service.js";
import { detectAndAnalyzeSubscriptions } from "../services/ai/subscription.service.js";
import {
  saveUserCorrection,
  listUserPreferences,
  deleteUserPreference,
} from "../services/ai/userPreference.service.js";
import { recordCategorizationEvent, getAnalyticsSummary } from "../services/ai/analytics.service.js";
import { extractMerchant } from "../utils/merchantNormalizer.util.js";
import { invalidateMerchantCache } from "../services/ai/merchantDB.service.js";
import { sendSuccess, sendError } from "../utils/response.util.js";


const categorizeSchema = Joi.object({
  description: Joi.string().trim().required(),
  amount: Joi.number().positive().optional(),
  currency: Joi.string().length(3).uppercase().optional(),
  merchantName: Joi.string().trim().optional().allow(""),
});

const batchCategorizeSchema = Joi.object({
  transactions: Joi.array()
    .items(
      Joi.object({
        description: Joi.string().trim().required(),
        amount: Joi.number().optional(),
        merchantName: Joi.string().optional().allow(""),
      })
    )
    .min(1)
    .max(50)
    .required(),
});

const correctSchema = Joi.object({
  merchantName: Joi.string().trim().min(1).max(255).required(),
  category: Joi.string().trim().min(1).max(80).required(),
  icon: Joi.string().trim().optional().default("📦"),
  previousCategory: Joi.string().trim().optional().allow("", null),
});

const analyticsSchema = Joi.object({
  days: Joi.number().integer().min(1).max(365).optional().default(30),
});

const chatSchema = Joi.object({
  message: Joi.string().trim().min(1).max(500).required(),
  history: Joi.array()
    .items(
      Joi.object({
        role: Joi.string().valid("user", "assistant").required(),
        content: Joi.string().required(),
      })
    )
    .optional()
    .default([]),
});


export const categorizeTransaction = async (req, res) => {
  const { error, value } = categorizeSchema.validate(req.body, { abortEarly: false });
  if (error) return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));

  const userId = req.user._id.toString();
  const startTime = Date.now();

  const result = await categorizeWithKnowledgeBase(value, userId);

  recordCategorizationEvent({
    userId,
    merchantKey: result.merchantKey || null,
    rawDescription: value.description,
    category: result.category,
    source: result.source,
    confidence: result.confidence,
    responseTimeMs: Date.now() - startTime,
    isBatch: false,
  });

  return sendSuccess(res, 200, "Transaction categorized", result);
};


export const batchCategorizeTransactions = async (req, res) => {
  const { error, value } = batchCategorizeSchema.validate(req.body, { abortEarly: false });
  if (error) return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));

  const userId = req.user._id.toString();
  const startTime = Date.now();

  const results = await batchCategorizeWithKnowledgeBase(value.transactions, userId);

  const totalTimeMs = Date.now() - startTime;
  const perItemMs = Math.round(totalTimeMs / results.length);

  const dbHits   = results.filter((r) => r.source === "merchant_db").length;
  const prefHits = results.filter((r) => r.source === "user_preference").length;
  const aiHits   = results.filter((r) => r.source === "ai").length;

  results.forEach((result, idx) => {
    recordCategorizationEvent({
      userId,
      merchantKey: result.merchantKey || null,
      rawDescription: value.transactions[idx]?.description || "",
      category: result.category,
      source: result.source,
      confidence: result.confidence,
      responseTimeMs: perItemMs,
      isBatch: true,
    });
  });

  return sendSuccess(res, 200, "Transactions categorized", {
    results,
    count: results.length,
    meta: {
      userPreferenceHits: prefHits,
      dbHits,
      aiHits,
      fallbackHits: results.length - dbHits - prefHits - aiHits,
      totalTimeMs,
    },
  });
};


export const correctCategorization = async (req, res) => {
  const { error, value } = correctSchema.validate(req.body, { abortEarly: false });
  if (error) return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));

  const userId = req.user._id.toString();
  const merchantKey = extractMerchant({ merchantName: value.merchantName });

  if (!merchantKey) {
    return sendError(res, 400, "Could not extract a valid merchant key from the provided name.");
  }

  const saved = await saveUserCorrection(
    userId,
    merchantKey,
    value.category,
    value.icon,
    value.previousCategory || null
  );

  invalidateMerchantCache(userId, merchantKey);

  recordCategorizationEvent({
    userId,
    merchantKey,
    rawDescription: value.merchantName,
    category: value.category,
    source: "user_preference",
    confidence: 1.0,
    responseTimeMs: null,
    isBatch: false,
  });

  return sendSuccess(res, 200, "Categorization preference saved", {
    merchantKey,
    category: saved.category,
    icon: saved.icon,
    totalCorrections: saved.totalCorrections,
    message: `Future "${merchantKey}" transactions will be categorized as "${saved.category}".`,
  });
};


export const getUserPreferences = async (req, res) => {
  const preferences = await listUserPreferences(req.user._id.toString());
  return sendSuccess(res, 200, "User preferences retrieved", { preferences, count: preferences.length });
};


export const deleteUserPreferenceHandler = async (req, res) => {
  const { merchantKey } = req.params;

  if (!merchantKey || typeof merchantKey !== "string") {
    return sendError(res, 400, "Invalid merchant key");
  }

  const deleted = await deleteUserPreference(
    req.user._id.toString(),
    merchantKey.toLowerCase().trim()
  );

  if (!deleted) {
    return sendError(res, 404, `No preference found for merchant "${merchantKey}"`);
  }

  return sendSuccess(res, 200, "Preference removed. This merchant will now use the default categorization.");
};


export const getCategorizationAnalytics = async (req, res) => {
  const { error, value } = analyticsSchema.validate(req.query, { abortEarly: false });
  if (error) return sendError(res, 400, "Invalid query parameters", error.details.map((d) => d.message));

  const summary = await getAnalyticsSummary(req.user._id.toString(), value.days);
  return sendSuccess(res, 200, "Categorization analytics retrieved", summary);
};


export const getInsights = async (req, res) => {
  const result = await generateInsights(req.user._id.toString());
  return sendSuccess(res, 200, "Financial insights generated", result);
};

export const getBudgetPredictions = async (req, res) => {
  const result = await predictBudgets(req.user._id);
  return sendSuccess(res, 200, "Budget predictions generated", result);
};

export const chatWithAI = async (req, res) => {
  const { error, value } = chatSchema.validate(req.body, { abortEarly: false });
  if (error) return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));

  const result = await chat(req.user._id.toString(), value.message, value.history);
  return sendSuccess(res, 200, "Response generated", result);
};

export const getSubscriptionInsights = async (req, res) => {
  const result = await detectAndAnalyzeSubscriptions(req.user._id.toString());
  return sendSuccess(res, 200, "Subscription insights generated", result);
};