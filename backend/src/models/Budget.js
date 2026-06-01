import mongoose from "mongoose";

const { Schema } = mongoose;

const BUDGET_PERIODS = ["daily", "weekly", "monthly", "yearly"];

const budgetSchema = new Schema(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [true, "User is required"],
      index: true,
    },

    category: {
      type: Schema.Types.ObjectId,
      ref: "Category",
      required: [true, "Category is required"],
      index: true,
    },

    amount: {
      type: Number,
      required: [true, "Budget amount is required"],
      min: [0.01, "Budget amount must be greater than 0"],
    },

    currency: {
      type: String,
      trim: true,
      uppercase: true,
      default: "INR",
      minlength: 3,
      maxlength: 3,
    },

    period: {
      type: String,
      enum: BUDGET_PERIODS,
      default: "monthly",
    },

    alertThreshold: {
      type: Number,
      default: 80,
      min: 0,
      max: 100,
    },

    spent: {
      type: Number,
      default: 0,
      min: 0,
    },

    alertSent: {
      type: Boolean,
      default: false,
    },

    isActive: {
      type: Boolean,
      default: true,
    },

    startDate: {
      type: Date,
      required: [true, "Start date is required"],
    },

    endDate: {
      type: Date,
      default: null,
    },

    aiSuggestedAmount: {
      type: Number,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

budgetSchema.index({ user: 1, category: 1, period: 1 });
budgetSchema.index({ user: 1, isActive: 1 });
budgetSchema.index({ user: 1, startDate: -1 });


const Budget = mongoose.model("Budget", budgetSchema);

export default Budget;
