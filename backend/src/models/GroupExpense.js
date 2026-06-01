import mongoose from "mongoose";

const { Schema } = mongoose;

const participantSchema = new Schema(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    shareAmount: {
      type: Number,
      required: true,
      min: 0,
    },

    paidAmount: {
      type: Number,
      default: 0,
      min: 0,
    },

    owesAmount: {
      type: Number,
      default: 0,
      min: 0,
    },

    status: {
      type: String,
      enum: ["pending", "settled"],
      default: "pending",
    },
  },
  { _id: true }
);

const groupExpenseSchema = new Schema(
  {
    group: {
      type: Schema.Types.ObjectId,
      ref: "Group",
      required: [true, "Group is required"],
      index: true,
    },

    paidBy: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [true, "Paid by is required"],
    },

    description: {
      type: String,
      trim: true,
      maxlength: 255,
      required: [true, "Description is required"],
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

    category: {
      type: String,
      trim: true,
      default: "other",
    },

    participants: [participantSchema],

    attachments: {
      type: [String],
      default: [],
    },

    splitType: {
      type: String,
      enum: ["equal", "custom", "percentage"],
      default: "equal",
    },

    expenseDate: {
      type: Date,
      default: Date.now,
    },

    isSettled: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

groupExpenseSchema.index({ group: 1, expenseDate: -1 });
groupExpenseSchema.index({ group: 1, paidBy: 1 });
groupExpenseSchema.index({ group: 1, "participants.user": 1 });
groupExpenseSchema.index({ group: 1, isSettled: 1 });


const GroupExpense = mongoose.model("GroupExpense", groupExpenseSchema);

export default GroupExpense;
