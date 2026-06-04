const Joi = require("joi");
const GroupExpense = require("../models/GroupExpense");
const { sendSuccess, sendPaginated } = require("../utils/response.util");
const { parsePagination, buildPaginationResponse } = require("../utils/paginate.util");

const createExpenseSchema = Joi.object({
  description: Joi.string().trim().max(255).required(),
  amount: Joi.number().positive().required(),
  category: Joi.string().trim().optional(),
  participants: Joi.array()
    .items(
      Joi.object({
        user: Joi.string().hex().length(24).required(),
        shareAmount: Joi.number().positive().required(),
      })
    )
    .required(),
  expenseDate: Joi.date().optional(),
});

const updateExpenseSchema = Joi.object({
  description: Joi.string().trim().max(255).optional(),
  category: Joi.string().trim().optional(),
  status: Joi.string().valid("pending", "settled").optional(),
});

const listExpensesSchema = Joi.object({
  page: Joi.number().min(1).optional(),
  limit: Joi.number().min(1).max(100).optional(),
  category: Joi.string().optional(),
});

const createExpense = async (req, res) => {
  const { error, value } = createExpenseSchema.validate(req.body, { abortEarly: false });
  if (error) throw new Error(error.details.map((d) => d.message).join(", "));

  const participants = value.participants.map((p) => ({
    ...p,
    owesAmount: p.shareAmount,
  }));

  const expense = await GroupExpense.create({
    ...value,
    group: req.params.groupId,
    paidBy: req.user._id,
    currency: "USD",
    participants,
    expenseDate: value.expenseDate || new Date(),
  });

  await expense.populate("paidBy", "name email");
  await expense.populate("participants.user", "name email");

  return sendSuccess(res, 201, "Expense created", expense);
};

const getExpenses = async (req, res) => {
  const { error, value } = listExpensesSchema.validate(req.query, { abortEarly: false });
  if (error) throw new Error(error.details.map((d) => d.message).join(", "));

  const { page, limit, skip } = parsePagination(value);
  const query = { group: req.params.groupId };

  if (value.category) query.category = value.category;

  const [expenses, total] = await Promise.all([
    GroupExpense.find(query)
      .populate("paidBy", "name email")
      .populate("participants.user", "name email")
      .sort({ expenseDate: -1 })
      .skip(skip)
      .limit(limit)
      .lean(),
    GroupExpense.countDocuments(query),
  ]);

  const pagination = buildPaginationResponse({ page, limit, total });
  return sendPaginated(res, 200, "Expenses retrieved", expenses, pagination);
};

const getExpense = async (req, res) => {
  const expense = await GroupExpense.findOne({
    _id: req.params.expenseId,
    group: req.params.groupId,
  })
    .populate("paidBy", "name email")
    .populate("participants.user", "name email");

  if (!expense) {
    const error = new Error("Expense not found");
    error.statusCode = 404;
    throw error;
  }

  return sendSuccess(res, 200, "Expense retrieved", expense);
};

const updateExpense = async (req, res) => {
  const { error, value } = updateExpenseSchema.validate(req.body, { abortEarly: false });
  if (error) throw new Error(error.details.map((d) => d.message).join(", "));

  const expense = await GroupExpense.findOneAndUpdate(
    { _id: req.params.expenseId, group: req.params.groupId },
    value,
    { new: true, runValidators: true }
  )
    .populate("paidBy", "name email")
    .populate("participants.user", "name email");

  if (!expense) {
    const error = new Error("Expense not found");
    error.statusCode = 404;
    throw error;
  }

  return sendSuccess(res, 200, "Expense updated", expense);
};

const deleteExpense = async (req, res) => {
  const expense = await GroupExpense.findOneAndDelete({
    _id: req.params.expenseId,
    group: req.params.groupId,
  });

  if (!expense) {
    const error = new Error("Expense not found");
    error.statusCode = 404;
    throw error;
  }

  return sendSuccess(res, 200, "Expense deleted");
};

module.exports = {
  createExpense,
  getExpenses,
  getExpense,
  updateExpense,
  deleteExpense,
};
