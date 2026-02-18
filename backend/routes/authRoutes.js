const express = require('express');
const router = express.Router();

const {
  registerUser,
  registerAdmin,
  loginUser,
  forgotPassword,
  resetPassword
} = require('../controllers/authController');

// Routes
router.post('/register', registerUser);
router.post('/register-admin', registerAdmin);
router.post('/login', loginUser);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);

module.exports = router;
