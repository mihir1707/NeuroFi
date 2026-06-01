import express from "express";
import {
  getGroups,
  createGroup,
  getGroup,
  updateGroup,
  deleteGroup,
  addMember,
  removeMember,
  createGroupExpense,
  getGroupExpenses,
  getGroupBalances,
} from "../controllers/group.controller.js";
import { authMiddleware } from "../middleware/auth.middleware.js";
import { asyncHandler } from "../middleware/errorHandler.middleware.js";

const router = express.Router();

router.use(authMiddleware);

router.get("/", asyncHandler(getGroups));
router.post("/", asyncHandler(createGroup));
router.get("/:groupId", asyncHandler(getGroup));
router.patch("/:groupId", asyncHandler(updateGroup));
router.delete("/:groupId", asyncHandler(deleteGroup));

router.post("/:groupId/members", asyncHandler(addMember));
router.delete("/:groupId/members/:memberId", asyncHandler(removeMember));

router.get("/:groupId/expenses", asyncHandler(getGroupExpenses));
router.post("/:groupId/expenses", asyncHandler(createGroupExpense));

router.get("/:groupId/balances", asyncHandler(getGroupBalances));

export default router;