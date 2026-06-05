import mongoose from "mongoose";

const { Schema } = mongoose;

const userMerchantPreferenceSchema = new Schema(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [true, "User is required"],
      index: true,
    },
    // normalized key e.g. "swiggy", "amazon"
    merchantKey: {
      type: String,
      required: [true, "Merchant key is required"],
      trim: true,
      lowercase: true,
      maxlength: [120, "Merchant key cannot exceed 120 characters"],
    },
    category: {
      type: String,
      required: [true, "Category is required"],
      trim: true,
      maxlength: [80, "Category cannot exceed 80 characters"],
    },
    icon: {
      type: String,
      trim: true,
      default: "📦",
    },
    previousCategory: {
      type: String,
      trim: true,
      default: null,
    },
    totalCorrections: {
      type: Number,
      default: 1,
      min: [1, "Total corrections must be at least 1"],
    },
    lastCorrectedAt: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

// one preference per merchant per user
userMerchantPreferenceSchema.index({ user: 1, merchantKey: 1 }, { unique: true });
userMerchantPreferenceSchema.index({ user: 1, lastCorrectedAt: -1 });
userMerchantPreferenceSchema.index({ merchantKey: 1 });

const UserMerchantPreference = mongoose.model(
  "UserMerchantPreference",
  userMerchantPreferenceSchema
);

export default UserMerchantPreference;
