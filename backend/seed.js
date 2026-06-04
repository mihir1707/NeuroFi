import mongoose from "mongoose";
import dotenv from "dotenv";
import User from "./src/models/User.js";
import Account from "./src/models/Account.js";
import Transaction from "./src/models/Transaction.js";

dotenv.config();

const MONGO_URI = process.env.MONGO_URI || "mongodb+srv://mihirkhunt2006_db_user:MihirKhunt200615@cluster0.7lg6whp.mongodb.net/?appName=Cluster0";

const seedData = async () => {
  try {
    await mongoose.connect(MONGO_URI);
    console.log("Connected to DB...");

    const user = await User.findOne();
    if (!user) {
      console.log("No user found in DB. Register a user first.");
      process.exit(1);
    }

    console.log(`Seeding data for user: ${user.name} (${user.email})`);

    // Create accounts
    const hdfc = new Account({
      user: user._id,
      name: "HDFC Bank",
      type: "bank",
      balance: 150000,
      currency: user.currency || "INR",
      icon: "💳",
      color: "#FFFFFF"
    });

    const sbi = new Account({
      user: user._id,
      name: "SBI Saving",
      type: "bank",
      balance: 45000,
      currency: user.currency || "INR",
      icon: "🏦",
      color: "#CCCCCC"
    });

    await hdfc.save();
    await sbi.save();
    console.log("Accounts created.");

    // Create transactions
    const transactions = [
      {
        user: user._id,
        account: hdfc._id,
        type: "income",
        amount: 85000,
        currency: user.currency || "INR",
        description: "Salary",
        category: null,
        aiCategory: "salary",
        transactionDate: new Date(),
        status: "posted"
      },
      {
        user: user._id,
        account: hdfc._id,
        type: "expense",
        amount: 2500,
        currency: user.currency || "INR",
        description: "Zomato",
        category: null,
        aiCategory: "food",
        transactionDate: new Date(Date.now() - 1000 * 60 * 60 * 2), // 2 hours ago
        status: "posted"
      },
      {
        user: user._id,
        account: sbi._id,
        type: "expense",
        amount: 12000,
        currency: user.currency || "INR",
        description: "Apartment Rent",
        category: null,
        aiCategory: "rent",
        transactionDate: new Date(Date.now() - 1000 * 60 * 60 * 24 * 2), // 2 days ago
        status: "posted"
      },
      {
        user: user._id,
        account: hdfc._id,
        type: "expense",
        amount: 1500,
        currency: user.currency || "INR",
        description: "Netflix Subscription",
        category: null,
        aiCategory: "entertainment",
        transactionDate: new Date(Date.now() - 1000 * 60 * 60 * 24 * 5), // 5 days ago
        status: "posted"
      },
      {
        user: user._id,
        account: hdfc._id,
        type: "transfer",
        amount: 5000,
        currency: user.currency || "INR",
        description: "Transfer to SBI",
        transferToAccount: sbi._id,
        category: null,
        aiCategory: "transfer",
        transactionDate: new Date(Date.now() - 1000 * 60 * 60 * 24 * 10), // 10 days ago
        status: "posted"
      }
    ];

    await Transaction.insertMany(transactions);
    console.log("Transactions created.");

    console.log("Dummy data injected successfully!");
    process.exit(0);
  } catch (error) {
    console.error("Error seeding data:", error);
    process.exit(1);
  }
};

seedData();
