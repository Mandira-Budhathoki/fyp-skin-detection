import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'doctor_bio_screen.dart';

class AppointmentScreen extends StatefulWidget {
  final dynamic initialDoctor;
  const AppointmentScreen({super.key, this.initialDoctor});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  bool _isLoading = true;
  bool _isSlotsLoading = false;
  List<dynamic> _doctors = [];
  dynamic _selectedDoctor;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  List<String> _availableSlots = [];
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  static const Color background = Color(0xFFF6F4E8); // Cream
  static const Color accent     = Color(0xFF008080); // Teal (Primary Action)
  static const Color secondary  = Color(0xFFC0E1D2); // Seafoam (Badges)
  static const Color warning    = Color(0xFFE2A96F); 
  
  static const Color textDark   = Color(0xFF2D3436);
  static const Color textGray   = Color(0xFF636E72);

  Future<void> _fetchDoctors() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    if (token != null) {
      final data = await ApiService.getDoctors(token);
      setState(() {
        _doctors = data;
        _isLoading = false;
        
        if (_doctors.isNotEmpty) {
          // If initialDoctor was passed, try to find it in the list (matching by _id)
          if (widget.initialDoctor != null) {
            _selectedDoctor = _doctors.firstWhere(
              (d) => d['_id'] == widget.initialDoctor['_id'],
              orElse: () => _doctors[0],
            );
          } else {
            _selectedDoctor = _doctors[0];
          }
          _fetchAvailableSlots();
        }
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAvailableSlots() async {
    if (_selectedDoctor == null) return;
    setState(() => _isSlotsLoading = true);
    final prefs   = await SharedPreferences.getInstance();
    final token   = prefs.getString('userToken');
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    if (token != null) {
      List<String> rawSlots = await ApiService.getAvailableSlots(token, _selectedDoctor['_id'], dateStr);
      
      // Filter out past slots if selected date is today
      final now = DateTime.now();
      final isToday = DateFormat('yyyy-MM-dd').format(now) == dateStr;
      
      if (isToday) {
        rawSlots = rawSlots.where((slot) {
          try {
            // "10:00 AM - 12:00 PM" -> split to get start time "10:00 AM"
            final startTimeStr = slot.split("-")[0].trim();
            final f = DateFormat("yyyy-MM-dd hh:mm a");
            final slotTime = f.parse("${dateStr} ${startTimeStr}");
            return slotTime.isAfter(now);
          } catch(e) {
            return true; 
          }
        }).toList();
      }

      setState(() {
        _availableSlots = rawSlots;
        _isSlotsLoading = false;
        if (_selectedTime != null && !_availableSlots.contains(_selectedTime)) {
          _selectedTime = null;
        }
      });
    } else {
      setState(() => _isSlotsLoading = false);
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedDoctor == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a doctor and a time slot first"), backgroundColor: Colors.orange),
      );
      return;
    }
    final phone = _phoneController.text.trim();
    final name  = _nameController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in your name and phone number"), backgroundColor: Colors.orange),
      );
      return;
    }
    if (!RegExp(r'^[9][6-8][0-9]{8}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 10-digit Nepali phone number"), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _isLoading = true);
    final prefs   = await SharedPreferences.getInstance();
    final token   = prefs.getString('userToken');
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    if (token != null) {
      final result = await ApiService.bookAppointment(
        token: token,
        dermatologistId: _selectedDoctor['_id'],
        date: dateStr,
        time: _selectedTime!,
        notes: _notesController.text,
        patientName: name,
        phoneNumber: phone,
      );
      setState(() => _isLoading = false);
      if (!mounted) return;
      if (result['success'] == true) {
        _showSuccessDialog(result['message']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Booking Failed'), backgroundColor: Colors.red),
        );
      }
    }
  }

  bool _isAvailableOnDate(dynamic doctor, DateTime date) {
    final dayName = DateFormat('EEEE').format(date);
    final List<dynamic> avail = doctor['availability'] ?? [];
    return avail.any((a) => a['day'] == dayName);
  }

  String _getDoctorDaysSummary(dynamic doctor) {
    final List<dynamic> avail = doctor['availability'] ?? [];
    if (avail.isEmpty) return "Consultancy";
    // Get unique days and map them to first 3 letters
    final dayNames = avail.map((a) => a['day'].toString().substring(0, 3)).toSet().toList();
    return dayNames.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    final keyboardH = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Book Appointment',
            style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8)],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),

