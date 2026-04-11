import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/api_service.dart'; // Make sure this exists
import 'admin_register_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {Color color = Colors.redAccent}) {
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

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // --- VALIDATIONS ---
    if (email.isEmpty) {
      _showSnack('Email is required');
      return;
    }
    if (!email.contains('@') || !email.contains('.com')) {
      _showSnack('Please enter a valid email (example@gmail.com)');
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
      final result = await ApiService.registerUser(
        name: name,
        email: email,
        password: password,
      );

      // --- HANDLE SERVER RESPONSE ---
      if (result != null && result is Map<String, dynamic>) {
        if (result["success"] == true) {
          // Success
          _showSnack(result["message"] ?? 'Registered successfully!', color: Colors.green);

          // Navigate to LoginScreen after short delay
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          });
        } else {
          // Failure from backend (like email already exists)
          _showSnack(result["message"] ?? 'Registration failed. Please try again.');
        }
      } else {
        // Unexpected response
        _showSnack('Unexpected server response. Try again later.');
        print('DEBUG: Register result -> $result');
      }
    } catch (e, stacktrace) {
      // Network error or unexpected error
      _showSnack('Cannot connect to server. Check your internet or try again.');
      print('DEBUG: Register error -> $e');
      print(stacktrace);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF6F4E8), // Cream
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC9B9B), // Rose
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add_rounded, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF2D3436), letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join the SkinHealth AI community',
                    style: TextStyle(color: Color(0xFF636E72), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),

                  _buildField(
                    controller: _nameController,
                    label: 'Full Name (optional)',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  _buildField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  _buildField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC9B9B), // Rose
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFFDC9B9B).withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isLoading ? null : _register,
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Register Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 18),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(color: Color(0xFFDC9B9B), fontSize: 14, fontWeight: FontWeight.w700),
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
                      'Register as Admin instead',
                      style: TextStyle(color: Colors.white54, fontSize: 13, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFAEB8B8), fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: const Color(0xFFDC9B9B), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
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
