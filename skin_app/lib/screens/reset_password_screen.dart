import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final password = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: password,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: "New Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await AuthService.resetPassword(
                  token,
                  password.text,
                );
                Navigator.pop(context);
              },
              child: const Text("Reset"),
            ),
          ],
        ),
      ),
    );
  }
}
