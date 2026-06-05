import { getOpenAIClient, isAIEnabled, AI_MODEL } from "../../config/openai.js";
import mongoose from "mongoose";
import Transaction from "../../models/Transaction.js";
import Budget from "../../models/Budget.js";
import SavingsGoal from "../../models/SavingsGoal.js";
import { getMonthRange } from "../../utils/dateRange.util.js";


// ─── HELPERS ──────────────────────────────────────────────────────────────────

const safeRate = (numerator, denominator) =>
  denominator > 0 ? +((numerator / denominator) * 100).toFixed(1) : 0;

const monthLabel = (year, month) =>
  new Date(year, month - 1, 1).toLocaleString("default", { month: "long", year: "numeric" });


// Fetch all 7 months of transaction data in one $facet aggregation instead of
// running separate queries for each month. Much faster on Atlas connections.
const fetchAllTransactionData = async (userId, currentMonthRange, currentMonth, currentYear) => {
  // Build date ranges for the 6 months of historical data we need.
  // month[0] = oldest (6 months ago), month[5] = most recent past month.
  const historicalRanges = [];
  for (let i = 6; i >= 1; i--) {
    let m = currentMonth - i;
    let y = currentYear;
    if (m <= 0) { m += 12; y -= 1; }
    historicalRanges.push({ year: y, month: m, ...getMonthRange(y, m) });
  }

  const sixMonthsAgo = historicalRanges[0].start;
  const userObjId = new mongoose.Types.ObjectId(userId);

  // Single aggregation: one collection scan, 8 parallel sub-pipelines via $facet
  const [result] = await Transaction.aggregate([
    {
      // Narrow to this user's transactions for the last 7 months total
      $match: {
        user: userObjId,
        transactionDate: { $gte: sixMonthsAgo, $lte: currentMonthRange.end },
      },
    },
    {
      $facet: {
        // ── Sub-pipeline 1: Current month income + expenses ─────────────────
        currentMonth: [
          {
            $match: {
              transactionDate: {
                $gte: currentMonthRange.start,
                $lte: currentMonthRange.end,
              },
            },
          },
          {
            $group: {
              _id: "$type",
              total: { $sum: "$amount" },
            },
          },
        ],

        // ── Sub-pipeline 2: Current month category breakdown (expenses only) ─
        currentCategories: [
          {
            $match: {
              transactionDate: {
                $gte: currentMonthRange.start,
                $lte: currentMonthRange.end,
              },
              type: "expense",
              category: { $ne: null },
            },
          },
          {
            $lookup: {
              from: "categories",
              localField: "category",
              foreignField: "_id",
              as: "categoryInfo",
            },
          },
          { $unwind: { path: "$categoryInfo", preserveNullAndEmpty: true } },
          {
            $group: {
              _id: { $ifNull: ["$categoryInfo.name", "Other"] },
              amount: { $sum: "$amount" },
            },
          },
          { $sort: { amount: -1 } },
          { $limit: 5 },
        ],

        // ── Sub-pipelines 3–8: One per historical month ──────────────────────
        // Each returns [{ income, expenses }] or [] if no transactions.
        ...Object.fromEntries(
          historicalRanges.map(({ year, month, start, end }, idx) => [
            `hist_${idx}`,
            [
              { $match: { transactionDate: { $gte: start, $lte: end } } },
              {
                $group: {
                  _id: "$type",
                  total: { $sum: "$amount" },
                },
              },
            ],
          ])
        ),
      },
    },
  ]);

  return { result, historicalRanges };
};


const extractIncomeExpenses = (groups = []) => ({
  income: groups.find((g) => g._id === "income")?.total ?? 0,
  expenses: groups.find((g) => g._id === "expense")?.total ?? 0,
});


