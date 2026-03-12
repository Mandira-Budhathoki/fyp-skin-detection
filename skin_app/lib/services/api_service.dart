import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Replacing with backend URL
  // Centralized IP and Ports for easy updates
  // TIP: Change 'serverIp' if you move to a new network (like college or home)
  // --- NETWORK CONFIGURATION ---
  // For Android Emulator, use: '10.0.2.2'
  // For iOS Simulator or Web, use: 'localhost'
  // For Real Phone, use your PC's IP (e.g. '100.64.199.161' or '192.168.x.x')
  
  // --- NETWORK CONFIGURATION ---
  static const String serverIp = '10.0.2.2'; 
  static const String authPort = '5000';    // Node.js
  static const String servicePort = '3000'; // Python
  static const String gatewayPort = '8000'; // Consolidated Gateway

  static const bool useTunnel = true; 
  static const String tunnelUrl = 'https://unactable-milly-neatly.ngrok-free.dev'; //replaceeeeeeeee

  // Base for Authentication (Node.js - Port 5000)
  static const String authBase = useTunnel 
      ? '$tunnelUrl/api/auth' 
      : 'http://$serverIp:8000/api/auth'; // Point to gateway even in local
      
  // Base for AI & Appointments (Python - Port 3000)
  static const String serviceBase = useTunnel 
      ? '$tunnelUrl/api' 
      : 'http://$serverIp:8000/api';

  // Specific Endpoints
  static const String analyzeUrl = '$serviceBase/analyze';
  static const String analyzeAcneUrl = '$serviceBase/analyze/acne';
  static const String chatbotUrl = '$serviceBase/chatbot';
  static const String appointmentUrl = '$serviceBase/appointments';


  // ---------------- AUTH METHODS ----------------

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$authBase/register');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Bypass-Tunnel-Reminder': 'true',
        },
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) { return {"success": false, "message": "Connection error"}; }
  }

  static Future<Map<String, dynamic>> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String adminSecret,
  }) async {
    final url = Uri.parse('$authBase/register-admin');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Bypass-Tunnel-Reminder': 'true'},
        body: jsonEncode({'name': name, 'email': email, 'password': password, 'adminSecret': adminSecret}),
      );
      return jsonDecode(response.body);
    } catch (e) { return {"success": false, "message": "Connection error"}; }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$authBase/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Bypass-Tunnel-Reminder': 'true'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) { return {"success": false, "message": "Connection error"}; }
  }

  static Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final url = Uri.parse('$authBase/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Bypass-Tunnel-Reminder': 'true'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) { return {"success": false, "message": "Connection error"}; }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final url = Uri.parse('$authBase/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Bypass-Tunnel-Reminder': 'true'},
        body: jsonEncode({'email': email, 'newPassword': newPassword}),
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) { return {"success": false, "message": "Connection error"}; }
  }

  // ---------------- APPOINTMENT METHODS ----------------

  static Future<List<dynamic>> getDoctors(String token) async {
    final url = Uri.parse('$appointmentUrl/doctors');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Bypass-Tunnel-Reminder': 'true',
        },
      );
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  static Future<List<dynamic>> getAllDoctorsAdmin(String token) async {
    final url = Uri.parse('$appointmentUrl/admin/doctors/all');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Bypass-Tunnel-Reminder': 'true',
        },
      );
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  // FIXED: Fetching from Python Service base
  static Future<List<dynamic>> getUsers(String token) async {
    final url = Uri.parse('$appointmentUrl/admin/users');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Bypass-Tunnel-Reminder': 'true',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['users'] ?? [];
      }
      return [];
    } catch (e) { return []; }
  }

  static Future<List<String>> getAvailableSlots(String token, String doctorId, String date) async {
    final url = Uri.parse('$appointmentUrl/doctors/$doctorId/slots?date=$date');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Bypass-Tunnel-Reminder': 'true',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['availableSlots']);
      }
      return [];
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> bookAppointment({
    required String token,
    required String dermatologistId,
    required String date,
    required String time,
    String notes = "",
    String patientName = "",
    String phoneNumber = "",
  }) async {
    final url = Uri.parse('$appointmentUrl/book');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Bypass-Tunnel-Reminder': 'true',
        },
        body: jsonEncode({
          'dermatologistId': dermatologistId,
          'date': date,
          'time': time,
          'notes': notes,
          'patientName': patientName,
          'phoneNumber': phoneNumber,
        }),
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) { return {"success": false, "message": "Booking failed."}; }
  }

  static Future<List<dynamic>> getUserAppointments(String token) async {
    final url = Uri.parse('$appointmentUrl/my');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Bypass-Tunnel-Reminder': 'true',
        },
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['appointments'] ?? [];
      }
      return [];
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> cancelAppointment(String token, String appointmentId) async {
    final url = Uri.parse('$appointmentUrl/$appointmentId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token', 'Bypass-Tunnel-Reminder': 'true'},
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) { return {"success": false, "message": "Cancellation failed."}; }
  }

  // ---------------- ADMIN APPOINTMENT METHODS ----------------

  static Future<List<dynamic>> getAllAppointments(String token) async {
    final url = Uri.parse('$appointmentUrl/admin/all');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Bypass-Tunnel-Reminder': 'true',
        },
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['appointments'] ?? [];
      }
      return [];
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> updateAppointmentStatus({
    required String token,
    required String appointmentId,
    required String status,
    String? adminNote,
  }) async {
    final url = Uri.parse('$appointmentUrl/admin/status/$appointmentId');
    try {
      final body = {'status': status};
      if (adminNote != null) body['adminNote'] = adminNote;
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Bypass-Tunnel-Reminder': 'true',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) { return {"success": false, "message": "Update failed."}; }
  }

  static Future<Map<String, dynamic>> addDoctor({
    required String token,
    required Map<String, dynamic> doctorData,
  }) async {
    final url = Uri.parse('$appointmentUrl/admin/doctors');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Bypass-Tunnel-Reminder': 'true',
        },
        body: jsonEncode(doctorData),
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) { return {"success": false, "message": "Failed to add doctor."}; }
  }

  static Future<Map<String, dynamic>> toggleDoctorStatus(String token, String doctorId) async {
    final url = Uri.parse('$appointmentUrl/admin/doctors/toggle/$doctorId');
    try {
      final response = await http.put(
        url,
        headers: {'Authorization': 'Bearer $token', 'Bypass-Tunnel-Reminder': 'true'},
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) { return {"success": false, "message": "Failed to toggle status."}; }
  }

  static Future<Map<String, dynamic>> toggleUserStatus(String token, String userId) async {
    final url = Uri.parse('$appointmentUrl/admin/users/toggle/$userId');
    try {
      final response = await http.put(
        url,
        headers: {'Authorization': 'Bearer $token', 'Bypass-Tunnel-Reminder': 'true'},
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) { return {"success": false, "message": "Failed to toggle status."}; }
  }

  // FIXED: Corrected history endpoint path to point to Python Service
  static Future<Map<String, dynamic>> getScanHistory(String token) async {
    final url = Uri.parse('$serviceBase/history'); // Points to /api/history (Python)
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Bypass-Tunnel-Reminder': 'true',
        },
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "history": [], "message": "Failed to fetch history."};
    }
  }

  static Future<Map<String, dynamic>> analyzeSkinAcne(String imagePath, String? token) async {
    final url = Uri.parse(analyzeAcneUrl);
    try {
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Bypass-Tunnel-Reminder'] = 'true';

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Connection to analyzer failed."};
    }
  }
}
