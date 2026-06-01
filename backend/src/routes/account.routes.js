import express from "express";
import {
  getAccounts,
  createAccount,
  getAccount,
  updateAccount,
  deleteAccount,
} from "../controllers/account.controller.js";
import { authMiddleware } from "../middleware/auth.middleware.js";
import { asyncHandler } from "../middleware/errorHandler.middleware.js";

const router = express.Router();

router.use(authMiddleware);

router.get("/", asyncHandler(getAccounts));
router.post("/", asyncHandler(createAccount));
router.get("/:accountId", asyncHandler(getAccount));
router.patch("/:accountId", asyncHandler(updateAccount));
router.delete("/:accountId", asyncHandler(deleteAccount));

export default router;
