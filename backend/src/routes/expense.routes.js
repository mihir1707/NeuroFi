import express from 'express';
const { asyncHandler } = require("../middleware/errorHandler.middleware");
const expenseController = require("../controllers/expense.controller");

const router = express.Router({ mergeParams: true });

router.post("/", asyncHandler(expenseController.createExpense));
router.get("/", asyncHandler(expenseController.getExpenses));
router.get("/:expenseId", asyncHandler(expenseController.getExpense));
router.patch("/:expenseId", asyncHandler(expenseController.updateExpense));
router.delete("/:expenseId", asyncHandler(expenseController.deleteExpense));

module.exports = router;
