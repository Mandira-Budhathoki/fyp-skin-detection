const mongoose = require('mongoose');

const dermatologistSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
    },
    specialization: {
        type: String, // e.g., "Dermatologist", "Cosmetologist", "Surgeon"
        required: true,
    },
    qualification: {
        type: String, // e.g., "MBBS, MD"
        required: true,
    },
    experience: {
        type: Number, // Years of experience
        required: true,
    },
    about: {
        type: String,
        default: "Experienced specialist dedicated to skin health.",
    },
    imageUrl: {
        type: String,
        default: "https://via.placeholder.com/150",
    },
    rating: {
        type: Number,
        default: 5.0,
    },
    reviewsCount: {
        type: Number,
        default: 0,
    },
    hourlyRate: {
        type: Number,
        required: true,
    },
    // Availability: List of days with their specific time slots
    // e.g., [{ day: "Monday", timeSlots: ["10:00", "11:00"] }, { day: "Wednesday", timeSlots: ["14:00"] }]
    availability: [
        {
            day: { type: String, required: true },
            timeSlots: { type: [String], required: true }
        }
    ],
}, { timestamps: true });

module.exports = mongoose.model('Dermatologist', dermatologistSchema);
