import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  List<dynamic> _allAppointments = [];
  List<dynamic> _users = [];
  List<dynamic> _doctors = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');

    if (token != null) {
      final appts = await ApiService.getAllAppointments(token);
      final users = await ApiService.getUsers(token);
      final doctors = await ApiService.getDoctors(token);
      setState(() {
        _allAppointments = appts;
        _users = users;
        _doctors = doctors;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String id, String status, {String? adminNote}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');

    if (token != null) {
      final result = await ApiService.updateAppointmentStatus(
        token: token,
        appointmentId: id,
        status: status,
        adminNote: adminNote,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Updated'),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        )
      );

      if (result['success'] == true) {
        _fetchData();
      }
    }
  }

  void _showRejectDialog(String id) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a2a3a),
        title: const Text("Reject Appointment", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter reason for rejection...",
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.tealAccent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(id, 'rejected', adminNote: controller.text);
            },
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final pending = _allAppointments.where((a) => a['status'] == 'pending').toList();
    final history = _allAppointments.where((a) => a['status'] != 'pending').toList();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF0f2027),
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "History"),
              Tab(text: "Users"),
              Tab(text: "Doctors"),
            ],
            indicatorColor: Colors.tealAccent,
            labelColor: Colors.tealAccent,
            unselectedLabelColor: Colors.white54,
          ),
        ),
        body: TabBarView(
          children: [
            _buildAppointmentList(pending, isPending: true),
            _buildAppointmentList(history, isPending: false),
            _buildUserList(),
            _buildDoctorList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList(List<dynamic> list, {required bool isPending}) {
    return RefreshIndicator(
      onRefresh: _fetchData,
      color: Colors.tealAccent,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
          : list.isEmpty
              ? Center(child: Text(isPending ? "No pending requests." : "No history found.", style: const TextStyle(color: Colors.white54, fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final apt = list[index];
                    final user = apt['userId'];
                    final doctor = apt['dermatologistId'];
                    final status = apt['status'].toString().toUpperCase();
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  apt['patientName'] != null && apt['patientName'].isNotEmpty 
                                      ? apt['patientName'] 
                                      : (user != null ? user['name'] : 'Unknown User'),
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              _statusChip(status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (apt['phoneNumber'] != null && apt['phoneNumber'].isNotEmpty)
                            _infoRow(Icons.phone, apt['phoneNumber'], color: Colors.tealAccent)
                          else
                            Text(user != null ? user['email'] : '', style: const TextStyle(color: Colors.white54, fontSize: 14)),
                          
                          const Divider(color: Colors.white10, height: 24),
                          _infoRow(Icons.person, "Doctor: ${doctor != null ? doctor['name'] : 'N/A'}"),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _infoRow(Icons.calendar_month, "Date: ${apt['date']}")),
                              Expanded(child: _infoRow(Icons.access_time, "Time: ${apt['time']}")),
                            ],
                          ),
                          if (apt['notes'] != null && apt['notes'].isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text("User Notes: ${apt['notes']}", style: const TextStyle(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic)),
                          ],
                          if (apt['adminNote'] != null && apt['adminNote'].isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text("Admin Remark: ${apt['adminNote']}", style: const TextStyle(color: Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                          if (isPending) ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.8), foregroundColor: Colors.white),
                                    onPressed: () => _showRejectDialog(apt['_id']),
                                    child: const Text("Reject"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                                    onPressed: () => _updateStatus(apt['_id'], 'approved'),
                                    child: const Text("Approve"),
                                  ),
                                ),
                              ],
                            )
                          ]
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildUserList() {
    return _isLoading 
      ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
      : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];
            return ListTile(
              leading: CircleAvatar(backgroundColor: Colors.tealAccent.withOpacity(0.2), child: Text(user['name'][0].toUpperCase(), style: const TextStyle(color: Colors.tealAccent))),
              title: Text(user['name'], style: const TextStyle(color: Colors.white)),
              subtitle: Text(user['email'], style: const TextStyle(color: Colors.white54)),
              trailing: Text(user['role'].toString().toUpperCase(), style: const TextStyle(color: Colors.tealAccent, fontSize: 10)),
            );
          },
        );
  }

  Widget _buildDoctorList() {
    return _isLoading 
      ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
      : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _doctors.length,
          itemBuilder: (context, index) {
            final doc = _doctors[index];
            return ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(doc['imageUrl'] ?? '')),
              title: Text(doc['name'], style: const TextStyle(color: Colors.white)),
              subtitle: Text(doc['specialization'], style: const TextStyle(color: Colors.white54)),
            );
          },
        );
  }

  Widget _statusChip(String status) {
    Color color = Colors.orange;
    if (status == 'APPROVED') color = Colors.greenAccent;
    if (status == 'REJECTED') color = Colors.redAccent;
    if (status == 'CANCELLED') color = Colors.white24;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoRow(IconData icon, String text, {Color color = Colors.tealAccent}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: color == Colors.tealAccent ? color : Colors.white70, fontWeight: color == Colors.tealAccent ? FontWeight.bold : FontWeight.normal))),
      ],
    );
  }
}
