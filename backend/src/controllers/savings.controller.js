import Joi from "joi";
import SavingsGoal from "../models/SavingsGoal.js";
import { sendSuccess, sendError, sendPaginated } from "../utils/response.util.js";
import { parsePagination, buildPagination } from "../utils/paginate.util.js";
import { sendGoalUpdate } from "../services/notification.service.js";

const createGoalSchema = Joi.object({
  name: Joi.string().trim().max(100).required(),
  description: Joi.string().trim().max(500).optional().allow(""),
  targetAmount: Joi.number().positive().required(),
  currency: Joi.string().length(3).uppercase().default("INR"),
  targetDate: Joi.date().required(),
  icon: Joi.string().optional().allow(""),
  color: Joi.string().pattern(/^#([0-9a-f]{3}|[0-9a-f]{6})$/i).optional(),
});

const updateGoalSchema = Joi.object({
  name: Joi.string().trim().max(100).optional(),
  description: Joi.string().trim().max(500).optional().allow(""),
  targetAmount: Joi.number().positive().optional(),
  targetDate: Joi.date().optional(),
  status: Joi.string().valid("active", "completed", "cancelled", "paused").optional(),
  icon: Joi.string().optional().allow(""),
  color: Joi.string().pattern(/^#([0-9a-f]{3}|[0-9a-f]{6})$/i).optional(),
});

const depositSchema = Joi.object({
  amount: Joi.number().positive().required(),
  notes: Joi.string().trim().max(500).optional().allow(""),
});

export const getSavingsGoals = async (req, res) => {
  const { page, limit, skip } = parsePagination(req.query);

  const filter = { user: req.user._id };
  if (req.query.status) filter.status = req.query.status;

  const [goals, total] = await Promise.all([
    SavingsGoal.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit).lean(),
    SavingsGoal.countDocuments(filter),
  ]);

  // Add progress and days remaining to each goal
  const enrichedGoals = goals.map((goal) => {
    const progressPercent = goal.targetAmount > 0
      ? Math.min(100, parseFloat(((goal.currentAmount / goal.targetAmount) * 100).toFixed(1)))
      : 0;

    const today = new Date();
    const daysRemaining = Math.max(0, Math.ceil((new Date(goal.targetDate) - today) / (1000 * 60 * 60 * 24)));

    return {
      ...goal,
      progressPercent,
      remainingAmount: Math.max(0, goal.targetAmount - goal.currentAmount),
      daysRemaining,
    };
  });

  return sendPaginated(res, 200, "Savings goals retrieved", enrichedGoals, buildPagination({ page, limit, total }));
};


export const createSavingsGoal = async (req, res) => {
  const { error, value } = createGoalSchema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  if (new Date(value.targetDate) <= new Date()) {
    return sendError(res, 400, "Target date must be in the future");
  }

  const goal = await SavingsGoal.create({
    ...value,
    user: req.user._id,
    icon: value.icon || "🎯",
    color: value.color || "#3B82F6",
  });

  const today = new Date();
  const monthsRemaining = Math.max(1, Math.ceil(
    (new Date(goal.targetDate) - today) / (1000 * 60 * 60 * 24 * 30)
  ));
  const monthlySuggestion = goal.targetAmount / monthsRemaining;

  return sendSuccess(res, 201, "Savings goal created! 🎯", {
    goal,
    monthlySuggestion: parseFloat(monthlySuggestion.toFixed(2)),
    monthsToTarget: monthsRemaining,
  });
};

export const getSavingsGoal = async (req, res) => {
  const goal = await SavingsGoal.findOne({
    _id: req.params.goalId,
    user: req.user._id,
  });

  if (!goal) {
    return sendError(res, 404, "Savings goal not found");
  }

  const progressPercent = goal.targetAmount > 0
    ? Math.min(100, parseFloat(((goal.currentAmount / goal.targetAmount) * 100).toFixed(1)))
    : 0;

  return sendSuccess(res, 200, "Savings goal retrieved", {
    ...goal.toObject(),
    progressPercent,
    remainingAmount: Math.max(0, goal.targetAmount - goal.currentAmount),
  });
};

export const updateSavingsGoal = async (req, res) => {
  const { error, value } = updateGoalSchema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const goal = await SavingsGoal.findOneAndUpdate(
    { _id: req.params.goalId, user: req.user._id },
    { $set: value },
    { new: true, runValidators: true }
  );

  if (!goal) {
    return sendError(res, 404, "Savings goal not found");
  }

  return sendSuccess(res, 200, "Savings goal updated successfully", goal);
};

export const depositToGoal = async (req, res) => {
  const { error, value } = depositSchema.validate(req.body, { abortEarly: false });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const goal = await SavingsGoal.findOne({
    _id: req.params.goalId,
    user: req.user._id,
    status: "active",
  });

  if (!goal) {
    return sendError(res, 404, "Active savings goal not found");
  }

  goal.currentAmount += value.amount;

  if (goal.currentAmount >= goal.targetAmount) {
    goal.status = "completed";
    goal.completedAt = new Date();
  }

  await goal.save();

  sendGoalUpdate(goal).catch((err) =>
    console.warn("[Savings] Goal notification failed:", err.message)
  );

  const progressPercent = Math.min(100, parseFloat(((goal.currentAmount / goal.targetAmount) * 100).toFixed(1)));

  return sendSuccess(res, 200, goal.status === "completed" ? "🎉 Congratulations! Goal completed!" : "Deposit added to goal!", {
    goal,
    progressPercent,
    remainingAmount: Math.max(0, goal.targetAmount - goal.currentAmount),
  });
};

export const deleteSavingsGoal = async (req, res) => {
  const goal = await SavingsGoal.findOneAndDelete({
    _id: req.params.goalId,
    user: req.user._id,
  });

  if (!goal) {
    return sendError(res, 404, "Savings goal not found");
  }

  return sendSuccess(res, 200, "Savings goal deleted successfully");
};