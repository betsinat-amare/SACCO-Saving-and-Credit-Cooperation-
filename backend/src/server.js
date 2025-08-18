const express = require("express");
const mongoose = require("mongoose");
const bodyParser = require("body-parser");
const routes = require("./routes");

const app = express();
app.use(bodyParser.json());

// DB connect
mongoose.connect("mongodb://127.0.0.1:27017/sacco", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});
mongoose.connection.once("open", () => {
  console.log("✅ MongoDB connected");
});

// Routes
app.use("/api", routes);

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
