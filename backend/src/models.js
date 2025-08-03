const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['admin', 'member'], default: 'member' },
  status: { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' },
  created_at: { type: Date, default: Date.now },
});

const savingsSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  amount: { type: Number, required: true },
  date: { type: Date, required: true },
  status: { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' },
  created_at: { type: Date, default: Date.now },
});

const creditSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  amount: { type: Number, required: true },
  remaining_debt: { type: Number, required: true }, // Track remaining debt
  date: { type: Date, required: true },
  status: { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' },
  created_at: { type: Date, default: Date.now },
});

const paymentSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  amount: { type: Number, required: true },
  date: { type: Date, required: true },
  status: { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' },
  created_at: { type: Date, default: Date.now },
});

const statsSchema = new mongoose.Schema({
  total_capital: { type: Number, default: 0 },
  total_members: { type: Number, default: 0 },
  total_credits: { type: Number, default: 0 },
  total_savings: { type: Number, default: 0 },
  meeting_day: { type: String, default: 'Monday' },
});

const User = mongoose.model('User', userSchema);
const Savings = mongoose.model('Savings', savingsSchema);
const Credit = mongoose.model('Credit', creditSchema);
const Payment = mongoose.model('Payment', paymentSchema);
const CooperativeStats = mongoose.model('CooperativeStats', statsSchema);

module.exports = { User, Savings, Credit, Payment, CooperativeStats }; 