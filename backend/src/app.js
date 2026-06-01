
import express from "express";
import cors from "cors";
import "dotenv/config";

import { API_PREFIX, CORS_ORIGINS, NODE_ENV } from "./config/constants.js";
import { logger } from "./middleware/logger.middleware.js";
import { rateLimiter } from "./middleware/rateLimiter.middleware.js";
import { notFoundHandler, errorHandler } from "./middleware/errorHandler.middleware.js";

import authRoutes from "./routes/auth.routes.js";
import userRoutes from "./routes/user.routes.js";
import accountRoutes from "./routes/account.routes.js";
import transactionRoutes from "./routes/transaction.routes.js";
import budgetRoutes from "./routes/budget.routes.js";
import categoryRoutes from "./routes/category.routes.js";
import savingsRoutes from "./routes/savings.routes.js";
import groupRoutes from "./routes/group.routes.js";
import notificationRoutes from "./routes/notification.routes.js";
import reportRoutes from "./routes/report.routes.js";
import receiptRoutes from "./routes/receipt.routes.js";
import aiRoutes from "./routes/ai.routes.js";

const app = express();

app.use(cors({
  origin: (origin, callback) => {
    if (!origin) return callback(null, true);

    if (CORS_ORIGINS.includes(origin) || CORS_ORIGINS.includes("*")) {
      callback(null, true);
    } else {
      console.warn(`[CORS] Blocked origin: ${origin}`);
      callback(null, false); // Reject but don't throw an error
    }
  },
  methods: ["GET", "POST", "PATCH", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,
}));

app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

app.use(rateLimiter);

app.use(logger);

app.get("/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Smart Finance Tracker API is running",
    environment: NODE_ENV,
    timestamp: new Date().toISOString(),
    uptime: `${Math.floor(process.uptime())}s`,
  });
});

app.use(`${API_PREFIX}/auth`, authRoutes);
app.use(`${API_PREFIX}/users`, userRoutes);
app.use(`${API_PREFIX}/accounts`, accountRoutes);
app.use(`${API_PREFIX}/transactions`, transactionRoutes);
app.use(`${API_PREFIX}/budgets`, budgetRoutes);
app.use(`${API_PREFIX}/categories`, categoryRoutes);
app.use(`${API_PREFIX}/savings`, savingsRoutes);
app.use(`${API_PREFIX}/groups`, groupRoutes);
app.use(`${API_PREFIX}/notifications`, notificationRoutes);
app.use(`${API_PREFIX}/reports`, reportRoutes);
app.use(`${API_PREFIX}/receipts`, receiptRoutes);
app.use(`${API_PREFIX}/ai`, aiRoutes);

app.use(notFoundHandler);

app.use(errorHandler);

export default app;
