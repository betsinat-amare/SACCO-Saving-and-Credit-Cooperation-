const express = require("express");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const cors = require("cors");
const errorHandler = require("./middleware/errormiddleware");

dotenv.config();
const app = express();

app.use(cors());
app.use(express.json());

// Routes
app.use("/api/auth", require("./src/routes/authRoutes"));
app.use("/api/savings", require("./src/routes/savingRoutes"));
app.use("/api/credits", require("./src/routes/creditRoutes"));
app.use("/api/payments", require("./src/routes/paymentRoutes"));
app.use("/api/dashboard", require("./src/routes/dashboardRoutes"));

// Error handler
app.use(errorHandler);

// Connect to MongoDB and start server
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log("MongoDB connected");
    app.listen(process.env.PORT || 5000, () => {
      console.log("Server running on port " + (process.env.PORT || 5000));
    });
  })
  .catch(err => console.error(err));
