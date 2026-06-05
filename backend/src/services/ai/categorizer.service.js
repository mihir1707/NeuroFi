import { getOpenAIClient, isAIEnabled, AI_MODEL, AI_MAX_TOKENS, AI_TEMPERATURE } from "../../config/openai.js";
import { categorizeWithMerchantDB, batchCategorizeWithMerchantDB } from "./merchantDB.service.js";

const DEFAULT_CATEGORIES = [
  { name: "Food & Drinks",     icon: "🍽️", keywords: ["restaurant", "cafe", "food", "coffee", "pizza", "zomato", "swiggy"] },
  { name: "Shopping",          icon: "🛒", keywords: ["amazon", "flipkart", "mall", "store", "shop"] },
  { name: "Transport",         icon: "🚗", keywords: ["uber", "ola", "petrol", "fuel", "metro", "bus", "train"] },
  { name: "Entertainment",     icon: "🎬", keywords: ["netflix", "spotify", "movie", "game", "amazon prime"] },
  { name: "Healthcare",        icon: "🏥", keywords: ["pharmacy", "hospital", "doctor", "medicine", "medical"] },
  { name: "Bills & Utilities", icon: "💡", keywords: ["electricity", "water", "internet", "mobile", "recharge"] },
  { name: "Education",         icon: "📚", keywords: ["school", "college", "course", "book", "udemy"] },
  { name: "Groceries",         icon: "🛍️", keywords: ["bigbasket", "grofers", "blinkit", "supermarket", "grocery"] },
  { name: "Other",             icon: "📦", keywords: [] },
];

const categorizeByKeywords = (description = "") => {
  const lower = description.toLowerCase();

  for (const cat of DEFAULT_CATEGORIES) {
    if (cat.keywords.some((kw) => lower.includes(kw))) {
      return { category: cat.name, icon: cat.icon, confidence: 0.6, source: "keyword_matching" };
    }
  }

  return { category: "Other", icon: "📦", confidence: 0.3, source: "default" };
};

export const categorizeExpense = async (txnData = {}) => {
  const { description = "", amount = 0, currency = "INR", merchantName = "" } = txnData;

  if (!isAIEnabled()) {
    return categorizeByKeywords(`${merchantName} ${description}`);
  }

  const client = getOpenAIClient();

  const prompt = `You are a financial expense categorizer. Categorize this transaction and respond with ONLY valid JSON.

Transaction Details:
- Description: "${description}"
- Merchant: "${merchantName}"
- Amount: ${amount} ${currency}

Available categories: Food & Drinks, Shopping, Transport, Entertainment, Healthcare, Bills & Utilities, Education, Groceries, Travel, Investments, Salary, Freelance, Other

Respond with this exact JSON format (no markdown, no extra text):
{
  "category": "category name from the list",
  "icon": "single relevant emoji",
  "confidence": 0.95,
  "reason": "brief reason for this category"
}`;

  try {
    const response = await client.chat.completions.create({
      model: AI_MODEL,
      messages: [{ role: "user", content: prompt }],
      max_tokens: AI_MAX_TOKENS,
      temperature: AI_TEMPERATURE,
    });

    const raw = response.choices[0]?.message?.content?.trim();
    if (!raw) return categorizeByKeywords(`${merchantName} ${description}`);

    const parsed = JSON.parse(raw);

    return {
      category: parsed.category || "Other",
      icon: parsed.icon || "📦",
      confidence: parsed.confidence || 0.7,
      reason: parsed.reason || "",
      source: "ai",
    };
  } catch (err) {
    console.warn("[AI Categorizer] Falling back to keywords:", err.message);
    return categorizeByKeywords(`${merchantName} ${description}`);
  }
};

export const categorizeWithKnowledgeBase = async (txnData = {}, userId = null) => {
  return categorizeWithMerchantDB(txnData, categorizeExpense, userId);
};

export const batchCategorizeWithKnowledgeBase = async (transactions = [], userId = null) => {
  return batchCategorizeWithMerchantDB(transactions, categorizeExpense, userId);
};

// kept for any existing callers outside AI routes
export const batchCategorize = async (transactions = []) => {
  const results = [];
  const BATCH_SIZE = 5;

  for (let i = 0; i < transactions.length; i += BATCH_SIZE) {
    const batch = transactions.slice(i, i + BATCH_SIZE);
    const settled = await Promise.allSettled(batch.map((t) => categorizeExpense(t)));

    results.push(
      ...settled.map((r, idx) =>
        r.status === "fulfilled" ? r.value : categorizeByKeywords(batch[idx].description)
      )
    );
  }

  return results;
};