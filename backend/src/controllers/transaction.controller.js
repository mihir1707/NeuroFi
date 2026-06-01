import Joi from "joi";
import Transaction from "../models/Transaction.js";
import Account from "../models/Account.js";
import Budget from "../models/Budget.js";
import { sendSuccess, sendError, sendPaginated } from "../utils/response.util.js";
import { parsePagination, buildPagination } from "../utils/paginate.util.js";
import { categorizeExpense } from "../services/ai/categorizer.service.js";
import { sendBudgetAlert } from "../services/notification.service.js";


const createTransactionSchema = Joi.object({
  account: Joi.string().hex().length(24).required(),
  transferToAccount: Joi.string().hex().length(24).optional(),
  type: Joi.string().valid("income", "expense", "transfer").required(),
  amount: Joi.number().positive().required(),
  currency: Joi.string().length(3).uppercase().default("INR"),
  category: Joi.string().hex().length(24).optional(),
  description: Joi.string().trim().max(255).optional().allow(""),
  notes: Joi.string().trim().max(2000).optional().allow(""),
  tags: Joi.array().items(Joi.string().trim().lowercase()).optional(),
  transactionDate: Joi.date().optional(),
  isRecurring: Joi.boolean().optional(),
  recurrenceInterval: Joi.string().valid("daily", "weekly", "monthly", "yearly").optional(),
  useAICategory: Joi.boolean().optional(),
});

const updateTransactionSchema = Joi.object({
  amount: Joi.number().positive().optional(),
  category: Joi.string().hex().length(24).optional().allow(null),
  description: Joi.string().trim().max(255).optional().allow(""),
  notes: Joi.string().trim().max(2000).optional().allow(""),
  tags: Joi.array().items(Joi.string().trim().lowercase()).optional(),
  transactionDate: Joi.date().optional(),
  status: Joi.string().valid("pending", "posted", "cancelled").optional(),
});


const updateAccountBalances = async (type, amount, accountId, transferToAccountId = null) => {
  if (type === "income") {
    await Account.findByIdAndUpdate(accountId, { $inc: { balance: amount } });
  } else if (type === "expense") {
    await Account.findByIdAndUpdate(accountId, { $inc: { balance: -amount } });
  } else if (type === "transfer" && transferToAccountId) {
    await Account.findByIdAndUpdate(accountId, { $inc: { balance: -amount } });
    await Account.findByIdAndUpdate(transferToAccountId, { $inc: { balance: amount } });
  }
};

const reverseAccountBalances = async (type, amount, accountId, transferToAccountId = null) => {
  if (type === "income") {
    await Account.findByIdAndUpdate(accountId, { $inc: { balance: -amount } });
  } else if (type === "expense") {
    await Account.findByIdAndUpdate(accountId, { $inc: { balance: amount } });
  } else if (type === "transfer" && transferToAccountId) {
    await Account.findByIdAndUpdate(accountId, { $inc: { balance: amount } });
    await Account.findByIdAndUpdate(transferToAccountId, { $inc: { balance: -amount } });
  }
};

const checkBudgetAlert = async (userId, categoryId, amount) => {
  if (!categoryId) return;

  const budget = await Budget.findOne({
    user: userId,
    category: categoryId,
    isActive: true,
  }).populate("category", "name").populate("user", "email");

  if (!budget) return;

  budget.spent += amount;
  await budget.save();

  const percentUsed = (budget.spent / budget.amount) * 100;
  if (percentUsed >= budget.alertThreshold && !budget.alertSent) {
    budget.alertSent = true;
    await budget.save();
    await sendBudgetAlert(budget).catch((err) =>
      console.warn("[Transaction] Budget alert failed:", err.message)
    );
  }
};

const getNextRecurrenceDate = (currentDate, interval) => {
  const next = new Date(currentDate);
  switch (interval) {
    case "daily":   next.setDate(next.getDate() + 1); break;
    case "weekly":  next.setDate(next.getDate() + 7); break;
    case "monthly": next.setMonth(next.getMonth() + 1); break;
    case "yearly":  next.setFullYear(next.getFullYear() + 1); break;
  }
  return next;
};

