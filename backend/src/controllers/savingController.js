const Saving = require("../models/savings");

// Member requests a saving
exports.addSaving = async (req, res) => {
  try {
    const { userId, amount } = req.body;
    const saving = new Saving({ userId, amount, status: "pending" });
    await saving.save();
    res.json({ message: "Saving request submitted", saving });
  } catch (err) {
    console.error("Error adding saving:", err);
    res.status(500).json({ error: "Internal server error" });
  }
};

// Admin approves/rejects a saving
exports.updateSavingStatus = async (req, res) => {
  try {
    const { savingId, status } = req.body;
    const saving = await Saving.findByIdAndUpdate(
      savingId,
      { status: status.toLowerCase() }, // normalize
      { new: true }
    );
    res.json({ message: "Saving status updated", saving });
  } catch (err) {
    console.error("Error updating saving:", err);
    res.status(500).json({ error: "Internal server error" });
  }
};
