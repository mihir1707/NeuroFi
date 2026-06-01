import { getOpenAIClient, isAIEnabled, AI_MODEL } from "../../config/openai.js";
import Transaction from "../../models/Transaction.js";
import Budget from "../../models/Budget.js";
import SavingsGoal from "../../models/SavingsGoal.js";
import { getMonthRange } from "../../utils/dateRange.util.js";


// HELPERS
const safeRate = (numerator, denominator) =>
  denominator > 0 ? +((numerator / denominator) * 100).toFixed(1) : 0;

const monthLabel = (year, month) =>
  new Date(year, month - 1, 1).toLocaleString("default", { month: "long", year: "numeric" });


// STEP 1 — CURRENT MONTH SUMMARY
const getCurrentMonthSummary = async (userId) => {
  const now = new Date();
  const year = now.getFullYear();
  const month = now.getMonth() + 1; // 1-based
  const { start, end } = getMonthRange(year, month);

  const dayOfMonth = now.getDate();
  const daysInMonth = new Date(year, month, 0).getDate();
  const monthProgressPct = +((dayOfMonth / daysInMonth) * 100).toFixed(1);

  const transactions = await Transaction.find({
    user: userId,
    transactionDate: { $gte: start, $lte: end },
  })
    .populate("category", "name")
    .lean();

  const income = transactions
    .filter((t) => t.type === "income")
    .reduce((sum, t) => sum + t.amount, 0);

  const expenses = transactions
    .filter((t) => t.type === "expense")
    .reduce((sum, t) => sum + t.amount, 0);

  const byCategory = {};
  transactions
    .filter((t) => t.type === "expense" && t.category)
    .forEach((t) => {
      const name = t.category?.name || "Other";
      byCategory[name] = (byCategory[name] || 0) + t.amount;
    });

  const budgets = await Budget.find({ user: userId, isActive: true })
    .populate("category", "name")
    .lean();

  const budgetSummary = budgets.map((b) => {
    const percentUsed = safeRate(b.spent, b.amount);
    // Burn rate: if you're at X% of month but spent Y% of budget, are you on track?
    const expectedPct = monthProgressPct;
    const burnStatus =
      percentUsed > expectedPct + 20
        ? "overspending"
        : percentUsed > expectedPct + 5
        ? "slightly over"
        : percentUsed < expectedPct - 20
        ? "well under"
        : "on track";

    // Project end-of-month spend based on daily rate
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

  const goals = await SavingsGoal.find({ user: userId, status: "active" }).lean();

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
    topCategories: Object.entries(byCategory)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 5)
      .map(([name, amount]) => ({ name, amount, pctOfExpenses: safeRate(amount, expenses) })),
    budgets: budgetSummary,
    goals: goalSummary,
  };
};


// STEP 2 — HISTORICAL COMPARISON (last 3 months)
const getHistoricalContext = async (userId, currentMonth, currentYear) => {
  const results = [];

  for (let i = 1; i <= 3; i++) {
    let m = currentMonth - i;
    let y = currentYear;
    if (m <= 0) { m += 12; y -= 1; }

    const { start, end } = getMonthRange(y, m);

    const txns = await Transaction.find({
      user: userId,
      transactionDate: { $gte: start, $lte: end },
    }).lean();

    const income = txns.filter((t) => t.type === "income").reduce((s, t) => s + t.amount, 0);
    const expenses = txns.filter((t) => t.type === "expense").reduce((s, t) => s + t.amount, 0);

    results.push({
      label: monthLabel(y, m),
      income,
      expenses,
      net: income - expenses,
      savingsRate: safeRate(income - expenses, income),
    });
  }

  // Averages across the 3 months
  const avgExpenses = results.reduce((s, r) => s + r.expenses, 0) / results.length;
  const avgIncome = results.reduce((s, r) => s + r.income, 0) / results.length;
  const avgSavingsRate = results.reduce((s, r) => s + r.savingsRate, 0) / results.length;

  return { months: results, avgExpenses, avgIncome, avgSavingsRate: +avgSavingsRate.toFixed(1) };
};


