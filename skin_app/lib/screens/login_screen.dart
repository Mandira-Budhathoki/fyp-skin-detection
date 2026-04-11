import 'dart:ui';
import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart'; 
import 'admin_register_screen.dart';
import 'intro_screen.dart';
import 'forgot_password_screen.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {Color color = Colors.redAccent}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // CHECK LOGIN 
  Future<void> _checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');

    if (token != null && token.isNotEmpty) {
      String? role = prefs.getString('userRole');
      if (!mounted) return;
      
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const IntroScreen()),
        );
      }
    }
  }

  // LOGIN
  Future<void> _login() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    //  Validation 
    if (email.isEmpty) {
      _showSnack('Email is required');
      return;
    }
    if (!email.contains('@')) {
      _showSnack('Enter a valid email');
      return;
    }
    if (password.isEmpty) {
      _showSnack('Password is required');
      return;
    }
    if (password.length < 6) {
      _showSnack('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.loginUser(
        email: email,
        password: password,
      );

      debugPrint('LOGIN RESPONSE: $result');

      if (result['success'] == true) {
        String token = result['token'];
        String role = result['user']['role'] ?? 'user';
        String userId = result['user']['id'].toString();
        String name = result['user']['name'] ?? 'User';
        String emailRes = result['user']['email'] ?? email;
        
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userToken', token);
        await prefs.setString('userRole', role);
        await prefs.setString('userId', userId);
        await prefs.setString('userName', name);
        await prefs.setString('userEmail', emailRes);
        await prefs.setInt('totalScans', result['user']['totalScans'] ?? 0);
        await prefs.setInt('currentStreak', result['user']['currentStreak'] ?? 0);
        await prefs.setString('lastScanDate', result['user']['lastScanDate'] ?? '');

        _showSnack(
          result['message'] ?? 'Logged in successfully!',
          color: Colors.green,
        );

        if (!mounted) return;

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const IntroScreen()),
          );
        }
      } else {
        _showSnack(result['message'] ?? 'Invalid email or password');
      }
    } catch (e) {
      _showSnack('Cannot connect to server. Check backend!');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  //  UI 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        color: const Color(0xFFF6F4E8), // Cream background
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _loginCard(context),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // CARD
  Widget _loginCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3436).withValues(alpha: 0.04), // Charcoal tint
            blurRadius: 10,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: const Color(0xFFE5EEE4)), // Pale Green border
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFDC9B9B), // Rose
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.health_and_safety_rounded, size: 40, color: Colors.white),
          ),
              const SizedBox(height: 16),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2D3436), // Charcoal
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Access your clinical health hub',
                style: TextStyle(color: Color(0xFF636E72), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 28),

              _inputField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 18),

              _inputField(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscure: _hidePassword,
                suffix: IconButton(
                  icon: Icon(
                    _hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF636E72),
                  ),
                  onPressed: () {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color(0xFFDC9B9B), // Rose
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC9B9B), // Rose
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFFDC9B9B).withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  'Create new account',
                  style: TextStyle(color: Color(0xFFDC9B9B), fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminRegisterScreen()),
                  );
                },
                child: const Text(
                  'Register as Admin',
                  style: TextStyle(color: Color(0xFF636E72), fontSize: 13, decoration: TextDecoration.underline),
                ),
              ),
            ],
        ),
      );
  }

  //  INPUT
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAEB8B8)),
        prefixIcon: Icon(icon, color: const Color(0xFFDC9B9B), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF6F4E8),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5EEE4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC9B9B), width: 1.5),
        ),
      ),
    );
  }
}
