import 'package:flutter/material.dart';
import 'melanoma_screen.dart';
import 'wound_screen.dart';
import 'skin_screen.dart';
import 'face_health_screen.dart';
import 'appointment_screen.dart';
import 'vitality_hub_screen.dart';
import 'my_appointments_screen.dart';
import 'scan_history_screen.dart';
import 'profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Map<String, dynamic>? _nextAppointment;
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animationController.forward();
    });
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');
    String? name = prefs.getString('userName');
    if (mounted) {
      setState(() {
        _userName = name ?? 'User';
      });
    }
    if (token != null) {
      final appointments = await ApiService.getUserAppointments(token);
      if (appointments.isNotEmpty) {
        final upcoming =
            appointments.where((a) => a['status'] == 'upcoming').toList();
        if (upcoming.isNotEmpty && mounted) {
          setState(() => _nextAppointment = upcoming[0]);
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER ──
                _buildHeader(),
                const SizedBox(height: 10),

                // ── APPOINTMENT PILL (only if exists) ──
                if (_nextAppointment != null) ...[
                  _buildAppointmentPill(),
                  const SizedBox(height: 10),
                ],

                // ── SECTION LABEL ──
                const Text(
                  'AI HEALTH TOOLS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: Color(0xFF4A90A4),
                  ),
                ),
                const SizedBox(height: 8),

                // ── FEATURE GRID — 3 columns ──
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.95,
                    children: [
                      _buildGridBtn(
                        icon: Icons.calendar_month_rounded,
                        label: 'Appointment',
                        color: const Color(0xFF7C5CBF),
                        onTap: () async {
                          await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AppointmentScreen()));
                          _loadUserData();
                        },
                      ),
                      _buildGridBtn(
                        icon: Icons.health_and_safety_rounded,
                        label: 'Melanoma',
                        color: const Color(0xFF2A9D8F),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const MelanomaScreen())),
                      ),
                      _buildGridBtn(
                        icon: Icons.healing_rounded,
                        label: 'Wound',
                        color: const Color(0xFFE76F51),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const WoundScreen())),
                      ),
                      _buildGridBtn(
                        icon: Icons.face_retouching_natural_rounded,
                        label: 'Skin Health',
                        color: const Color(0xFFE9C46A),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const SkinScreen())),
                      ),
                      _buildGridBtn(
                        icon: Icons.face_6_rounded,
                        label: 'Face Health',
                        color: const Color(0xFFE87EA1),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const FaceHealthScreen())),
                      ),
                      _buildGridBtn(
                        icon: Icons.auto_awesome_rounded,
                        label: 'Health Hub',
                        color: const Color(0xFF4CC9F0),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const VitalityHubScreen())),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ── QUICK ACCESS ──
                const Text(
                  'QUICK ACCESS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: Color(0xFF4A90A4),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickBtn(
                        icon: Icons.history_rounded,
                        label: 'Visits',
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const MyAppointmentsScreen())),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickBtn(
                        icon: Icons.analytics_outlined,
                        label: 'Reports',
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ScanHistoryScreen())),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickBtn(
                        icon: Icons.person_outline_rounded,
                        label: 'Profile',
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen())),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HEADER WIDGET ──
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2E3B), Color(0xFF1E3A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A4A5E), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2A9D8F).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medical_services_rounded,
                color: Color(0xFF2A9D8F), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $_userName 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Your Personal Skin AI',
                  style: TextStyle(color: Color(0xFF8AABB8), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2A9D8F).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: Color(0xFF2A9D8F), size: 20),
          ),
        ],
      ),
    );
  }

  // ── APPOINTMENT PILL ──
  Widget _buildAppointmentPill() {
    final doctor = _nextAppointment!['dermatologistId'];
    final docName = doctor != null ? doctor['name'] : 'Doctor';
    final date = _nextAppointment!['date'] ?? '';
    final time = _nextAppointment!['time'] ?? '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A4C93), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.alarm_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$docName — $date at $time',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('UPCOMING', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // ── GRID BUTTON ──
  Widget _buildGridBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF1A2832),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.15), width: 1),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── QUICK ACCESS BUTTON ──
  Widget _buildQuickBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF1A2832),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF4A90A4), size: 20),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8AABB8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
