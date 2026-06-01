import { getOpenAIClient, isAIEnabled, AI_MODEL } from "../../config/openai.js";
import Transaction from "../../models/Transaction.js";
import Account from "../../models/Account.js";
import Budget from "../../models/Budget.js";
import SavingsGoal from "../../models/SavingsGoal.js";
import { getMonthRange } from "../../utils/dateRange.util.js";


const buildFinancialContext = async (userId) => {
  const now = new Date();
  const { start, end } = getMonthRange(now.getFullYear(), now.getMonth() + 1);

  const [accounts, transactions, budgets, goals] = await Promise.all([
    Account.find({ user: userId, isArchived: false }).lean(),
    Transaction.find({ user: userId, transactionDate: { $gte: start, $lte: end } })
      .populate("category", "name")
      .lean(),
    Budget.find({ user: userId, isActive: true }).populate("category", "name").lean(),
    SavingsGoal.find({ user: userId, status: "active" }).lean(),
  ]);

  const totalBalance = accounts.reduce((sum, a) => sum + a.balance, 0);
  const income = transactions.filter((t) => t.type === "income").reduce((s, t) => s + t.amount, 0);
  const expenses = transactions.filter((t) => t.type === "expense").reduce((s, t) => s + t.amount, 0);

  const budgetContext = budgets.map((b) =>
    `${b.category?.name}: ₹${b.spent}/${b.amount} spent (${((b.spent / b.amount) * 100).toFixed(0)}%)`
  ).join(", ");

  const goalContext = goals.map((g) =>
    `${g.name}: ₹${g.currentAmount}/${g.targetAmount} (${((g.currentAmount / g.targetAmount) * 100).toFixed(0)}%)`
  ).join(", ");

  return `
User's Financial Snapshot for ${now.toLocaleString("default", { month: "long", year: "numeric" })}:
- Total Account Balance: ₹${totalBalance.toFixed(2)}
- This Month Income: ₹${income.toFixed(2)}
- This Month Expenses: ₹${expenses.toFixed(2)}
- Net Savings This Month: ₹${(income - expenses).toFixed(2)}
- Budgets: ${budgetContext || "None set"}
- Savings Goals: ${goalContext || "None set"}
- Total Transactions This Month: ${transactions.length}
`.trim();
};


export const chat = async (userId, userMessage, conversationHistory = []) => {
  if (!isAIEnabled()) {
    return {
      reply: "AI chat is not available right now. Please check your OpenAI API key configuration.",
      suggestions: [
        "View your transactions",
        "Check your budget",
        "See savings goals",
      ],
      source: "fallback",
    };
  }

  const client = getOpenAIClient();
  const financialContext = await buildFinancialContext(userId);

  const systemMessage = `You are a helpful personal finance assistant named "FinBot". 
You have access to the user's financial data and help them understand their spending, savings, and budget.

${financialContext}

Guidelines:
- Be friendly, encouraging, and specific with numbers
- Always use ₹ for amounts (Indian Rupees)
- Keep responses concise (2-3 paragraphs max)
- If asked something you can't answer from the data, say so honestly
- Provide actionable tips when relevant`;

  const messages = [
    { role: "system", content: systemMessage },
    ...conversationHistory.slice(-6),
    { role: "user", content: userMessage },
  ];

  try {
    const response = await client.chat.completions.create({
      model: AI_MODEL,
      messages,
      max_tokens: 400,
      temperature: 0.5,
    });

    const reply = response.choices[0]?.message?.content?.trim() || "I couldn't process that. Please try again.";

    return {
      reply,
      suggestions: generateFollowUpSuggestions(userMessage),
      source: "ai",
    };
  } catch (error) {
    console.error("[FinBot] Chat error:", error.message);
    return {
      reply: "I'm having trouble connecting right now. Please try again in a moment.",
      suggestions: [],
      source: "error",
    };
  }
};

const generateFollowUpSuggestions = (message) => {
  const suggestions = [
    "How can I save more money?",
    "What's my biggest expense this month?",
    "Am I on track with my budgets?",
    "Show me my savings goal progress",
    "How does this month compare to last month?",
  ];

  return suggestions.filter((s) => !s.toLowerCase().includes(message.toLowerCase().slice(0, 10))).slice(0, 3);
};
