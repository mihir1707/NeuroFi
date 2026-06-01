import mongoose from "mongoose";

const { Schema } = mongoose;

const receiptSchema = new Schema(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [true, "User is required"],
      index: true,
    },

    transaction: {
      type: Schema.Types.ObjectId,
      ref: "Transaction",
      default: null,
    },

    imageUrl: {
      type: String,
      required: [true, "Image URL is required"],
      trim: true,
    },

    imageKey: {
      type: String,
      trim: true,
      default: "",
    },

    provider: {
      type: String,
      enum: ["cloudinary", "s3", "local"],
      default: "cloudinary",
    },

    fileName: {
      type: String,
      trim: true,
      default: "",
    },

    fileSize: {
      type: Number,
      default: 0,
    },

    mimeType: {
      type: String,
      trim: true,
      default: "image/jpeg",
    },

    extractedData: {
      merchantName: { type: String, default: "" },

      totalAmount: { type: Number, default: null },

      receiptDate: { type: Date, default: null },

      suggestedCategory: { type: String, default: "" },

      rawText: { type: String, default: "" },
    },

    ocrProcessed: {
      type: Boolean,
      default: false,
    },

    notes: {
      type: String,
      trim: true,
      maxlength: 500,
      default: "",
    },
  },
  {
    timestamps: true,
  }
);

receiptSchema.index({ user: 1, createdAt: -1 });
receiptSchema.index({ transaction: 1 });
receiptSchema.index({ user: 1, ocrProcessed: 1 });


const Receipt = mongoose.model("Receipt", receiptSchema);

export default Receipt;