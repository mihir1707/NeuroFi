/**
 * Merchant Knowledge Base — Seed Script
 *
 * Populates the `merchant_categories` collection with common Indian merchants
 * so the system can return instant, high-confidence categories without ever
 * reaching the AI for well-known brands.
 *
 * Usage:
 *   node seedMerchants.js              — upsert (safe to re-run)
 *   node seedMerchants.js --clear      — wipe collection first, then insert
 *
 * The script exits with code 0 on success and 1 on failure.
 */

import mongoose from "mongoose";
import dotenv from "dotenv";
import MerchantCategory from "./src/models/MerchantCategory.js";

dotenv.config();

const MONGO_URI =
  process.env.MONGO_URI ||
  "mongodb+srv://mihirkhunt2006_db_user:MihirKhunt200615@cluster0.7lg6whp.mongodb.net/?appName=Cluster0";

// ─── SEED DATA ────────────────────────────────────────────────────────────────
// Each entry uses the normalized merchant key (lowercase, no special chars)
// that `normalizeMerchant()` would produce for real transaction strings.

const MERCHANT_SEEDS = [
  // ── Food Delivery ──────────────────────────────────────────────────────────
  { merchantName: "swiggy",     category: "Food & Drinks",    icon: "🍔", confidence: 1.0 },
  { merchantName: "zomato",     category: "Food & Drinks",    icon: "🍕", confidence: 1.0 },

  // ── Ride Hailing ──────────────────────────────────────────────────────────
  { merchantName: "uber",       category: "Transport",        icon: "🚗", confidence: 1.0 },
  { merchantName: "ola",        category: "Transport",        icon: "🚕", confidence: 1.0 },
  { merchantName: "rapido",     category: "Transport",        icon: "🛵", confidence: 1.0 },

  // ── E-Commerce ────────────────────────────────────────────────────────────
  { merchantName: "amazon",     category: "Shopping",         icon: "📦", confidence: 1.0 },
  { merchantName: "flipkart",   category: "Shopping",         icon: "🛒", confidence: 1.0 },
  { merchantName: "myntra",     category: "Shopping",         icon: "👗", confidence: 1.0 },
  { merchantName: "ajio",       category: "Shopping",         icon: "👟", confidence: 1.0 },
  { merchantName: "meesho",     category: "Shopping",         icon: "🛍️", confidence: 1.0 },
  { merchantName: "nykaa",      category: "Shopping",         icon: "💄", confidence: 1.0 },
  { merchantName: "lenskart",   category: "Shopping",         icon: "👓", confidence: 1.0 },

  // ── Grocery & Daily Needs ─────────────────────────────────────────────────
  { merchantName: "dmart",      category: "Groceries",        icon: "🏪", confidence: 1.0 },
  { merchantName: "bigbasket",  category: "Groceries",        icon: "🛒", confidence: 1.0 },
  { merchantName: "blinkit",    category: "Groceries",        icon: "⚡", confidence: 1.0 },
  { merchantName: "zepto",      category: "Groceries",        icon: "🥦", confidence: 1.0 },

  // ── Telecom / Utilities ───────────────────────────────────────────────────
  { merchantName: "jio",        category: "Bills & Utilities", icon: "📶", confidence: 1.0 },
  { merchantName: "airtel",     category: "Bills & Utilities", icon: "📡", confidence: 1.0 },
  { merchantName: "vi",         category: "Bills & Utilities", icon: "📱", confidence: 1.0 },
  { merchantName: "bsnl",       category: "Bills & Utilities", icon: "📞", confidence: 1.0 },

  // ── Fast Food / QSR ───────────────────────────────────────────────────────
  { merchantName: "mcdonalds",  category: "Food & Drinks",    icon: "🍟", confidence: 1.0 },
  { merchantName: "dominos",    category: "Food & Drinks",    icon: "🍕", confidence: 1.0 },
  { merchantName: "pizzahut",   category: "Food & Drinks",    icon: "🍕", confidence: 1.0 },
  { merchantName: "kfc",        category: "Food & Drinks",    icon: "🍗", confidence: 1.0 },
  { merchantName: "starbucks",  category: "Food & Drinks",    icon: "☕", confidence: 1.0 },

  // ── Entertainment / OTT ──────────────────────────────────────────────────
  { merchantName: "netflix",    category: "Entertainment",    icon: "🎬", confidence: 1.0 },
  { merchantName: "spotify",    category: "Entertainment",    icon: "🎵", confidence: 1.0 },
  { merchantName: "hotstar",    category: "Entertainment",    icon: "📺", confidence: 1.0 },
  { merchantName: "youtube",    category: "Entertainment",    icon: "▶️", confidence: 1.0 },

  // ── Payment Wallets / UPI ─────────────────────────────────────────────────
  { merchantName: "gpay",       category: "Other",            icon: "💳", confidence: 1.0 },
  { merchantName: "phonepe",    category: "Other",            icon: "💳", confidence: 1.0 },
  { merchantName: "paytm",      category: "Other",            icon: "💳", confidence: 1.0 },

  // ── Healthcare ────────────────────────────────────────────────────────────
  { merchantName: "1mg",        category: "Healthcare",       icon: "💊", confidence: 1.0 },
  { merchantName: "pharmeasy",  category: "Healthcare",       icon: "🏥", confidence: 1.0 },
  { merchantName: "practo",     category: "Healthcare",       icon: "🩺", confidence: 1.0 },

  // ── Travel ───────────────────────────────────────────────────────────────
  { merchantName: "irctc",      category: "Travel",           icon: "🚂", confidence: 1.0 },
  { merchantName: "makemytrip", category: "Travel",           icon: "✈️", confidence: 1.0 },
  { merchantName: "goibibo",    category: "Travel",           icon: "✈️", confidence: 1.0 },
  { merchantName: "cleartrip",  category: "Travel",           icon: "🌍", confidence: 1.0 },
  { merchantName: "indigo",     category: "Travel",           icon: "✈️", confidence: 1.0 },
  { merchantName: "airindia",   category: "Travel",           icon: "✈️", confidence: 1.0 },

  // ── Education ────────────────────────────────────────────────────────────
  { merchantName: "udemy",      category: "Education",        icon: "📚", confidence: 1.0 },
  { merchantName: "coursera",   category: "Education",        icon: "🎓", confidence: 1.0 },
  { merchantName: "byjus",      category: "Education",        icon: "📖", confidence: 1.0 },
  { merchantName: "unacademy",  category: "Education",        icon: "🎓", confidence: 1.0 },
];