export const getTransactions = async (req, res) => {
  const { page, limit, skip } = parsePagination(req.query);

  const filter = { user: req.user._id };

  if (req.query.type) filter.type = req.query.type;
  if (req.query.account) filter.account = req.query.account;
  if (req.query.category) filter.category = req.query.category;
  
  if (req.query.startDate || req.query.endDate) {
    filter.transactionDate = {};
    if (req.query.startDate) filter.transactionDate.$gte = new Date(req.query.startDate);
    if (req.query.endDate) filter.transactionDate.$lte = new Date(req.query.endDate);
  }

  if (req.query.search) {
    filter.description = { $regex: req.query.search, $options: "i" };
  }

  const [transactions, total] = await Promise.all([
    Transaction.find(filter)
      .populate("category", "name icon color")
      .populate("account", "name type currency")
      .sort({ transactionDate: -1 })
      .skip(skip)
      .limit(limit)
      .lean(),
    Transaction.countDocuments(filter),
  ]);

  return sendPaginated(res, 200, "Transactions retrieved", transactions, buildPagination({ page, limit, total }));
};

export const createTransaction = async (req, res) => {
  const { error, value } = createTransactionSchema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const account = await Account.findOne({ _id: value.account, user: req.user._id });
  if (!account) {
    return sendError(res, 404, "Account not found");
  }

  if (value.type === "transfer") {
    if (!value.transferToAccount) {
      return sendError(res, 400, "transferToAccount is required for transfer transactions");
    }
    if (String(value.account) === String(value.transferToAccount)) {
      return sendError(res, 400, "Source and destination accounts must be different");
    }
    const destAccount = await Account.findOne({ _id: value.transferToAccount, user: req.user._id });
    if (!destAccount) {
      return sendError(res, 404, "Destination account not found");
    }
  }

  let aiCategoryResult = null;
  if (value.useAICategory && !value.category && value.type === "expense") {
    aiCategoryResult = await categorizeExpense({
      description: value.description || "",
      amount: value.amount,
      currency: value.currency || account.currency,
    }).catch(() => null);
  }

  const transaction = await Transaction.create({
    ...value,
    user: req.user._id,
    currency: value.currency || account.currency || "INR",
    transactionDate: value.transactionDate || new Date(),
    aiCategory: aiCategoryResult?.category || "",
    nextRecurrenceDate: value.isRecurring && value.recurrenceInterval
      ? getNextRecurrenceDate(value.transactionDate || new Date(), value.recurrenceInterval)
      : null,
  });

  await updateAccountBalances(value.type, value.amount, value.account, value.transferToAccount);

  if (value.type === "expense" && value.category) {
    checkBudgetAlert(req.user._id, value.category, value.amount).catch((err) =>
      console.warn("[Transaction] Budget check failed:", err.message)
    );
  }

  await transaction.populate([
    { path: "category", select: "name icon color" },
    { path: "account", select: "name type currency" },
  ]);

  return sendSuccess(res, 201, "Transaction created successfully", {
    transaction,
    aiCategory: aiCategoryResult,
  });
};

export const getTransaction = async (req, res) => {
  const transaction = await Transaction.findOne({
    _id: req.params.transactionId,
    user: req.user._id,
  })
    .populate("category", "name icon color")
    .populate("account", "name type currency balance")
    .populate("receipt");

  if (!transaction) {
    return sendError(res, 404, "Transaction not found");
  }

  return sendSuccess(res, 200, "Transaction retrieved", transaction);
};

export const updateTransaction = async (req, res) => {
  const { error, value } = updateTransactionSchema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const transaction = await Transaction.findOneAndUpdate(
    { _id: req.params.transactionId, user: req.user._id },
    { $set: value },
    { new: true, runValidators: true }
  )
    .populate("category", "name icon color")
    .populate("account", "name type currency");

  if (!transaction) {
    return sendError(res, 404, "Transaction not found");
  }

  return sendSuccess(res, 200, "Transaction updated successfully", transaction);
};

export const deleteTransaction = async (req, res) => {
  const transaction = await Transaction.findOneAndDelete({
    _id: req.params.transactionId,
    user: req.user._id,
  });

  if (!transaction) {
    return sendError(res, 404, "Transaction not found");
  }

  await reverseAccountBalances(
    transaction.type,
    transaction.amount,
    transaction.account,
    transaction.transferToAccount
  );

  return sendSuccess(res, 200, "Transaction deleted successfully");
};