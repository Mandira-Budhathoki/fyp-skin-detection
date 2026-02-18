const Appointment = require('../models/Appointment');
const Dermatologist = require('../models/Dermatologist');

// ------------------------------------------------------------------
// Get All Doctors
// ------------------------------------------------------------------
exports.getDermatologists = async (req, res) => {
    try {
        const doctors = await Dermatologist.find({}).sort({ name: 1 });
        res.status(200).json(doctors);
    } catch (error) {
        res.status(500).json({ success: false, message: "Error fetching doctors", error: error.message });
    }
};

// ------------------------------------------------------------------
// Get Available Slots for Doctor on Specific Date
// ------------------------------------------------------------------
exports.getAvailableSlots = async (req, res) => {
    const { doctorId } = req.params;
    const { date } = req.query; // Expecting "YYYY-MM-DD"

    try {
        const doctor = await Dermatologist.findById(doctorId);
        if (!doctor) {
            return res.status(404).json({ success: false, message: "Doctor not found" });
        }

        // 1. Get day of week from date (Timezone-safe parsing)
        const [year, month, day] = date.split('-').map(Number);
        const dateObj = new Date(year, month - 1, day);
        const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        const dayName = days[dateObj.getDay()];

        // 2. Find doctor's availability for that day
        const dayAvailability = doctor.availability.find(a => a.day === dayName);
        if (!dayAvailability) {
            return res.status(200).json({ success: true, availableSlots: [] });
        }

        const allSlots = dayAvailability.timeSlots;

        // 3. Find booked appointments for that doctor on that date
        // Exclude rejected and cancelled appointments
        const bookedAppointments = await Appointment.find({
            dermatologistId: doctorId,
            date: date,
            status: { $in: ['pending', 'approved'] }
        }).select('time');

        const bookedSlots = bookedAppointments.map(a => a.time);

        // 4. Calculate available slots
        const availableSlots = allSlots.filter(slot => !bookedSlots.includes(slot));

        res.status(200).json({ success: true, availableSlots });

    } catch (error) {
        res.status(500).json({ success: false, message: "Error fetching slots", error: error.message });
    }
};

// ------------------------------------------------------------------
// Book Appointment
// ------------------------------------------------------------------
exports.bookAppointment = async (req, res) => {
    const { dermatologistId, date, time, notes } = req.body;
    const userId = req.user.id;

    try {
        // 1. Conflict Check (Double Booking Prevention)
        const existingAppointment = await Appointment.findOne({
            dermatologistId,
            date,
            time,
            status: { $in: ['pending', 'approved'] }
        });

        if (existingAppointment) {
            return res.status(409).json({ success: false, message: "This slot is already booked" });
        }

        // 2. Create Appointment
        const newAppointment = new Appointment({
            userId,
            dermatologistId,
            date,
            time,
            notes,
            status: 'pending'
        });

        await newAppointment.save();
        res.status(201).json({ success: true, message: "Appointment request submitted. Waiting for admin approval.", appointment: newAppointment });

    } catch (error) {
        res.status(500).json({ success: false, message: "Booking failed", error: error.message });
    }
};

// ------------------------------------------------------------------
// Get User Appointments (Patient/User View)
// ------------------------------------------------------------------
exports.getUserAppointments = async (req, res) => {
    const userId = req.user.id;
    try {
        const appointments = await Appointment.find({ userId })
            .populate('dermatologistId', 'name specialization imageUrl')
            .sort({ date: 1, time: 1 });
        res.status(200).json({ success: true, appointments });
    } catch (error) {
        res.status(500).json({ success: false, message: "Error fetching appointments", error: error.message });
    }
};

// ------------------------------------------------------------------
// Cancel Appointment (2-hour "Real Life" Rule)
// ------------------------------------------------------------------
exports.cancelAppointment = async (req, res) => {
    const { id } = req.params;
    const userId = req.user.id;

    try {
        const appointment = await Appointment.findById(id);
        if (!appointment) {
            return res.status(404).json({ success: false, message: "Appointment not found" });
        }

        // Check ownership
        if (appointment.userId.toString() !== userId) {
            return res.status(403).json({ success: false, message: "Unauthorized action" });
        }

        // Check 2-hour notice rule
        const [hour, minute] = appointment.time.split(':');
        const appointmentDateTime = new Date(appointment.date);
        appointmentDateTime.setHours(parseInt(hour), parseInt(minute), 0, 0);

        const currentTime = new Date();
        const diffInMs = appointmentDateTime.getTime() - currentTime.getTime();
        const diffInHours = diffInMs / (1000 * 60 * 60);

        if (diffInHours < 2) {
            return res.status(400).json({
                success: false,
                message: "Cannot cancel. Appointments must be cancelled at least 2 hours before the scheduled time."
            });
        }

        appointment.status = 'cancelled';
        await appointment.save();

        res.status(200).json({ success: true, message: "Appointment cancelled successfully" });

    } catch (error) {
        res.status(500).json({ success: false, message: "Cancellation failed", error: error.message });
    }
};

