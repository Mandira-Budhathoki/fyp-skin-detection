import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart';

class AuthService {
  static const baseUrl = "http://localhost:5000/api/auth";

  static Future<bool> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await TokenStorage.save(data['token']);
      return true;
    }
    return false;
  }

  static Future<bool> signup(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password
      }),
    );

    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      await TokenStorage.save(data['token']);
      return true;
    }
    return false;
  }

  static Future<bool> forgotPassword(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return res.statusCode == 200;
  }

  static Future<bool> resetPassword(
      String token, String newPassword) async {
    final res = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'password': newPassword
      }),
    );
    return res.statusCode == 200;
  }
}
