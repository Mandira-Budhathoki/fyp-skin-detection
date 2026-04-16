import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'scan_history_screen.dart';
import 'my_appointments_screen.dart';

// ─────────────────────────────────────────────
//  COLOR TOKENS
// ─────────────────────────────────────────────
class _C {
  static const bg       = Color(0xFFF7F9FC);
  static const card     = Color(0xFFFFFFFF);
  static const border   = Color(0xFFE2E8F0);
  static const primary  = Color(0xFF0F172A); // Deep slate
  static const teal     = Color(0xFF00B894); // Accent
  static const textPri  = Color(0xFF0F172A);
  static const textSec  = Color(0xFF64748B);
  static const textMut  = Color(0xFF94A3B8);
  static const danger   = Color(0xFFEF4444);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = "Patient";
  String _email = "patient@example.com";
  bool _isLoading = true;

  // Settings state
  bool _notificationsOn = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _name  = prefs.getString('userName')  ?? "Patient";
        _email = prefs.getString('userEmail') ?? "patient@example.com";
        _notificationsOn = prefs.getBool('notificationsOn') ?? true;
        _isLoading = false;
      });
    }
  }

  Future<void> _savePref(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: _C.textSec)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: _C.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _C.bg,
        body: Center(child: CircularProgressIndicator(color: _C.primary, strokeWidth: 2.5)),
      );
    }

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.card,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: _C.textPri),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: _C.textPri,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.border),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── PROFILE HERO CARD ──
            _buildProfileHero(),
            const SizedBox(height: 20),

            // ── MY INFO ──
            _buildSectionLabel('MY INFO'),
            const SizedBox(height: 10),
            _buildInfoCard(),
            const SizedBox(height: 20),

            // ── HEALTH RECORDS ──
            _buildSectionLabel('HEALTH RECORDS'),
            const SizedBox(height: 10),
            _buildMenuTile(
              icon: Icons.insert_chart_outlined_rounded,
              title: 'Scan Reports',
              subtitle: 'View your AI skin analysis',
              color: _C.primary,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ScanHistoryScreen())),
            ),
            _buildMenuTile(
              icon: Icons.calendar_month_rounded,
              title: 'My Appointments',
              subtitle: 'Manage your consultations',
              color: _C.primary,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyAppointmentsScreen())),
            ),
            const SizedBox(height: 20),

            // ── SETTINGS ──
            _buildSectionLabel('SETTINGS'),
            const SizedBox(height: 10),
            _buildSettingsCard(),
            const SizedBox(height: 20),

            // ── ABOUT & LOGOUT ──
            _buildSectionLabel('ACCOUNT'),
            const SizedBox(height: 10),
            _buildMenuTile(
              icon: Icons.info_outline_rounded,
              title: 'About DermaAI',
              subtitle: 'Version 1.0.0',
              color: _C.primary,
              onTap: () => _showAbout(),
            ),
            _buildMenuTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              color: _C.danger,
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  PROFILE HERO
  // ─────────────────────────────────────────────
  Widget _buildProfileHero() {
    final initials = _name.isNotEmpty
        ? _name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'U';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_C.teal, _C.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _name,
            style: const TextStyle(
              color: _C.textPri,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _email,
            style: const TextStyle(
              color: _C.textSec,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  MY INFO CARD
  // ─────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow(
            icon: Icons.person_outline_rounded,
            label: 'Full Name',
            value: _name,
            color: _C.primary,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: _C.border),
          ),
          _infoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: _email,
            color: _C.primary,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: _C.border),
          ),
          _infoRow(
            icon: Icons.verified_user_outlined,
            label: 'Account Status',
            value: 'Verified',
            color: _C.teal,
            isVerified: true,
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isVerified = false,
  }) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _C.textMut,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _C.textPri,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.check_circle_rounded,
                        size: 14, color: _C.teal),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  SETTINGS CARD  (functional toggles)
  // ─────────────────────────────────────────────
  Widget _buildSettingsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _settingsToggle(
            icon: Icons.notifications_none_rounded,
            title: 'Push Notifications',
            subtitle: 'Appointment reminders & updates',
            color: _C.primary,
            value: _notificationsOn,
            onChanged: (v) {
              setState(() => _notificationsOn = v);
              _savePref('notificationsOn', v);
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(v ? 'Notifications enabled' : 'Notifications disabled'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _settingsToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _C.textPri,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _C.textSec,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            activeTrackColor: color.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SECTION LABEL
  // ─────────────────────────────────────────────
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            width: 3, height: 12,
            decoration: BoxDecoration(
              color: _C.teal,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: _C.textSec,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  MENU TILE
  // ─────────────────────────────────────────────
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color == _C.danger ? _C.danger : _C.textPri,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _C.textSec,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: _C.textMut),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  ABOUT DIALOG
  // ─────────────────────────────────────────────
  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _C.teal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.health_and_safety_rounded,
                  size: 18, color: _C.teal),
            ),
            const SizedBox(width: 10),
            const Text('DermaAI',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Personal Skin Health Expert',
              style: TextStyle(
                color: _C.textSec,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'DermaAI uses advanced artificial intelligence to analyze skin conditions, detect melanoma, monitor wounds, and provide personalized health insights.',
              style: TextStyle(
                color: _C.textSec,
                fontSize: 12,
                height: 1.6,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: _C.textMut, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(color: _C.teal, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
