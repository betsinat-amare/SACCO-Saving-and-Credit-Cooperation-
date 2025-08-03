const express = require('express');
const { User, Savings, Credit, Payment, CooperativeStats } = require('./models');
const { signToken, hashPassword, comparePassword } = require('./auth');

const router = express.Router();

// Register new member (pending approval)
router.post('/register', async (req, res) => {
  const { name, email, password } = req.body;
  try {
    const hashed = await hashPassword(password);
    const user = new User({ name, email, password: hashed });
    await user.save();
    res.status(201).json({ user: { id: user._id, name: user.name, email: user.email, role: user.role, status: user.status } });
  } catch (err) {
    res.status(400).json({ error: 'Registration failed', details: err.message });
  }
});

// Login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) return res.status(401).json({ error: 'Invalid credentials' });
    if (user.status !== 'approved') return res.status(403).json({ error: 'Account not approved' });
    const valid = await comparePassword(password, user.password);
    if (!valid) return res.status(401).json({ error: 'Invalid credentials' });
    const token = signToken({ id: user._id, role: user.role });
    res.json({ token, user: { id: user._id, name: user.name, email: user.email, role: user.role } });
  } catch (err) {
    res.status(500).json({ error: 'Login failed', details: err.message });
  }
});

// Admin: Approve member
router.post('/admin/approve-member', async (req, res) => {
  const { userId } = req.body;
  try {
    const user = await User.findByIdAndUpdate(userId, { status: 'approved' }, { new: true });
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({ user });
  } catch (err) {
    res.status(500).json({ error: 'Approval failed', details: err.message });
  }
});

// Admin: Reject member
router.post('/admin/reject-member', async (req, res) => {
  const { userId } = req.body;
  try {
    const user = await User.findByIdAndUpdate(userId, { status: 'rejected' }, { new: true });
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({ user });
  } catch (err) {
    res.status(500).json({ error: 'Rejection failed', details: err.message });
  }
});

// Member: Add savings
router.post('/savings', async (req, res) => {
  const { userId, amount, date } = req.body;
  try {
    const savings = new Savings({ user: userId, amount, date });
    await savings.save();
    res.status(201).json({ savings });
  } catch (err) {
    res.status(400).json({ error: 'Add savings failed', details: err.message });
  }
});

