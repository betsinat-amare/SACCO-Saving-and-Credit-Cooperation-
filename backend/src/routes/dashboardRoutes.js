const express = require("express");
const router = express.Router();
const dashboardController = require("../controllers/dashboardController");

router.get("/:userId", dashboardController.getUserDashboard);
router.get("/stats", dashboardController.getCooperativeStats);

module.exports = router;
