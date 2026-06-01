import Transaction from "../models/Transaction.js";
import Account from "../models/Account.js";
import Budget from "../models/Budget.js";
import { getMonthRange, getYearRange } from "../utils/dateRange.util.js";


export const generateMonthlyReport = async (userId, year, month) => {
  const { start, end } = getMonthRange(year, month);

  const transactions = await Transaction.find({
    user: userId,
    transactionDate: { $gte: start, $lte: end },
  })
    .populate("category", "name icon color")
    .populate("account", "name type")
    .lean();

  const incomeTransactions = transactions.filter((t) => t.type === "income");
  const expenseTransactions = transactions.filter((t) => t.type === "expense");
  const transferTransactions = transactions.filter((t) => t.type === "transfer");

  const totalIncome = incomeTransactions.reduce((sum, t) => sum + t.amount, 0);
  const totalExpenses = expenseTransactions.reduce((sum, t) => sum + t.amount, 0);
  const netSavings = totalIncome - totalExpenses;

  const expensesByCategory = {};
  expenseTransactions.forEach((t) => {
    const catName = t.category?.name || "Uncategorized";
    const catId = t.category?._id?.toString() || "uncategorized";

    if (!expensesByCategory[catId]) {
      expensesByCategory[catId] = {
        categoryId: catId,
        name: catName,
        icon: t.category?.icon || "📦",
        color: t.category?.color || "#64748B",
        total: 0,
        count: 0,
        transactions: [],
      };
    }

    expensesByCategory[catId].total += t.amount;
    expensesByCategory[catId].count += 1;
  });

  const categorySummary = Object.values(expensesByCategory).sort((a, b) => b.total - a.total);

  const dailySpending = {};
  expenseTransactions.forEach((t) => {
    const day = new Date(t.transactionDate).getDate();
    dailySpending[day] = (dailySpending[day] || 0) + t.amount;
  });

  const budgets = await Budget.find({ user: userId, isActive: true })
    .populate("category", "name")
    .lean();

  const budgetPerformance = budgets.map((b) => {
    const categorySpend = expensesByCategory[b.category?._id?.toString()]?.total || 0;
    const percentUsed = b.amount > 0 ? (categorySpend / b.amount) * 100 : 0;

    return {
      category: b.category?.name || "Unknown",
      budgetAmount: b.amount,
      actualSpend: categorySpend,
      percentUsed: parseFloat(percentUsed.toFixed(1)),
      status: percentUsed > 100 ? "exceeded" : percentUsed > 80 ? "warning" : "good",
    };
  });

  return {
    period: { year, month, start, end },
    summary: {
      totalIncome,
      totalExpenses,
      netSavings,
      savingsRate: totalIncome > 0 ? parseFloat(((netSavings / totalIncome) * 100).toFixed(1)) : 0,
      transactionCount: transactions.length,
    },
    categorySummary,
    dailySpending,
    budgetPerformance,
    transactions,
  };
};

export const generateYearlyReport = async (userId, year) => {
  const { start, end } = getYearRange(year);

  const transactions = await Transaction.find({
    user: userId,
    transactionDate: { $gte: start, $lte: end },
  }).lean();

  const monthlyData = {};
  for (let m = 1; m <= 12; m++) {
    monthlyData[m] = { income: 0, expenses: 0, net: 0 };
  }

  transactions.forEach((t) => {
    const month = new Date(t.transactionDate).getMonth() + 1;
    if (t.type === "income") monthlyData[month].income += t.amount;
    else if (t.type === "expense") monthlyData[month].expenses += t.amount;
  });

  Object.keys(monthlyData).forEach((m) => {
    monthlyData[m].net = monthlyData[m].income - monthlyData[m].expenses;
  });

  const totalIncome = transactions.filter((t) => t.type === "income").reduce((s, t) => s + t.amount, 0);
  const totalExpenses = transactions.filter((t) => t.type === "expense").reduce((s, t) => s + t.amount, 0);

  return {
    period: { year, start, end },
    summary: {
      totalIncome,
      totalExpenses,
      netSavings: totalIncome - totalExpenses,
      savingsRate: totalIncome > 0 ? parseFloat((((totalIncome - totalExpenses) / totalIncome) * 100).toFixed(1)) : 0,
    },
    monthlyBreakdown: monthlyData,
    transactionCount: transactions.length,
  };
};


export const exportToCSV = async (userId, filters = {}) => {
  const query = { user: userId };

  if (filters.startDate) query.transactionDate = { $gte: new Date(filters.startDate) };
  if (filters.endDate) query.transactionDate = { ...query.transactionDate, $lte: new Date(filters.endDate) };
  if (filters.type) query.type = filters.type;

  const transactions = await Transaction.find(query)
    .populate("category", "name")
    .populate("account", "name")
    .sort({ transactionDate: -1 })
    .lean();

  const headers = ["Date", "Type", "Amount", "Currency", "Category", "Account", "Description", "Notes", "Tags"];

  const rows = transactions.map((t) => [
    new Date(t.transactionDate).toISOString().split("T")[0],
    t.type,
    t.amount,
    t.currency,
    t.category?.name || "",
    t.account?.name || "",
    `"${(t.description || "").replace(/"/g, '""')}"`,
    `"${(t.notes || "").replace(/"/g, '""')}"`,
    (t.tags || []).join(";"),
  ]);

  const csvContent = [
    headers.join(","),
    ...rows.map((row) => row.join(",")),
  ].join("\n");

  return csvContent;
};