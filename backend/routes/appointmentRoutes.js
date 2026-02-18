const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const {
    getDermatologists,
    getAvailableSlots,
    bookAppointment,
    getUserAppointments,
    cancelAppointment,
    getPendingAppointments,
    updateAppointmentStatus,
    seedDermatologists
} = require('../controllers/appointmentController');

// ------------------------------------------------------------------
// Public/Shared Routes
// ------------------------------------------------------------------

// Get all doctors
router.get('/doctors', authMiddleware, getDermatologists);

// Get available slots for a doctor on a specific date
router.get('/doctors/:doctorId/slots', authMiddleware, getAvailableSlots);

// ------------------------------------------------------------------
// User (Patient) Routes
// ------------------------------------------------------------------

// Book an appointment
router.post('/book', authMiddleware, bookAppointment);

// Get my appointments
router.get('/my', authMiddleware, getUserAppointments);

// Cancel an appointment
router.delete('/:id', authMiddleware, cancelAppointment);

// ------------------------------------------------------------------
// Admin Routes
// ------------------------------------------------------------------

// Get all pending appointments
router.get('/admin/pending', authMiddleware, getPendingAppointments);

// Approve or reject an appointment
router.put('/admin/status/:id', authMiddleware, updateAppointmentStatus);

// ------------------------------------------------------------------
// Utility Routes
// ------------------------------------------------------------------

// Seed Data
router.post('/seed', seedDermatologists);

module.exports = router;
