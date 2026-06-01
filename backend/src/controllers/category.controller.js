import Joi from "joi";
import Category from "../models/Category.js";
import { sendSuccess, sendError, sendPaginated } from "../utils/response.util.js";
import { parsePagination, buildPagination } from "../utils/paginate.util.js";


const createCategorySchema = Joi.object({
  name: Joi.string().trim().max(80).required(),
  type: Joi.string().valid("income", "expense").required(),
  icon: Joi.string().optional().allow(""),
  color: Joi.string().pattern(/^#([0-9a-f]{3}|[0-9a-f]{6})$/i).optional(),
});

const updateCategorySchema = Joi.object({
  name: Joi.string().trim().max(80).optional(),
  icon: Joi.string().optional().allow(""),
  color: Joi.string().pattern(/^#([0-9a-f]{3}|[0-9a-f]{6})$/i).optional(),
  isActive: Joi.boolean().optional(),
});

export const getCategories = async (req, res) => {
  const { page, limit, skip } = parsePagination(req.query);

  const filter = {
    $or: [{ user: req.user._id }, { isDefault: true }],
  };

  if (req.query.type) filter.type = req.query.type;
  if (req.query.isActive !== undefined) filter.isActive = req.query.isActive !== "false";

  const [categories, total] = await Promise.all([
    Category.find(filter)
      .sort({ isDefault: -1, sortOrder: 1, name: 1 })
      .skip(skip)
      .limit(limit)
      .lean(),
    Category.countDocuments(filter),
  ]); 

  return sendPaginated(res, 200, "Categories retrieved", categories, buildPagination({ page, limit, total }));
};

export const createCategory = async (req, res) => {
  const { error, value } = createCategorySchema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const existingCategory = await Category.findOne({
    user: req.user._id,
    normalizedName: value.name.trim().toLowerCase(),
    type: value.type,
  });

  if (existingCategory) {
    return sendError(res, 409, `A ${value.type} category named "${value.name}" already exists`);
  }

  const category = await Category.create({
    ...value,
    user: req.user._id,
    color: value.color || "#64748B",
    icon: value.icon || "📦",
  });

  return sendSuccess(res, 201, "Category created successfully", category);
};

export const updateCategory = async (req, res) => {
  const { error, value } = updateCategorySchema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const category = await Category.findOneAndUpdate(
    { _id: req.params.categoryId, user: req.user._id, isDefault: false },
    { $set: value },
    { new: true, runValidators: true }
  );

  if (!category) {
    return sendError(res, 404, "Category not found or cannot be modified (system defaults cannot be edited)");
  }

  return sendSuccess(res, 200, "Category updated successfully", category);
};

export const deleteCategory = async (req, res) => {
  const category = await Category.findOneAndDelete({
    _id: req.params.categoryId,
    user: req.user._id,
    isDefault: false,
  });

  if (!category) {
    return sendError(res, 404, "Category not found or cannot be deleted (system defaults cannot be deleted)");
  }

  return sendSuccess(res, 200, "Category deleted successfully");
};