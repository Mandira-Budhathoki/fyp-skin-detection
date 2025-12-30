import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person,
                  size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _infoTile("Name", "Test User"),
            _infoTile("Email", "user@email.com"),
            _infoTile("App Version", "1.0.0"),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(value),
    );
  }
}