const buildCurrentMonthSummary = (facetResult, historicalRanges, budgets, goals) => {
  const now = new Date();
  const year = now.getFullYear();
  const month = now.getMonth() + 1;
  const dayOfMonth = now.getDate();
  const daysInMonth = new Date(year, month, 0).getDate();
  const monthProgressPct = +((dayOfMonth / daysInMonth) * 100).toFixed(1);

  const { income, expenses } = extractIncomeExpenses(facetResult.currentMonth);

  // Category totals from the aggregation
  const topCategories = (facetResult.currentCategories || []).map(
    ({ _id: name, amount }) => ({
      name,
      amount,
      pctOfExpenses: safeRate(amount, expenses),
    })
  );

  // Budget burn-rate analysis (budgets fetched separately — they use $spent field, not txns)
  const budgetSummary = budgets.map((b) => {
    const percentUsed = safeRate(b.spent, b.amount);
    const burnStatus =
      percentUsed > monthProgressPct + 20
        ? "overspending"
        : percentUsed > monthProgressPct + 5
        ? "slightly over"
        : percentUsed < monthProgressPct - 20
        ? "well under"
        : "on track";

    const dailyRate = dayOfMonth > 0 ? b.spent / dayOfMonth : 0;
    const projectedMonthEnd = Math.round(dailyRate * daysInMonth);

    return {
      category: b.category?.name || "Unknown",
      budgetAmount: b.amount,
      spent: b.spent,
      remaining: b.amount - b.spent,
      percentUsed,
      burnStatus,
      projectedMonthEnd,
      willExceed: projectedMonthEnd > b.amount,
      excessProjected: Math.max(0, projectedMonthEnd - b.amount),
    };
  });

  // Goals progress
  const goalSummary = goals.map((g) => {
    const progress = safeRate(g.currentAmount, g.targetAmount);
    const remaining = g.targetAmount - g.currentAmount;
    const daysToTarget = g.targetDate
      ? Math.ceil((new Date(g.targetDate) - now) / (1000 * 60 * 60 * 24))
      : null;
    const dailyRequired =
      daysToTarget && daysToTarget > 0 ? +(remaining / daysToTarget).toFixed(0) : null;

    return {
      name: g.name,
      progress,
      currentAmount: g.currentAmount,
      targetAmount: g.targetAmount,
      remaining,
      targetDate: g.targetDate,
      daysToTarget,
      dailySavingsRequired: dailyRequired,
      onTrack: dailyRequired !== null ? dailyRequired < (income / daysInMonth) * 0.3 : null,
    };
  });

  return {
    month: now.toLocaleString("default", { month: "long" }),
    year,
    monthNumber: month,
    dayOfMonth,
    daysInMonth,
    monthProgressPct,
    income,
    expenses,
    net: income - expenses,
    savingsRate: safeRate(income - expenses, income),
    topCategories,
    budgets: budgetSummary,
    goals: goalSummary,
  };
};


const buildHistoricalContext = (facetResult, historicalRanges) => {
  const months = historicalRanges.map(({ year, month }, idx) => {
    const { income, expenses } = extractIncomeExpenses(facetResult[`hist_${idx}`] || []);
    return {
      label: monthLabel(year, month),
      income,
      expenses,
      net: income - expenses,
      savingsRate: safeRate(income - expenses, income),
    };
  });

  const avgExpenses = months.reduce((s, r) => s + r.expenses, 0) / months.length;
  const avgIncome = months.reduce((s, r) => s + r.income, 0) / months.length;
  const avgSavingsRate = months.reduce((s, r) => s + r.savingsRate, 0) / months.length;

  return {
    months: months.slice(-3),
    avgExpenses,
    avgIncome,
    avgSavingsRate: +avgSavingsRate.toFixed(1),
  };
};


const buildStreaks = (facetResult, historicalRanges) => {
  const streaks = { savingsStreak: 0, overspendStreak: 0 };

  for (let i = historicalRanges.length - 1; i >= 0; i--) {
    const { income, expenses } = extractIncomeExpenses(facetResult[`hist_${i}`] || []);
    const saved = income > expenses;

    if (saved) {
      streaks.savingsStreak++;
    } else {
      streaks.savingsStreak = 0;
    }

    if (!saved && income > 0) {
      streaks.overspendStreak++;
    } else {
      streaks.overspendStreak = 0;
    }

    if (streaks.savingsStreak === 0 && streaks.overspendStreak === 0 && i < historicalRanges.length - 1) {
      break;
    }
  }

  return streaks;
};


