import Joi from "joi";
import Budget from "../models/Budget.js";
import Transaction from "../models/Transaction.js";
import { sendSuccess, sendError, sendPaginated } from "../utils/response.util.js";
import { parsePagination, buildPagination } from "../utils/paginate.util.js";
import { getMonthRange } from "../utils/dateRange.util.js";

const createBudgetSchema = Joi.object({
  category: Joi.string().hex().length(24).required(),
  amount: Joi.number().positive().required(),
  currency: Joi.string().length(3).uppercase().default("INR"),
  period: Joi.string().valid("daily", "weekly", "monthly", "yearly").default("monthly"),
  alertThreshold: Joi.number().min(0).max(100).default(80),
  startDate: Joi.date().default(() => new Date()),
  endDate: Joi.date().optional().allow(null),
});

const updateBudgetSchema = Joi.object({
  amount: Joi.number().positive().optional(),
  alertThreshold: Joi.number().min(0).max(100).optional(),
  isActive: Joi.boolean().optional(),
  endDate: Joi.date().optional().allow(null),
});

export const getBudgets = async (req, res) => {
  const { page, limit, skip } = parsePagination(req.query);

  const filter = { user: req.user._id };
  if (req.query.period) filter.period = req.query.period;
  if (req.query.isActive !== undefined) filter.isActive = req.query.isActive === "true";

  const [budgets, total] = await Promise.all([
    Budget.find(filter)
      .populate("category", "name icon color")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .lean(),
    Budget.countDocuments(filter),
  ]);

  const now = new Date();
  const { start, end } = getMonthRange(now.getFullYear(), now.getMonth() + 1);

  const enrichedBudgets = await Promise.all(
    budgets.map(async (budget) => {
      const spendingResult = await Transaction.aggregate([
        {
          $match: {
            user: req.user._id,
            category: budget.category?._id,
            type: "expense",
            transactionDate: { $gte: start, $lte: end },
          },
        },
        { $group: { _id: null, total: { $sum: "$amount" } } },
      ]);

      const actualSpent = spendingResult[0]?.total || 0;
      const percentUsed = budget.amount > 0 ? (actualSpent / budget.amount) * 100 : 0;

      return {
        ...budget,
        spent: actualSpent,
        percentUsed: parseFloat(percentUsed.toFixed(1)),
        remaining: Math.max(0, budget.amount - actualSpent),
        status: percentUsed >= 100 ? "exceeded" : percentUsed >= budget.alertThreshold ? "warning" : "good",
      };
    })
  );

  return sendPaginated(res, 200, "Budgets retrieved", enrichedBudgets, buildPagination({ page, limit, total }));
};

export const createBudget = async (req, res) => {
  const { error, value } = createBudgetSchema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const existingBudget = await Budget.findOne({
    user: req.user._id,
    category: value.category,
    period: value.period,
    isActive: true,
  });

  if (existingBudget) {
    return sendError(
      res,
      409,
      "An active budget for this category and period already exists. Update the existing one instead."
    );
  }

  const budget = await Budget.create({
    ...value,
    user: req.user._id,
  });

  await budget.populate("category", "name icon color");

  return sendSuccess(res, 201, "Budget created successfully", budget);
};

export const getBudget = async (req, res) => {
  const budget = await Budget.findOne({
    _id: req.params.budgetId,
    user: req.user._id,
  }).populate("category", "name icon color");

  if (!budget) {
    return sendError(res, 404, "Budget not found");
  }

  return sendSuccess(res, 200, "Budget retrieved", budget);
};

export const updateBudget = async (req, res) => {
  const { error, value } = updateBudgetSchema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const budget = await Budget.findOneAndUpdate(
    { _id: req.params.budgetId, user: req.user._id },
    { $set: value },
    { new: true, runValidators: true }
  ).populate("category", "name icon color");

  if (!budget) {
    return sendError(res, 404, "Budget not found");
  }

  return sendSuccess(res, 200, "Budget updated successfully", budget);
};

export const deleteBudget = async (req, res) => {
  const budget = await Budget.findOneAndDelete({
    _id: req.params.budgetId,
    user: req.user._id,
  });

  if (!budget) {
    return sendError(res, 404, "Budget not found");
  }

  return sendSuccess(res, 200, "Budget deleted successfully");
};