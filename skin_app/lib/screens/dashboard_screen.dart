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
  int _totalScans = 0;
  int _currentStreak = 0;
  bool _notifDismissed = false;
  bool _notificationsEnabled = true;

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
    
    if (mounted) {
      setState(() {
        _userName = name ?? 'User';
        // Use cached values initially
        _totalScans = prefs.getInt('totalScans') ?? 0;
        _currentStreak = prefs.getInt('currentStreak') ?? 0;
        _notificationsEnabled = prefs.getBool('notificationsOn') ?? true;
      });
    }

    if (token != null) {
      // 1. Fetch REAL-TIME Scan History for Count & Streak
      final historyData = await ApiService.getScanHistory(token);
      if (historyData['success'] == true) {
        final history = historyData['history'] as List;
        final count = history.length;
        
        // Calculate Streak
        int streak = _calculateStreak(history);

        if (mounted) {
          setState(() {
            _totalScans = count;
            _currentStreak = streak;
          });
          // Cache for next session
          prefs.setInt('totalScans', count);
          prefs.setInt('currentStreak', streak);
        }
      }

      // 2. Fetch Appointments
      final appointments = await ApiService.getUserAppointments(token);
      if (appointments.isNotEmpty) {
        final upcoming = appointments
            .where((a) => a['status'] == 'pending' || a['status'] == 'approved')
            .toList();
        if (mounted) {
          setState(() {
            _upcomingAppointments = List<Map<String, dynamic>>.from(upcoming);
          });
        }
      }
    }
  }

  int _calculateStreak(List<dynamic> history) {
    if (history.isEmpty) return 0;
    
    // Get unique dates of scans
    final dates = history.map((s) {
      final dt = DateTime.parse(s['timestamp']);
      return DateTime(dt.year, dt.month, dt.day);
    }).toSet().toList();
    
    dates.sort((a, b) => b.compareTo(a)); // Newest first

    final today = DateTime.now();
    final todayClean = DateTime(today.year, today.month, today.day);
    
    int streak = 0;
    DateTime checkDate = todayClean;

    // Check if the first date is today or yesterday
    if (dates.isEmpty) return 0;
    if (dates[0] != todayClean && dates[0] != todayClean.subtract(const Duration(days: 1))) {
      return 0; // Streak broken if no scan today or yesterday
    }

    if (dates[0] == todayClean || dates[0] == todayClean.subtract(const Duration(days: 1))) {
      checkDate = dates[0];
      streak = 1;
      
      for (int i = 1; i < dates.length; i++) {
        if (dates[i] == checkDate.subtract(const Duration(days: 1))) {
          streak++;
          checkDate = dates[i];
        } else {
          break;
        }
      }
    }
    
    return streak;
  }

  Future<void> _push(Widget screen) async {
    await Navigator.push(context, _slideRoute(screen));
    _loadUserData(); // REFRESH DATA when returning to dashboard
  }

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
      drawer: _buildDrawer(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            SizedBox(height: safeTop),

            // ── HEADER ──
            _buildHeader(),
            
            // ── STREAK & STATS BAR ──
            _buildEngagementBar(),
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

                    const SizedBox(height: 12),

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
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu_rounded, color: _C.primary, size: 28),
              splashRadius: 24,
            ),
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
    final dateStr = appt['date'] ?? '';
    final timeStr = appt['time'] ?? '';
    final count   = _upcomingAppointments.length;

    // Time left calculation
    String timeLeft = "";
    try {
      final now = DateTime.now();
      final apptDate = DateTime.parse(dateStr);
      final diff = apptDate.difference(now);
      
      if (diff.isNegative) {
        timeLeft = "Starting now";
      } else if (diff.inDays > 0) {
        timeLeft = "${diff.inDays}d ${diff.inHours % 24}h remaining";
      } else if (diff.inHours > 0) {
        timeLeft = "${diff.inHours}h ${diff.inMinutes % 60}m remaining";
      } else {
        timeLeft = "${diff.inMinutes} mins remaining";
      }
    } catch (_) {
      timeLeft = "Be on time!";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFDC8A).withOpacity(0.5)),
        boxShadow: [BoxShadow(color: const Color(0xFFFFAB2E).withOpacity(0.1), blurRadius: 10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFFFAB2E).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.alarm_on_rounded, color: Color(0xFFFFAB2E), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      count > 1 ? '$count Appointments' : 'Upcoming Visit',
                      style: const TextStyle(color: _C.textPri, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFFF6B6B).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(timeLeft, style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 9, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Dr. $docName • $dateStr at $timeStr',
                  style: const TextStyle(color: _C.textSec, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _notifDismissed = true),
            icon: const Icon(Icons.close_rounded, size: 18, color: _C.textSec),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      color: _C.bg,
      child: Row(
        children: [
          _statItem("🔥", "$_currentStreak day streak", const Color(0xFFFF9F1C)),
          const SizedBox(width: 12),
          _statItem("📸", "$_totalScans scans", const Color(0xFF00D1FF)),
        ],
      ),
    );
  }

  Widget _statItem(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    String timeLeft = "Be on time!";
    String docDetails = "No upcoming visits";
    if (_upcomingAppointments.isNotEmpty) {
      final appt = _upcomingAppointments[0];
      docDetails = "Dr. ${appt['dermatologistId']?['name'] ?? 'Consultant'}";
      try {
        final now = DateTime.now();
        final diff = DateTime.parse(appt['date']).difference(now);
        if (diff.isNegative) timeLeft = "Starting now";
        else if (diff.inDays > 0) timeLeft = "${diff.inDays}d left";
        else timeLeft = "${diff.inHours}h ${diff.inMinutes % 60}m left";
      } catch (_) {}
    }

    return Drawer(
      backgroundColor: _C.bg,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [_C.primary, Color(0xFF2C3E50)])),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _C.primary)),
            ),
            accountName: Text(_userName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            accountEmail: const Text("Verified Health Profile", style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("MY ENGAGEMENT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _C.textSec, letterSpacing: 1)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _statItem("🔥", "$_currentStreak streak", const Color(0xFFFF9F1C))),
                    const SizedBox(width: 8),
                    Expanded(child: _statItem("📸", "$_totalScans scans", const Color(0xFF00D1FF))),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          if (_upcomingAppointments.isNotEmpty && _notificationsEnabled) ...[
            _drawerMenuHeader("DON'T FORGET!"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9F1C).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFF9F1C).withOpacity(0.3), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.alarm_on_rounded, size: 16, color: Color(0xFFD35400)),
                        const SizedBox(width: 8),
                        const Text("NOW BE READY", style: TextStyle(color: Color(0xFFD35400), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                          child: Text(timeLeft, style: const TextStyle(color: Color(0xFFFF9F1C), fontWeight: FontWeight.w900, fontSize: 10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      docDetails,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF2C3E50)),
                    ),
                    Text(
                      "${_upcomingAppointments[0]['date']} at ${_upcomingAppointments[0]['time']}",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF2C3E50).withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          _drawerMenuHeader("NAVIGATION"),
          _drawerTile(Icons.history_rounded, "Scan History", () => _push(const ScanHistoryScreen())),
          _drawerTile(Icons.calendar_month_rounded, "My Visits", () => _push(const MyAppointmentsScreen())),
          _drawerTile(Icons.person_outline_rounded, "Account Settings", () => _push(const ProfileScreen())),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Opacity(opacity: 0.5, child: Text("DermaAI v1.2.0", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600))),
          ),
        ],
      ),
    );
  }

  Widget _drawerMenuHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _C.textSec, letterSpacing: 1)),
    );
  }

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: _C.primary, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _C.textPri)),
      dense: true,
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}