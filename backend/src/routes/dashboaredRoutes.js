const express = require("express");
const router = express.Router();
const dashboardController = require("../controllers/dashboardController");

// Get user dashboard (savings, credits, payments summary)
router.get("/:userId", dashboardController.getUserDashboard);

module.exports = router;
