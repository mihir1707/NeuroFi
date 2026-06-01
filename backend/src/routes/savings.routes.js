import express from "express";
import {
  getSavingsGoals,
  createSavingsGoal,
  getSavingsGoal,
  updateSavingsGoal,
  depositToGoal,
  deleteSavingsGoal,
} from "../controllers/savings.controller.js";
import { authMiddleware } from "../middleware/auth.middleware.js";
import { asyncHandler } from "../middleware/errorHandler.middleware.js";

const router = express.Router();

router.use(authMiddleware);

router.get("/", asyncHandler(getSavingsGoals));
router.post("/", asyncHandler(createSavingsGoal));
router.get("/:goalId", asyncHandler(getSavingsGoal));
router.patch("/:goalId", asyncHandler(updateSavingsGoal));
router.patch("/:goalId/deposit", asyncHandler(depositToGoal));
router.delete("/:goalId", asyncHandler(deleteSavingsGoal));

export default router;