// ------------------------------------------------------------------
// ADMIN: Get Pending Appointments
// ------------------------------------------------------------------
exports.getPendingAppointments = async (req, res) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ success: false, message: "Admin access required" });
    }

    try {
        const appointments = await Appointment.find({ status: 'pending' })
            .populate('userId', 'name email')
            .populate('dermatologistId', 'name specialization')
            .sort({ date: 1, time: 1 });
        res.status(200).json({ success: true, appointments });
    } catch (error) {
        res.status(500).json({ success: false, message: "Error fetching pending appointments", error: error.message });
    }
};

// ------------------------------------------------------------------
// ADMIN: Update Appointment Status (Approve/Reject)
// ------------------------------------------------------------------
exports.updateAppointmentStatus = async (req, res) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ success: false, message: "Admin access required" });
    }

    const { id } = req.params;
    const { status } = req.body; // 'approved' or 'rejected'

    if (!['approved', 'rejected'].includes(status)) {
        return res.status(400).json({ success: false, message: "Invalid status" });
    }

    try {
        const appointment = await Appointment.findById(id);
        if (!appointment) {
            return res.status(404).json({ success: false, message: "Appointment not found" });
        }

        appointment.status = status;
        await appointment.save();

        res.status(200).json({ success: true, message: `Appointment ${status} successfully` });
    } catch (error) {
        res.status(500).json({ success: false, message: "Status update failed", error: error.message });
    }
};

