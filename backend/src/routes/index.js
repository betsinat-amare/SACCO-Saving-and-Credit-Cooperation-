const express = require("express");
const router = express.Router();

const savingController = require("../controllers/savingController");
const creditController = require("../controllers/creditController");
const paymentController = require("../controllers/paymentController");
const dashboardController = require("../controllers/dashboardController");

// Savings
router.post("/savings", savingController.addSaving);
router.put("/savings/status", savingController.updateSavingStatus);

// Credits
router.post("/credits", creditController.requestCredit);
router.put("/credits/status", creditController.updateCreditStatus);

// Payments
router.post("/payments", paymentController.makePayment);
router.put("/payments/status", paymentController.updatePaymentStatus);

// Dashboard
router.get("/dashboard/:userId", dashboardController.getUserDashboard);

module.exports = router;
