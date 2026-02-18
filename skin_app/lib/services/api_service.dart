import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your backend URL
  static const String baseUrl = 'http://192.168.1.81:3000/api/auth';
  static const String appointmentUrl = 'http://192.168.1.81:3000/api/appointments';

  // ---------------- AUTH METHODS ----------------

  // Register User (Patient)
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error"};
    }
  }

  // Register Admin
  static Future<Map<String, dynamic>> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String adminSecret,
  }) async {
    final url = Uri.parse('$baseUrl/register-admin');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'adminSecret': adminSecret,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error"};
    }
  }

  // Login (Returns token and user role)
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error"};
    }
  }

  // Forgot Password
  static Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final url = Uri.parse('$baseUrl/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error"};
    }
  }

  // Reset Password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection error"};
    }
  }

  // ---------------- APPOINTMENT METHODS ----------------

  // Get Doctors
  static Future<List<dynamic>> getDoctors(String token) async {
    final url = Uri.parse('$appointmentUrl/doctors');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Get All Users (Admin Only)
  static Future<List<dynamic>> getUsers(String token) async {
    final url = Uri.parse('$baseUrl/users');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['users'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Get Available Slots
  static Future<List<String>> getAvailableSlots(String token, String doctorId, String date) async {
    final url = Uri.parse('$appointmentUrl/doctors/$doctorId/slots?date=$date');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['availableSlots']);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Book Appointment
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
        },
        body: jsonEncode({
          'dermatologistId': dermatologistId,
          'date': date,
          'time': time,
          'notes': notes,
          'patientName': patientName,
          'phoneNumber': phoneNumber,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Booking failed. Connection error."};
    }
  }

  // Get User Appointments (My Appointments)
  static Future<List<dynamic>> getUserAppointments(String token) async {
    final url = Uri.parse('$appointmentUrl/my');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['appointments'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Cancel Appointment
  static Future<Map<String, dynamic>> cancelAppointment(String token, String appointmentId) async {
    final url = Uri.parse('$appointmentUrl/$appointmentId');
    try {
      final response = await http.delete(
        url,
        headers: {
           'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Cancellation failed. Connection error."};
    }
  }

  // ---------------- ADMIN APPOINTMENT METHODS ----------------

  // Get All Appointments (Admin History)
  static Future<List<dynamic>> getAllAppointments(String token) async {
    final url = Uri.parse('$appointmentUrl/admin/all');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['appointments'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Update Appointment Status (Approve/Reject)
  static Future<Map<String, dynamic>> updateAppointmentStatus({
    required String token,
    required String appointmentId,
    required String status,
    String? adminNote,
  }) async {
    final url = Uri.parse('$appointmentUrl/admin/status/$appointmentId');
    try {
      final body = {
        'status': status,
      };
      if (adminNote != null) {
        body['adminNote'] = adminNote;
      }

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Status update failed. Connection error."};
    }
  }
}
