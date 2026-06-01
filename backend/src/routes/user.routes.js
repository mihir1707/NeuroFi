import express from "express";
import { getProfile, updateProfile, changePassword, deactivateAccount } from "../controllers/user.controller.js";
import { authMiddleware } from "../middleware/auth.middleware.js";
import { asyncHandler } from "../middleware/errorHandler.middleware.js";

const router = express.Router();

router.use(authMiddleware);

router.get("/profile", asyncHandler(getProfile));
router.patch("/profile", asyncHandler(updateProfile));
router.patch("/change-password", asyncHandler(changePassword));
router.delete("/account", asyncHandler(deactivateAccount));

export default router;