      // ── Sticky bottom button ──
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, -4))],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: accent.withValues(alpha: 0.3),
            ),
            onPressed: _bookAppointment,
            child: const Text("Book Appointment Now",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.4)),
          ),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accent))
          : Stack(
              children: [
                Positioned(top: -60, right: -60, child: _decorCircle(secondary.withValues(alpha: 0.15), 220)),
                Positioned(bottom: 60, left: -70, child: _decorCircle(accent.withValues(alpha: 0.12), 240)),

                SingleChildScrollView(
                  padding: EdgeInsets.only(top: 20, bottom: keyboardH + 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 1. Select Available Specialist (Back at Top) ──
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text("Select Specialist",
                            style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 280,
                        child: _doctors.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_off_rounded, color: textGray.withOpacity(0.3), size: 40),
                                  const SizedBox(height: 8),
                                  const Text("No specialists available currently.", 
                                    style: TextStyle(color: textGray, fontStyle: FontStyle.italic, fontSize: 12)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _doctors.length,
                              itemBuilder: (context, index) {
                                // Sorting logic: Show doctors available on selected date first
                                final sortedDocs = [..._doctors];
                                sortedDocs.sort((a, b) {
                                  bool aAvail = _isAvailableOnDate(a, _selectedDate);
                                  bool bAvail = _isAvailableOnDate(b, _selectedDate);
                                  if (aAvail && !bAvail) return -1;
                                  if (!aAvail && bAvail) return 1;
                                  return 0;
                                });

                                final doc        = sortedDocs[index];
                                final isSelected = _selectedDoctor != null && _selectedDoctor['_id'] == doc['_id'];
                                final isAvailableToday = _isAvailableOnDate(doc, _selectedDate);
                                
                                final String docImage = doc['imageUrl'] ?? 'assets/images/logo.png';
                                final String name = doc['name']?.startsWith('Dr.') == true ? doc['name'] : 'Dr. ${doc['name']}';

                                return GestureDetector(
                                  onTap: () {
                                    setState(() { _selectedDoctor = doc; _selectedTime = null; });
                                    _fetchAvailableSlots();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    width: 175,
                                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(color: isSelected ? accent : Colors.black.withValues(alpha: 0.04), width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected ? accent.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04),
                                          blurRadius: 20, offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        // Fixed image size container
                                        Container(
                                          height: 140, // Uniform height
                                          width: double.infinity,
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(22),
                                            color: background,
                                          ),
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(22),
                                                child: Image.asset(docImage, 
                                                  height: 140, width: double.infinity,
                                                  fit: BoxFit.cover, alignment: Alignment.topCenter,
                                                  errorBuilder: (ctx, e, s) => Center(child: Icon(Icons.person, color: textGray.withOpacity(0.3)))),
                                              ),
                                              Positioned(
                                                top: 10, right: 10,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: isAvailableToday ? secondary : Colors.grey.withValues(alpha: 0.5), 
                                                    borderRadius: BorderRadius.circular(10)
                                                  ),
                                                  child: Text(_getDoctorDaysSummary(doc), 
                                                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                                ),
                                              ),
                                              if (isSelected)
                                                const Positioned(
                                                  bottom: 8, right: 8,
                                                  child: CircleAvatar(radius: 12, backgroundColor: accent, child: Icon(Icons.check, size: 14, color: Colors.white)),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                                          child: Column(
                                            children: [
                                              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: textDark)),
                                              const SizedBox(height: 1),
                                              Text(doc['specialization'].toString().toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: isAvailableToday ? accent : textGray, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                                              const SizedBox(height: 8),
                                              // Restoration of Bio Button
                                              InkWell(
                                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => DoctorBioScreen(doctor: doc))),
                                                child: Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: secondary.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(color: secondary.withValues(alpha: 0.1)),
                                                  ),
                                                  child: const Center(
                                                    child: Text("VIEW BIO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: textDark, letterSpacing: 0.5)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                      ),

                      const SizedBox(height: 28),

                      // ── 2. Select Date (Moved Below Doctor List) ──
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text("Select Date",
                            style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                              builder: (ctx, child) => Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(
                                      primary: accent, onPrimary: Colors.white,
                                      surface: Colors.white, onSurface: textDark),
                                  dialogBackgroundColor: Colors.white,
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setState(() { 
                                _selectedDate = picked; 
                                _selectedTime = null; 
                                // We NO LONGER filter out doctors from list, 
                                // so _selectedDoctor can remain even if they don't work today.
                                // We just show 'NOT TODAY' on their badge.
                              });
                              _fetchAvailableSlots();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black.withOpacity(0.06)),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textDark)),
                                const Icon(Icons.calendar_month_rounded, color: accent),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── 3. Time Slots ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             const Text("Time Slot",
                                style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                            if (_isSlotsLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: accent)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _availableSlots.isEmpty && !_isSlotsLoading
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white, 
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.event_busy_rounded, color: textGray.withOpacity(0.3), size: 32),
                                    const SizedBox(height: 8),
                                    const Text("No slots available for this selection.", 
                                      style: TextStyle(color: textGray, fontSize: 13, fontStyle: FontStyle.italic)),
                                  ],
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: Wrap(
                                  spacing: 12, // Horizontal space between slots
                                  runSpacing: 12, // Vertical space if they wrap to 2nd row
                                  alignment: WrapAlignment.start,
                                  children: _availableSlots.map((time) {
                                    final isSel = _selectedTime == time;
                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedTime = time),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: isSel ? accent : Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: isSel ? accent : Colors.black.withValues(alpha: 0.05)),
                                          boxShadow: isSel ? [BoxShadow(color: accent.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))] : [],
                                        ),
                                        // Ensure the time fits well
                                        child: Text(time, 
                                          style: TextStyle(
                                            color: isSel ? Colors.white : textDark, 
                                            fontWeight: FontWeight.w800, 
                                            fontSize: 12,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),

                      const SizedBox(height: 26),

                      // ── 4. Your Details ──
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text("Your Details",
                            style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildField(_nameController, "Full Name", Icons.person_outline_rounded),
                            const SizedBox(height: 14),
                            _buildField(_phoneController, "Phone Number", Icons.phone_android_rounded, isPhone: true),
                            const SizedBox(height: 14),
                            _buildField(_notesController, "Notes (Optional)", Icons.chat_bubble_outline_rounded, maxLines: 2),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _decorCircle(Color c, double size) =>
      Container(width: size, height: size, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon,
      {bool isPhone = false, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(fontWeight: FontWeight.w500, color: textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textGray),
        prefixIcon: Icon(icon, color: accent, size: 22),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withOpacity(0.07))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withOpacity(0.07))),
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: accent, width: 1.5)),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Success",
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (ctx, anim, _, __) => Transform.scale(
        scale: Curves.easeOutBack.transform(anim.value),
        child: Opacity(
          opacity: anim.value.clamp(0.0, 1.0),
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: secondary.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (c, v, ch) => Transform.rotate(angle: v * 6.28, child: ch),
                    child: const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 64),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Booked!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark)),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.center,
                    style: const TextStyle(color: textGray, fontSize: 15, height: 1.5)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                    child: const Text("Awesome!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}