const mongoose = require("mongoose");

const creditSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  amount: Number,
  remainingDebt: Number,
  status: { type: String, enum: ["pending", "approved", "rejected"], default: "pending" },
  date: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Credit", creditSchema);
