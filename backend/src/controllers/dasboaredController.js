const Saving = require("../models/savings");
const Credit = require("../models/credits");
const Payment = require("../models/payment");

exports.getUserDashboard = async (req, res) => {
  try {
    const { userId } = req.params;

    // Savings
    const savings = await Saving.find({ userId, status: { $regex: /^approved$/i } });
    const totalSavings = savings.reduce((sum, s) => sum + (s.amount || 0), 0);

    // Credits
    const credits = await Credit.find({ userId });
    const totalCredit = credits.reduce((sum, c) => sum + (c.amount || 0), 0);
    const remainingDebt = credits.reduce((sum, c) => sum + (c.remainingDebt || 0), 0);

    // Payments
    const payments = await Payment.find({ userId, status: { $regex: /^approved$/i } });
    const totalPaid = payments.reduce((sum, p) => sum + (p.amount || 0), 0);

    // Pending counts
    const pendingSavings = await Saving.countDocuments({ userId, status: "pending" });
    const pendingCredits = await Credit.countDocuments({ userId, status: "pending" });
    const pendingPayments = await Payment.countDocuments({ userId, status: "pending" });

    res.json({
      totalSavings,
      totalCredit,
      remainingDebt,
      totalPaid,
      pending: {
        savings: pendingSavings,
        credits: pendingCredits,
        payments: pendingPayments,
      },
    });
  } catch (err) {
    console.error("Error fetching dashboard:", err);
    res.status(500).json({ error: "Internal server error" });
  }
};
