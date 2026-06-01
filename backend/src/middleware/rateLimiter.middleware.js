import rateLimit from "express-rate-limit";
import { RATE_LIMIT_WINDOW_MS, RATE_LIMIT_MAX, AUTH_RATE_LIMIT_MAX } from "../config/constants.js";

export const rateLimiter = rateLimit({
  windowMs: RATE_LIMIT_WINDOW_MS,  // Time window for counting requests.
  max: RATE_LIMIT_MAX,             
  standardHeaders: true,           
  legacyHeaders: false,
  message: {
    success: false,
    message: "Too many requests from this IP. Please wait a few minutes and try again.",
  },
  skip: (req) => req.path === "/health",
});

export const authLimiter = rateLimit({
  windowMs: RATE_LIMIT_WINDOW_MS,
  max: AUTH_RATE_LIMIT_MAX,        
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true,     
  message: {
    success: false,
    message: "Too many login attempts. Please wait 15 minutes before trying again.",
  },
});

export const createLimiter = (options = {}) => {
  return rateLimit({
    windowMs: options.windowMs || RATE_LIMIT_WINDOW_MS,
    max: options.max || RATE_LIMIT_MAX,
    standardHeaders: true,
    legacyHeaders: false,
    message: {
      success: false,
      message: options.message || "Too many requests. Please try again later.",
    },
    ...options,
  });
};