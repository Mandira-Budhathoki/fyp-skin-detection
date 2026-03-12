import 'package:flutter/material.dart';
import 'melanoma_screen.dart';
import 'wound_screen.dart';
import 'skin_screen.dart';
import 'appointment_screen.dart';
import 'my_appointments_screen.dart';
import 'scan_history_screen.dart';
import 'profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _checkNextAppointment(); // Check for upcoming appointment

    _fadeAnimation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOut);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutQuart));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animationController.forward();
    });
  }

  Map<String, dynamic>? _nextAppointment;

  Future<void> _checkNextAppointment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');

    if (token != null) {
      final appointments = await ApiService.getUserAppointments(token);
      if (appointments.isNotEmpty) {
        // Filter for upcoming
        final upcoming = appointments.where((a) => a['status'] == 'upcoming').toList();
        if (upcoming.isNotEmpty) {
           setState(() {
             _nextAppointment = upcoming[0]; // Assuming sorted by backend
           });
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Soft gray-blue background
      body: Stack(
        children: [
          // Decorative background circles
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                  color: const Color(0xFF2A9D8F).withOpacity(0.05),
                  shape: BoxShape.circle),
            ),
          ),
          Positioned(
            top: 100,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                  color: const Color(0xFF264653).withOpacity(0.05),
                  shape: BoxShape.circle),
            ),
          ),
          
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      if (_nextAppointment != null) _buildNextAppointmentCard(),
                      const SizedBox(height: 32),
                      const Text(
                        "AI Analysis Tools",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF264653),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.1,
                                children: [
                                  _buildFeatureGridItem(
                                    title: 'Book\nAppointment',
                                    icon: Icons.calendar_month_rounded,
                                    color: const Color(0xFF6A4C93),
                                    onTap: () async {
                                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentScreen()));
                                      _checkNextAppointment();
                                    },
                                  ),
                                  _buildFeatureGridItem(
                                    title: 'Melanoma\nDetection',
                                    icon: Icons.health_and_safety_rounded,
                                    color: const Color(0xFF2A9D8F),
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MelanomaScreen())),
                                  ),
                                  _buildFeatureGridItem(
                                    title: 'Wound\nAnalysis',
                                    icon: Icons.healing_rounded,
                                    color: const Color(0xFFE76F51),
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WoundScreen())),
                                  ),
                                  _buildFeatureGridItem(
                                    title: 'Skin\nHealth',
                                    icon: Icons.face_retouching_natural_rounded,
                                    color: const Color(0xFFE9C46A),
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SkinScreen())),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              _buildQuickActions(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF264653), // Dark Slate
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF264653).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medical_services_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Welcome to DermaAI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Your Personal Skin Assistant',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGridItem({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF264653),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Access",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF264653),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSmallActionCard(
                icon: Icons.history_rounded,
                label: "Visits",
                color: const Color(0xFF264653),
                onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAppointmentsScreen()));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallActionCard(
                icon: Icons.analytics_outlined,
                label: "Reports",
                color: const Color(0xFF264653),
                onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanHistoryScreen()));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallActionCard(
                icon: Icons.person_outline_rounded,
                label: "Profile",
                color: const Color(0xFF264653),
                onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallActionCard(
      {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextAppointmentCard() {
    if (_nextAppointment == null) return const SizedBox.shrink();

    final date = _nextAppointment!['date'];
    final time = _nextAppointment!['time'];
    final doctor = _nextAppointment!['dermatologistId'];
    final docName = doctor != null ? doctor['name'] : 'Doctor';

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6A4C93), Color(0xFF8D5FBF)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF6A4C93).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          const Icon(Icons.alarm, color: Colors.white, size: 30),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Upcoming Appointment", style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text("$docName", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text("$date at $time", style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }
}
