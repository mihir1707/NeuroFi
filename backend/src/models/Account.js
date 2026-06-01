import mongoose from "mongoose";

const { Schema } = mongoose;

const ACCOUNT_TYPES = [
  "cash",        
  "bank",        
  "credit_card", 
  "debit_card",  
  "wallet",      
  "investment",  
  "loan",        
  "other",
];

const accountSchema = new Schema(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [true, "User is required"],
      index: true,
    },

    name: {
      type: String,
      required: [true, "Account name is required"],
      trim: true,
      maxlength: [100, "Account name cannot exceed 100 characters"],
    },

    type: {
      type: String,
      enum: ACCOUNT_TYPES,
      default: "bank",
    },

    institution: {
      type: String,
      trim: true,
      maxlength: 120,
      default: "",
    },

    balance: {
      type: Number,
      required: [true, "Balance is required"],
      default: 0,
    },

    currency: {
      type: String,
      trim: true,
      uppercase: true,
      default: "INR",
      minlength: 3,
      maxlength: 3,
    },

    accountNumberLast4: {
      type: String,
      trim: true,
      default: "",
      match: [/^\d{0,4}$/, "Must be 0-4 digits"],
    },

    icon: {
      type: String,
      default: "💳",
    },

    color: {
      type: String,
      default: "#3B82F6",
      match: [/^#([0-9a-f]{3}|[0-9a-f]{6})$/i, "Invalid hex color"],
    },

    isArchived: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

accountSchema.index({ user: 1, createdAt: -1 });
accountSchema.index({ user: 1, type: 1 });
accountSchema.index({ user: 1, isArchived: 1, name: 1 });


const Account = mongoose.model("Account", accountSchema);

export default Account;
