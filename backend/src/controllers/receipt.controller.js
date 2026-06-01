import Receipt from "../models/Receipt.js";
import Transaction from "../models/Transaction.js";
import { sendSuccess, sendError } from "../utils/response.util.js";
import { extractReceiptData } from "../services/ocr.service.js";

export const uploadReceipt = async (req, res) => {
  if (!req.file) {
    return sendError(res, 400, "No image file uploaded. Please attach a receipt image.");
  }

  let extractedData = {
    merchantName: "",
    totalAmount: null,
    receiptDate: null,
    suggestedCategory: "Other",
    rawText: "",
    confidence: 0,
    source: "none",
  };

  try {
    extractedData = await extractReceiptData(req.file.buffer, req.file.mimetype);
  } catch (error) {
    console.warn("[Receipt] OCR extraction failed:", error.message);
  }

  const imageUrl = `data:${req.file.mimetype};base64,${req.file.buffer.toString("base64")}`;

  const receipt = await Receipt.create({
    user: req.user._id,
    imageUrl,
    imageKey: `receipt_${req.user._id}_${Date.now()}`,
    provider: "local",
    fileName: req.file.originalname,
    fileSize: req.file.size,
    mimeType: req.file.mimetype,
    extractedData,
    ocrProcessed: true,
  });

  return sendSuccess(res, 201, "Receipt uploaded and scanned successfully", {
    receipt: {
      _id: receipt._id,
      imageUrl: receipt.imageUrl,
      fileName: receipt.fileName,
      ocrProcessed: receipt.ocrProcessed,
      extractedData: receipt.extractedData,
    },
    suggestedTransaction: {
      amount: extractedData.totalAmount,
      description: extractedData.merchantName,
      transactionDate: extractedData.receiptDate,
      category: extractedData.suggestedCategory,
    },
  });
};

export const getReceipt = async (req, res) => {
  const receipt = await Receipt.findOne({
    _id: req.params.receiptId,
    user: req.user._id,
  }).populate("transaction", "amount description transactionDate");

  if (!receipt) {
    return sendError(res, 404, "Receipt not found");
  }

  return sendSuccess(res, 200, "Receipt retrieved", receipt);
};

export const linkReceiptToTransaction = async (req, res) => {
  const { transactionId } = req.body;

  if (!transactionId) {
    return sendError(res, 400, "transactionId is required");
  }

  const transaction = await Transaction.findOne({
    _id: transactionId,
    user: req.user._id,
  });

  if (!transaction) {
    return sendError(res, 404, "Transaction not found");
  }

  const receipt = await Receipt.findOneAndUpdate(
    { _id: req.params.receiptId, user: req.user._id },
    { $set: { transaction: transactionId } },
    { new: true }
  );

  if (!receipt) {
    return sendError(res, 404, "Receipt not found");
  }

  await Transaction.findByIdAndUpdate(transactionId, { receipt: receipt._id });

  return sendSuccess(res, 200, "Receipt linked to transaction successfully", receipt);
};

export const deleteReceipt = async (req, res) => {
  const receipt = await Receipt.findOneAndDelete({
    _id: req.params.receiptId,
    user: req.user._id,
  });

  if (!receipt) {
    return sendError(res, 404, "Receipt not found");
  }

  if (receipt.transaction) {
    await Transaction.findByIdAndUpdate(receipt.transaction, { receipt: null });
  }

  return sendSuccess(res, 200, "Receipt deleted successfully");
};