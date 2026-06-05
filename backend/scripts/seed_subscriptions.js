import mongoose from 'mongoose';
import dotenv from 'dotenv';
import User from './src/models/User.js';
import Account from './src/models/Account.js';
import Transaction from './src/models/Transaction.js';

dotenv.config();

mongoose.connect(process.env.MONGO_URI, { dbName: 'neurofi' })
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error(err));

async function seed() {
  const user = await User.findOne();
  if (!user) {
    console.log('No users found in database');
    process.exit(1);
  }

  const account = await Account.findOne({ user: user._id });
  if (!account) {
    console.log('No accounts found for user');
    process.exit(1);
  }
  
  const subscriptions = [
    { name: 'Netflix Subscription', amount: 15.99 },
    { name: 'Spotify Premium', amount: 9.99 },
    { name: 'Apple Music', amount: 10.99 }, // Duplicate streaming
    { name: 'Planet Fitness Gym', amount: 20.00 }, // Gym membership (Zombie risk)
    { name: 'Amazon Prime', amount: 14.99 },
    { name: 'Adobe Creative Cloud', amount: 54.99 } // High value SaaS
  ];

  const now = new Date();
  const txnsToInsert = [];

  for (const sub of subscriptions) {
    for (let i = 1; i <= 4; i++) {
      const date = new Date(now);
      date.setDate(date.getDate() - (i * 30) + Math.floor(Math.random() * 3)); // roughly 30 days apart

      txnsToInsert.push({
        user: user._id,
        account: account._id,
        type: 'expense',
        amount: sub.amount,
        description: sub.name,
        category: null,
        transactionDate: date,
        status: 'posted'
      });
    }
  }

  await Transaction.insertMany(txnsToInsert);
  console.log(`Seeded ${txnsToInsert.length} subscription transactions for user ${user.email}!`);
  process.exit(0);
}

seed();
