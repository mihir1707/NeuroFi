import Notification from "../models/Notification.js";
import { sendSuccess, sendError, sendPaginated } from "../utils/response.util.js";
import { parsePagination, buildPagination } from "../utils/paginate.util.js";

export const getNotifications = async (req, res) => {
  const { page, limit, skip } = parsePagination(req.query);

  const filter = { user: req.user._id };

  if (req.query.isRead !== undefined) filter.isRead = req.query.isRead === "true";
  if (req.query.type) filter.type = req.query.type;

  const [notifications, total, unreadCount] = await Promise.all([
    Notification.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .lean(),
    Notification.countDocuments(filter),
    Notification.countDocuments({ user: req.user._id, isRead: false }),
  ]);

  return sendPaginated(
    res,
    200,
    "Notifications retrieved",
    notifications,
    {
      ...buildPagination({ page, limit, total }),
      unreadCount,
    }
  );
};

export const markAllAsRead = async (req, res) => {
  const result = await Notification.updateMany(
    { user: req.user._id, isRead: false },
    { $set: { isRead: true, readAt: new Date() } }
  );

  return sendSuccess(res, 200, `Marked ${result.modifiedCount} notification(s) as read`);
};

export const markAsRead = async (req, res) => {
  const notification = await Notification.findOneAndUpdate(
    { _id: req.params.notificationId, user: req.user._id },
    { $set: { isRead: true, readAt: new Date() } },
    { new: true }
  );

  if (!notification) {
    return sendError(res, 404, "Notification not found");
  }

  return sendSuccess(res, 200, "Notification marked as read", notification);
};


export const deleteNotification = async (req, res) => {
  const notification = await Notification.findOneAndDelete({
    _id: req.params.notificationId,
    user: req.user._id,
  });

  if (!notification) {
    return sendError(res, 404, "Notification not found");
  }

  return sendSuccess(res, 200, "Notification deleted");
};