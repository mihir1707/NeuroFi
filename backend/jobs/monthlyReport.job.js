import cron from "node-cron";
import User from "../src/models/User.js";
import { generateMonthlyReport } from "../src/services/report.service.js";
import { sendMonthlyReportEmail } from "../src/services/email.service.js";

const runMonthlyReportJob = async () => {
  const now = new Date();

  const reportYear = now.getMonth() === 0 ? now.getFullYear() - 1 : now.getFullYear();
  const reportMonth = now.getMonth() === 0 ? 12 : now.getMonth();

  const monthName = new Date(reportYear, reportMonth - 1).toLocaleString("default", { month: "long" });

  console.info(`[Cron] Generating monthly reports for ${monthName} ${reportYear}`);

  const users = await User.find({ isActive: true }).lean();
  let reportsGenerated = 0;
  let emailsSent = 0;

  for (const user of users) {
    try {
      const report = await generateMonthlyReport(user._id, reportYear, reportMonth);

      if (report.summary.transactionCount > 0) {
        const emailSent = await sendMonthlyReportEmail(
          user.email,
          user.name,
          {
            month: monthName,
            year: reportYear,
            income: report.summary.totalIncome,
            expenses: report.summary.totalExpenses,
            net: report.summary.netSavings,
            topCategories: report.categorySummary.slice(0, 5),
          }
        );

        if (emailSent) emailsSent++;
      }

      reportsGenerated++;
    } catch (error) {
      console.error(`[Cron] Failed to generate report for user ${user._id}:`, error.message);
    }
  }

  return { usersProcessed: users.length, reportsGenerated, emailsSent };
};

export const initMonthlyReportJob = () => {
  return cron.schedule("0 7 1 * *", async () => {
    try {
      console.info("[Cron] Running monthly report job...");
      const result = await runMonthlyReportJob();
      console.info(`[Cron] Monthly reports: ${result.reportsGenerated} generated, ${result.emailsSent} emails sent`);
    } catch (error) {
      console.error("[Cron] Monthly report job failed:", error.message);
    }
  });
};