import Account from "../models/Account.js";
import { sendSuccess, sendError } from "../utils/response.util.js";
import { generateMonthlyReport, generateYearlyReport, exportToCSV } from "../services/report.service.js";
import { getExchangeRates, getSupportedCurrencies } from "../services/currency.service.js";

export const getMonthlyReport = async (req, res) => {
  const year = parseInt(req.query.year) || new Date().getFullYear();
  const month = parseInt(req.query.month) || new Date().getMonth() + 1;

  if (month < 1 || month > 12) {
    return sendError(res, 400, "Month must be between 1 and 12");
  }

  const report = await generateMonthlyReport(req.user._id, year, month);

  return sendSuccess(res, 200, "Monthly report generated", report);
};

export const getYearlyReport = async (req, res) => {
  const year = parseInt(req.query.year) || new Date().getFullYear();
  const report = await generateYearlyReport(req.user._id, year);

  return sendSuccess(res, 200, "Yearly report generated", report);
};

export const getOverview = async (req, res) => {
  const accounts = await Account.find({
    user: req.user._id,
    isArchived: false,
  }).lean();

  const totalBalance = accounts.reduce((sum, a) => sum + a.balance, 0);

  const byType = accounts.reduce((acc, account) => {
    acc[account.type] = (acc[account.type] || 0) + account.balance;
    return acc;
  }, {});

  const assets = accounts.filter((a) => a.type !== "loan" && a.type !== "credit_card").reduce((sum, a) => sum + a.balance, 0);
  const liabilities = accounts.filter((a) => a.type === "loan" || a.type === "credit_card").reduce((sum, a) => sum + Math.abs(a.balance), 0);
  const netWorth = assets - liabilities;

  return sendSuccess(res, 200, "Financial overview", {
    netWorth,
    totalBalance,
    assets,
    liabilities,
    accounts,
    byType,
    accountCount: accounts.length,
  });
};

export const exportReport = async (req, res) => {
  const filters = {
    startDate: req.query.startDate,
    endDate: req.query.endDate,
    type: req.query.type,
    account: req.query.account,
  };

  const csvContent = await exportToCSV(req.user._id, filters);

  const fileName = `finance_report_${new Date().toISOString().split("T")[0]}.csv`;

  res.setHeader("Content-Type", "text/csv");
  res.setHeader("Content-Disposition", `attachment; filename="${fileName}"`);
  res.status(200).send(csvContent);
};

export const getCurrencyRates = async (req, res) => {
  const baseCurrency = (req.query.base || req.user.currency || "INR").toUpperCase();

  const [rates, supportedCurrencies] = await Promise.all([
    getExchangeRates(baseCurrency),
    getSupportedCurrencies(),
  ]);

  return sendSuccess(res, 200, "Exchange rates retrieved", {
    base: baseCurrency,
    rates,
    supportedCurrencies,
    lastUpdated: new Date().toISOString(),
  });
};