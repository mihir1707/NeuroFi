import mongoose from "mongoose";

const { Schema } = mongoose;

const GOAL_STATUS = ["active", "completed", "cancelled", "paused"];

const savingsGoalSchema = new Schema(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [true, "User is required"],
      index: true,
    },

    name: {
      type: String,
      required: [true, "Goal name is required"],
      trim: true,
      maxlength: [100, "Goal name cannot exceed 100 characters"],
    },

    description: {
      type: String,
      trim: true,
      maxlength: 500,
      default: "",
    },

    targetAmount: {
      type: Number,
      required: [true, "Target amount is required"],
      min: [0.01, "Target amount must be greater than 0"],
    },

    currentAmount: {
      type: Number,
      default: 0,
      min: 0,
    },

    currency: {
      type: String,
      trim: true,
      uppercase: true,
      default: "INR",
      minlength: 3,
      maxlength: 3,
    },

    targetDate: {
      type: Date,
      required: [true, "Target date is required"],
    },

    status: {
      type: String,
      enum: GOAL_STATUS,
      default: "active",
    },

    completedAt: {
      type: Date,
      default: null,
    },

    icon: {
      type: String,
      default: "🎯",
    },

    color: {
      type: String,
      default: "#3B82F6",
      match: [/^#([0-9a-f]{3}|[0-9a-f]{6})$/i, "Invalid hex color"],
    },

    aiMonthlySuggestion: {
      type: Number,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);


savingsGoalSchema.virtual("progressPercent").get(function () {
  if (!this.targetAmount || this.targetAmount === 0) return 0;
  return Math.min(100, ((this.currentAmount / this.targetAmount) * 100).toFixed(1));
});

savingsGoalSchema.virtual("remainingAmount").get(function () {
  return Math.max(0, this.targetAmount - this.currentAmount);
});


savingsGoalSchema.index({ user: 1, status: 1 });
savingsGoalSchema.index({ user: 1, targetDate: 1 });
savingsGoalSchema.index({ user: 1, createdAt: -1 });


const SavingsGoal = mongoose.model("SavingsGoal", savingsGoalSchema);

export default SavingsGoal;