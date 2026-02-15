import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your backend URL
  static const String baseUrl = 'http://192.168.1.81:5000/api/auth';

  // ---------------- Register ----------------
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

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (!data.containsKey("success")) {
        data["success"] = response.statusCode == 200;
      }

      return data;
    } catch (e) {
      return {
        "success": false,
        "message": "Cannot connect to server. Check backend!",
      };
    }
  }

  // ---------------- Login ----------------
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

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (!data.containsKey("success")) {
        data["success"] = response.statusCode == 200;
      }

      return data;
    } catch (e) {
      return {
        "success": false,
        "message": "Cannot connect to server. Check backend!",
      };
    }
  }

  // ---------------- Forgot Password ----------------
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (!data.containsKey("success")) {
        data["success"] = response.statusCode == 200;
      }

      return data;
    } catch (e) {
      return {
        "success": false,
        "message": "Cannot connect to server. Check backend!",
      };
    }
  }

  // ---------------- Reset Password ----------------
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
          'newPassword': newPassword, // using newPassword for clarity
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (!data.containsKey("success")) {
        data["success"] = response.statusCode == 200;
      }

      return data;
    } catch (e) {
      return {
        "success": false,
        "message": "Cannot connect to server. Check backend!",
      };
    }
  }
}
