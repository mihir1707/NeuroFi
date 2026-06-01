import mongoose from "mongoose";

const { Schema } = mongoose;

const TRANSACTION_TYPES = ["income", "expense", "transfer"];

const TRANSACTION_STATUS = ["pending", "posted", "cancelled"];

const RECURRENCE_INTERVALS = ["daily", "weekly", "monthly", "yearly"];

const transactionSchema = new Schema(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [true, "User is required"],
      index: true,
    },

    account: {
      type: Schema.Types.ObjectId,
      ref: "Account",
      required: [true, "Account is required"],
      index: true,
    },

    transferToAccount: {
      type: Schema.Types.ObjectId,
      ref: "Account",
      default: null,
    },

    type: {
      type: String,
      enum: TRANSACTION_TYPES,
      required: [true, "Transaction type is required"],
    },

    amount: {
      type: Number,
      required: [true, "Amount is required"],
      min: [0.01, "Amount must be greater than 0"],
    },

    currency: {
      type: String,
      trim: true,
      uppercase: true,
      default: "INR",
      minlength: 3,
      maxlength: 3,
    },

    description: {
      type: String,
      trim: true,
      maxlength: 255,
      default: "",
    },

    notes: {
      type: String,
      trim: true,
      maxlength: 2000,
      default: "",
    },

    category: {
      type: Schema.Types.ObjectId,
      ref: "Category",
      default: null,
      index: true,
    },

    aiCategory: {
      type: String,
      default: "",
    },

    aiCategoryConfirmed: {
      type: Boolean,
      default: false,
    },

    tags: {
      type: [String],
      default: [],
    },

    status: {
      type: String,
      enum: TRANSACTION_STATUS,
      default: "posted",
    },

    transactionDate: {
      type: Date,
      required: [true, "Transaction date is required"],
      default: Date.now,
      index: true,
    },

    receipt: {
      type: Schema.Types.ObjectId,
      ref: "Receipt",
      default: null,
    },

    isRecurring: {
      type: Boolean,
      default: false,
    },

    recurrenceInterval: {
      type: String,
      enum: RECURRENCE_INTERVALS,
      default: null,
    },

    nextRecurrenceDate: {
      type: Date,
      default: null,
    },

    parentRecurringId: {
      type: Schema.Types.ObjectId,
      ref: "Transaction",
      default: null,
    },

    groupExpense: {
      type: Schema.Types.ObjectId,
      ref: "GroupExpense",
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

transactionSchema.index({ user: 1, transactionDate: -1 });
transactionSchema.index({ user: 1, account: 1, transactionDate: -1 });
transactionSchema.index({ user: 1, category: 1, transactionDate: -1 });
transactionSchema.index({ user: 1, type: 1, transactionDate: -1 });
transactionSchema.index({ user: 1, isRecurring: 1, nextRecurrenceDate: 1 });


const Transaction = mongoose.model("Transaction", transactionSchema);

export default Transaction;