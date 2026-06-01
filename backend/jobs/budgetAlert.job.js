import cron from "node-cron";
import Budget from "../src/models/Budget.js";
import Transaction from "../src/models/Transaction.js";
import { sendBudgetAlert } from "../src/services/notification.service.js";
import { getMonthRange } from "../src/utils/dateRange.util.js";

const runBudgetAlertJob = async () => {
  const now = new Date();
  const { start, end } = getMonthRange(now.getFullYear(), now.getMonth() + 1);

  const budgets = await Budget.find({ isActive: true })
    .populate("category", "name")
    .populate("user", "email name")
    .lean();

  let alertsSent = 0;
  let budgetsChecked = 0;

  for (const budget of budgets) {
    budgetsChecked++;

    const spendingResult = await Transaction.aggregate([
      {
        $match: {
          user: budget.user._id,
          category: budget.category._id,
          type: "expense",
          transactionDate: { $gte: start, $lte: end },
        },
      },
      { $group: { _id: null, total: { $sum: "$amount" } } },
    ]);

    const actualSpent = spendingResult[0]?.total || 0;
    const percentUsed = budget.amount > 0 ? (actualSpent / budget.amount) * 100 : 0;

    await Budget.findByIdAndUpdate(budget._id, { spent: actualSpent });

    if (percentUsed >= budget.alertThreshold && !budget.alertSent) {
      await sendBudgetAlert({
        ...budget,
        spent: actualSpent,
      });

      await Budget.findByIdAndUpdate(budget._id, { alertSent: true });
      alertsSent++;
    }
  }

  return { budgetsChecked, alertsSent };
};

export const initBudgetAlertJob = () => {
  return cron.schedule("0 9 * * *", async () => {
    try {
      console.info("[Cron] Running budget alert job...");
      const result = await runBudgetAlertJob();
      console.info(`[Cron] Budget alerts: checked ${result.budgetsChecked} budgets, sent ${result.alertsSent} alerts`);
    } catch (error) {
      console.error("[Cron] Budget alert job failed:", error.message);
    }
  });
};