const computeHealthScore = (summary, history, streaks) => {
  let score = 100;
  const deductions = [];
  const bonuses = [];

  if (summary.savingsRate >= 30)      { bonuses.push({ reason: "Excellent savings rate (≥30%)", pts: 5 }); }
  else if (summary.savingsRate >= 20) { }
  else if (summary.savingsRate >= 10) { score -= 15; deductions.push("Savings rate below 20%"); }
  else if (summary.savingsRate >= 0)  { score -= 30; deductions.push("Very low savings rate (<10%)"); }
  else                                { score -= 40; deductions.push("Spending more than earning"); }

  const exceededBudgets = summary.budgets.filter((b) => b.percentUsed >= 100);
  const nearLimitBudgets = summary.budgets.filter((b) => b.percentUsed >= 85 && b.percentUsed < 100);
  score -= exceededBudgets.length * 10;
  score -= nearLimitBudgets.length * 5;
  if (exceededBudgets.length > 0) deductions.push(`${exceededBudgets.length} budget(s) exceeded`);

  const projectedOverruns = summary.budgets.filter((b) => b.willExceed && b.percentUsed < 100);
  score -= projectedOverruns.length * 5;
  if (projectedOverruns.length > 0) deductions.push(`${projectedOverruns.length} budget(s) projected to exceed`);

  if (streaks.savingsStreak >= 3)  { bonuses.push({ reason: `${streaks.savingsStreak}-month savings streak`, pts: 5 }); }
  if (streaks.overspendStreak >= 2) { score -= 10; deductions.push(`${streaks.overspendStreak}-month overspending streak`); }

  const nearGoals = summary.goals.filter((g) => g.progress >= 75);
  if (nearGoals.length > 0) bonuses.push({ reason: `${nearGoals.length} goal(s) nearly complete`, pts: 3 * nearGoals.length });

  const bonusTotal = bonuses.reduce((s, b) => s + b.pts, 0);
  const finalScore = Math.min(100, Math.max(0, score + bonusTotal));

  const label =
    finalScore >= 85 ? "Excellent" :
    finalScore >= 70 ? "Good" :
    finalScore >= 50 ? "Fair" :
    "Needs Attention";

  return { score: finalScore, label, deductions, bonuses };
};


const buildScoreExplanation = (healthScore) => {
  const parts = [];
  if (healthScore.deductions.length > 0) parts.push(`Concerns: ${healthScore.deductions.join(", ")}`);
  if (healthScore.bonuses.length > 0) parts.push(`Bonuses: ${healthScore.bonuses.map((b) => b.reason).join(", ")}`);
  return parts.length > 0 ? parts.join(". ") : "Your finances are in good shape.";
};

