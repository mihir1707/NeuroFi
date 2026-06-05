import mongoose from 'mongoose';
import dotenv from 'dotenv';
import bcrypt from 'bcryptjs';
import User from './src/models/User.js';
import Account from './src/models/Account.js';
import Transaction from './src/models/Transaction.js';
import Notification from './src/models/Notification.js';

dotenv.config();

mongoose.connect(process.env.MONGO_URI, { dbName: 'neurofi' })
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error(err));

async function seed() {
  await User.deleteMany({});
  await Account.deleteMany({});
  await Transaction.deleteMany({});
  await Notification.deleteMany({});

  console.log('Cleared existing database.');

  // Create test user
  const user = new User({
    name: 'Test User',
    email: 'testuser@example.com',
    password: 'Password123!',
    currency: 'USD',
    monthlyBudget: 2000,
  });
  await user.save();

  // Create account
  const account = new Account({
    user: user._id,
    name: 'Main Checking',
    type: 'bank',
    balance: 5000,
    currency: 'USD'
  });
  await account.save();

  // Generate 5 months of data
  const txnsToInsert = [];
  const now = new Date();

  const merchants = [
    { name: 'Starbucks', type: 'expense', amountRange: [4, 15] },
    { name: 'Uber', type: 'expense', amountRange: [12, 45] },
    { name: 'Whole Foods', type: 'expense', amountRange: [60, 200] },
    { name: 'Amazon', type: 'expense', amountRange: [20, 150] },
    { name: 'Salary', type: 'income', amountRange: [3000, 3000] },
  ];

  for (let m = 0; m < 5; m++) {
    const numTxns = Math.floor(Math.random() * 51) + 50; // 50 to 100 txns
    for (let i = 0; i < numTxns; i++) {
      const merchant = merchants[Math.floor(Math.random() * merchants.length)];
      const amount = (Math.random() * (merchant.amountRange[1] - merchant.amountRange[0])) + merchant.amountRange[0];
      
      const date = new Date(now);
      date.setMonth(date.getMonth() - m);
      date.setDate(Math.floor(Math.random() * 28) + 1);

      txnsToInsert.push({
        user: user._id,
        account: account._id,
        type: merchant.type,
        amount: amount,
        description: merchant.name,
        transactionDate: date,
        status: 'posted'
      });
    }
  }

  // Add subscriptions
  const subscriptions = [
    { name: 'Netflix', amount: 15.99 },
    { name: 'Spotify', amount: 9.99 },
    { name: 'Planet Fitness', amount: 20.00 }
  ];

  for (const sub of subscriptions) {
    for (let m = 0; m < 5; m++) {
      const date = new Date(now);
      date.setMonth(date.getMonth() - m);
      date.setDate(5);
      txnsToInsert.push({
        user: user._id,
        account: account._id,
        type: 'expense',
        amount: sub.amount,
        description: sub.name,
        transactionDate: date,
        status: 'posted'
      });
    }
  }

  await Transaction.insertMany(txnsToInsert);
  
  // Add Notifications
  await Notification.insertMany([
    { user: user._id, title: 'Welcome!', message: 'Welcome to Neurofi.', type: 'system', isRead: false },
    { user: user._id, title: 'Budget Alert', message: 'You are close to your limit.', type: 'budget_alert', isRead: false }
  ]);

  console.log(`Successfully seeded user testuser@example.com with password Password123!`);
  console.log(`Generated ${txnsToInsert.length} transactions over 5 months.`);
  process.exit(0);
}

seed();
