const express = require("express");
const router = express.Router();
const savingController = require("../controllers/savingController");

router.post("/", savingController.addSaving);
router.put("/status", savingController.updateSavingStatus);
router.get("/:userId", savingController.getUserSavings);

module.exports = router;