const generateRuleBasedInsights = (summary, history, streaks, healthScore) => {
  const insights = [];
  const { monthProgressPct, dayOfMonth, daysInMonth } = summary;

  if (summary.savingsRate < 0) {
    insights.push({ type: "alert", title: "Spending Exceeds Income", message: `You've spent ₹${Math.abs(summary.net).toFixed(0)} more than you earned this month. Review your expenses immediately to avoid debt.`, icon: "🚨", priority: 1 });
  } else if (summary.savingsRate < 10) {
    insights.push({ type: "warning", title: "Low Savings Rate", message: `You're saving only ${summary.savingsRate}% of your income this month. Aim for at least 20%. Your top expense is ${summary.topCategories[0]?.name} at ₹${summary.topCategories[0]?.amount?.toFixed(0)}.`, icon: "⚠️", priority: 2 });
  } else if (summary.savingsRate >= 20) {
    insights.push({ type: "achievement", title: "Strong Savings Rate 🎉", message: `You're saving ${summary.savingsRate}% of your income — above the recommended 20%. ${streaks.savingsStreak > 1 ? `That's ${streaks.savingsStreak} months in a row!` : "Keep it up!"}`, icon: "💰", priority: 5 });
  }

  if (streaks.savingsStreak >= 3) {
    insights.push({ type: "achievement", title: `${streaks.savingsStreak}-Month Savings Streak!`, message: `You've saved money every month for the past ${streaks.savingsStreak} months. Consistency is the key to long-term wealth.`, icon: "🔥", priority: 5 });
  }

  if (streaks.overspendStreak >= 2) {
    insights.push({ type: "warning", title: "Recurring Overspending Pattern", message: `You've spent more than you earned for ${streaks.overspendStreak} consecutive months. Consider reviewing your fixed costs or finding ways to increase income.`, icon: "📉", priority: 1 });
  }

  if (history.avgExpenses > 0 && summary.expenses > 0) {
    const expenseChangePct = safeRate(summary.expenses - history.avgExpenses, history.avgExpenses);
    if (expenseChangePct > 25) {
      insights.push({ type: "warning", title: "Expenses Up Significantly", message: `Your spending this month is ${expenseChangePct}% higher than your 3-month average (₹${history.avgExpenses.toFixed(0)}). Check what's driving the increase.`, icon: "📈", priority: 2 });
    } else if (expenseChangePct < -20) {
      insights.push({ type: "achievement", title: "Great Spending Control", message: `You've spent ${Math.abs(expenseChangePct)}% less than your 3-month average. Well done on keeping costs down!`, icon: "✨", priority: 5 });
    }
  }

  summary.budgets.forEach((b) => {
    if (b.willExceed && b.percentUsed < 100) {
      insights.push({ type: "alert", title: `${b.category} Budget at Risk`, message: `At your current pace, you'll spend ₹${b.projectedMonthEnd.toFixed(0)} on ${b.category} by month-end — ₹${b.excessProjected.toFixed(0)} over your ₹${b.budgetAmount} budget. You're only ${Math.round(monthProgressPct)}% into the month.`, icon: "🔔", priority: 2 });
    } else if (b.percentUsed >= 100) {
      insights.push({ type: "alert", title: `${b.category} Budget Exceeded`, message: `You've used ${b.percentUsed}% of your ${b.category} budget (₹${b.spent.toFixed(0)} of ₹${b.budgetAmount}). Consider pausing discretionary spending here.`, icon: "🚨", priority: 1 });
    } else if (b.percentUsed >= 85) {
      insights.push({ type: "warning", title: `${b.category} Budget Almost Full`, message: `${b.percentUsed}% of your ${b.category} budget used with ${Math.round(100 - monthProgressPct)}% of the month remaining. Only ₹${b.remaining.toFixed(0)} left.`, icon: "⚠️", priority: 2 });
    } else if (b.burnStatus === "well under" && monthProgressPct > 50) {
      insights.push({ type: "tip", title: `${b.category} Well Within Budget`, message: `You've only used ${b.percentUsed}% of your ${b.category} budget halfway through the month. Great discipline!`, icon: "👍", priority: 5 });
    }
  });

  summary.goals.forEach((g) => {
    if (g.progress >= 90) {
      insights.push({ type: "achievement", title: `Almost Done: ${g.name}`, message: `You're ${g.progress}% of the way to your "${g.name}" goal! Just ₹${g.remaining.toFixed(0)} more to go.`, icon: "🎯", priority: 4 });
    } else if (g.daysToTarget !== null && g.daysToTarget <= 30 && g.progress < 80) {
      insights.push({ type: "alert", title: `Goal Deadline Approaching: ${g.name}`, message: `"${g.name}" is due in ${g.daysToTarget} days but only ${g.progress}% complete. You need to save ₹${g.dailySavingsRequired}/day to hit it.`, icon: "⏰", priority: 2 });
    } else if (g.onTrack === false) {
      insights.push({ type: "tip", title: `Goal Off Track: ${g.name}`, message: `To reach "${g.name}" by ${new Date(g.targetDate).toLocaleDateString("en-IN")}, you need ₹${g.dailySavingsRequired}/day. Review your budget to allocate more.`, icon: "💡", priority: 3 });
    }
  });

  if (summary.topCategories.length > 0) {
    const top = summary.topCategories[0];
    if (top.pctOfExpenses > 40) {
      insights.push({ type: "tip", title: `${top.name} Dominates Your Spending`, message: `${top.name} accounts for ${top.pctOfExpenses}% of all your expenses (₹${top.amount.toFixed(0)}). High concentration in one category is worth reviewing.`, icon: "🔍", priority: 3 });
    }
  }

  if (insights.length === 0) {
    insights.push({ type: "tip", title: "Finances Looking Healthy", message: "No major issues detected. Keep logging transactions consistently for more detailed insights.", icon: "✅", priority: 5 });
  }

  return {
    insights: insights.sort((a, b) => a.priority - b.priority).slice(0, 6),
    overallScore: healthScore.score,
    scoreLabel: healthScore.label,
    scoreExplanation: buildScoreExplanation(healthScore),
    summary,
    generatedAt: new Date().toISOString(),
    source: "rules",
  };
};


const getAIInsights = async (summary, history, streaks, healthScore) => {
  const client = getOpenAIClient();

  const prompt = `You are a friendly, smart personal finance advisor for an Indian user. Today is day ${summary.dayOfMonth} of ${summary.daysInMonth} in ${summary.month} ${summary.year} (${summary.monthProgressPct}% through the month).

Income: ₹${summary.income.toFixed(0)} | Expenses: ₹${summary.expenses.toFixed(0)} | Net: ₹${summary.net.toFixed(0)} | Savings Rate: ${summary.savingsRate}%

Top Spending:
${summary.topCategories.map((c) => `  • ${c.name}: ₹${c.amount.toFixed(0)} (${c.pctOfExpenses}% of expenses)`).join("\n")}

Budget Status:
${summary.budgets.map((b) => `  • ${b.category}: ${b.percentUsed}% used (₹${b.spent.toFixed(0)}/₹${b.budgetAmount}) — ${b.burnStatus}${b.willExceed ? ` ⚠️ projected to exceed by ₹${b.excessProjected.toFixed(0)}` : ""}`).join("\n")}

Savings Goals:
${summary.goals.map((g) => `  • ${g.name}: ${g.progress}% complete, ₹${g.remaining.toFixed(0)} remaining${g.daysToTarget ? `, due in ${g.daysToTarget} days` : ""}`).join("\n") || "  None"}

Avg Expenses: ₹${history.avgExpenses.toFixed(0)} | Avg Income: ₹${history.avgIncome.toFixed(0)} | Avg Savings Rate: ${history.avgSavingsRate}%
${history.months.map((m) => `  • ${m.label}: expenses ₹${m.expenses.toFixed(0)}, savings ${m.savingsRate}%`).join("\n")}

Savings streak: ${streaks.savingsStreak} months | Overspend streak: ${streaks.overspendStreak} months

HEALTH SCORE: ${healthScore.score}/100 (${healthScore.label}) 
Deductions: ${healthScore.deductions.join(", ") || "none"}
Bonuses: ${healthScore.bonuses.map((b) => b.reason).join(", ") || "none"}

Give 4-6 specific, actionable insights. Avoid generic advice. Reference actual numbers.

Respond ONLY with valid JSON:
{
  "insights": [
    {
      "type": "warning|tip|achievement|alert",
      "title": "Short title",
      "message": "Specific advice",
      "icon": "emoji",
      "priority": 1
    }
  ],
  "overallScore": ${healthScore.score},
  "scoreLabel": "${healthScore.label}",
  "scoreExplanation": "One sentence summary"
}`;

  const response = await client.chat.completions.create({
    model: AI_MODEL,
    messages: [{ role: "user", content: prompt }],
    max_tokens: 1000,
    temperature: 0.35,
  });

  const raw = response.choices[0]?.message?.content?.trim() ?? "";
  const parsed = JSON.parse(raw);

  return {
    ...parsed,
    summary,
    generatedAt: new Date().toISOString(),
    source: "ai",
  };
};


export const generateInsights = async (userId) => {
  const now = new Date();
  const currentYear = now.getFullYear();
  const currentMonth = now.getMonth() + 1;
  const currentMonthRange = getMonthRange(currentYear, currentMonth);

  const [{ result: facetResult, historicalRanges }, [budgets, goals]] = await Promise.all([
    fetchAllTransactionData(userId, currentMonthRange, currentMonth, currentYear),
    Promise.all([
      Budget.find({ user: userId, isActive: true }).populate("category", "name").lean(),
      SavingsGoal.find({ user: userId, status: "active" }).lean(),
    ]),
  ]);

  // Derive all summaries from the in-memory facet result — zero extra DB calls
  const summary = buildCurrentMonthSummary(facetResult, historicalRanges, budgets, goals);
  const history = buildHistoricalContext(facetResult, historicalRanges);
  const streaks = buildStreaks(facetResult, historicalRanges);
  const healthScore = computeHealthScore(summary, history, streaks);

  if (isAIEnabled()) {
    try {
      return await getAIInsights(summary, history, streaks, healthScore);
    } catch (error) {
      console.warn("[AI Insights] Falling back to rule-based:", error.message);
    }
  }

  return generateRuleBasedInsights(summary, history, streaks, healthScore);
};