// STEP 3 — SPENDING STREAKS
const getStreaks = async (userId, currentMonth, currentYear) => {
  const streaks = { savingsStreak: 0, overspendStreak: 0 };

  for (let i = 1; i <= 6; i++) {
    let m = currentMonth - i;
    let y = currentYear;
    if (m <= 0) { m += 12; y -= 1; }

    const { start, end } = getMonthRange(y, m);
    const txns = await Transaction.find({
      user: userId,
      transactionDate: { $gte: start, $lte: end },
    }).lean();

    const income = txns.filter((t) => t.type === "income").reduce((s, t) => s + t.amount, 0);
    const expenses = txns.filter((t) => t.type === "expense").reduce((s, t) => s + t.amount, 0);
    const saved = income > expenses;

    if (i === 1 || streaks.savingsStreak > 0) {
      if (saved) streaks.savingsStreak++;
      else streaks.savingsStreak = 0;
    }
    if (i === 1 || streaks.overspendStreak > 0) {
      if (!saved && income > 0) streaks.overspendStreak++;
      else streaks.overspendStreak = 0;
    }
  }

  return streaks;
};


// STEP 4 — FINANCIAL HEALTH SCORE (multi-factor)
const computeHealthScore = (summary, history, streaks) => {
  let score = 100;
  const deductions = [];
  const bonuses = [];

  if (summary.savingsRate >= 30) { bonuses.push({ reason: "Excellent savings rate (≥30%)", pts: 5 }); }
  else if (summary.savingsRate >= 20) { /* baseline, no deduction */ }
  else if (summary.savingsRate >= 10) { score -= 15; deductions.push("Savings rate below 20%"); }
  else if (summary.savingsRate >= 0)  { score -= 30; deductions.push("Very low savings rate (<10%)"); }
  else { score -= 40; deductions.push("Spending more than earning"); }

  const exceededBudgets = summary.budgets.filter((b) => b.percentUsed >= 100);
  const nearLimitBudgets = summary.budgets.filter((b) => b.percentUsed >= 85 && b.percentUsed < 100);
  score -= exceededBudgets.length * 10;
  score -= nearLimitBudgets.length * 5;
  if (exceededBudgets.length > 0) deductions.push(`${exceededBudgets.length} budget(s) exceeded`);

  const projectedOverruns = summary.budgets.filter((b) => b.willExceed && b.percentUsed < 100);
  score -= projectedOverruns.length * 5;
  if (projectedOverruns.length > 0) deductions.push(`${projectedOverruns.length} budget(s) projected to exceed`);

  if (streaks.savingsStreak >= 3) { bonuses.push({ reason: `${streaks.savingsStreak}-month savings streak`, pts: 5 }); }
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


// STEP 5 — RICH RULE-BASED INSIGHTS
const generateRuleBasedInsights = (summary, history, streaks, healthScore) => {
  const insights = [];
  const { monthProgressPct, dayOfMonth, daysInMonth } = summary;

  if (summary.savingsRate < 0) {
    insights.push({
      type: "alert",
      title: "Spending Exceeds Income",
      message: `You've spent ₹${Math.abs(summary.net).toFixed(0)} more than you earned this month. Review your expenses immediately to avoid debt.`,
      icon: "🚨",
      priority: 1,
    });
  } else if (summary.savingsRate < 10) {
    insights.push({
      type: "warning",
      title: "Low Savings Rate",
      message: `You're saving only ${summary.savingsRate}% of your income this month. Aim for at least 20%. Your top expense is ${summary.topCategories[0]?.name} at ₹${summary.topCategories[0]?.amount?.toFixed(0)}.`,
      icon: "⚠️",
      priority: 2,
    });
  } else if (summary.savingsRate >= 20) {
    insights.push({
      type: "achievement",
      title: "Strong Savings Rate 🎉",
      message: `You're saving ${summary.savingsRate}% of your income — above the recommended 20%. ${streaks.savingsStreak > 1 ? `That's ${streaks.savingsStreak} months in a row!` : "Keep it up!"}`,
      icon: "💰",
      priority: 5,
    });
  }

  // ── STREAKS ────────────────────────────────
  if (streaks.savingsStreak >= 3) {
    insights.push({
      type: "achievement",
      title: `${streaks.savingsStreak}-Month Savings Streak!`,
      message: `You've saved money every month for the past ${streaks.savingsStreak} months. Consistency is the key to long-term wealth.`,
      icon: "🔥",
      priority: 5,
    });
  }

  if (streaks.overspendStreak >= 2) {
    insights.push({
      type: "warning",
      title: "Recurring Overspending Pattern",
      message: `You've spent more than you earned for ${streaks.overspendStreak} consecutive months. Consider reviewing your fixed costs or finding ways to increase income.`,
      icon: "📉",
      priority: 1,
    });
  }

  // ── HISTORICAL COMPARISON ──────────────────
  if (history.avgExpenses > 0 && summary.expenses > 0) {
    const expenseChangePct = safeRate(summary.expenses - history.avgExpenses, history.avgExpenses);
    if (expenseChangePct > 25) {
      insights.push({
        type: "warning",
        title: "Expenses Up Significantly",
        message: `Your spending this month is ${expenseChangePct}% higher than your 3-month average (₹${history.avgExpenses.toFixed(0)}). Check what's driving the increase.`,
        icon: "📈",
        priority: 2,
      });
    } else if (expenseChangePct < -20) {
      insights.push({
        type: "achievement",
        title: "Great Spending Control",
        message: `You've spent ${Math.abs(expenseChangePct)}% less than your 3-month average. Well done on keeping costs down!`,
        icon: "✨",
        priority: 5,
      });
    }
  }

  // ── BURN RATE ALERTS ───────────────────────
  summary.budgets.forEach((b) => {
    if (b.willExceed && b.percentUsed < 100) {
      insights.push({
        type: "alert",
        title: `${b.category} Budget at Risk`,
        message: `At your current pace, you'll spend ₹${b.projectedMonthEnd.toFixed(0)} on ${b.category} by month-end — ₹${b.excessProjected.toFixed(0)} over your ₹${b.budgetAmount} budget. You're only ${Math.round(monthProgressPct)}% into the month.`,
        icon: "🔔",
        priority: 2,
      });
    } else if (b.percentUsed >= 100) {
      insights.push({
        type: "alert",
        title: `${b.category} Budget Exceeded`,
        message: `You've used ${b.percentUsed}% of your ${b.category} budget (₹${b.spent.toFixed(0)} of ₹${b.budgetAmount}). Consider pausing discretionary spending here.`,
        icon: "🚨",
        priority: 1,
      });
    } else if (b.percentUsed >= 85) {
      insights.push({
        type: "warning",
        title: `${b.category} Budget Almost Full`,
        message: `${b.percentUsed}% of your ${b.category} budget used with ${Math.round(100 - monthProgressPct)}% of the month remaining. Only ₹${b.remaining.toFixed(0)} left.`,
        icon: "⚠️",
        priority: 2,
      });
    } else if (b.burnStatus === "well under" && monthProgressPct > 50) {
      insights.push({
        type: "tip",
        title: `${b.category} Well Within Budget`,
        message: `You've only used ${b.percentUsed}% of your ${b.category} budget halfway through the month. Great discipline!`,
        icon: "👍",
        priority: 5,
      });
    }
  });

  // ── GOALS ─────────────────────────────────
  summary.goals.forEach((g) => {
    if (g.progress >= 90) {
      insights.push({
        type: "achievement",
        title: `Almost Done: ${g.name}`,
        message: `You're ${g.progress}% of the way to your "${g.name}" goal! Just ₹${g.remaining.toFixed(0)} more to go.`,
        icon: "🎯",
        priority: 4,
      });
    } else if (g.daysToTarget !== null && g.daysToTarget <= 30 && g.progress < 80) {
      insights.push({
        type: "alert",
        title: `Goal Deadline Approaching: ${g.name}`,
        message: `"${g.name}" is due in ${g.daysToTarget} days but only ${g.progress}% complete. You need to save ₹${g.dailySavingsRequired}/day to hit it.`,
        icon: "⏰",
        priority: 2,
      });
    } else if (g.onTrack === false) {
      insights.push({
        type: "tip",
        title: `Goal Off Track: ${g.name}`,
        message: `To reach "${g.name}" by ${new Date(g.targetDate).toLocaleDateString("en-IN")}, you need ₹${g.dailySavingsRequired}/day. Review your budget to allocate more.`,
        icon: "💡",
        priority: 3,
      });
    }
  });

  // ── LARGE SINGLE CATEGORY ─────────────────
  if (summary.topCategories.length > 0) {
    const top = summary.topCategories[0];
    if (top.pctOfExpenses > 40) {
      insights.push({
        type: "tip",
        title: `${top.name} Dominates Your Spending`,
        message: `${top.name} accounts for ${top.pctOfExpenses}% of all your expenses (₹${top.amount.toFixed(0)}). High concentration in one category is worth reviewing.`,
        icon: "🔍",
        priority: 3,
      });
    }
  }

  // ── DEFAULT FALLBACK ───────────────────────
  if (insights.length === 0) {
    insights.push({
      type: "tip",
      title: "Finances Looking Healthy",
      message: "No major issues detected. Keep logging transactions consistently for more detailed insights.",
      icon: "✅",
      priority: 5,
    });
  }

  const sorted = insights.sort((a, b) => a.priority - b.priority).slice(0, 6);

  return {
    insights: sorted,
    overallScore: healthScore.score,
    scoreLabel: healthScore.label,
    scoreExplanation: buildScoreExplanation(healthScore),
    summary,
    generatedAt: new Date().toISOString(),
    source: "rules",
  };
};

const buildScoreExplanation = (healthScore) => {
  const parts = [];
  if (healthScore.deductions.length > 0) parts.push(`Concerns: ${healthScore.deductions.join(", ")}`);
  if (healthScore.bonuses.length > 0) parts.push(`Bonuses: ${healthScore.bonuses.map((b) => b.reason).join(", ")}`);
  return parts.length > 0 ? parts.join(". ") : "Your finances are in good shape.";
};


// STEP 6 — AI INSIGHTS (ENHANCED PROMPT)
const getAIInsights = async (summary, history, streaks, healthScore) => {
  const client = getOpenAIClient();

  const prompt = `You are a friendly, smart personal finance advisor for an Indian user. Today is day ${summary.dayOfMonth} of ${summary.daysInMonth} in ${summary.month} ${summary.year} (${summary.monthProgressPct}% through the month).

── CURRENT MONTH ──
Income: ₹${summary.income.toFixed(0)} | Expenses: ₹${summary.expenses.toFixed(0)} | Net: ₹${summary.net.toFixed(0)} | Savings Rate: ${summary.savingsRate}%

Top Spending:
${summary.topCategories.map((c) => `  • ${c.name}: ₹${c.amount.toFixed(0)} (${c.pctOfExpenses}% of expenses)`).join("\n")}

Budget Status:
${summary.budgets.map((b) => `  • ${b.category}: ${b.percentUsed}% used (₹${b.spent.toFixed(0)}/₹${b.budgetAmount}) — ${b.burnStatus}${b.willExceed ? ` ⚠️ projected to exceed by ₹${b.excessProjected.toFixed(0)}` : ""}`).join("\n")}

Savings Goals:
${summary.goals.map((g) => `  • ${g.name}: ${g.progress}% complete, ₹${g.remaining.toFixed(0)} remaining${g.daysToTarget ? `, due in ${g.daysToTarget} days` : ""}`).join("\n") || "  None"}

── HISTORY (last 3 months avg) ──
Avg Expenses: ₹${history.avgExpenses.toFixed(0)} | Avg Income: ₹${history.avgIncome.toFixed(0)} | Avg Savings Rate: ${history.avgSavingsRate}%
${history.months.map((m) => `  • ${m.label}: expenses ₹${m.expenses.toFixed(0)}, savings ${m.savingsRate}%`).join("\n")}

── BEHAVIORAL ──
Savings streak: ${streaks.savingsStreak} months | Overspend streak: ${streaks.overspendStreak} months

── PRE-COMPUTED HEALTH SCORE: ${healthScore.score}/100 (${healthScore.label}) ──
Deductions: ${healthScore.deductions.join(", ") || "none"}
Bonuses: ${healthScore.bonuses.map((b) => b.reason).join(", ") || "none"}

Give 4-6 insights that are specific, actionable, and account for WHERE we are in the month (day ${summary.dayOfMonth}/${summary.daysInMonth}). Avoid generic advice. Reference actual numbers. Be concise and warm.

Respond ONLY with valid JSON (no markdown):
{
  "insights": [
    {
      "type": "warning|tip|achievement|alert",
      "title": "Short title (max 6 words)",
      "message": "Specific advice with actual numbers (max 80 words)",
      "icon": "relevant emoji",
      "priority": 1
    }
  ],
  "overallScore": ${healthScore.score},
  "scoreLabel": "${healthScore.label}",
  "scoreExplanation": "One sentence referencing actual numbers from their data"
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
  // Gather all context in parallel where possible
  const summary = await getCurrentMonthSummary(userId);

  const [history, streaks] = await Promise.all([
    getHistoricalContext(userId, summary.monthNumber, summary.year),
    getStreaks(userId, summary.monthNumber, summary.year),
  ]);

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