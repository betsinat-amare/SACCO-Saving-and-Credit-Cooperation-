const express = require("express");
const router = express.Router();
const creditController = require("../controllers/creditController");

router.post("/", creditController.requestCredit);
router.put("/status", creditController.updateCreditStatus);
router.get("/:userId", creditController.getUserCredits);

module.exports = router;
