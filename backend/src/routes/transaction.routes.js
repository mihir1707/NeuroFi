import express from "express";
import {
  getTransactions,
  createTransaction,
  getTransaction,
  updateTransaction,
  deleteTransaction,
} from "../controllers/transaction.controller.js";
import { authMiddleware } from "../middleware/auth.middleware.js";
import { asyncHandler } from "../middleware/errorHandler.middleware.js";

const router = express.Router();

router.use(authMiddleware);

router.get("/", asyncHandler(getTransactions));
router.post("/", asyncHandler(createTransaction));
router.get("/:transactionId", asyncHandler(getTransaction));
router.patch("/:transactionId", asyncHandler(updateTransaction));
router.delete("/:transactionId", asyncHandler(deleteTransaction));

export default router;
