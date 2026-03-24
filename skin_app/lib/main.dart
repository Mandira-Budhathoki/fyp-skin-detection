import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/appointment_screen.dart';
import 'screens/chatbot_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkinCare AI',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const WelcomeWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/appointment': (context) => const AppointmentScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
      },
    );
  }
}

/// Wrapper to decide what comes after WelcomeScreen
class WelcomeWrapper extends StatefulWidget {
  const WelcomeWrapper({super.key});

  @override
  State<WelcomeWrapper> createState() => _WelcomeWrapperState();
}

class _WelcomeWrapperState extends State<WelcomeWrapper> {
  @override
  Widget build(BuildContext context) {
    return const WelcomeScreen();
  }
}
