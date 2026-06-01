import express from "express";
import {
  getMonthlyReport,
  getYearlyReport,
  getOverview,
  exportReport,
  getCurrencyRates,
} from "../controllers/report.controller.js";
import { authMiddleware } from "../middleware/auth.middleware.js";
import { asyncHandler } from "../middleware/errorHandler.middleware.js";

const router = express.Router();

router.use(authMiddleware);

router.get("/monthly", asyncHandler(getMonthlyReport));
router.get("/yearly", asyncHandler(getYearlyReport));
router.get("/overview", asyncHandler(getOverview));
router.get("/export", asyncHandler(exportReport));
router.get("/currency", asyncHandler(getCurrencyRates));

export default router;
