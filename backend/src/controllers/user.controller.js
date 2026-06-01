import Joi from "joi";
import User from "../models/User.js";
import { sendSuccess, sendError } from "../utils/response.util.js";


const updateProfileSchema = Joi.object({
  name: Joi.string().trim().min(2).max(120).optional(),
  phone: Joi.string().trim().max(20).optional().allow(""),
  currency: Joi.string().length(3).uppercase().optional(),
  monthlyBudget: Joi.number().min(0).optional(),
  notificationsEnabled: Joi.boolean().optional(),
  aiInsightsEnabled: Joi.boolean().optional(),
  profileImage: Joi.string().uri().optional().allow(""),
});

const changePasswordSchema = Joi.object({
  currentPassword: Joi.string().required(),
  newPassword: Joi.string().min(6).max(128).required(),
});

export const getProfile = async (req, res) => {
  const user = await User.findById(req.user._id);

  if (!user) {
    return sendError(res, 404, "User not found");
  }

  return sendSuccess(res, 200, "Profile retrieved", user.toJSON());
};

export const updateProfile = async (req, res) => {
  const { error, value } = updateProfileSchema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const user = await User.findByIdAndUpdate(
    req.user._id,
    { $set: value },
    { new: true, runValidators: true }
  );

  if (!user) {
    return sendError(res, 404, "User not found");
  }

  return sendSuccess(res, 200, "Profile updated successfully", user.toJSON());
};

export const changePassword = async (req, res) => {
  const { error, value } = changePasswordSchema.validate(req.body, { abortEarly: false });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const user = await User.findById(req.user._id).select("+password");

  if (!user) {
    return sendError(res, 404, "User not found");
  }

  const isCurrentPasswordValid = await user.comparePassword(value.currentPassword);

  if (!isCurrentPasswordValid) {
    return sendError(res, 401, "Current password is incorrect");
  }

  const isSamePassword = await user.comparePassword(value.newPassword);
  if (isSamePassword) {
    return sendError(res, 400, "New password must be different from your current password");
  }

  user.password = value.newPassword;
  await user.save();

  return sendSuccess(res, 200, "Password changed successfully. Please log in again with your new password.");
};

export const deactivateAccount = async (req, res) => {
  await User.findByIdAndUpdate(req.user._id, { isActive: false });

  return sendSuccess(res, 200, "Account deactivated. You can reactivate by contacting support.");
};