import Notification from "../models/Notification.js";

export const createNotification = async (options = {}) => {
  const {
    userId,
    type,
    title,
    message,
    relatedEntity = null,
    relatedEntityType = null,
    metadata = {},
  } = options;

  if (!userId || !type || !title || !message) {
    throw new Error("Missing required notification fields: userId, type, title, message");
  }

  const notification = await Notification.create({
    user: userId,
    type,
    title,
    message,
    relatedEntity,
    relatedEntityType,
    metadata,
  });

  return notification;
};

export const sendBudgetAlert = async (budget) => {
  const spent = budget.spent || 0;
  const limit = budget.amount || 0;
  const percentage = limit > 0 ? ((spent / limit) * 100).toFixed(0) : 0;
  const categoryName = budget.category?.name || "your category";

  const isExceeded = spent >= limit;

  await createNotification({
    userId: budget.user._id || budget.user,
    type: "budget_alert",
    title: isExceeded
      ? `⚠️ Budget Exceeded: ${categoryName}`
      : `🔔 Budget Alert: ${categoryName}`,
    message: isExceeded
      ? `You've exceeded your ${budget.period} budget for ${categoryName}! Spent: ₹${spent.toFixed(0)} / ₹${limit.toFixed(0)}`
      : `You've used ${percentage}% of your ${budget.period} budget for ${categoryName}. (₹${spent.toFixed(0)} of ₹${limit.toFixed(0)})`,
    relatedEntity: budget._id,
    relatedEntityType: "budget",
    metadata: { spent, limit, percentage: Number(percentage), category: categoryName },
  });
};

export const sendGoalUpdate = async (goal) => {
  const progress = goal.targetAmount > 0
    ? ((goal.currentAmount / goal.targetAmount) * 100).toFixed(0)
    : 0;

  const remaining = (goal.targetAmount - goal.currentAmount).toFixed(2);

  await createNotification({
    userId: goal.user,
    type: "goal_update",
    title: `🎯 Goal Progress: ${goal.name}`,
    message: `You've reached ${progress}% of your "${goal.name}" goal! ₹${remaining} remaining.`,
    relatedEntity: goal._id,
    relatedEntityType: "goal",
    metadata: { progress: Number(progress), remaining: Number(remaining) },
  });
};

export const sendGroupExpenseNotification = async (expense, userId, payerName = "Someone") => {
  const participant = expense.participants?.find(
    (p) => String(p.user) === String(userId)
  );

  const shareAmount = participant?.shareAmount || 0;

  await createNotification({
    userId,
    type: "group_expense",
    title: `💸 New Group Expense`,
    message: `${payerName} added "${expense.description}" of ₹${expense.amount.toFixed(2)}. Your share: ₹${shareAmount.toFixed(2)}.`,
    relatedEntity: expense._id,
    relatedEntityType: "group",
    metadata: {
      expenseAmount: expense.amount,
      shareAmount,
      description: expense.description,
    },
  });
};

export const sendAIInsightNotification = async (userId, insight) => {
  await createNotification({
    userId,
    type: "ai_insight",
    title: insight.title,
    message: insight.message,
    metadata: { source: "ai" },
  });
};