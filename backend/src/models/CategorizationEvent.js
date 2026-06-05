import mongoose from "mongoose";

const { Schema } = mongoose;

const CATEGORIZATION_SOURCES = [
  "user_preference",
  "merchant_db",
  "ai",
  "keyword_matching",
  "default",
];

const categorizationEventSchema = new Schema(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [true, "User is required"],
      index: true,
    },
    merchantKey: {
      type: String,
      trim: true,
      lowercase: true,
      default: null,
    },
    rawDescription: {
      type: String,
      trim: true,
      maxlength: [255, "Raw description cannot exceed 255 characters"],
      default: "",
    },
    category: {
      type: String,
      required: [true, "Category is required"],
      trim: true,
      maxlength: [80, "Category cannot exceed 80 characters"],
    },
    source: {
      type: String,
      enum: CATEGORIZATION_SOURCES,
      required: [true, "Source is required"],
    },
    confidence: {
      type: Number,
      min: 0,
      max: 1,
      default: null,
    },
    responseTimeMs: {
      type: Number,
      min: 0,
      default: null,
    },
    isBatch: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: { createdAt: true, updatedAt: false },
  }
);

categorizationEventSchema.index({ user: 1, createdAt: -1 });
categorizationEventSchema.index({ user: 1, source: 1 });
categorizationEventSchema.index({ source: 1, createdAt: -1 });

// auto-delete after 90 days
categorizationEventSchema.index(
  { createdAt: 1 },
  { expireAfterSeconds: 90 * 24 * 60 * 60 }
);

const CategorizationEvent = mongoose.model("CategorizationEvent", categorizationEventSchema);

export default CategorizationEvent;
