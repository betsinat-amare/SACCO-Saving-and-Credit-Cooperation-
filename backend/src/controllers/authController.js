const User = require("../models/user");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

// User registration (new users default to pending status)
exports.register = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;

    const hashed = await bcrypt.hash(password, 10);
    const user = await User.create({
      name,
      email,
      password: hashed,
      role: "member",
      status: "pending", // 👈 new users must be approved by admin
    });

    res.json({
      message: "User registered, waiting for admin approval",
      userId: user._id,
    });
  } catch (err) {
    if (err.code === 11000 && err.keyPattern && err.keyPattern.email) {
      return res.status(400).json({ message: "Email already registered" });
    }
    next(err);
  }
};

// User login
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: "User not found" });

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(400).json({ message: "Invalid credentials" });

    if (user.status !== "approved") {
      return res.status(403).json({ message: "Account not approved yet" });
    }

    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({ token, user });
  } catch (err) {
    next(err);
  }
};

// Admin approves or rejects a user
exports.updateUserStatus = async (req, res, next) => {
  try {
    const { userId, status } = req.body; 
    // status must be either "approved" or "rejected"

    if (!["approved", "rejected"].includes(status)) {
      return res.status(400).json({ message: "Invalid status value" });
    }

    const user = await User.findByIdAndUpdate(
      userId,
      { status },
      { new: true }
    );

    if (!user) return res.status(404).json({ message: "User not found" });

    res.json({ message: `User status updated to ${status}`, user });
  } catch (err) {
    next(err);
  }
};
