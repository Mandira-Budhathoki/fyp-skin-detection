import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _appointments = [];
  late TabController _tabController;

  // Premium color palette for consistency
  static const Color deepNavy = Color(0xFF0A1828);
  static const Color richBurgundy = Color(0xFF8B2635);
  static const Color warmGold = Color(0xFFD4AF37);
  static const Color softCream = Color(0xFFFAF9F6);
  static const Color paleGray = Color(0xFFF5F5F0);
  static const Color charcoal = Color(0xFF2D3748);
  static const Color mutedTeal = Color(0xFF1B5B6B);
  static const Color accentPurple = Color(0xFF6B4C8A);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAppointments() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');

    if (token != null) {
      final data = await ApiService.getUserAppointments(token);
      if (mounted) {
        setState(() {
          _appointments = data;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelAppointment(String id) async {
    bool? confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Cancel",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Cancel Appointment?', style: TextStyle(color: deepNavy, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to cancel? This action cannot be undone.',
          style: TextStyle(color: charcoal, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Keep It', style: TextStyle(color: charcoal.withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel Appointment', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      transitionBuilder: (ctx, anim, _, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(anim.value),
        child: FadeTransition(opacity: anim, child: child),
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');

    if (token != null) {
      final result = await ApiService.cancelAppointment(token, id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Action completed'),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );

      if (result['success'] == true) {
        _fetchAppointments();
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _appointments.where((a) => a['status'] == 'pending' || a['status'] == 'approved').toList();
    final history = _appointments.where((a) => a['status'] == 'cancelled' || a['status'] == 'rejected').toList();

    return Scaffold(
      backgroundColor: paleGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'MY VISITS',
          style: TextStyle(
            color: deepNavy,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: paleGray,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: deepNavy.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              labelColor: deepNavy,
              unselectedLabelColor: charcoal.withOpacity(0.5),
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
              tabs: const [
                Tab(text: "UPCOMING"),
                Tab(text: "HISTORY"),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accentPurple))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(upcoming, isUpcoming: true),
                _buildList(history, isUpcoming: false),
              ],
            ),
    );
  }

  Widget _buildList(List<dynamic> items, {required bool isUpcoming}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: deepNavy.withOpacity(0.04),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Icon(Icons.event_note_outlined, size: 48, color: charcoal.withOpacity(0.2)),
            ),
            const SizedBox(height: 24),
            Text(
              isUpcoming ? "No scheduled visits" : "No past history",
              style: TextStyle(
                color: charcoal.withOpacity(0.4),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final apt = items[index];
        final doctor = apt['dermatologistId'];
        final date = apt['date'];
        final time = apt['time'];
        final status = apt['status'];
        final docName = doctor != null ? doctor['name'] : 'Specialist';
        final spec = doctor != null ? doctor['specialization'] : 'Dermatologist';
        final img = doctor != null && doctor['imageUrl'] != null ? doctor['imageUrl'] : 'assets/images/logo.png';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: deepNavy.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: paleGray, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: AssetImage(img),
                        backgroundColor: paleGray,
                        onBackgroundImageError: (_, __) => const Icon(Icons.person, color: charcoal),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            docName,
                            style: const TextStyle(
                              color: deepNavy,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            spec.toUpperCase(),
                            style: TextStyle(
                              color: mutedTeal,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(status),
                  ],
                ),
              ),
              const Divider(height: 1),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: softCream.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildInfoItem(Icons.calendar_today_rounded, date, charcoal),
                        const Spacer(),
                        _buildInfoItem(Icons.access_time_filled_rounded, time, charcoal),
                      ],
                    ),
                    if (apt['adminNote'] != null && apt['adminNote'].toString().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded, size: 16, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Admin Remark: ${apt['adminNote']}",
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (isUpcoming && status == 'pending') ...[
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _cancelAppointment(apt['_id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red.shade600,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: Colors.red.shade100, width: 1.5),
                          ),
                        ),
                        child: const Text(
                          "CANCEL VISIT",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    switch (status) {
      case 'approved':
        color = Colors.green.shade600;
        icon = Icons.check_circle_rounded;
        break;
      case 'pending':
        color = warmGold;
        icon = Icons.hourglass_empty_rounded;
        break;
      case 'rejected':
        color = Colors.red.shade600;
        icon = Icons.cancel_rounded;
        break;
      case 'cancelled':
        color = charcoal.withOpacity(0.4);
        icon = Icons.do_not_disturb_on_rounded;
        break;
      default:
        color = charcoal;
        icon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
