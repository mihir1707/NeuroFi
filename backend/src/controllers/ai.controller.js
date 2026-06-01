import Joi from "joi";
import { categorizeExpense, batchCategorize } from "../services/ai/categorizer.service.js";
import { generateInsights } from "../services/ai/insights.service.js";
import { predictBudgets } from "../services/ai/predictor.service.js";
import { chat } from "../services/ai/chatbot.service.js";
import { sendSuccess, sendError } from "../utils/response.util.js";


const categorizeSchema = Joi.object({
  description: Joi.string().trim().required(),
  amount: Joi.number().positive().optional(),
  currency: Joi.string().length(3).uppercase().optional(),
  merchantName: Joi.string().trim().optional().allow(""),
});

const batchCategorizeSchema = Joi.object({
  transactions: Joi.array()
    .items(
      Joi.object({
        description: Joi.string().trim().required(),
        amount: Joi.number().optional(),
        merchantName: Joi.string().optional().allow(""),
      })
    )
    .min(1)
    .max(50)
    .required(),
});

const chatSchema = Joi.object({
  message: Joi.string().trim().min(1).max(500).required(),
  history: Joi.array()
    .items(
      Joi.object({
        role: Joi.string().valid("user", "assistant").required(),
        content: Joi.string().required(),
      })
    )
    .optional()
    .default([]),
});

export const categorizeTransaction = async (req, res) => {
  const { error, value } = categorizeSchema.validate(req.body, { abortEarly: false });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const result = await categorizeExpense(value);

  return sendSuccess(res, 200, "Transaction categorized", result);
};


export const batchCategorizeTransactions = async (req, res) => {
  const { error, value } = batchCategorizeSchema.validate(req.body, { abortEarly: false });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const results = await batchCategorize(value.transactions);

  return sendSuccess(res, 200, "Transactions categorized", {
    results,
    count: results.length,
  });
};

export const getInsights = async (req, res) => {
  const result = await generateInsights(req.user._id.toString());

  return sendSuccess(res, 200, "Financial insights generated", result);
};


export const getBudgetPredictions = async (req, res) => {
  const result = await predictBudgets(req.user._id);

  return sendSuccess(res, 200, "Budget predictions generated", result);
};


export const chatWithAI = async (req, res) => {
  const { error, value } = chatSchema.validate(req.body, { abortEarly: false });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const result = await chat(req.user._id.toString(), value.message, value.history);

  return sendSuccess(res, 200, "Response generated", result);
};