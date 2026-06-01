import Joi from "joi";
import Group from "../models/Group.js";
import GroupExpense from "../models/GroupExpense.js";
import { sendSuccess, sendError, sendPaginated } from "../utils/response.util.js";
import { parsePagination, buildPagination } from "../utils/paginate.util.js";
import { sendGroupExpenseNotification } from "../services/notification.service.js";


const createGroupSchema = Joi.object({
  name: Joi.string().trim().max(100).required(),
  description: Joi.string().trim().max(500).optional().allow(""),
  currency: Joi.string().length(3).uppercase().default("INR"),
  icon: Joi.string().optional().allow(""),
  color: Joi.string().pattern(/^#([0-9a-f]{3}|[0-9a-f]{6})$/i).optional(),
});

const addMemberSchema = Joi.object({
  userId: Joi.string().hex().length(24).required(),
  role: Joi.string().valid("admin", "member").default("member"),
});

const createExpenseSchema = Joi.object({
  description: Joi.string().trim().max(255).required(),
  amount: Joi.number().positive().required(),
  currency: Joi.string().length(3).uppercase().optional(),
  category: Joi.string().trim().optional().allow(""),
  splitType: Joi.string().valid("equal", "custom", "percentage").default("equal"),
  participants: Joi.array()
    .items(
      Joi.object({
        user: Joi.string().hex().length(24).required(),
        shareAmount: Joi.number().min(0).required(),
      })
    )
    .optional(),
  expenseDate: Joi.date().optional(),
});

export const getGroups = async (req, res) => {
  const { page, limit, skip } = parsePagination(req.query);

  const filter = { "members.user": req.user._id };
  if (req.query.isActive !== undefined) filter.isActive = req.query.isActive !== "false";

  const [groups, total] = await Promise.all([
    Group.find(filter)
      .populate("members.user", "name email profileImage")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .lean(),
    Group.countDocuments(filter),
  ]);

  return sendPaginated(res, 200, "Groups retrieved", groups, buildPagination({ page, limit, total }));
};

export const createGroup = async (req, res) => {
  const { error, value } = createGroupSchema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const group = await Group.create({
    ...value,
    icon: value.icon || "👥",
    color: value.color || "#10B981",
    members: [{ user: req.user._id, role: "admin" }],
  });

  await group.populate("members.user", "name email");

  return sendSuccess(res, 201, "Group created successfully", group);
};

export const getGroup = async (req, res) => {
  const group = await Group.findOne({
    _id: req.params.groupId,
    "members.user": req.user._id,
  }).populate("members.user", "name email profileImage");

  if (!group) {
    return sendError(res, 404, "Group not found");
  }

  return sendSuccess(res, 200, "Group retrieved", group);
};

export const updateGroup = async (req, res) => {
  const group = await Group.findOneAndUpdate(
    { _id: req.params.groupId, "members.user": req.user._id },
    { $set: req.body },
    { new: true, runValidators: true }
  ).populate("members.user", "name email");

  if (!group) {
    return sendError(res, 404, "Group not found");
  }

  return sendSuccess(res, 200, "Group updated successfully", group);
};

export const addMember = async (req, res) => {
  const { error, value } = addMemberSchema.validate(req.body, { abortEarly: false });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const group = await Group.findOne({
    _id: req.params.groupId,
    "members.user": req.user._id,
  });

  if (!group) {
    return sendError(res, 404, "Group not found");
  }

  const isAlreadyMember = group.members.some((m) => String(m.user) === value.userId);
  if (isAlreadyMember) {
    return sendError(res, 409, "This user is already a member of the group");
  }

  group.members.push({ user: value.userId, role: value.role || "member" });
  await group.save();
  await group.populate("members.user", "name email");

  return sendSuccess(res, 200, "Member added to group successfully", group);
};

export const removeMember = async (req, res) => {
  const group = await Group.findOne({
    _id: req.params.groupId,
    "members.user": req.user._id,
  });

  if (!group) {
    return sendError(res, 404, "Group not found");
  }

  const admins = group.members.filter((m) => m.role === "admin");
  const isRemovingAdmin = group.members.find(
    (m) => String(m.user) === req.params.memberId && m.role === "admin"
  );

  if (isRemovingAdmin && admins.length === 1) {
    return sendError(res, 400, "Cannot remove the only admin. Assign another admin first.");
  }

  group.members = group.members.filter((m) => String(m.user) !== req.params.memberId);
  await group.save();

  return sendSuccess(res, 200, "Member removed from group");
};

export const deleteGroup = async (req, res) => {
  const group = await Group.findOneAndDelete({
    _id: req.params.groupId,
    "members.user": req.user._id,
  });

  if (!group) {
    return sendError(res, 404, "Group not found");
  }

  await GroupExpense.deleteMany({ group: req.params.groupId });

  return sendSuccess(res, 200, "Group deleted successfully");
};

export const createGroupExpense = async (req, res) => {
  const { error, value } = createExpenseSchema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    return sendError(res, 400, "Validation failed", error.details.map((d) => d.message));
  }

  const group = await Group.findOne({
    _id: req.params.groupId,
    "members.user": req.user._id,
  });

  if (!group) {
    return sendError(res, 404, "Group not found");
  }

  let participants = value.participants;
  if (!participants || participants.length === 0 || value.splitType === "equal") {
    const shareAmount = value.amount / group.members.length;
    participants = group.members.map((m) => ({
      user: m.user,
      shareAmount: parseFloat(shareAmount.toFixed(2)),
      owesAmount: String(m.user) === String(req.user._id) ? 0 : parseFloat(shareAmount.toFixed(2)),
      paidAmount: String(m.user) === String(req.user._id) ? parseFloat(shareAmount.toFixed(2)) : 0,
    }));
  }

  const expense = await GroupExpense.create({
    ...value,
    group: req.params.groupId,
    paidBy: req.user._id,
    currency: value.currency || group.currency,
    participants,
    expenseDate: value.expenseDate || new Date(),
  });

  await Group.findByIdAndUpdate(req.params.groupId, { $inc: { totalExpenses: value.amount } });

  await expense.populate([
    { path: "paidBy", select: "name email" },
    { path: "participants.user", select: "name email" },
  ]);

  const otherParticipants = expense.participants.filter(
    (p) => String(p.user._id || p.user) !== String(req.user._id)
  );

  Promise.all(
    otherParticipants.map((p) =>
      sendGroupExpenseNotification(expense, p.user._id || p.user, req.user.name)
    )
  ).catch((err) => console.warn("[Group Expense] Notification error:", err.message));

  return sendSuccess(res, 201, "Group expense added", expense);
};