// ─── SEED FUNCTION ────────────────────────────────────────────────────────────

const seedMerchants = async () => {
  const shouldClear = process.argv.includes("--clear");

  try {
    await mongoose.connect(MONGO_URI);
    console.log("✅ Connected to MongoDB");

    if (shouldClear) {
      const { deletedCount } = await MerchantCategory.deleteMany({});
      console.log(`🗑️  Cleared ${deletedCount} existing merchant records`);
    }

    let inserted = 0;
    let skipped  = 0;

    for (const seed of MERCHANT_SEEDS) {
      const result = await MerchantCategory.findOneAndUpdate(
        { merchantName: seed.merchantName },
        {
          $setOnInsert: {
            ...seed,
            source: "manual",
            usageCount: 0,
          },
        },
        { upsert: true, new: true, rawResult: true }
      );

      if (result.lastErrorObject?.upserted) {
        inserted++;
      } else {
        skipped++;
      }
    }

    console.log(`\n📊 Merchant Knowledge Base seed complete:`);
    console.log(`   ✅ Inserted : ${inserted} new merchants`);
    console.log(`   ⏭️  Skipped  : ${skipped} already existing`);
    console.log(`   📦 Total in DB after seed: ${await MerchantCategory.countDocuments()}`);

    process.exit(0);
  } catch (error) {
    console.error("❌ Seeding failed:", error.message);
    process.exit(1);
  }
};

seedMerchants();
