const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    dermatologistId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Dermatologist',
        required: true,
    },
    date: {
        type: String, // ISO Date String "YYYY-MM-DD" is best for matching availability
        required: true,
    },
    time: {
        type: String, // "10:00 AM"
        required: true,
    },
    status: {
        type: String,
        enum: ['pending', 'approved', 'rejected', 'cancelled'],
        default: 'pending',
    },
    notes: {
        type: String,
        default: "",
    },
}, { timestamps: true });

// Ensure unique booking per doctor per slot
// "A doctor cannot be in two places at once"
// Only block if status is NOT 'cancelled' or 'rejected'
// Note: MongoDB unique index doesn't easily support conditional uniqueness like this, 
// so we'll rely on controller logic for complex checks, but keep a general index if preferred.
// Actually, let's keep it simple for now as the controller handles the "conflict check".
// appointmentSchema.index({ dermatologistId: 1, date: 1, time: 1 }, { unique: true });

module.exports = mongoose.model('Appointment', appointmentSchema);
