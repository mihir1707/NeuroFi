import mongoose from "mongoose";

const { Schema } = mongoose;

const groupMemberSchema = new Schema(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    // "admin" can manage the group; 
    // "member" can only add/view expenses
    role: {
      type: String,
      enum: ["admin", "member"],
      default: "member",
    },

    joinedAt: {
      type: Date,
      default: Date.now,
    },
  },
  { _id: false }
);

const groupSchema = new Schema(
  {
    name: {
      type: String,
      required: [true, "Group name is required"],
      trim: true,
      maxlength: [100, "Group name cannot exceed 100 characters"],
    },

    description: {
      type: String,
      trim: true,
      maxlength: 500,
      default: "",
    },

    members: [groupMemberSchema],

    currency: {
      type: String,
      trim: true,
      uppercase: true,
      default: "INR",
      minlength: 3,
      maxlength: 3,
    },

    totalExpenses: {
      type: Number,
      default: 0,
      min: 0,
    },

    icon: {
      type: String,
      default: "👥",
    },

    color: {
      type: String,
      default: "#10B981",
      match: [/^#([0-9a-f]{3}|[0-9a-f]{6})$/i, "Invalid hex color"],
    },

    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

groupSchema.index({ "members.user": 1 });
groupSchema.index({ isActive: 1 });
groupSchema.index({ createdAt: -1 });


const Group = mongoose.model("Group", groupSchema);

export default Group;
