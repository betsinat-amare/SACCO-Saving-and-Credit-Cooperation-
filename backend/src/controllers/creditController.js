const Credit = require("../models/Credit");
const Saving = require("../models/Saving");

exports.requestCredit = async (req, res) => {
  try {
    const { userId, amount } = req.body;
    console.log(`Credit request - User ID: ${userId}, Amount: ${amount}`);

    // Fetch only approved savings (case-insensitive)
    const savings = await Saving.find({
      userId,
      status: { $regex: /^approved$/i },
    });

    console.log("DEBUG savings records:", savings);

    const totalSavings = savings.reduce((sum, s) => sum + (s.amount || 0), 0);
    const maxAllowed = totalSavings * 2;

    console.log(
      `Credit validation - Total Savings: ${totalSavings}, Max Allowed: ${maxAllowed}`
    );

    if (amount > maxAllowed) {
      return res.status(400).json({
        error: `Credit request denied. Max allowed is ${maxAllowed}`,
      });
    }

    const credit = new Credit({
      userId,
      amount,
      status: "pending",
      date: new Date(),
      remainingDebt: amount,
    });
    await credit.save();

    res.json({ message: "Credit request submitted", credit });
  } catch (err) {
    console.error("Error requesting credit:", err);
    res.status(500).json({ error: "Internal server error" });
  }
};

// Admin approves/rejects credit
exports.updateCreditStatus = async (req, res) => {
  try {
    const { creditId, status } = req.body;
    const credit = await Credit.findByIdAndUpdate(
      creditId,
      { status: status.toLowerCase() },
      { new: true }
    );
    res.json({ message: "Credit status updated", credit });
  } catch (err) {
    console.error("Error updating credit:", err);
    res.status(500).json({ error: "Internal server error" });
  }
};
