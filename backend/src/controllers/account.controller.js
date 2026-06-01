import Joi from "joi";
import Account from "../models/Account.js";
import Transaction from "../models/Transaction.js";
import { sendSuccess, sendError, sendPaginated } from "../utils/response.util.js";
import { parsePagination, buildPagination } from "../utils/paginate.util.js";

// Validation Schemas
const createAccountSchema = Joi.object({
  name: Joi.string().trim().max(100).required(),
  type: Joi.string()
    .valid("cash", "bank", "credit_card", "debit_card", "wallet", "investment", "loan", "other")
    .default("bank"),
  institution: Joi.string().trim().max(120).optional().allow(""),
  balance: Joi.number().required(),
  currency: Joi.string().length(3).uppercase().default("INR"),
  accountNumberLast4: Joi.string().pattern(/^\d{4}$/).optional().allow(""),
  icon: Joi.string().optional().allow(""),
  color: Joi.string().pattern(/^#([0-9a-f]{3}|[0-9a-f]{6})$/i).optional(),
});

const updateAccountSchema = Joi.object({
  name: Joi.string().trim().max(100).optional(),
  type: Joi.string()
    .valid("cash", "bank", "credit_card", "debit_card", "wallet", "investment", "loan", "other")
    .optional(),
  institution: Joi.string().trim().max(120).optional().allow(""),
  icon: Joi.string().optional().allow(""),
  color: Joi.string().pattern(/^#([0-9a-f]{3}|[0-9a-f]{6})$/i).optional(),
  isArchived: Joi.boolean().optional(),
});

export const getAccounts = async (req, res) => {
  const { page, limit, skip } = parsePagination(req.query);

  const filter = { user: req.user._id };
  if (req.query.type) filter.type = req.query.type;
  if (req.query.isArchived !== undefined) {
    filter.isArchived = req.query.isArchived === "true";
  }

  const [accounts, total] = await Promise.all([
    Account.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit).lean(),
    Account.countDocuments(filter),
  ]);

  const totalBalance = accounts
    .filter((a) => !a.isArchived)
    .reduce((sum, a) => sum + a.balance, 0);

  return sendPaginated(res, 200, "Accounts retrieved", accounts, {
    ...buildPagination({ page, limit, total }),
    totalBalance,
  });
};

export const createAccount = async (req, res) => {
  const { error, value } = createAccountSchema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const account = await Account.create({
    ...value,
    user: req.user._id,
  });

  return sendSuccess(res, 201, "Account created successfully", account);
};

export const getAccount = async (req, res) => {
  const account = await Account.findOne({
    _id: req.params.accountId,
    user: req.user._id,
  });

  if (!account) {
    return sendError(res, 404, "Account not found");
  }

  const recentTransactions = await Transaction.find({ account: account._id })
    .populate("category", "name icon")
    .sort({ transactionDate: -1 })
    .limit(5)
    .lean();

  return sendSuccess(res, 200, "Account retrieved", {
    ...account.toObject(),
    recentTransactions,
  });
};

export const updateAccount = async (req, res) => {
  const { error, value } = updateAccountSchema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const account = await Account.findOneAndUpdate(
    { _id: req.params.accountId, user: req.user._id },
    { $set: value },
    { new: true, runValidators: true }
  );

  if (!account) {
    return sendError(res, 404, "Account not found");
  }

  return sendSuccess(res, 200, "Account updated successfully", account);
};

export const deleteAccount = async (req, res) => {
  const transactionCount = await Transaction.countDocuments({
    account: req.params.accountId,
  });

  if (transactionCount > 0) {
    return sendError(
      res,
      400,
      `Cannot delete account: it has ${transactionCount} transaction(s). Archive it instead.`
    );
  }

  const account = await Account.findOneAndDelete({
    _id: req.params.accountId,
    user: req.user._id,
  });

  if (!account) {
    return sendError(res, 404, "Account not found");
  }

  return sendSuccess(res, 200, "Account deleted successfully");
};