const mongoose = require("mongoose");

const SavingSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  amount: { type: Number, required: true },
  status: { type: String, default: "pending" }, // pending, approved, rejected
  date: { type: Date, default: Date.now },
});

module.exports = mongoose.model("Saving", SavingSchema);
