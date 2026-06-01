import express from "express";
import {
  getNotifications,
  markAllAsRead,
  markAsRead,
  deleteNotification,
} from "../controllers/notification.controller.js";
import { authMiddleware } from "../middleware/auth.middleware.js";
import { asyncHandler } from "../middleware/errorHandler.middleware.js";

const router = express.Router();

router.use(authMiddleware);

router.get("/", asyncHandler(getNotifications));
router.patch("/read-all", asyncHandler(markAllAsRead));
router.patch("/:notificationId/read", asyncHandler(markAsRead));
router.delete("/:notificationId", asyncHandler(deleteNotification));

export default router;
