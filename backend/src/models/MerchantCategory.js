import mongoose from "mongoose";

const { Schema } = mongoose;

const merchantCategorySchema = new Schema(
  {
    merchantName: {
      type: String,
      required: [true, "Merchant name is required"],
      trim: true,
      lowercase: true,
      maxlength: [120, "Merchant name cannot exceed 120 characters"],
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
    confidence: {
      type: Number,
      required: [true, "Confidence is required"],
      min: [0, "Confidence cannot be below 0"],
      max: [1, "Confidence cannot exceed 1"],
      default: 1.0,
    },
    source: {
      type: String,
      enum: ["manual", "ai"],
      required: [true, "Source is required"],
      default: "manual",
    },
    usageCount: {
      type: Number,
      default: 0,
      min: [0, "Usage count cannot be negative"],
    },
  },
  { timestamps: true }
);

merchantCategorySchema.index({ merchantName: 1 }, { unique: true });
merchantCategorySchema.index({ usageCount: -1 });
merchantCategorySchema.index({ source: 1 });

const MerchantCategory = mongoose.model("MerchantCategory", merchantCategorySchema);

export default MerchantCategory;
