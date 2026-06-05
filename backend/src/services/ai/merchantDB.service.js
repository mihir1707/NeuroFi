import MerchantCategory from "../../models/MerchantCategory.js";
import { extractMerchant } from "../../utils/merchantNormalizer.util.js";
import { lookupUserPreference } from "./userPreference.service.js";

const AUTO_SAVE_THRESHOLD = 0.85;

// Simple in-memory cache to avoid hitting MongoDB on every request for known merchants.
// key = merchantKey (global) or "userId:merchantKey" (user prefs)
const cache = new Map();
const GLOBAL_TTL = 10 * 60 * 1000; // 10 min
const USER_TTL   =  5 * 60 * 1000; //  5 min

const cacheGet = (key) => {
  const entry = cache.get(key);
  if (!entry) return undefined;
  if (Date.now() > entry.expiresAt) {
    cache.delete(key);
    return undefined;
  }
  return entry.value;
};

const cacheSet = (key, value, ttl) => {
  cache.set(key, { value, expiresAt: Date.now() + ttl });
};

// Called when user saves a correction so next request sees updated preference
export const invalidateMerchantCache = (userId, merchantKey) => {
  cache.delete(merchantKey);
  cache.delete(`${userId}:${merchantKey}`);
};

export const getMerchantCacheStats = () => ({ size: cache.size });

const getGlobalMerchant = async (merchantKey) => {
  const cached = cacheGet(merchantKey);
  if (cached !== undefined) return cached;

  const record = await MerchantCategory.findOneAndUpdate(
    { merchantName: merchantKey },
    { $inc: { usageCount: 1 } },
    { new: true }
  ).lean();

  cacheSet(merchantKey, record || null, GLOBAL_TTL);
  return record || null;
};

const getUserPref = async (userId, merchantKey) => {
  const key = `${userId}:${merchantKey}`;
  const cached = cacheGet(key);
  if (cached !== undefined) return cached;

  const record = await lookupUserPreference(userId, merchantKey);
  cacheSet(key, record || null, USER_TTL);
  return record || null;
};

const saveMerchantFromAI = async (merchantKey, aiResult) => {
  if (!merchantKey || (aiResult.confidence ?? 0) < AUTO_SAVE_THRESHOLD) return;

  try {
    await MerchantCategory.findOneAndUpdate(
      { merchantName: merchantKey },
      {
        $setOnInsert: {
          merchantName: merchantKey,
          category: aiResult.category,
          icon: aiResult.icon || "📦",
          confidence: aiResult.confidence,
          source: "ai",
          usageCount: 1,
        },
      },
      { upsert: true, new: true }
    );
    cache.delete(merchantKey);
  } catch (err) {
    if (err.code !== 11000) {
      console.warn("[MerchantDB] Failed to save merchant:", merchantKey, err.message);
    }
  }
};

const buildUserPrefResponse = (record) => ({
  category: record.category,
  icon: record.icon,
  confidence: 1.0,
  source: "user_preference",
  merchantKey: record.merchantKey,
});

const buildDbResponse = (record) => ({
  category: record.category,
  icon: record.icon,
  confidence: 1.0,
  source: "merchant_db",
  merchantKey: record.merchantName,
});

export const categorizeWithMerchantDB = async (txnData, aiCategorizerFn, userId = null) => {
  const merchantKey = extractMerchant(txnData);

  if (userId && merchantKey) {
    const userPref = await getUserPref(userId, merchantKey);
    if (userPref) return buildUserPrefResponse(userPref);
  }

  if (merchantKey) {
    const dbRecord = await getGlobalMerchant(merchantKey);
    if (dbRecord) return buildDbResponse(dbRecord);
  }

  const aiResult = await aiCategorizerFn(txnData);

  if (merchantKey && aiResult.source !== "keyword_matching") {
    await saveMerchantFromAI(merchantKey, aiResult);
  }

  return { ...aiResult, merchantKey: merchantKey || null };
};

export const batchCategorizeWithMerchantDB = async (transactions, aiCategorizerFn, userId = null) => {
  const results = new Array(transactions.length).fill(null);
  const aiQueue = [];

  await Promise.all(
    transactions.map(async (txn, idx) => {
      const merchantKey = extractMerchant(txn);

      if (userId && merchantKey) {
        const userPref = await getUserPref(userId, merchantKey);
        if (userPref) {
          results[idx] = buildUserPrefResponse(userPref);
          return;
        }
      }

      if (merchantKey) {
        const dbRecord = await getGlobalMerchant(merchantKey);
        if (dbRecord) {
          results[idx] = buildDbResponse(dbRecord);
          return;
        }
      }

      aiQueue.push({ idx, merchantKey, txn });
    })
  );

  const BATCH_SIZE = 5;

  for (let i = 0; i < aiQueue.length; i += BATCH_SIZE) {
    const chunk = aiQueue.slice(i, i + BATCH_SIZE);

    const chunkResults = await Promise.allSettled(
      chunk.map(({ txn }) => aiCategorizerFn(txn))
    );

    await Promise.all(
      chunkResults.map(async (settled, localIdx) => {
        const { idx, merchantKey } = chunk[localIdx];

        if (settled.status === "fulfilled") {
          const aiResult = settled.value;
          if (merchantKey && aiResult.source !== "keyword_matching") {
            await saveMerchantFromAI(merchantKey, aiResult);
          }
          results[idx] = { ...aiResult, merchantKey: merchantKey || null };
        } else {
          results[idx] = {
            category: "Other",
            icon: "📦",
            confidence: 0.3,
            source: "default",
            merchantKey: chunk[localIdx].merchantKey || null,
          };
        }
      })
    );
  }

  return results;
};
