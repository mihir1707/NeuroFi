import cron from "node-cron";
import Transaction from "../src/models/Transaction.js";
import { createNotification } from "../src/services/notification.service.js";


const runBillReminderJob = async () => {
  const now = new Date();
  const in2Days = new Date(now);
  in2Days.setDate(in2Days.getDate() + 2);

  const upcomingBills = await Transaction.find({
    isRecurring: true,
    nextRecurrenceDate: { $gte: now, $lte: in2Days },
  })
    .populate("user", "name email")
    .populate("account", "name")
    .populate("category", "name")
    .lean();

  let remindersSent = 0;

  for (const bill of upcomingBills) {
    const dueDate = new Date(bill.nextRecurrenceDate);
    const daysUntilDue = Math.ceil((dueDate - now) / (1000 * 60 * 60 * 24));

    const dueDateStr = dueDate.toLocaleDateString("en-IN", {
      day: "numeric",
      month: "short",
      year: "numeric",
    });

    const message = daysUntilDue <= 0
      ? `Your recurring payment "${bill.description}" of ₹${bill.amount} is due today!`
      : `Your recurring payment "${bill.description}" of ₹${bill.amount} is due in ${daysUntilDue} day(s) (${dueDateStr}).`;

    await createNotification({
      userId: bill.user._id,
      type: "bill_reminder",
      title: `Bill Due ${daysUntilDue <= 0 ? "Today" : `in ${daysUntilDue} Day(s)`}`,
      message,
      relatedEntity: bill._id,
      relatedEntityType: "transaction",
      metadata: {
        amount: bill.amount,
        description: bill.description,
        dueDate: bill.nextRecurrenceDate,
      },
    });

    remindersSent++;
  }

  return { billsChecked: upcomingBills.length, remindersSent };
};

export const initBillReminderJob = () => {
  return cron.schedule("0 8 * * *", async () => {
    try {
      console.info("[Cron] Running bill reminder job...");
      const result = await runBillReminderJob();
      console.info(`[Cron] Bill reminders: checked ${result.billsChecked} bills, sent ${result.remindersSent} reminders`);
    } catch (error) {
      console.error("[Cron] Bill reminder job failed:", error.message);
    }
  });
};
