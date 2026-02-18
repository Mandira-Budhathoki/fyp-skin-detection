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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');

    if (token != null) {
      final data = await ApiService.getUserAppointments(token);
      setState(() {
        _appointments = data;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelAppointment(String id) async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2E35),
        title: const Text('Cancel Appointment?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure? You can only cancel at least 2 hours before the appointment.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red))),
        ],
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
        )
      );

      if (result['success'] == true) {
        _fetchAppointments(); // Refresh list
      } else {
         setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Upcoming: pending or approved
    final upcoming = _appointments.where((a) => a['status'] == 'pending' || a['status'] == 'approved').toList();
    // History: cancelled or rejected
    final history = _appointments.where((a) => a['status'] == 'cancelled' || a['status'] == 'rejected').toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0f2027),
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.tealAccent,
          labelColor: Colors.tealAccent,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Active"),
            Tab(text: "History"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
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
            Icon(Icons.calendar_today, size: 60, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? "No active appointments" : "No appointment history",
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final apt = items[index];
        final doctor = apt['dermatologistId'];
        final date = apt['date'];
        final time = apt['time'];
        final status = apt['status'];
        
        final imageUrl = doctor != null && doctor['imageUrl'] != null 
            ? doctor['imageUrl'] 
            : 'https://via.placeholder.com/150';
        final docName = doctor != null ? doctor['name'] : 'Doctor Unavailable';
        final specialization = doctor != null ? doctor['specialization'] : '';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(imageUrl),
                      onBackgroundImageError: (_,__) => const Icon(Icons.person, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            docName,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            specialization,
                            style: const TextStyle(color: Colors.tealAccent, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(status),
                  ],
                ),
                const Divider(color: Colors.white10, height: 24),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.white54, size: 16),
                    const SizedBox(width: 8),
                    Text(date, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, color: Colors.white54, size: 16),
                    const SizedBox(width: 8),
                    Text(time, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
                if (isUpcoming && status != 'cancelled') ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _cancelAppointment(apt['_id']),
                      child: const Text("Cancel Appointment"),
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'approved': color = Colors.greenAccent; break;
      case 'pending': color = Colors.orangeAccent; break;
      case 'rejected': color = Colors.redAccent; break;
      case 'cancelled': color = Colors.grey; break;
      default: color = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
