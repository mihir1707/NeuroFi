import "dotenv/config";
import http from "http";
import app from "./src/app.js";
import { connectDB } from "./src/config/db.js";
import { validateConfig, PORT, HOST, NODE_ENV } from "./src/config/constants.js";

try {
  validateConfig();
} catch (error) {
  console.error(error.message);
  process.exit(1);
}

const server = http.createServer(app);

const startServer = async () => {
  try {
    console.info("\nStarting Smart Finance Tracker Backend...");
    console.info(`Environment: ${NODE_ENV}`);

    await connectDB();

    server.listen(PORT, HOST, () => {
      console.info(`\nServer is running!`);
      console.info(`API: http://${HOST === "0.0.0.0" ? "localhost" : HOST}:${PORT}`);
      console.info(`Health: http://localhost:${PORT}/health`);
      console.info(`API Base: http://localhost:${PORT}/api/v1`);
      console.info(`\nAvailable Routes:`);
      console.info(`   POST   /api/v1/auth/register`);
      console.info(`   POST   /api/v1/auth/login`);
      console.info(`   GET    /api/v1/transactions`);
      console.info(`   GET    /api/v1/budgets`);
      console.info(`   GET    /api/v1/accounts`);
      console.info(`   GET    /api/v1/savings`);
      console.info(`   GET    /api/v1/groups`);
      console.info(`   GET    /api/v1/reports/monthly`);
      console.info(`   POST   /api/v1/ai/insights`);
      console.info(`   POST   /api/v1/ai/chat\n`);
    });

    await startCronJobs();

  } catch (error) {
    console.error("Failed to start server:", error.message);
    process.exit(1);
  }
};

const startCronJobs = async () => {
  try {
    const { initBudgetAlertJob } = await import("./jobs/budgetAlert.job.js");
    const { initBillReminderJob } = await import("./jobs/billReminder.job.js");
    const { initMonthlyReportJob } = await import("./jobs/monthlyReport.job.js");

    initBudgetAlertJob();   
    initBillReminderJob();  
    initMonthlyReportJob(); 

    console.info("Cron jobs started: budget alerts, bill reminders, monthly reports");
  } catch (error) {
    console.warn("Some cron jobs failed to start:", error.message);
  }
};


const gracefulShutdown = async (signal) => {
  console.info(`\n${signal} received. Shutting down gracefully...`);

  server.close(async () => {
    console.info("HTTP server closed");

    try {
      const { disconnectDB } = await import("./src/config/db.js");
      await disconnectDB();
      console.info("MongoDB disconnected");
    } catch (error) {
      console.error("Error during DB disconnect:", error.message);
    }

    console.info("Goodbye!");
    process.exit(0);
  });

  setTimeout(() => {
    console.error("Forced shutdown after timeout");
    process.exit(1);
  }, 10000);
};

process.on("SIGTERM", () => gracefulShutdown("SIGTERM"));
process.on("SIGINT", () => gracefulShutdown("SIGINT"));

process.on("uncaughtException", (error) => {
  console.error("Failed to start server:", error.message);
  console.error(error.stack);
  process.exit(1);
});

process.on("unhandledRejection", (reason) => {
  console.error("Failed to start server:", reason);
  process.exit(1);
});

startServer();