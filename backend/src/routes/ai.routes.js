import express from "express";
import {
  categorizeTransaction,
  batchCategorizeTransactions,
  correctCategorization,
  getUserPreferences,
  deleteUserPreferenceHandler,
  getCategorizationAnalytics,
  getInsights,
  getBudgetPredictions,
  chatWithAI,
  getSubscriptionInsights,
} from "../controllers/ai.controller.js";
import { authMiddleware } from "../middleware/auth.middleware.js";
import { asyncHandler } from "../middleware/errorHandler.middleware.js";
import { createLimiter } from "../middleware/rateLimiter.middleware.js";

const router = express.Router();

// Shared AI rate limiter — 30 requests / 15 min per IP
const aiLimiter = createLimiter({
  max: 30,
  message: "Too many AI requests. Please wait a few minutes.",
});

// All AI routes require authentication
router.use(authMiddleware);
router.use(aiLimiter);


// ─── CATEGORIZATION ───────────────────────────────────────────────────────────

// Single transaction categorization (User Pref → Merchant DB → AI pipeline)
router.post("/categorize", asyncHandler(categorizeTransaction));

// Batch categorization — up to 50 transactions; unknown-only sent to AI
router.post("/categorize/batch", asyncHandler(batchCategorizeTransactions));

// User correction — teach the system "this merchant → this category" for me
router.post("/categorize/correct", asyncHandler(correctCategorization));

// List all of the user's saved merchant-category preferences
router.get("/categorize/preferences", asyncHandler(getUserPreferences));

// Remove a user preference for a specific merchant (revert to global default)
router.delete("/categorize/preferences/:merchantKey", asyncHandler(deleteUserPreferenceHandler));


// ─── INSIGHTS & PREDICTIONS ───────────────────────────────────────────────────

router.get("/insights", asyncHandler(getInsights));
router.get("/subscriptions", asyncHandler(getSubscriptionInsights));
router.get("/predict-budget", asyncHandler(getBudgetPredictions));


// ─── ANALYTICS ────────────────────────────────────────────────────────────────

// Categorization analytics: DB hit rate, AI savings, top merchants, daily trend
// Query: ?days=30 (default 30, max 365)
router.get("/analytics", asyncHandler(getCategorizationAnalytics));


// ─── CHAT ─────────────────────────────────────────────────────────────────────

router.post("/chat", asyncHandler(chatWithAI));


export default router;
