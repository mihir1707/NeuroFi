import express from "express";
import {
  getBudgets,
  createBudget,
  getBudget,
  updateBudget,
  deleteBudget,
} from "../controllers/budget.controller.js";
import { authMiddleware } from "../middleware/auth.middleware.js";
import { asyncHandler } from "../middleware/errorHandler.middleware.js";

const router = express.Router();

router.use(authMiddleware);

router.get("/", asyncHandler(getBudgets));
router.post("/", asyncHandler(createBudget));
router.get("/:budgetId", asyncHandler(getBudget));
router.patch("/:budgetId", asyncHandler(updateBudget));
router.delete("/:budgetId", asyncHandler(deleteBudget));

export default router;
