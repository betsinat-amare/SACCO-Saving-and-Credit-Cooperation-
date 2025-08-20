const User = require("../models/user");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

// User registration
exports.register = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;

    const hashed = await bcrypt.hash(password, 10);
    const user = await User.create({ name, email, password: hashed });

    res.json({ message: "User registered, waiting for admin approval", userId: user._id });
  } catch (err) {
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

    if (!user.approved) return res.status(403).json({ message: "Account not approved yet" });

    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: "7d" });
    res.json({ token, user });
  } catch (err) {
    next(err);
  }
};

// Admin approves or updates a user's status
exports.updateUserStatus = async (req, res, next) => {
  try {
    const { userId, approved } = req.body; // admin sends userId and approved status
    const user = await User.findByIdAndUpdate(userId, { approved }, { new: true });

    if (!user) return res.status(404).json({ message: "User not found" });

    res.json({ message: "User status updated", user });
  } catch (err) {
    next(err);
  }
};
