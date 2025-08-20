const express = require("express");
const router = express.Router();
const paymentController = require("../controllers/paymentController");

// Make a payment
router.post("/", paymentController.makePayment);

// Approve/Reject payment (Admin)
router.put("/status", paymentController.updatePaymentStatus);

module.exports = router;
