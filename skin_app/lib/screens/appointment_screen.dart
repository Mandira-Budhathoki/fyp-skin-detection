import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

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

  String _getAvailabilitySummary(dynamic doctor) {
    if (doctor == null || doctor['availability'] == null) return "N/A";
    List<dynamic> days = doctor['availability'];
    if (days.isEmpty) return "No schedule";
    return days.map((e) => (e['day'] as String).substring(0, 3)).join(", ");
  }

  bool _isDoctorAvailableOn(dynamic doctor, DateTime date) {
    if (doctor == null || doctor['availability'] == null) return false;
    String dayName = DateFormat('EEEE').format(date);
    List<dynamic> availability = doctor['availability'];
    return availability.any((a) => a['day'] == dayName);
  }

  Future<void> _fetchDoctors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');

    if (token != null) {
      final data = await ApiService.getDoctors(token);
      setState(() {
        _doctors = data;
        _isLoading = false;
        if (_doctors.isNotEmpty) {
           _selectedDoctor = _doctors[0]; // Auto-select first doctor
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    if (token != null) {
      final slots = await ApiService.getAvailableSlots(token, _selectedDoctor['_id'], dateStr);
      setState(() {
        _availableSlots = slots;
        _isSlotsLoading = false;
        // If currently selected time is no longer available, deselect it
        if (_selectedTime != null && !_availableSlots.contains(_selectedTime)) {
          _selectedTime = null;
        }
      });
    } else {
      setState(() => _isSlotsLoading = false);
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedDoctor == null || _selectedTime == null) return;

    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    if (token != null) {
      // Validate phone number (Nepali 10 digits)
      final phone = _phoneController.text.trim();
      final name = _nameController.text.trim();
      
      if (name.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your name"), backgroundColor: Colors.orange));
        setState(() => _isLoading = false);
        return;
      }

      if (!RegExp(r'^[9][6-8][0-9]{8}$').hasMatch(phone)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter a valid 10-digit Nepali phone number (starting 97/98)"), backgroundColor: Colors.orange));
        setState(() => _isLoading = false);
        return;
      }

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

      if (result['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(result['message'] ?? 'Request Submitted!'), backgroundColor: Colors.green)
        );
        Navigator.pop(context); // Go back
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(result['message'] ?? 'Booking Failed'), backgroundColor: Colors.red)
        );
        _fetchAvailableSlots(); // Refresh slots
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f2027),
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Doctor Selection
                  const Text("Select Doctor", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _doctors.length,
                      itemBuilder: (context, index) {
                         final doc = _doctors[index];
                         final isSelected = _selectedDoctor == doc;
                         final availableToday = _isDoctorAvailableOn(doc, _selectedDate);

                         return GestureDetector(
                           onTap: () {
                             setState(() {
                               _selectedDoctor = doc;
                               _selectedTime = null;
                             });
                             _fetchAvailableSlots();
                           },
                           child: Container(
                             width: 140,
                             margin: const EdgeInsets.only(right: 12),
                             padding: const EdgeInsets.all(12),
                             decoration: BoxDecoration(
                               color: isSelected ? Colors.tealAccent.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                               border: Border.all(color: isSelected ? Colors.tealAccent : Colors.white10),
                               borderRadius: BorderRadius.circular(20),
                               boxShadow: isSelected ? [BoxShadow(color: Colors.tealAccent.withOpacity(0.2), blurRadius: 10)] : []
                             ),
                             child: Stack(
                               children: [
                                 Column(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     CircleAvatar(
                                       radius: 30,
                                       backgroundImage: NetworkImage(doc['imageUrl'] ?? 'https://via.placeholder.com/150'),
                                     ),
                                     const SizedBox(height: 8),
                                     Text(
                                        doc['name'], 
                                        maxLines: 1, 
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)
                                     ),
                                     Text(
                                        doc['specialization'], 
                                        maxLines: 1, 
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.grey, fontSize: 10)
                                     ),
                                     const SizedBox(height: 4),
                                     Text(
                                       _getAvailabilitySummary(doc),
                                       maxLines: 1,
                                       overflow: TextOverflow.ellipsis,
                                       style: TextStyle(color: Colors.tealAccent.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.w500),
                                     )
                                   ],
                                 ),
                                 if (availableToday)
                                   Positioned(
                                     top: 0,
                                     right: 0,
                                     child: Container(
                                       padding: const EdgeInsets.all(4),
                                       decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                       child: const Icon(Icons.check, color: Colors.white, size: 10),
                                     ),
                                   )
                               ],
                             ),
                           ),
                         );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Date Selection
                  const Text("Select Date", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today, color: Colors.tealAccent),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Colors.tealAccent,
                                      onPrimary: Colors.black,
                                      surface: Color(0xFF1F2E35),
                                      onSurface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              }
                            );
                            if (picked != null && picked != _selectedDate) {
                              setState(() {
                                _selectedDate = picked;
                                _selectedTime = null;
                              });
                              _fetchAvailableSlots();
                            }
                          },
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. Time Slots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Time Slots", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      if (_isSlotsLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.tealAccent))
                    ],
                  ),
                  const SizedBox(height: 12),
                  _availableSlots.isEmpty && !_isSlotsLoading
                      ? const Text("No slots available for this day.", style: TextStyle(color: Colors.white54))
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _availableSlots.map((time) {
                             final isSelected = _selectedTime == time;
                             return GestureDetector(
                               onTap: () => setState(() => _selectedTime = time),
                               child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                 decoration: BoxDecoration(
                                   color: isSelected ? Colors.tealAccent : Colors.white.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(10),
                                 ),
                                 child: Text(
                                   time,
                                   style: TextStyle(
                                     color: isSelected ? Colors.black : Colors.white,
                                     fontWeight: FontWeight.w600,
                                   ),
                                 ),
                               ),
                             );
                          }).toList(),
                        ),

                  const SizedBox(height: 24),

                  // 4. Contact Info
                  const Text("Contact Information", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                       hintText: "Your Full Name",
                       hintStyle: const TextStyle(color: Colors.white54),
                       filled: true,
                       fillColor: Colors.white.withOpacity(0.05),
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                       prefixIcon: const Icon(Icons.person, color: Colors.tealAccent, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                       hintText: "Nepali Phone Number (e.g. 98XXXXXXXX)",
                       hintStyle: const TextStyle(color: Colors.white54),
                       filled: true,
                       fillColor: Colors.white.withOpacity(0.05),
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                       prefixIcon: const Icon(Icons.phone, color: Colors.tealAccent, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 5. Notes
                  TextField(
                    controller: _notesController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    decoration: InputDecoration(
                       hintText: "Notes for the doctor (optional)",
                       hintStyle: const TextStyle(color: Colors.white54),
                       filled: true,
                       fillColor: Colors.white.withOpacity(0.05),
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 5. Book Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: (_selectedTime == null || _isSlotsLoading) ? null : _bookAppointment,
                      child: const Text('Submit Appointment Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
