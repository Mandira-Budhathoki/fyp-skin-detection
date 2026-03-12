import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'scan_history_screen.dart';
import 'my_appointments_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = "Patient";
  String _email = "patient@example.com";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('userName') ?? "Patient";
      _email = prefs.getString('userEmail') ?? "patient@example.com";
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0f2027),
        body: Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Health Records"),
                  const SizedBox(height: 16),
                  _buildMenuTile(
                    icon: Icons.analytics_rounded,
                    title: "Scan History",
                    subtitle: "View your AI skin reports",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanHistoryScreen())),
                  ),
                  _buildMenuTile(
                    icon: Icons.calendar_today_rounded,
                    title: "My Appointments",
                    subtitle: "Manage your consultations",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAppointmentsScreen())),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Account Settings"),
                  const SizedBox(height: 16),
                  _buildMenuTile(
                    icon: Icons.settings_rounded,
                    title: "Settings",
                    subtitle: "Notification & privacy",
                    onTap: () {},
                  ),
                  _buildMenuTile(
                    icon: Icons.logout_rounded,
                    title: "Logout",
                    subtitle: "Sign out of your account",
                    color: Colors.redAccent,
                    onTap: _logout,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF264653),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0f2027), Color(0xFF264653)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.tealAccent.withOpacity(0.1),
                  child: const Icon(Icons.person, size: 50, color: Colors.tealAccent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Text(_name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF264653))),
          const SizedBox(height: 4),
          Text(_email, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF264653), letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = const Color(0xFF264653),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      ),
    );
  }
}
