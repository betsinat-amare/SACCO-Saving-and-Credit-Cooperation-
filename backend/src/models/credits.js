const mongoose = require("mongoose");

const CreditSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  amount: { type: Number, required: true },
  status: { type: String, default: "pending" }, // pending, approved, rejected
  date: { type: Date, default: Date.now },
  remainingDebt: { type: Number, required: true },
});

module.exports = mongoose.model("Credit", CreditSchema);
