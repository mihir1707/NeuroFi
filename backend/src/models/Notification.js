import mongoose from "mongoose";

const { Schema } = mongoose;

const NOTIFICATION_TYPES = [
  "budget_alert",      
  "bill_reminder",      
  "goal_update",        
  "group_expense",      
  "transaction_alert",  
  "ai_insight",         
  "system",             
];

const notificationSchema = new Schema(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [true, "User is required"],
      index: true,
    },

    type: {
      type: String,
      enum: NOTIFICATION_TYPES,
      required: [true, "Notification type is required"],
    },

    title: {
      type: String,
      required: [true, "Title is required"],
      trim: true,
      maxlength: 200,
    },

    message: {
      type: String,
      required: [true, "Message is required"],
      trim: true,
      maxlength: 1000,
    },

    isRead: {
      type: Boolean,
      default: false,
    },

    readAt: {
      type: Date,
      default: null,
    },

    relatedEntity: {
      type: Schema.Types.ObjectId,
      default: null,
    },

    relatedEntityType: {
      type: String,
      enum: ["transaction", "budget", "group", "goal", "receipt", null],
      default: null,
    },

    metadata: {
      type: Schema.Types.Mixed,
      default: {},
    },

    pushSent: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

notificationSchema.index({ user: 1, isRead: 1, createdAt: -1 });
notificationSchema.index({ user: 1, type: 1 });
notificationSchema.index({ createdAt: 1 }, { expireAfterSeconds: 7776000 });


const Notification = mongoose.model("Notification", notificationSchema);

export default Notification;