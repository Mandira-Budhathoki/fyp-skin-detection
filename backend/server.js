const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const authRoutes = require('./routes/authRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

/* =======================
   MIDDLEWARE
======================= */

// Enable CORS
app.use(
  cors({
    origin: "*", // Later you can restrict to frontend URL
    credentials: true,
  })
);

// Parse JSON
app.use(express.json());

/* =======================
   ROUTES
======================= */

// Health Check Route
app.get('/', (req, res) => {
  res.send('Skin App Backend Running 🚀');
});

// Auth Routes
app.use('/api/auth', authRoutes);
app.use('/api/appointments', require('./routes/appointmentRoutes'));

/* =======================
   DATABASE CONNECTION
======================= */

// ✅ Updated for Mongoose 7+ (removed unsupported options)
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log(' MongoDB Connected Successfully');
  })
  .catch((err) => {
    console.error(' MongoDB Connection Error:', err.message);
    process.exit(1);
  });

/* =======================
   START SERVER
======================= */

app.listen(PORT, '0.0.0.0', () => {
  console.log(` Server running on http://0.0.0.0:${PORT}`);
});