// ------------------------------------------------------------------
// Seed Doctors (8 Representative Doctors)
// ------------------------------------------------------------------
exports.seedDermatologists = async (req, res) => {
    try {
        await Dermatologist.deleteMany({});

        const doctors = [
            {
                name: "Dr. Sameer Bashyal",
                specialization: "Dermatologist",
                qualification: "MD (Dermatology)",
                experience: 12,
                about: "Expert in clinical dermatology and skin cancer detection.",
                hourlyRate: 2000,
                imageUrl: "https://t4.ftcdn.net/jpg/02/60/04/09/360_F_260040900_oO6YW1sHTnKxby4GcjCvtypUCWjnXVg5.jpg",
                availability: [
                    { day: "Monday", timeSlots: ["09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "15:00", "15:30", "16:00", "16:30"] },
                    { day: "Tuesday", timeSlots: ["09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "15:00", "15:30", "16:00"] },
                    { day: "Wednesday", timeSlots: ["10:00", "11:00", "14:00", "15:00", "16:00", "17:00"] },
                    { day: "Thursday", timeSlots: ["09:00", "10:00", "11:00", "12:00"] },
                    { day: "Friday", timeSlots: ["09:00", "10:00", "11:00", "15:00", "16:00"] }
                ]
            },
            {
                name: "Dr. Mandira Budhathoki",
                specialization: "Dermatologist",
                qualification: "MBBS, MD",
                experience: 8,
                about: "Specialized in acne, psoriasis, and pediatric dermatology.",
                hourlyRate: 1800,
                imageUrl: "https://t3.ftcdn.net/jpg/02/95/51/80/360_F_295518040_vpFSSkt9aX6kQkX7p3j0y6f8z4f7c5hM.jpg",
                availability: [
                    { day: "Monday", timeSlots: ["10:00", "11:00", "12:00", "14:00", "15:00"] },
                    { day: "Tuesday", timeSlots: ["10:00", "11:00", "12:00"] },
                    { day: "Wednesday", timeSlots: ["10:00", "11:00", "12:00"] },
                    { day: "Thursday", timeSlots: ["10:00", "11:00", "12:00", "14:00", "15:00", "16:00"] },
                    { day: "Friday", timeSlots: ["09:00", "10:00", "11:00", "12:00"] }
                ]
            },
            {
                name: "Dr. Anju Thapa",
                specialization: "Cosmetologist",
                qualification: "Diploma in Cosmetology",
                experience: 6,
                about: "Focused on aesthetic treatments and chemical peels.",
                hourlyRate: 1500,
                imageUrl: "https://via.placeholder.com/150",
                availability: [
                    { day: "Monday", timeSlots: ["13:00", "14:00", "15:00", "16:00"] },
                    { day: "Tuesday", timeSlots: ["13:00", "14:00", "15:00", "16:00"] },
                    { day: "Wednesday", timeSlots: ["13:00", "14:00", "15:00", "16:00"] },
                    { day: "Thursday", timeSlots: ["13:00", "14:00", "15:00", "16:00"] },
                    { day: "Friday", timeSlots: ["13:00", "14:00", "15:00", "16:00"] }
                ]
            },
            {
                name: "Dr. Ramesh Koirala",
                specialization: "Skin Surgeon",
                qualification: "MS (Surgery)",
                experience: 15,
                about: "Expert in mole removal and skin grafts.",
                hourlyRate: 3000,
                imageUrl: "https://via.placeholder.com/150",
                availability: [
                    { day: "Monday", timeSlots: ["08:00", "09:00", "10:00"] },
                    { day: "Wednesday", timeSlots: ["08:00", "09:00", "10:00"] },
                    { day: "Friday", timeSlots: ["08:00", "09:00", "10:00"] }
                ]
            },
            {
                name: "Dr. Binita Sharma",
                specialization: "Pediatric Dermatologist",
                qualification: "MD (Pediatrics & Dermatology)",
                experience: 10,
                about: "Dedicated to skin health for children and infants.",
                hourlyRate: 1900,
                imageUrl: "https://via.placeholder.com/150",
                availability: [
                    { day: "Monday", timeSlots: ["09:00", "10:00", "11:00"] },
                    { day: "Tuesday", timeSlots: ["09:00", "10:00", "11:00"] },
                    { day: "Thursday", timeSlots: ["09:00", "10:00", "11:00"] },
                    { day: "Friday", timeSlots: ["09:00", "10:00", "11:00"] },
                    { day: "Saturday", timeSlots: ["10:00", "11:00", "12:00"] }
                ]
            },
            {
                name: "Dr. Sunil Pathak",
                specialization: "Hair Specialist",
                qualification: "MD, Trichologist",
                experience: 7,
                about: "Specialist in hair loss and scalp treatments.",
                hourlyRate: 2200,
                imageUrl: "https://via.placeholder.com/150",
                availability: [
                    { day: "Tuesday", timeSlots: ["16:00", "17:00", "18:00"] },
                    { day: "Wednesday", timeSlots: ["16:00", "17:00", "18:00"] },
                    { day: "Thursday", timeSlots: ["16:00", "17:00", "18:00"] },
                    { day: "Sunday", timeSlots: ["10:00", "11:00", "12:00"] }
                ]
            },
            {
                name: "Dr. Priyanka Gupta",
                specialization: "Laser Specialist",
                qualification: "MD",
                experience: 5,
                about: "Focused on laser hair removal and skin rejuvenation.",
                hourlyRate: 2500,
                imageUrl: "https://via.placeholder.com/150",
                availability: [
                    { day: "Wednesday", timeSlots: ["15:00", "16:00", "17:00"] },
                    { day: "Thursday", timeSlots: ["15:00", "16:00", "17:00"] },
                    { day: "Friday", timeSlots: ["15:00", "16:00", "17:00"] },
                    { day: "Saturday", timeSlots: ["09:00", "10:00", "11:00"] }
                ]
            },
            {
                name: "Dr. Arjun Raut",
                specialization: "General Dermatologist",
                qualification: "MD",
                experience: 9,
                about: "General skin consultations and routine checkups.",
                hourlyRate: 1700,
                imageUrl: "https://via.placeholder.com/150",
                availability: [
                    { day: "Monday", timeSlots: ["12:00", "13:00", "14:00", "15:00"] },
                    { day: "Tuesday", timeSlots: ["12:00", "13:00", "14:00", "15:00"] },
                    { day: "Wednesday", timeSlots: ["09:00", "10:00", "11:00", "12:00"] },
                    { day: "Thursday", timeSlots: ["09:00", "10:00", "11:00", "12:00"] },
                    { day: "Friday", timeSlots: ["09:00", "10:00", "11:00", "12:00"] }
                ]
            }
        ];

        await Dermatologist.insertMany(doctors);
        res.status(201).json({ success: true, message: "8 Doctors seeded successfully" });

    } catch (error) {
        res.status(500).json({ success: false, message: "Seeding failed", error: error.message });
    }
};
