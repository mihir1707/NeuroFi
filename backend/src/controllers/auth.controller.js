import Joi from "joi";
import User from "../models/User.js";
import { generateToken } from "../utils/jwt.util.js";
import { sendSuccess, sendError } from "../utils/response.util.js";
import { sendWelcomeEmail } from "../services/email.service.js";


const registerSchema = Joi.object({
  name: Joi.string().trim().min(2).max(120).required().messages({
    "string.min": "Name must be at least 2 characters",
    "any.required": "Name is required",
  }),
  email: Joi.string().trim().email().lowercase().required(),
  password: Joi.string().min(6).max(128).required().messages({
    "string.min": "Password must be at least 6 characters",
  }),
  currency: Joi.string().length(3).uppercase().default("INR"),
  phone: Joi.string().trim().max(20).optional().allow(""),
});

const loginSchema = Joi.object({
  email: Joi.string().trim().email().lowercase().required(),
  password: Joi.string().required(),
});

const changePasswordSchema = Joi.object({
  currentPassword: Joi.string().required(),
  newPassword: Joi.string().min(6).max(128).required(),
});


export const register = async (req, res) => {
  const { error, value } = registerSchema.validate(req.body, { abortEarly: false, stripUnknown: true });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const existingUser = await User.findOne({ email: value.email });

  if (existingUser) {
    return sendError(res, 409, "An account with this email already exists. Please log in.");
  }

  const user = await User.create({
    name: value.name,
    email: value.email,
    password: value.password,
    currency: value.currency || "INR",
    phone: value.phone || "",
  });

  const token = generateToken(user);

  sendWelcomeEmail(user.email, user.name).catch((err) =>
    console.warn("[Auth] Welcome email failed:", err.message)
  );

  return sendSuccess(res, 201, "Account created successfully! Welcome aboard 🎉", {
    user: user.toJSON(),
    token,
  });
};

export const login = async (req, res) => {
  const { error, value } = loginSchema.validate(req.body, { abortEarly: false });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const user = await User.findOne({ email: value.email }).select("+password");

  if (!user) {
    return sendError(res, 401, "Invalid email or password");
  }

  const isPasswordValid = await user.comparePassword(value.password);

  if (!isPasswordValid) {
    return sendError(res, 401, "Invalid email or password");
  }

  if (!user.isActive) {
    return sendError(res, 403, "Your account has been deactivated. Please contact support.");
  }

  user.lastLoginAt = new Date();
  await user.save({ validateBeforeSave: false });

  const token = generateToken(user);

  return sendSuccess(res, 200, "Login successful! Welcome back 👋", {
    user: user.toJSON(),
    token,
  });
};

export const logout = async (req, res) => {
  return sendSuccess(res, 200, "Logged out successfully. See you soon! 👋");
};

export const getMe = async (req, res) => {
  const user = await User.findById(req.user._id);

  if (!user) {
    return sendError(res, 404, "User not found");
  }

  return sendSuccess(res, 200, "Profile retrieved", user.toJSON());
};