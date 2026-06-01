import { IS_PRODUCTION } from "../config/constants.js";

export const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

export const notFoundHandler = (req, res, next) => {
  const error = new Error(`Route not found: ${req.method} ${req.originalUrl}`);
  error.statusCode = 404;
  next(error);
};

const normalizeError = (error) => {
  if (error.statusCode) return error;

  if (error.name === "ValidationError") {
    const messages = Object.values(error.errors).map((e) => e.message);
    const validationError = new Error(messages.join(". "));
    validationError.statusCode = 400;
    validationError.details = messages;
    return validationError;
  }

  if (error.code === 11000) {
    const field = Object.keys(error.keyPattern || {})[0] || "field";
    const dupError = new Error(`${field} already exists. Please use a different value.`);
    dupError.statusCode = 409;
    return dupError;
  }

  if (error.name === "CastError") {
    const castError = new Error(`Invalid value for field '${error.path}'. Expected ${error.kind}.`);
    castError.statusCode = 400;
    return castError;
  }

  if (error.name === "TokenExpiredError") {
    const expiredError = new Error("Authentication token has expired. Please log in again.");
    expiredError.statusCode = 401;
    return expiredError;
  }

  if (error.name === "JsonWebTokenError") {
    const jwtError = new Error("Invalid authentication token.");
    jwtError.statusCode = 401;
    return jwtError;
  }

  const internalError = new Error("Something went wrong. Please try again later.");
  internalError.statusCode = 500;
  return internalError;
};

export const errorHandler = (error, req, res, next) => {
  const normalizedError = normalizeError(error);
  const statusCode = normalizedError.statusCode || 500;

  const response = {
    success: false,
    message: normalizedError.message,
  };

  if (normalizedError.details) {
    response.details = normalizedError.details;
  }

  if (!IS_PRODUCTION && error.stack) {
    response.stack = error.stack;
  }

  if (statusCode >= 500) {
    console.error(`[Error ${statusCode}] ${req.method} ${req.path}:`, error.message);
  }

  res.status(statusCode).json(response);
};