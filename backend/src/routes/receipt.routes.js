import express from "express";
import {
  uploadReceipt,
  getReceipt,
  linkReceiptToTransaction,
  deleteReceipt,
} from "../controllers/receipt.controller.js";
import { authMiddleware } from "../middleware/auth.middleware.js";
import { asyncHandler } from "../middleware/errorHandler.middleware.js";
import {
  uploadReceipt as uploadMiddleware,
  handleUploadError,
} from "../middleware/upload.middleware.js";

const router = express.Router();

router.use(authMiddleware);

router.post("/", uploadMiddleware, handleUploadError, asyncHandler(uploadReceipt));
router.get("/:receiptId", asyncHandler(getReceipt));
router.patch("/:receiptId/link", asyncHandler(linkReceiptToTransaction));
router.delete("/:receiptId", asyncHandler(deleteReceipt));

export default router;
