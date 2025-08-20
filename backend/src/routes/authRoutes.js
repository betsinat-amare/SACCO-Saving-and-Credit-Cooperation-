const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");

// User registration
router.post("/register", authController.register);

// User login
router.post("/login", authController.login);

// Admin approves a new user
router.put("/status", authController.updateUserStatus);

module.exports = router;
