import mongoose from "mongoose";

const { Schema } = mongoose;

const CATEGORY_TYPES = ["income", "expense"];

const categorySchema = new Schema(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      default: null,
      index: true,
    },

    name: {
      type: String,
      required: [true, "Category name is required"],
      trim: true,
      maxlength: [80, "Category name cannot exceed 80 characters"],
    },

    normalizedName: {
      type: String,
      trim: true,
      lowercase: true,
    },

    type: {
      type: String,
      enum: CATEGORY_TYPES,
      required: [true, "Category type is required"],
    },

    icon: {
      type: String,
      trim: true,
      default: "📦",
    },

    color: {
      type: String,
      trim: true,
      default: "#64748B",
      match: [/^#([0-9a-f]{3}|[0-9a-f]{6})$/i, "Invalid hex color"],
    },

    isDefault: {
      type: Boolean,
      default: false,
    },

    isActive: {
      type: Boolean,
      default: true,
    },

    sortOrder: {
      type: Number,
      default: 0,
      min: 0,
    },
  },
  {
    timestamps: true,
  }
);

categorySchema.pre("validate", function (next) {
  if (this.name) {
    this.normalizedName = this.name.trim().toLowerCase();
  }

  if (this.isDefault) {
    this.user = null;
  }

  next();
});


categorySchema.index({ user: 1, type: 1, isActive: 1 });

// Prevent duplicate user-created category names
categorySchema.index(
  { user: 1, normalizedName: 1, type: 1 },
  {
    unique: true,
    partialFilterExpression: { user: { $type: "objectId" } },
  }
);

// Prevent duplicate default category names
categorySchema.index(
  { isDefault: 1, normalizedName: 1, type: 1 },
  {
    unique: true,
    partialFilterExpression: { isDefault: true },
  }
);
categorySchema.index({ isDefault: 1, type: 1, sortOrder: 1 });


const Category = mongoose.model("Category", categorySchema);

export default Category;
