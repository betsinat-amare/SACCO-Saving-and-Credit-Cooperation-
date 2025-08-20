const express = require("express");
const router = express.Router();
const creditController = require("../controllers/creditController");

// Request new credit
router.post("/", creditController.requestCredit);

// Approve/Reject credit (Admin)
router.put("/status", creditController.updateCreditStatus);

module.exports = router;
