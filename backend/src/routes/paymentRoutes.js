const express = require("express");
const router = express.Router();
const paymentController = require("../controllers/paymentController");

router.post("/", paymentController.makePayment);
router.put("/status", paymentController.updatePaymentStatus);
router.get("/:userId", paymentController.getUserPayments);

module.exports = router;