// Member: Add credit with validation
router.post('/credits', async (req, res) => {
  const { userId, amount, date } = req.body;
  try {
    // Calculate member's total approved savings
    const totalSavings = await Savings.aggregate([
      { $match: { user: userId, status: 'approved' } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);
    const savingsAmount = totalSavings[0]?.total || 0;
    const maxCreditAllowed = savingsAmount * 2;

    if (amount > maxCreditAllowed) {
      return res.status(400).json({ 
        error: 'Credit amount exceeds limit', 
        details: `Maximum credit allowed is $${maxCreditAllowed} (2x your total savings of $${savingsAmount})` 
      });
    }

    const credit = new Credit({ 
      user: userId, 
      amount, 
      remaining_debt: amount, // Initially, remaining debt equals credit amount
      date 
    });
    await credit.save();
    res.status(201).json({ credit });
  } catch (err) {
    res.status(400).json({ error: 'Add credit failed', details: err.message });
  }
});

// Member: Add payment request
router.post('/payments', async (req, res) => {
  const { userId, amount, date } = req.body;
  try {
    const payment = new Payment({ user: userId, amount, date });
    await payment.save();
    res.status(201).json({ payment });
  } catch (err) {
    res.status(400).json({ error: 'Add payment failed', details: err.message });
  }
});

// Member: View own savings
router.get('/savings/:userId', async (req, res) => {
  try {
    const savings = await Savings.find({ user: req.params.userId });
    res.json({ savings });
  } catch (err) {
    res.status(500).json({ error: 'Fetch savings failed', details: err.message });
  }
});

// Member: View own credits
router.get('/credits/:userId', async (req, res) => {
  try {
    const credits = await Credit.find({ user: req.params.userId });
    res.json({ credits });
  } catch (err) {
    res.status(500).json({ error: 'Fetch credits failed', details: err.message });
  }
});

// Member: View own payments
router.get('/payments/:userId', async (req, res) => {
  try {
    const payments = await Payment.find({ user: req.params.userId });
    res.json({ payments });
  } catch (err) {
    res.status(500).json({ error: 'Fetch payments failed', details: err.message });
  }
});

// Admin: Approve savings
router.post('/admin/approve-savings', async (req, res) => {
  const { savingsId } = req.body;
  try {
    const savings = await Savings.findByIdAndUpdate(savingsId, { status: 'approved' }, { new: true });
    if (!savings) return res.status(404).json({ error: 'Savings not found' });
    res.json({ savings });
  } catch (err) {
    res.status(500).json({ error: 'Approval failed', details: err.message });
  }
});

// Admin: Reject savings
router.post('/admin/reject-savings', async (req, res) => {
  const { savingsId } = req.body;
  try {
    const savings = await Savings.findByIdAndUpdate(savingsId, { status: 'rejected' }, { new: true });
    if (!savings) return res.status(404).json({ error: 'Savings not found' });
    res.json({ savings });
  } catch (err) {
    res.status(500).json({ error: 'Rejection failed', details: err.message });
  }
});

// Admin: Approve credit
router.post('/admin/approve-credit', async (req, res) => {
  const { creditId } = req.body;
  try {
    const credit = await Credit.findByIdAndUpdate(creditId, { status: 'approved' }, { new: true });
    if (!credit) return res.status(404).json({ error: 'Credit not found' });
    res.json({ credit });
  } catch (err) {
    res.status(500).json({ error: 'Approval failed', details: err.message });
  }
});

// Admin: Reject credit
router.post('/admin/reject-credit', async (req, res) => {
  const { creditId } = req.body;
  try {
    const credit = await Credit.findByIdAndUpdate(creditId, { status: 'rejected' }, { new: true });
    if (!credit) return res.status(404).json({ error: 'Credit not found' });
    res.json({ credit });
  } catch (err) {
    res.status(500).json({ error: 'Rejection failed', details: err.message });
  }
});

// Admin: Approve payment and update remaining debt
router.post('/admin/approve-payment', async (req, res) => {
  const { paymentId } = req.body;
  try {
    const payment = await Payment.findByIdAndUpdate(paymentId, { status: 'approved' }, { new: true });
    if (!payment) return res.status(404).json({ error: 'Payment not found' });

    // Update remaining debt for all approved credits of this user
    const userCredits = await Credit.find({ user: payment.user, status: 'approved' });
    let totalPaid = 0;
    
    // Calculate total approved payments for this user
    const approvedPayments = await Payment.find({ user: payment.user, status: 'approved' });
    totalPaid = approvedPayments.reduce((sum, p) => sum + p.amount, 0);

    // Update remaining debt for each credit
    for (const credit of userCredits) {
      const originalAmount = credit.amount;
      const remainingDebt = Math.max(0, originalAmount - (totalPaid - (originalAmount - credit.remaining_debt)));
      await Credit.findByIdAndUpdate(credit._id, { remaining_debt: remainingDebt });
    }

    res.json({ payment });
  } catch (err) {
    res.status(500).json({ error: 'Payment approval failed', details: err.message });
  }
});

// Admin: Reject payment
router.post('/admin/reject-payment', async (req, res) => {
  const { paymentId } = req.body;
  try {
    const payment = await Payment.findByIdAndUpdate(paymentId, { status: 'rejected' }, { new: true });
    if (!payment) return res.status(404).json({ error: 'Payment not found' });
    res.json({ payment });
  } catch (err) {
    res.status(500).json({ error: 'Payment rejection failed', details: err.message });
  }
});

// Admin: View all savings (pending, approved, rejected)
router.get('/admin/all-savings', async (req, res) => {
  try {
    const savings = await Savings.find().populate('user', 'name email');
    res.json({ savings });
  } catch (err) {
    res.status(500).json({ error: 'Fetch failed', details: err.message });
  }
});

// Admin: View all credits (pending, approved, rejected)
router.get('/admin/all-credits', async (req, res) => {
  try {
    const credits = await Credit.find().populate('user', 'name email');
    res.json({ credits });
  } catch (err) {
    res.status(500).json({ error: 'Fetch failed', details: err.message });
  }
});

// Admin: View all payments (pending, approved, rejected)
router.get('/admin/all-payments', async (req, res) => {
  try {
    const payments = await Payment.find().populate('user', 'name email');
    res.json({ payments });
  } catch (err) {
    res.status(500).json({ error: 'Fetch failed', details: err.message });
  }
});

// Admin: View all pending savings/credits
router.get('/admin/pending-savings', async (req, res) => {
  try {
    const savings = await Savings.find({ status: 'pending' }).populate('user', 'name email');
    res.json({ savings });
  } catch (err) {
    res.status(500).json({ error: 'Fetch failed', details: err.message });
  }
});
router.get('/admin/pending-credits', async (req, res) => {
  try {
    const credits = await Credit.find({ status: 'pending' }).populate('user', 'name email');
    res.json({ credits });
  } catch (err) {
    res.status(500).json({ error: 'Fetch failed', details: err.message });
  }
});

// Admin: View all pending payments
router.get('/admin/pending-payments', async (req, res) => {
  try {
    const payments = await Payment.find({ status: 'pending' }).populate('user', 'name email');
    res.json({ payments });
  } catch (err) {
    res.status(500).json({ error: 'Fetch failed', details: err.message });
  }
});

// Admin: View all pending members
router.get('/pending-members', async (req, res) => {
  try {
    const users = await User.find({ status: 'pending' });
    res.json({ users });
  } catch (err) {
    res.status(500).json({ error: 'Fetch failed', details: err.message });
  }
});

// Admin: View all members (both pending and approved)
router.get('/all-members', async (req, res) => {
  try {
    const users = await User.find({ role: 'member' });
    res.json({ users });
  } catch (err) {
    res.status(500).json({ error: 'Fetch failed', details: err.message });
  }
});

// Stats: Get cooperative stats
router.get('/stats', async (req, res) => {
  try {
    let stats = await CooperativeStats.findOne();
    if (!stats) {
      stats = new CooperativeStats();
      await stats.save();
    }
    // Optionally, update stats with real-time values
    const total_members = await User.countDocuments({ status: 'approved' });
    const total_savings = await Savings.aggregate([
      { $match: { status: 'approved' } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);
    const total_credits = await Credit.aggregate([
      { $match: { status: 'approved' } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);
    stats.total_members = total_members;
    stats.total_savings = total_savings[0]?.total || 0;
    stats.total_credits = total_credits[0]?.total || 0;
    stats.total_capital = stats.total_savings - stats.total_credits;
    await stats.save();
    res.json({ stats });
  } catch (err) {
    res.status(500).json({ error: 'Fetch stats failed', details: err.message });
  }
});

module.exports = router; 