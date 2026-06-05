/**
 * Merchant Normalization Utility
 *
 * Cleans and normalizes raw merchant/transaction strings so they can be
 * consistently matched against the `merchant_categories` knowledge base.
 *
 * Examples:
 *   "SWIGGY*ORDER123"        -> "swiggy"
 *   "UBER INDIA TRIP 8234"   -> "uber"
 *   "AMAZON PAY INDIA"       -> "amazon"
 *   "ZOMATO ONLINE PAYMENT"  -> "zomato"
 *   "MCDONALD'S #1234"       -> "mcdonalds"
 */

// ─── NOISE WORDS ─────────────────────────────────────────────────────────────
// These are generic suffixes / commerce terms that appear across many
// merchants. We strip them AFTER the per-merchant regex pass so the final
// token represents the actual brand.

const NOISE_WORDS = new Set([
  "pay", "payment", "payments", "online", "india", "pvt", "ltd", "limited",
  "private", "technologies", "technology", "tech", "solutions", "solution",
  "services", "service", "digital", "app", "apps", "inapp", "internet",
  "network", "networks", "systems", "system", "enterprises", "enterprise",
  "global", "international", "group", "store", "shop", "official",
  "order", "orders", "booking", "bookings", "trip", "trips",
  "recharge", "subscription", "monthly", "annual", "yearly",
  "gst", "invoice", "txn", "transaction",
]);

// ─── BRAND ALIAS MAP ─────────────────────────────────────────────────────────
// Maps any variant that should resolve to a canonical brand token.

const BRAND_ALIASES = {
  swiggy: "swiggy",
  zomato: "zomato",
  uber: "uber",
  "uber eats": "uber",
  ola: "ola",
  rapido: "rapido",
  amazon: "amazon",
  "amazon prime": "amazon",
  flipkart: "flipkart",
  myntra: "myntra",
  ajio: "ajio",
  dmart: "dmart",
  "d mart": "dmart",
  bigbasket: "bigbasket",
  "big basket": "bigbasket",
  blinkit: "blinkit",
  "grofers": "blinkit",          // Grofers rebranded to Blinkit
  zepto: "zepto",
  jio: "jio",
  "reliance jio": "jio",
  airtel: "airtel",
  "bharti airtel": "airtel",
  vi: "vi",
  vodafone: "vi",
  "vodafone idea": "vi",
  bsnl: "bsnl",
  mcdonalds: "mcdonalds",
  "mcdonald": "mcdonalds",
  "mc donalds": "mcdonalds",
  dominos: "dominos",
  domino: "dominos",
  "domino's": "dominos",
  pizzahut: "pizzahut",
  "pizza hut": "pizzahut",
  kfc: "kfc",
  starbucks: "starbucks",
  netflix: "netflix",
  spotify: "spotify",
  hotstar: "hotstar",
  "disney hotstar": "hotstar",
  youtube: "youtube",
  "google pay": "gpay",
  gpay: "gpay",
  phonepe: "phonepe",
  paytm: "paytm",
  nykaa: "nykaa",
  meesho: "meesho",
  lenskart: "lenskart",
  "1mg": "1mg",
  pharmeasy: "pharmeasy",
  practo: "practo",
  irctc: "irctc",
  makemytrip: "makemytrip",
  "make my trip": "makemytrip",
  goibibo: "goibibo",
  cleartrip: "cleartrip",
  indigo: "indigo",
  "air india": "airindia",
};

// ─── NORMALIZER ──────────────────────────────────────────────────────────────

/**
 * Normalize a raw transaction description / merchant name into a canonical
 * lowercase token suitable for database lookup.
 *
 * @param {string} raw - Raw description or merchant name from the transaction.
 * @returns {string} Normalized merchant token, e.g. "swiggy", "amazon".
 */
export const normalizeMerchant = (raw = "") => {
  if (!raw || typeof raw !== "string") return "";

  let text = raw.trim().toLowerCase();

  // 1. Remove everything after common transaction ID separators
  //    e.g. "SWIGGY*ORDER78329" -> "swiggy"
  text = text.split(/[*|#@/\\]/)[0].trim();

  // 2. Strip leading/trailing transaction reference numbers
  //    e.g. "123456 AMAZON PAY 789" -> "amazon pay"
  text = text.replace(/^\d+\s+/, "").replace(/\s+\d+$/, "").trim();

  // 3. Remove apostrophes (for names like "McDonald's")
  text = text.replace(/'/g, "");

  // 4. Replace non-alphanumeric characters (except spaces) with a space
  text = text.replace(/[^a-z0-9\s]/g, " ");

  // 5. Collapse multiple spaces
  text = text.replace(/\s+/g, " ").trim();

  // 6. Check the full cleaned phrase against the alias map first
  if (BRAND_ALIASES[text]) {
    return BRAND_ALIASES[text];
  }

  // 7. Remove pure-numeric tokens (transaction IDs embedded mid-string)
  const tokens = text.split(" ").filter((t) => !/^\d+$/.test(t));

  // 8. Check the first meaningful token against alias map
  if (tokens.length > 0 && BRAND_ALIASES[tokens[0]]) {
    return BRAND_ALIASES[tokens[0]];
  }

  // 9. Remove noise words and return the first remaining token as the merchant
  const meaningful = tokens.filter((t) => !NOISE_WORDS.has(t));

  const result = meaningful[0] ?? tokens[0] ?? "";
  return result.trim();
};


/**
 * Extract the most likely merchant name from a transaction object.
 * Prefers `merchantName` field; falls back to `description`.
 *
 * @param {{ description?: string, merchantName?: string }} transaction
 * @returns {string} Normalized merchant token.
 */
export const extractMerchant = (transaction = {}) => {
  const { merchantName = "", description = "" } = transaction;
  const source = (merchantName || description).trim();
  return normalizeMerchant(source);
};
