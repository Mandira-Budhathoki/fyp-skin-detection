import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'dart:math' as math;
import 'dart:async';

// ─────────────────────────────────────────────
//  COLOR TOKENS
// ─────────────────────────────────────────────
class _C {
  static const bg      = Color(0xFF070B14);
  static const surface = Color(0xFF0F1624);
  static const card    = Color(0xFF131D2E);

  static const pending  = Color(0xFFFFB347);
  static const pendingD = Color(0xFF7C4A00);

  static const history  = Color(0xFF38BDF8);
  static const historyD = Color(0xFF0C3A52);

  static const users    = Color(0xFF34EFA8);
  static const usersD   = Color(0xFF06402A);

  static const doctors  = Color(0xFFFF6B6B);
  static const doctorsD = Color(0xFF4A1010);

  static const live    = Color(0xFF22D3A5);
  static const danger  = Color(0xFFFF4D4D);
  static const quiz    = Color(0xFFA78BFA);
  static const quizD   = Color(0xFF4C1D95);
  
  static const w70 = Color(0xB3FFFFFF);
  static const w30 = Color(0x4DFFFFFF);
  static const w10 = Color(0x1AFFFFFF);
  static const w06 = Color(0x0FFFFFFF);
}

// ─────────────────────────────────────────────
//  OVERVIEW PAGE  (same class name as original)
// ─────────────────────────────────────────────
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  // ── ORIGINAL STATE (untouched) ──────────────
  bool _isLoading = true;
  List<dynamic> _allAppointments = [];
  List<dynamic> _users = [];
  List<dynamic> _doctors = [];
  int _selectedIndex = 0;

  // ── NEW ANIMATION CONTROLLERS ───────────────
  late AnimationController _bubbleController;
  late AnimationController _pulseCtrl;
  late AnimationController _entryCtrl;
  late Animation<double> _entryAnim;

  // ── DOCTOR CONTROLLERS ───────────────────
  final _nameCtrl = TextEditingController();
  final _specCtrl = TextEditingController();
  final _qualCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _bioCtrl = TextEditingController(text: "Dedicated specialist with years of clinical experience.");
  final _slotsCtrl = TextEditingController(text: "10:00 AM - 11:00 AM");

  @override
  void initState() {
    super.initState();
    _fetchData();

    // original
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _entryAnim =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    _nameCtrl.dispose();
    _specCtrl.dispose();
    _qualCtrl.dispose();
    _expCtrl.dispose();
    _bioCtrl.dispose();
    _slotsCtrl.dispose();
    super.dispose();
  }

  // ── ORIGINAL LOGIC (untouched) ──────────────
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');

    if (token != null) {
      final appts = await ApiService.getAllAppointments(token);
      final users = await ApiService.getUsers(token);
      final doctors = await ApiService.getAllDoctorsAdmin(token);
      setState(() {
        _allAppointments = appts;
        _users = users;
        _doctors = doctors;
        _isLoading = false;
      });
      _entryCtrl.forward(from: 0);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Future<void> _updateStatus(String id, String status, {String? adminNote}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');
    if (token != null) {
      final res = await ApiService.updateAppointmentStatus(
          token: token, appointmentId: id, status: status, adminNote: adminNote);
      
      if (!mounted) return;
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Action Successful: $status"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Action Failed"), backgroundColor: _C.danger),
        );
      }
      _fetchData();
    }
  }

  Future<void> _toggleUser(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');
    if (token != null) {
      final res = await ApiService.toggleUserStatus(token, id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Status Updated"), backgroundColor: _C.users),
      );
      _fetchData();
    }
  }

  Future<void> _toggleDoctor(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');
    if (token != null) {
      final res = await ApiService.toggleDoctorStatus(token, id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Status Updated"), backgroundColor: _C.doctors),
      );
      _fetchData();
    }
  }

  // ── BUILD ───────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Use the Logout button to exit admin panel.'),
            duration: Duration(seconds: 2),
            backgroundColor: _C.danger,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: _C.bg,
        body: Stack(children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: _isLoading
                ? _buildLoader()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(children: [
                        const SizedBox(height: 24),
                        _buildHeader(),
                        const SizedBox(height: 24),
                        ScaleTransition(
                            scale: _entryAnim, child: _buildLiveCard()),
                        const SizedBox(height: 28),
                        _buildSectionGrid(),
                        const SizedBox(height: 40),
                      ]),
                    ),
                  ),
          ),
        ]),
        // original FAB — only shown on doctors tab (index 3)
        // On overview we don't show it; it's on the detail page
      ),
    );
  }

  // ── ANIMATED BACKGROUND (original logic, new colors) ──
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bubbleController,
      builder: (context, child) {
        final t = _bubbleController.value * 2 * math.pi;
        return Stack(children: [
          _buildBubble(
            top: -60 + 30 * math.sin(t * 0.6),
            left: -50 + 20 * math.cos(t * 0.4),
            size: 260,
            color: _C.history.withOpacity(0.10),
          ),
          _buildBubble(
            top: 220 + 40 * math.cos(t * 0.5),
            right: -60 + 30 * math.sin(t * 0.7),
            size: 220,
            color: _C.pending.withOpacity(0.08),
          ),
          _buildBubble(
            bottom: 80 + 50 * math.sin(t * 0.3),
            left: 40 + 20 * math.cos(t * 0.8),
            size: 180,
            color: _C.users.withOpacity(0.09),
          ),
          _buildBubble(
            bottom: -30 + 20 * math.cos(t),
            right: 20 + 15 * math.sin(t * 1.1),
            size: 200,
            color: _C.doctors.withOpacity(0.08),
          ),
          CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _GridPainter()),
        ]);
      },
    );
  }

  Widget _buildBubble({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [color, color.withOpacity(0)]),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, __) => Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64 + 8 * _pulseCtrl.value,
            height: 64 + 8 * _pulseCtrl.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                  colors: [Color(0xFF1E90FF), Color(0xFF0A4A8F)]),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E90FF)
                      .withOpacity(0.4 + 0.3 * _pulseCtrl.value),
                  blurRadius: 28,
                  spreadRadius: 4,
                )
              ],
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(height: 24),
          const Text('Loading Admin Portal',
              style: TextStyle(
                  color: _C.w70,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
        ]),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────
  Widget _buildHeader() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => Container(
                  width: 7, height: 7,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _C.live,
                    boxShadow: [
                      BoxShadow(
                        color: _C.live
                            .withOpacity(0.5 + 0.5 * _pulseCtrl.value),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                ),
              ),
              const Text('ADMIN PORTAL',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                      color: _C.w30)),
            ]),
            const SizedBox(height: 6),
            const Text('Overview',
                style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                    height: 1.1)),
          ]),
          // original logout logic
          Container(
            decoration: BoxDecoration(
              color: _C.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _C.danger.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded,
                  color: _C.danger, size: 22),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: _C.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    title: const Text('End Session?',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800)),
                    content: const Text(
                        'Are you sure you want to end your administration session?',
                        style: TextStyle(color: _C.w70)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel',
                              style: TextStyle(color: _C.w30))),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.danger,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _logout();
                        },
                        child: const Text('Logout',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ]);
  }

  // ── LIVE STATS CARD ─────────────────────────
  Widget _buildLiveCard() {
    final pending =
        _allAppointments.where((a) => a['status'] == 'pending').length;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1F3C), Color(0xFF0A2744)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _C.history.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: _C.history.withOpacity(0.12),
              blurRadius: 32,
              offset: const Offset(0, 12))
        ],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Live Stats',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _C.live
                    .withOpacity(0.08 + 0.05 * _pulseCtrl.value),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _C.live.withOpacity(0.35)),
              ),
              child: Row(children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _C.live,
                    boxShadow: [
                      BoxShadow(
                          color: _C.live
                              .withOpacity(0.7 * _pulseCtrl.value),
                          blurRadius: 6)
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Text('LIVE',
                    style: TextStyle(
                        color: _C.live,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          _miniStat('${_allAppointments.length}', 'Appointments',
              _C.history),
          _vDiv(),
          _miniStat('$pending', 'Pending', _C.pending),
          _vDiv(),
          _miniStat('${_users.length}', 'Users', _C.users),
          _vDiv(),
          _miniStat('${_doctors.length}', 'Doctors', _C.doctors),
        ]),
      ]),
    );
  }

  Widget _vDiv() =>
      Container(width: 1, height: 36, color: _C.w10);

  Widget _miniStat(String val, String label, Color color) => Expanded(
        child: Column(children: [
          Text(val,
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: color,
                  shadows: [
                    Shadow(color: color.withOpacity(0.5), blurRadius: 10)
                  ])),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: _C.w30,
                  letterSpacing: 0.4),
              textAlign: TextAlign.center),
        ]),
      );

  // ── 2×2 SECTION GRID ────────────────────────
  Widget _buildSectionGrid() {
    final pendingCount =
        _allAppointments.where((a) => a['status'] == 'pending').length;
    final historyCount =
        _allAppointments.where((a) => a['status'] != 'pending').length;

    return Column(children: [
      Row(children: [
        _SectionCard(
          index: 0,
          icon: Icons.pending_actions_rounded,
          title: 'Pending',
          count: pendingCount,
          color: _C.pending,
          darkColor: _C.pendingD,
          hint: 'Click Pending to see\npending requests',
          emoji: '⏳',
          onTap: _openSection,
        ),
        const SizedBox(width: 14),
        _SectionCard(
          index: 1,
          icon: Icons.history_rounded,
          title: 'History',
          count: historyCount,
          color: _C.history,
          darkColor: _C.historyD,
          hint: 'Check history for\nfurther info',
          emoji: '📋',
          onTap: _openSection,
        ),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        _SectionCard(
          index: 2,
          icon: Icons.people_rounded,
          title: 'Users',
          count: _users.length,
          color: _C.users,
          darkColor: _C.usersD,
          hint: 'See users to view\nnumber of users',
          emoji: '👥',
          onTap: _openSection,
        ),
        const SizedBox(width: 14),
        _SectionCard(
          index: 3,
          icon: Icons.medical_services_rounded,
          title: 'Doctors',
          count: _doctors.length,
          color: _C.doctors,
          darkColor: _C.doctorsD,
          hint: 'Doctors to check\ntheir availability',
          emoji: '🩺',
          onTap: _openSection,
        ),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        _SectionCard(
          index: 4,
          icon: Icons.quiz_rounded,
          title: 'Quiz',
          count: 0, // Dynamic loading if needed
          color: _C.quiz,
          darkColor: _C.quizD,
          hint: 'Manage quiz\nquestions & bank',
          emoji: '📝',
          onTap: _openSection,
        ),
        const Spacer(),
      ]),
    ]);
  }

  void _openSection(int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, anim, __) => FadeTransition(
          opacity: anim,
          child: _AdminDetailPage(
            initialIndex: index,
            allAppointments: _allAppointments,
            users: _users,
            doctors: _doctors,
            onUpdateStatus: _updateStatus,
            onToggleUser: _toggleUser,
            onToggleDoctor: _toggleDoctor,
            onShowAddDoctor: (ctx) => _showAddDoctorDialog(ctx),
            onRefresh: _fetchData,
          ),
        ),
      ),
    );
  }

  // ── ADD DOCTOR DIALOG (original logic) ──────
  void _showAddDoctorDialog(BuildContext context) {
    final List<String> weekDays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final Set<String> selectedDays = {'Monday', 'Wednesday', 'Friday'};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: const BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: _C.w30, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 20),
                const Text('New Specialist',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 16),
                _customField(_nameCtrl, "Doctor's Name", Icons.person_rounded),
                _customField(_specCtrl, 'Specialization (e.g. Skin Specialist)', Icons.workspace_premium_rounded),
                Row(children: [
                   Expanded(child: _customField(_qualCtrl, 'Qualification', Icons.school_rounded)),
                   const SizedBox(width: 10),
                   Expanded(child: _customField(_expCtrl, 'Exp (Years)', Icons.history_rounded, isNum: true)),
                ]),
                _customField(_bioCtrl, 'Professional Bio/About', Icons.description_outlined),
                const SizedBox(height: 12),
                
                // --- Day Selector ---
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Select Working Days", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: weekDays.map((day) {
                    final isSel = selectedDays.contains(day);
                    return InkWell(
                      onTap: () => setModalState(() => isSel ? selectedDays.remove(day) : selectedDays.add(day)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? _C.doctors : _C.w06,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSel ? _C.doctors : _C.w10),
                        ),
                        child: Text(day.substring(0, 3), style: TextStyle(color: isSel ? Colors.white : _C.w70, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                // --- Slot Input ---
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Time Slots (Comma separated)", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                _customField(_slotsCtrl, "e.g. 10:00 AM - 11:00 AM", Icons.timer_outlined),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.doctors,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      if (_nameCtrl.text.isEmpty || selectedDays.isEmpty) return;
                      Navigator.pop(ctx);
                      
                      final slots = _slotsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                      final List<Map<String, dynamic>> availability = selectedDays.map((day) => {
                        'day': day,
                        'timeSlots': slots
                      }).toList();

                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String? token = prefs.getString('userToken');
                      if (token != null) {
                        await ApiService.addDoctor(
                          token: token,
                          doctorData: {
                            'name': _nameCtrl.text,
                            'specialization': _specCtrl.text,
                            'qualification': _qualCtrl.text,
                            'experience': int.tryParse(_expCtrl.text) ?? 5,
                            'availability': availability,
                            'about': _bioCtrl.text.isEmpty ? 'Professional specialist join our medical team.' : _bioCtrl.text,
                            'imageUrl': 'assets/images/logo.png',
                          }
                        );
                        _nameCtrl.clear();
                        _specCtrl.clear();
                        _qualCtrl.clear();
                        _expCtrl.clear();
                        _fetchData();
                      }
                    },
                    child: const Text('Add This Specialist',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _customField(TextEditingController ctrl, String hint,
      IconData icon,
      {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: ctrl,
        keyboardType:
            isNum ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _C.doctors),
          hintText: hint,
          hintStyle: const TextStyle(color: _C.w30),
          filled: true,
          fillColor: _C.w06,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: _C.doctors.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: _C.doctors, width: 1.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DETAIL PAGE  (4 tabs)
// ─────────────────────────────────────────────
class _AdminDetailPage extends StatefulWidget {
  final int initialIndex;
  final List<dynamic> allAppointments;
  final List<dynamic> users;
  final List<dynamic> doctors;
  final Future<void> Function(String, String, {String? adminNote}) onUpdateStatus;
  final Future<void> Function(String) onToggleUser;
  final Future<void> Function(String) onToggleDoctor;
  final void Function(BuildContext) onShowAddDoctor;
  final VoidCallback onRefresh;

  const _AdminDetailPage({
    required this.initialIndex,
    required this.allAppointments,
    required this.users,
    required this.doctors,
    required this.onUpdateStatus,
    required this.onToggleUser,
    required this.onToggleDoctor,
    required this.onShowAddDoctor,
    required this.onRefresh,
  });

  @override
  State<_AdminDetailPage> createState() => _AdminDetailPageState();
}

class _AdminDetailPageState extends State<_AdminDetailPage>
    with TickerProviderStateMixin {
  late int _selectedIndex;
  late List<dynamic> _allAppointments;
  late List<dynamic> _users;
  late List<dynamic> _doctors;
  late AnimationController _fadeCtrl;

  static const _tabColors = [
    _C.pending,
    _C.history,
    _C.users,
    _C.doctors,
    _C.quiz,
  ];
  static const _tabIcons = [
    Icons.pending_actions_rounded,
    Icons.history_rounded,
    Icons.people_rounded,
    Icons.medical_services_rounded,
    Icons.quiz_rounded,
  ];
  static const _tabLabels = ['Pending', 'History', 'Users', 'Doctors', 'Questions'];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _allAppointments = widget.allAppointments;
    _users = widget.users;
    _doctors = widget.doctors;
    _loadQuizQuestions();
    _fadeCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 280))
      ..forward();
  }

  List<dynamic> _quizQuestions = [];
  bool _loadingQuiz = false;

  Future<void> _loadQuizQuestions() async {
    setState(() => _loadingQuiz = true);
    try {
      final qs = await ApiService.getQuizQuestions(null);
      setState(() => _quizQuestions = qs);
    } catch (e) { print(e); }
    setState(() => _loadingQuiz = false);
  }

  Future<void> _deleteQuizQ(String qid) async {
    final res = await ApiService.deleteQuizQuestion(qid);
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Question Deleted")));
      _loadQuizQuestions();
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _switchTab(int i) {
    setState(() => _selectedIndex = i);
    _fadeCtrl.forward(from: 0);
  }

  Future<void> _reload() async {
    widget.onRefresh();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');
    if (token != null) {
      final a = await ApiService.getAllAppointments(token);
      final u = await ApiService.getUsers(token);
      final d = await ApiService.getAllDoctorsAdmin(token);
      setState(() {
        _allAppointments = a;
        _users = u;
        _doctors = d;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(children: [
        CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _GridPainter()),
        SafeArea(
          child: Column(children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeCtrl,
                child: _buildContent(),
              ),
            ),
          ]),
        ),
      ]),
      floatingActionButton: _selectedIndex == 3 || _selectedIndex == 4
          ? FloatingActionButton.extended(
              onPressed: () => _selectedIndex == 3 
                  ? widget.onShowAddDoctor(context) 
                  : _showAddQuizDialog(),
              backgroundColor: _selectedIndex == 3 ? _C.doctors : _C.quiz,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(_selectedIndex == 3 ? 'Add Specialist' : 'Add Question',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    final color = _tabColors[_selectedIndex];
    final label = _tabLabels[_selectedIndex];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(children: [
        Material(
          color: _C.w06,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.w10),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                Text('Manage your ${label.toLowerCase()}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: _C.w30,
                        fontWeight: FontWeight.w500)),
              ]),
        ),
        Material(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: _reload,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child:
                  Icon(Icons.refresh_rounded, color: color, size: 20),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _C.w06,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.w10),
      ),
      child: Row(
        children: List.generate(5, (i) {
          final sel = _selectedIndex == i;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _switchTab(i),
                borderRadius: BorderRadius.circular(13),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  decoration: BoxDecoration(
                    color: sel
                        ? _tabColors[i].withOpacity(0.85)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                                color: _tabColors[i].withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3))
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(_tabIcons[i],
                        size: 20,
                        color: sel ? Colors.white : _C.w30),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildAppointmentList(
            _allAppointments
                .where((a) => a['status'] == 'pending')
                .toList(),
            true);
      case 1:
        return _buildAppointmentList(
            _allAppointments
                .where((a) => a['status'] != 'pending')
                .toList(),
            false);
      case 2:
        return _buildUserList();
      case 3:
        return _buildDoctorList();
      case 4:
        return _buildQuizManager();
      default:
        return const SizedBox();
    }
  }

  Widget _buildQuizManager() {
    if (_loadingQuiz) return const Center(child: CircularProgressIndicator(color: _C.quiz));
    if (_quizQuestions.isEmpty) return const Center(child: Text("No custom questions found", style: TextStyle(color: _C.w30)));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _quizQuestions.length,
      itemBuilder: (context, index) {
        final q = _quizQuestions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _C.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: _C.quiz.withOpacity(0.1))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: _C.quiz.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(q['category'] ?? 'General', style: const TextStyle(color: _C.quiz, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              IconButton(icon: const Icon(Icons.delete_outline_rounded, color: _C.danger, size: 20), onPressed: () => _deleteQuizQ(q['id'] ?? q['_id'])),
            ]),
            const SizedBox(height: 8),
            Text(q['question'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Text("Correct: ${q['options'][q['correctIndex']]}", style: const TextStyle(color: _C.users, fontSize: 11)),
          ]),
        );
      },
    );
  }
  void _showAddQuizDialog() {
    final qCtrl = TextEditingController();
    final opt1 = TextEditingController();
    final opt2 = TextEditingController();
    final opt3 = TextEditingController();
    final opt4 = TextEditingController();
    final expCtrl = TextEditingController();
    String category = 'UV & Sun Safety';
    int correct = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: _C.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('New Quiz Question', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _customField(qCtrl, 'Question', Icons.help_outline),
                _customField(opt1, 'Option 1', Icons.circle_outlined),
                _customField(opt2, 'Option 2', Icons.circle_outlined),
                _customField(opt3, 'Option 3', Icons.circle_outlined),
                _customField(opt4, 'Option 4', Icons.circle_outlined),
                _customField(expCtrl, 'Explanation (Optional)', Icons.info_outline),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text("Correct Index (0-3):", style: TextStyle(color: Colors.white)),
                  DropdownButton<int>(
                    value: correct,
                    dropdownColor: _C.surface,
                    items: [0, 1, 2, 3].map((i) => DropdownMenuItem(value: i, child: Text(i.toString(), style: const TextStyle(color: Colors.white)))).toList(),
                    onChanged: (v) => setM(() => correct = v!),
                  ),
                ]),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _C.quiz, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      if (qCtrl.text.isEmpty || opt1.text.isEmpty || opt2.text.isEmpty) return;
                      await ApiService.addQuizQuestion({
                        'category': category,
                        'question': qCtrl.text,
                        'options': [opt1.text, opt2.text, opt3.text, opt4.text],
                        'correctIndex': correct,
                        'explanation': expCtrl.text
                      });
                      Navigator.pop(ctx);
                      _loadQuizQuestions();
                    },
                    child: const Text('Add Question', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _customField(TextEditingController ctrl, String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _C.quiz, size: 18),
          hintText: hint,
          hintStyle: const TextStyle(color: _C.w30),
          filled: true,
          fillColor: _C.w06,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  // ── APPOINTMENT LIST (original logic) ───────
  Widget _buildAppointmentList(List<dynamic> list, bool isPending) {
    if (list.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Container(
            padding: const EdgeInsets.all(26),
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: _C.w06),
            child: const Icon(Icons.inbox_rounded,
                size: 48, color: _C.w30),
          ),
          const SizedBox(height: 16),
          Text(
              isPending
                  ? 'No pending request'
                  : 'No history found',
              style: const TextStyle(
                  color: _C.w30,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final apt = list[index];
        return _buildAppointmentCard(apt, isPending);
      },
    );
  }

  Widget _buildAppointmentCard(dynamic apt, bool isPending) {
    final status = apt['status'].toString().toUpperCase();
    final doctor = apt['dermatologistId'];

    Color sc = _C.w30;
    if (status == 'APPROVED') sc = _C.users;
    if (status == 'PENDING') sc = _C.pending;
    if (status == 'REJECTED' || status == 'CANCELLED') sc = _C.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: sc.withOpacity(0.2), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Container(
          height: 3,
          decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [sc, sc.withOpacity(0)]),
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Expanded(
                child: Text(
                  apt['patientName'] ?? 'Anonymous Patient',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: sc.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sc.withOpacity(0.3)),
                ),
                child: Text(status,
                    style: TextStyle(
                        color: sc,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 0.5)),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _infoChip(Icons.calendar_today_rounded,
                  apt['date'], _C.history),
              const SizedBox(width: 8),
              _infoChip(Icons.access_time_rounded,
                  apt['time'], _C.pending),
            ]),
            const SizedBox(height: 12),
            Divider(color: _C.w10, height: 1),
            const SizedBox(height: 12),
            Text(
              'Specialist: ${doctor != null ? doctor['name'] : 'N/A'}',
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _C.w70,
                  fontSize: 13),
            ),
            if (apt['notes'] != null &&
                apt['notes'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('"${apt['notes']}"',
                  style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: _C.w30,
                      fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 16),
            if (isPending) ...[
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showRejectDialog(apt),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _C.danger.withOpacity(0.15),
                      foregroundColor: _C.danger,
                      elevation: 0,
                      side: BorderSide(
                          color: _C.danger.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(13)),
                      minimumSize: const Size(0, 42),
                    ),
                    child: const Text('Reject',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showApproveDialog(apt),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _C.users.withOpacity(0.15),
                      foregroundColor: _C.users,
                      elevation: 0,
                      side: BorderSide(
                          color: _C.users.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(13)),
                      minimumSize: const Size(0, 42),
                    ),
                    child: const Text('Approve',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                ),
              ]),
            ] else if (status == 'APPROVED') ...[
               // Option to cancel already approved appointment (e.g. phone call)
               SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(apt),
                  icon: const Icon(Icons.phone_disabled_rounded, size: 16),
                  label: const Text("User Cancelled via Phone", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _C.danger,
                    side: BorderSide(color: _C.danger.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    minimumSize: const Size(0, 42),
                  ),
                ),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11)),
      ]),
    );
  }

  // ── USER LIST (original logic) ───────────────
  Widget _buildUserList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final name = user['name'] ?? 'User';
        final isFrozen = user['isFrozen'] ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.users.withOpacity(0.15)),
          ),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: isFrozen
                        ? [
                            const Color(0xFF2D3748),
                            const Color(0xFF4A5568)
                          ]
                        : [
                            const Color(0xFF059669),
                            const Color(0xFF34EFA8)
                          ]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.person_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(user['email'] ?? '',
                    style: const TextStyle(
                        fontSize: 11, color: _C.w30),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 6),
            // fixed-width trailing — NO OVERFLOW
            SizedBox(
              width: 72,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    isFrozen ? 'PASSIVE' : 'ACTIVE',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: isFrozen
                            ? _C.danger
                            : _C.users,
                        letterSpacing: 0.5),
                  ),
                  Transform.scale(
                    scale: 0.72,
                    alignment: Alignment.center,
                    child: Switch(
                      value: !isFrozen,
                      onChanged: (val) async {
                         await widget.onToggleUser(user['_id'] ?? user['id']);
                         _reload();
                      },
                      activeColor: _C.users,
                      inactiveThumbColor: _C.danger,
                      activeTrackColor:
                          _C.users.withOpacity(0.25),
                      inactiveTrackColor:
                          _C.danger.withOpacity(0.2),
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }

  // ── DOCTOR LIST (original logic) ─────────────
  Widget _buildDoctorList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: _doctors.length,
      itemBuilder: (context, index) {
        final doc = _doctors[index];
        final isActive = doc['isActive'] ?? true;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: _C.doctors.withOpacity(0.15)),
          ),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: isActive
                        ? [
                            const Color(0xFFB91C1C),
                            const Color(0xFFFF6B6B)
                          ]
                        : [
                            const Color(0xFF2D3748),
                            const Color(0xFF4A5568)
                          ]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.medical_services_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                Text(doc['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(doc['specialization'] ?? '',
                    style: const TextStyle(
                        fontSize: 11, color: _C.w30),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 6),
            // fixed-width trailing — NO OVERFLOW
            SizedBox(
              width: 72,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    isActive ? 'ACTIVE' : 'PASSIVE',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: isActive
                            ? _C.doctors
                            : _C.danger,
                        letterSpacing: 0.5),
                  ),
                  Transform.scale(
                    scale: 0.72,
                    alignment: Alignment.center,
                    child: Switch(
                      value: isActive,
                      onChanged: (val) async {
                         await widget.onToggleDoctor(doc['_id'] ?? doc['id']);
                         _reload();
                      },
                      activeColor: _C.doctors,
                      inactiveThumbColor: _C.danger,
                      activeTrackColor:
                          _C.doctors.withOpacity(0.25),
                      inactiveTrackColor:
                          _C.danger.withOpacity(0.2),
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }
  void _showApproveDialog(dynamic apt) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Approve Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add a note for the user (Optional):", style: TextStyle(color: _C.w70, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "e.g. Please bring your previous reports...",
                hintStyle: const TextStyle(color: _C.w30, fontSize: 12),
                filled: true,
                fillColor: _C.w06,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: _C.w30))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.users,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.onUpdateStatus(apt['_id'], 'approved', adminNote: noteCtrl.text);
              _reload();
            },
            child: const Text("Confirm Approve", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(dynamic apt) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Reject Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Provide a reason so the user knows why (Optional):", style: TextStyle(color: _C.w70, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "e.g. Doctor is unavailable, Please choose another time...",
                hintStyle: const TextStyle(color: _C.w30, fontSize: 12),
                filled: true,
                fillColor: _C.w06,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: _C.w30))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.onUpdateStatus(apt['_id'], 'rejected', adminNote: noteCtrl.text);
              _reload();
            },
            child: const Text("Confirm Reject", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }


  void _showCancelDialog(dynamic apt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Cancel Appointment?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("This appointment was previously approved. Marking it as cancelled will notify the system. Proceed?", style: TextStyle(color: _C.w70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No", style: TextStyle(color: _C.w30))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _C.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.onUpdateStatus(apt['_id'], 'rejected');
              _reload();
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SECTION CARD  (overview grid)
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final int index;
  final IconData icon;
  final String title;
  final int count;
  final Color color;
  final Color darkColor;
  final String hint;
  final String emoji;
  final void Function(int) onTap;

  const _SectionCard({
    required this.index,
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    required this.darkColor,
    required this.hint,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: darkColor,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(26),
          splashColor: color.withOpacity(0.2),
          highlightColor: color.withOpacity(0.1),
          child: Container(
            height: 190,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                  color: color.withOpacity(0.25), width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: color.withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                Text(emoji,
                    style: const TextStyle(fontSize: 18)),
              ]),
              const SizedBox(height: 8),
              Text('$count',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                      shadows: [
                        Shadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 12)
                      ])),
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 4),
              SizedBox(
                height: 26,
                child: _TypewriterText(
                    text: hint,
                    color: color.withOpacity(0.75)),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    Text('Open',
                        style: TextStyle(
                            fontSize: 9,
                            color: color,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(width: 3),
                    Icon(Icons.arrow_forward_rounded,
                        size: 10, color: color),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TYPEWRITER TEXT
// ─────────────────────────────────────────────
class _TypewriterText extends StatefulWidget {
  final String text;
  final Color color;
  const _TypewriterText(
      {required this.text, required this.color});
  @override
  State<_TypewriterText> createState() =>
      _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  String _shown = '';
  int _idx = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Future.delayed(
        const Duration(milliseconds: 700), _start);
  }

  void _start() {
    _timer =
        Timer.periodic(const Duration(milliseconds: 42), (_) {
      if (!mounted) return;
      if (_idx < widget.text.length) {
        setState(
            () => _shown = widget.text.substring(0, ++_idx));
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(
        _shown,
        style: TextStyle(
            fontSize: 10,
            color: widget.color,
            fontWeight: FontWeight.w500,
            height: 1.3),
        maxLines: 2,
        overflow: TextOverflow.clip,
      );
}

// ─────────────────────────────────────────────
//  GRID PAINTER
// ─────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(
          Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(
          Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}