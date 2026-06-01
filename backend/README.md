# 🤖 AI-Powered Smart Finance Tracker API

A production-ready, highly modular Express backend for an AI-Powered Smart Finance Tracker mobile application. 

This backend provides a comprehensive set of RESTful APIs to manage users, accounts, transactions, budgets, savings goals, and group expense splitting, supercharged with AI capabilities for categorization, financial insights, budget prediction, and a finance chatbot.

## ✨ Features

- **🔐 Authentication:** JWT-based user registration, login, logout, and profile management.
- **💳 Multi-Wallet Accounts:** Manage multiple bank accounts, cash wallets, and credit cards with real-time balance tracking.
- **💸 Transaction Management:** Track income, expenses, and inter-account transfers. Supports recurring transactions.
- **📊 Smart Budgets:** Category-wise budget tracking with automatic spending calculation and threshold alerts.
- **🎯 Savings Goals:** Goal-oriented savings tracking with deposit management and auto-completion.
- **👥 Group Split Expenses:** Create groups, add members, and automatically split expenses (equal, percentage, or custom amounts). View settlement balances (who owes who).
- **🧾 Receipt Scanner:** Upload receipt images and automatically extract data (merchant, amount, date) using AI OCR.
- **📈 Reports & Analytics:** Generate monthly and yearly financial reports, net worth calculations, and export transactions to CSV.
- **🤖 AI Capabilities:**
  - **Categorization:** Auto-categorize transactions based on descriptions.
  - **Financial Insights:** Personalized spending analysis and actionable advice.
  - **Budget Prediction:** Smart suggestions for next month's budget based on past behavior.
  - **Finance Chatbot:** Conversational AI assistant for personalized finance queries.

## 🛠️ Technology Stack

- **Runtime:** Node.js (ES Modules)
- **Framework:** Express.js
- **Database:** MongoDB with Mongoose ODM
- **Validation:** Joi
- **Security:** bcryptjs (password hashing), jsonwebtoken (JWT), express-rate-limit, cors
- **File Uploads:** Multer (memory storage)
- **Background Jobs:** node-cron
- **AI Integration:** OpenAI API (gpt-4o-mini)

## 🚀 Getting Started

### 1. Prerequisites
- Node.js (v18 or higher recommended)
- MongoDB (running locally or via MongoDB Atlas)

### 2. Installation
```bash
# Clone the repository and navigate to the backend directory
cd backend

# Install dependencies
npm install
```

### 3. Environment Configuration
Copy the sample environment file and configure your variables:
```bash
cp .env.example .env
```
Ensure you set your `MONGO_URI`, `JWT_SECRET`, and `OPENAI_API_KEY` (if you want AI features).

### 4. Running the Server
```bash
# Development mode (auto-restarts on changes)
npm run dev

# Production mode
npm start
```
The server will start on `http://localhost:5000` (or your configured port).

## 🧪 API Testing

A complete **Postman Collection** is included in the root directory: `Smart_Finance_Tracker.postman_collection.json`.

1. Import the file into Postman.
2. The collection automatically handles authentication tokens and IDs for chained requests.
3. Start by running the **Register** or **Login** request under the `Auth` folder to set your bearer token.

## 📁 Project Structure

```text
backend/
├── jobs/               # Background cron jobs (alerts, reports, reminders)
├── src/
│   ├── config/         # Database and third-party API configurations
│   ├── controllers/    # Request handlers and business logic coordination
│   ├── middleware/     # Auth, error handling, rate limiting, logging, uploads
│   ├── models/         # Mongoose schemas and database models
│   ├── routes/         # Express API route definitions
│   ├── services/       # Core business logic and AI integrations
│   ├── utils/          # Helper functions (JWT, responses, pagination, dates)
│   └── app.js          # Express application setup
├── .env.example        # Environment variables template
├── package.json        # Dependencies and scripts
├── server.js           # Server entry point
└── Smart_Finance_Tracker.postman_collection.json
```

## ⚠️ Graceful Degradation
If third-party API keys (like OpenAI) are missing from your `.env` file, the application won't crash. It will gracefully fall back to rule-based logic or mock data so you can continue development without interruptions.
