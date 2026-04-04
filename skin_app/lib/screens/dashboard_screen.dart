import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

// ─────────────────────────────────────────────
//  COLOR TOKENS  (matching reference theme)
// ─────────────────────────────────────────────
class _C {
  static const bg        = Color(0xFFFFFFFF);
  static const primary   = Color(0xFF5D6FDA); // The blue button color
  static const textPri   = Color(0xFF22283A);
  static const textSec   = Color(0xFF5F6C85);
  static const border    = Color(0xFFF0F2F7);

  // Card Backgrounds
  static const cardLightBlue = Color(0xFFF4F6FB);
  static const cardLightCyan = Color(0xFFE9F7F8);
  static const cardLightRed  = Color(0xFFFCF3F3);
  static const cardLightGray = Color(0xFFF8F9FA);

  // Bottom Banner Gradient
  static const bannerGradStart = Color(0xFFE9EEFE);
  static const bannerGradEnd   = Color(0xFFE2F5F0);
}

// ─────────────────────────────────────────────
//  DASHBOARD SCREEN
// ─────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double>   _fadeAnimation;
  List<Map<String, dynamic>> _upcomingAppointments = [];
  String _userName = 'User';
  bool _notifDismissed = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animationController.forward();
    });

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    final name  = prefs.getString('userName');
    if (mounted) setState(() => _userName = name ?? 'User');

    if (token != null) {
      final appointments = await ApiService.getUserAppointments(token);
      if (appointments.isNotEmpty) {
        final upcoming = appointments
            .where((a) => a['status'] == 'upcoming')
            .toList();
        if (mounted) {
          setState(() {
            _upcomingAppointments = List<Map<String, dynamic>>.from(upcoming);
          });
        }
      }
    }
  }

  Future<void> _push(Widget screen) =>
      Navigator.push(context, _slideRoute(screen));

  Route _slideRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, a, __) => page,
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      );

  // ── Time-aware greeting ────────────────────
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  String get _firstNameOnly {
    final parts = _userName.trim().split(' ');
    return parts.isNotEmpty ? parts[0] : _userName;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ── BUILD ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final safeTop    = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _C.bg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            SizedBox(height: safeTop),

            // ── HEADER ──
            _buildHeader(),
            const Divider(height: 1, color: _C.border, thickness: 1),

            // ── HORIZONTAL MENU (Reference style) ──
            _buildHorizontalMenu(),
            const Divider(height: 1, color: _C.border, thickness: 1),

            // ── FITTED CONTENT ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    // Appointment Notification (if any)
                    if (_upcomingAppointments.isNotEmpty && !_notifDismissed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAppointmentNotification(),
                      ),

                    // Primary Action Card
                    Expanded(
                      flex: 3,
                      child: _buildWideCard(
                        title: 'Comprehensive Face Scan',
                        subtitle: 'Skin type, expression, face type and more',
                        bg: _C.cardLightBlue,
                        iconLabel: Icons.document_scanner_rounded,
                        onTap: () => _push(const FaceHealthScreen()),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Main Wide Card
                    Expanded(
                      flex: 3,
                      child: _buildWideCard(
                        title: 'Skin Condition Detection',
                        subtitle: 'Analyze acne, eczema, milia & more',
                        bg: _C.cardLightGray,
                        iconLabel: Icons.face_retouching_natural_rounded,
                        onTap: () => _push(const SkinScreen()),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Grid Row 1
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildGridItem(
                              title: 'Melanoma',
                              subtitle: 'Early detection &\nrisk assessment',
                              bg: _C.cardLightCyan,
                              iconLabel: Icons.biotech_rounded,
                              onTap: () => _push(const MelanomaScreen()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGridItem(
                              title: 'Wound Scan',
                              subtitle: 'AI recovery &\nhealing tracking',
                              bg: _C.cardLightRed,
                              iconLabel: Icons.healing_rounded,
                              onTap: () => _push(const WoundScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Grid Row 2
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildGridItem(
                              title: 'Health Hub',
                              subtitle: 'Vitality index &\nwellness insights',
                              bg: _C.cardLightCyan,
                              iconLabel: Icons.hub_rounded,
                              onTap: () => _push(const VitalityHubScreen()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGridItem(
                              title: 'History',
                              subtitle: 'View all past\nscan reports',
                              bg: _C.cardLightGray,
                              iconLabel: Icons.history_rounded,
                              onTap: () => _push(const ScanHistoryScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bottom Gradient Banner
                    _buildBottomBanner(),
                    
                    SizedBox(height: safeBottom > 0 ? safeBottom : 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: _C.bg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(
                  color: _C.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_greeting!',
                    style: const TextStyle(
                      color: _C.textSec,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _firstNameOnly,
                    style: const TextStyle(
                      color: _C.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(), // or custom action
            icon: const Icon(Icons.menu_rounded, color: _C.primary, size: 28),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HORIZONTAL MENU
  // ─────────────────────────────────────────────
  Widget _buildHorizontalMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _menuItem('My Visits', () => _push(const MyAppointmentsScreen())),
          _menuItem('Reports', () => _push(const ScanHistoryScreen())),
          _menuItem('Profile', () => _push(const ProfileScreen())),
        ],
      ),
    );
  }

  Widget _menuItem(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _C.textPri,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, color: _C.textSec, size: 16),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  CARDS & BLOCKS
  // ─────────────────────────────────────────────
  Widget _buildWideCard({
    required String title,
    required String subtitle,
    required Color bg,
    required IconData iconLabel,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                iconLabel,
                size: 110,
                color: Colors.black.withOpacity(0.04),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _C.textPri,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _C.textSec,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required String title,
    required String subtitle,
    required Color bg,
    required IconData iconLabel,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -15,
              bottom: -15,
              child: Icon(
                iconLabel,
                size: 80,
                color: Colors.black.withOpacity(0.04),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _C.textPri,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _C.textSec,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BOTTOM BANNER
  // ─────────────────────────────────────────────
  Widget _buildBottomBanner() {
    return GestureDetector(
      onTap: () async {
        await _push(const AppointmentScreen());
        _loadUserData();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [_C.bannerGradStart, _C.bannerGradEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Need a specialist?',
                    style: TextStyle(
                      color: _C.textPri,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Book a board-certified dermatologist directly.',
                    style: TextStyle(color: _C.textSec, fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Book Visit',
                style: TextStyle(
                  color: _C.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  APPOINTMENT NOTIFICATION
  // ─────────────────────────────────────────────
  Widget _buildAppointmentNotification() {
    final appt   = _upcomingAppointments[0];
    final doctor = appt['dermatologistId'];
    final docName = (doctor != null ? doctor['name'] : 'Your Specialist') as String;
    final date   = appt['date'] ?? '';
    final time   = appt['time'] ?? '';
    final count  = _upcomingAppointments.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFDC8A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFFFAB2E), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count > 1 ? '$count Upcoming Appointments' : 'Upcoming Appointment',
                  style: const TextStyle(
                    color: _C.textPri,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dr. $docName • $date at $time',
                  style: const TextStyle(
                    color: _C.textSec,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _notifDismissed = true),
            child: const Icon(Icons.close_rounded, size: 18, color: _C.textSec),
          ),
        ],
      ),
    );
  }
}