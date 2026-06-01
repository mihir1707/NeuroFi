import express from "express";
import {
  getCategories,
  createCategory,
  updateCategory,
  deleteCategory,
} from "../controllers/category.controller.js";
import { authMiddleware } from "../middleware/auth.middleware.js";
import { asyncHandler } from "../middleware/errorHandler.middleware.js";

const router = express.Router();

router.use(authMiddleware);

router.get("/", asyncHandler(getCategories));
router.post("/", asyncHandler(createCategory));
router.patch("/:categoryId", asyncHandler(updateCategory));
router.delete("/:categoryId", asyncHandler(deleteCategory));

export default router;
