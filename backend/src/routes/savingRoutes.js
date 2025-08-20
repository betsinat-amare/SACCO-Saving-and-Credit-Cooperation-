const express = require("express");
const router = express.Router();
const savingController = require("../controllers/savingController");

// Add a new saving request
router.post("/", savingController.addSaving);

// Approve/Reject saving (Admin)
router.put("/status", savingController.updateSavingStatus);

module.exports = router;
