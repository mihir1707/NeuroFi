const CACHE_DURATION_MS = 24 * 60 * 60 * 1000; // 24 hours (API updates daily)
const ratesCache = new Map();

const isCacheValid = (key) => {
  const cached = ratesCache.get(key);
  if (!cached) return false;
  return Date.now() - cached.fetchedAt < CACHE_DURATION_MS;
};

const getDateString = () => "latest";

const buildJsDelivrUrl = (currencyCode) => {
  const date = getDateString();
  return `https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@${date}/v1/currencies/${currencyCode.toLowerCase()}.json`;
};

const buildCloudflareUrl = (currencyCode) => {
  const date = getDateString();
  return `https://${date}.currency-api.pages.dev/v1/currencies/${currencyCode.toLowerCase()}.json`;
};

const fetchFromUrl = async (url) => {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 8000);
  try {
    const response = await fetch(url, { signal: controller.signal });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return await response.json();
  } finally {
    clearTimeout(timeout);
  }
};

const fetchRatesFromAPI = async (baseCurrency = "INR") => {
  const code = baseCurrency.toLowerCase();
  const primaryUrl   = buildJsDelivrUrl(code);
  const fallbackUrl  = buildCloudflareUrl(code);

  let data = null;

  try {
    data = await fetchFromUrl(primaryUrl);
    console.log(`[Currency] Fetched rates via jsDelivr for ${baseCurrency.toUpperCase()}`);
  } catch (primaryErr) {
    console.warn(`[Currency] jsDelivr failed (${primaryErr.message}), trying Cloudflare fallback...`);
    try {
      data = await fetchFromUrl(fallbackUrl);
      console.log(`[Currency] Fetched rates via Cloudflare fallback for ${baseCurrency.toUpperCase()}`);
    } catch (fallbackErr) {
      console.error(`[Currency] Both sources failed:`, fallbackErr.message);
      return {};
    }
  }

  const rates = data?.[code];
  if (!rates || typeof rates !== "object") {
    console.error("[Currency] Unexpected API response format:", data);
    return {};
  }

  return rates;
};

export const getExchangeRates = async (baseCurrency = "INR") => {
  const currency = baseCurrency.toUpperCase();

  if (isCacheValid(currency)) {
    return ratesCache.get(currency).rates;
  }

  const rates = await fetchRatesFromAPI(currency);

  if (Object.keys(rates).length > 0) {
    ratesCache.set(currency, {
      rates,
      fetchedAt: Date.now(),
    });
  }

  return rates;
};

export const convertCurrency = async (amount, fromCurrency = "INR", toCurrency = "INR") => {
  if (fromCurrency.toUpperCase() === toCurrency.toUpperCase()) return amount;

  try {
    const rates = await getExchangeRates(fromCurrency);
    const rate = rates[toCurrency.toLowerCase()];

    if (!rate) {
      console.warn(`[Currency] No rate found for ${fromCurrency} → ${toCurrency}`);
      return amount;
    }

    return parseFloat((amount * rate).toFixed(2));
  } catch (error) {
    console.error("[Currency] Conversion failed:", error.message);
    return amount;
  }
};

export const getSupportedCurrencies = async () => {
  try {
    const primaryUrl  = "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json";
    const fallbackUrl = "https://latest.currency-api.pages.dev/v1/currencies.json";

    if (isCacheValid("__currencies_list__")) {
      return ratesCache.get("__currencies_list__").rates;
    }

    let data = null;
    try {
      data = await fetchFromUrl(primaryUrl);
    } catch {
      data = await fetchFromUrl(fallbackUrl);
    }

    const list = Object.keys(data || {}).sort();

    ratesCache.set("__currencies_list__", {
      rates: list,
      fetchedAt: Date.now(),
    });

    return list;
  } catch (error) {
    console.error("[Currency] Failed to fetch supported currencies:", error.message);
    return ["inr", "usd", "eur", "gbp", "aed", "sgd", "jpy"];
  }
};

export const formatCurrency = (amount, currency = "INR") => {
  try {
    return new Intl.NumberFormat("en-IN", {
      style: "currency",
      currency: currency.toUpperCase(),
      minimumFractionDigits: 2,
    }).format(amount);
  } catch {
    return `${currency.toUpperCase()} ${Number(amount).toFixed(2)}`;
  }
};

export const clearRatesCache = () => {
  ratesCache.clear();
  console.log("[Currency] Cache cleared");
};