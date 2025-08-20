const Payment = require("../models/payment");
const Credit = require("../models/credits");

exports.makePayment = async (req, res) => {
  try {
    const { userId, amount } = req.body;
    const payment = new Payment({ userId, amount, status: "pending" });
    await payment.save();
    res.json({ message: "Payment submitted", payment });
  } catch (err) {
    console.error("Error making payment:", err);
    res.status(500).json({ error: "Internal server error" });
  }
};

// Admin approves payment -> reduces credit debt
exports.updatePaymentStatus = async (req, res) => {
  try {
    const { paymentId, status } = req.body;

    const payment = await Payment.findById(paymentId);
    if (!payment) return res.status(404).json({ error: "Payment not found" });

    payment.status = status.toLowerCase();
    await payment.save();

    // If approved, reduce the user's oldest debt
    if (payment.status === "approved") {
      const credit = await Credit.findOne({
        userId: payment.userId,
        status: { $regex: /^approved$/i },
        remainingDebt: { $gt: 0 },
      }).sort({ date: 1 }); // oldest credit first

      if (credit) {
        credit.remainingDebt = Math.max(0, credit.remainingDebt - payment.amount);
        await credit.save();
      }
    }

    res.json({ message: "Payment status updated", payment });
  } catch (err) {
    console.error("Error updating payment:", err);
    res.status(500).json({ error: "Internal server error" });
  }
};
