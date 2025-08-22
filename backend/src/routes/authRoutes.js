const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");

// Registration & login
router.post("/register", authController.register);
router.post("/login", authController.login);

// Admin approves or updates user status
router.put("/status", authController.updateUserStatus);

module.exports = router;
