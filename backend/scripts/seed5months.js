import mongoose from "mongoose";
import dotenv from "dotenv";
import User from "./src/models/User.js";
import Account from "./src/models/Account.js";
import Transaction from "./src/models/Transaction.js";
import Category from "./src/models/Category.js";
import Notification from "./src/models/Notification.js";
import Budget from "./src/models/Budget.js";
import SavingsGoal from "./src/models/SavingsGoal.js";

dotenv.config();

const MONGO_URI = process.env.MONGO_URI || "mongodb+srv://mihirkhunt2006_db_user:MihirKhunt200615@cluster0.7lg6whp.mongodb.net/?appName=Cluster0";

const seedData = async () => {
  try {
    await mongoose.connect(MONGO_URI);
    console.log("✅ Connected to DB...");

    let user = await User.findOne();
    if (!user) {
      console.log("Creating default user...");
      user = await User.create({
        name: "Test User",
        email: "test@example.com",
        passwordHash: "dummy",
        baseCurrency: "INR",
      });
    }
    console.log(`👤 Using user: ${user.name} (${user.email})`);

    // Accounts
    let account = await Account.findOne({ user: user._id });
    if (!account) {
      account = await Account.create({
        user: user._id,
        name: "Main Bank",
        type: "bank",
        balance: 500000,
        currency: "INR",
        icon: "🏦",
      });
    }

    // Categories
    const expenseCats = ["Food & Drinks", "Shopping", "Transport", "Entertainment", "Bills & Utilities", "Groceries"];
    const categoriesMap = {};
    for (const name of expenseCats) {
      let cat = await Category.findOne({ name, type: "expense", $or: [{ user: user._id }, { isDefault: true }] });
      if (!cat) {
        cat = await Category.create({ name, type: "expense", user: user._id, isDefault: false });
      }
      categoriesMap[name] = cat._id;
    }
    
    let salaryCat = await Category.findOne({ name: "Salary", type: "income", $or: [{ user: user._id }, { isDefault: true }] });
    if (!salaryCat) {
      salaryCat = await Category.create({ name: "Salary", type: "income", user: user._id, isDefault: false });
    }

    // Seed 5 months of transactions
    const now = new Date();
    const transactions = [];
    
    for (let i = 0; i <= 5; i++) {
      const targetMonthDate = new Date(now.getFullYear(), now.getMonth() - i, 15);
      
      // 1 Income (Salary)
      transactions.push({
        user: user._id,
        account: account._id,
        type: "income",
        amount: Math.floor(Math.random() * 50000) + 100000, // 1L to 1.5L
        currency: "INR",
        description: "Monthly Salary",
        category: salaryCat._id,
        aiCategory: "salary",
        transactionDate: new Date(targetMonthDate.getFullYear(), targetMonthDate.getMonth(), 1),
        status: "posted"
      });

      // 50-100 Expenses
      const numExpenses = Math.floor(Math.random() * 51) + 50; // 50 to 100
      for (let j = 0; j < numExpenses; j++) {
        const catName = expenseCats[Math.floor(Math.random() * expenseCats.length)];
        const day = Math.floor(Math.random() * 28) + 1;
        const txnDate = new Date(targetMonthDate.getFullYear(), targetMonthDate.getMonth(), day);
        
        transactions.push({
          user: user._id,
          account: account._id,
          type: "expense",
          amount: Math.floor(Math.random() * 4900) + 100, // 100 to 5000
          currency: "INR",
          description: `${catName} Expense ${j}`,
          category: categoriesMap[catName],
          aiCategory: catName.toLowerCase(),
          transactionDate: txnDate,
          status: "posted"
        });
      }
    }
    
    // Clear old transactions for this user so we don't blow up DB if run repeatedly
    await Transaction.deleteMany({ user: user._id });
    await Transaction.insertMany(transactions);
    console.log(`💸 Inserted ${transactions.length} transactions across 6 months.`);

    // Budgets
    await Budget.deleteMany({ user: user._id });
    const budgets = [];
    for (let i = 0; i < 3; i++) {
      budgets.push({
        user: user._id,
        category: categoriesMap[expenseCats[i]],
        amount: 20000,
        spent: Math.floor(Math.random() * 19000),
        period: "monthly",
        startDate: new Date(now.getFullYear(), now.getMonth(), 1)
      });
    }
    await Budget.insertMany(budgets);
    console.log(`📊 Inserted ${budgets.length} budgets.`);

    // Goals
    await SavingsGoal.deleteMany({ user: user._id });
    await SavingsGoal.insertMany([
      {
        user: user._id,
        name: "New Car",
        targetAmount: 500000,
        currentAmount: 150000,
        targetDate: new Date(now.getFullYear() + 1, now.getMonth(), 1),
        status: "active"
      },
      {
        user: user._id,
        name: "Emergency Fund",
        targetAmount: 1000000,
        currentAmount: 400000,
        targetDate: new Date(now.getFullYear() + 2, now.getMonth(), 1),
        status: "active"
      }
    ]);
    console.log(`🎯 Inserted 2 savings goals.`);

    // Notifications
    await Notification.deleteMany({ user: user._id });
    const notifications = [
      {
        user: user._id,
        type: "budget_alert",
        title: "Food Budget Almost Exhausted",
        message: "You have used 85% of your Food & Drinks budget this month.",
        isRead: false
      },
      {
        user: user._id,
        type: "ai_insight",
        title: "Spending Spike Detected",
        message: "Your shopping expenses are 30% higher than last month.",
        isRead: false
      },
      {
        user: user._id,
        type: "goal_update",
        title: "Goal Progress",
        message: "You reached 30% of your New Car goal!",
        isRead: true
      }
    ];
    await Notification.insertMany(notifications);
    console.log(`🔔 Inserted 3 notifications.`);

    console.log("✅ Seed completed successfully!");
    process.exit(0);

  } catch (error) {
    console.error("❌ Seeding failed:", error);
    process.exit(1);
  }
};

seedData();