export const getGroupExpenses = async (req, res) => {
  const { page, limit, skip } = parsePagination(req.query);

  const [expenses, total] = await Promise.all([
    GroupExpense.find({ group: req.params.groupId })
      .populate("paidBy", "name email")
      .populate("participants.user", "name email")
      .sort({ expenseDate: -1 })
      .skip(skip)
      .limit(limit)
      .lean(),
    GroupExpense.countDocuments({ group: req.params.groupId }),
  ]);

  return sendPaginated(res, 200, "Group expenses retrieved", expenses, buildPagination({ page, limit, total }));
};

export const getGroupBalances = async (req, res) => {
  const expenses = await GroupExpense.find({
    group: req.params.groupId,
    isSettled: false,
  })
    .populate("paidBy", "name email")
    .populate("participants.user", "name email")
    .lean();

  const balances = {};

  expenses.forEach((expense) => {
    expense.participants.forEach((participant) => {
      const userId = String(participant.user._id || participant.user);
      const payerId = String(expense.paidBy._id || expense.paidBy);

      if (!balances[userId]) balances[userId] = { userId, name: participant.user.name, balance: 0 };
      if (!balances[payerId]) balances[payerId] = { userId: payerId, name: expense.paidBy.name, balance: 0 };

      if (userId !== payerId) {
        balances[userId].balance -= participant.owesAmount;
        balances[payerId].balance += participant.owesAmount;
      }
    });
  });

  return sendSuccess(res, 200, "Group balances calculated", {
    balances: Object.values(balances),
    totalExpenses: expenses.reduce((sum, e) => sum + e.amount, 0),
    unsettledCount: expenses.length,
  });
};