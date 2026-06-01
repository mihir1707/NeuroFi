import express from "express";
import {
  categorizeTransaction,
  batchCategorizeTransactions,
  getInsights,
  getBudgetPredictions,
  chatWithAI,
} from "../controllers/ai.controller.js";
import { authMiddleware } from "../middleware/auth.middleware.js";
import { asyncHandler } from "../middleware/errorHandler.middleware.js";
import { createLimiter } from "../middleware/rateLimiter.middleware.js";

const router = express.Router();

const aiLimiter = createLimiter({
  max: 30,
  message: "Too many AI requests. Please wait a few minutes.",
});

router.use(authMiddleware);
router.use(aiLimiter);

router.post("/categorize", asyncHandler(categorizeTransaction));
router.post("/categorize/batch", asyncHandler(batchCategorizeTransactions));

router.get("/insights", asyncHandler(getInsights));
router.get("/predict-budget", asyncHandler(getBudgetPredictions));

router.post("/chat", asyncHandler(chatWithAI));

export default router;
