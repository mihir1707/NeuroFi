import cron from "node-cron";
import { getExchangeRates } from "../src/services/currency.service.js";

const BASE_CURRENCIES = ["INR", "USD", "EUR", "GBP"];

const refreshCurrencyRates = async () => {
  let refreshed = 0;

  for (const currency of BASE_CURRENCIES) {
    try {
      await getExchangeRates(currency);
      refreshed++;
    } catch (error) {
      console.warn(`[Cron] Failed to refresh rates for ${currency}:`, error.message);
    }
  }

  return { refreshed };
};

export const initCurrencySyncJob = () => {
  return cron.schedule("0 * * * *", async () => {
    try {
      console.info("[Cron] Refreshing currency exchange rates...");
      const result = await refreshCurrencyRates();
      console.info(`[Cron] Refreshed rates for ${result.refreshed}/${BASE_CURRENCIES.length} currencies`);
    } catch (error) {
      console.error("[Cron] Currency sync job failed:", error.message);
    }
  });
};