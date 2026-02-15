import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'intro_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _splashController;
  late AnimationController _breathingController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _slideUpAnimation;
  late Animation<double> _breathingAnimation;

  bool _showIntro = false;

  @override
  void initState() {
    super.initState();

    // 1. SPLASH CONTROLLER (Sequenced entrance)
    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000), // Increased to 4 seconds
    );

    // 2. BREATHING CONTROLLER (Continuous pulse)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // --- SEQUENCED ANIMATIONS ---

    // Logo Scale (0.8 -> 1.0)
    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    // Logo Fade In
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Text Fade In
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );

    // Slide Up for Content
    _slideUpAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    // --- CONTINUOUS ANIMATION ---
    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Start Sequence
    _splashController.forward();
    
    // Start Breathing after logo has scaled in
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _breathingController.repeat(reverse: true);
    });

    // Timer to switch to Intro View
    Timer(const Duration(milliseconds: 4500), () { 
      // 4000ms duration + 500ms buffer for breathing effect to be appreciated
      if (mounted) {
        setState(() {
          _showIntro = true;
        });
      }
    });

  }



  @override
  void dispose() {
    _splashController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  void _navigateToNext() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // User likely logged in
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const IntroScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      // New User
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const RegisterScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF5F7FA), // Light Grey-Blue
                    Color(0xFFE4E9F2), // Slightly darker
                  ],
                ),
              ),
            ),
          ),
          
          // Painted Background Pattern
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal.withValues(alpha: 0.05),
              ),
            ),
          ),
           Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pink.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Content
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: _showIntro ? _buildIntroView() : _buildSplashView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplashView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ScaleTransition for entry, then AnimatedBuilder for breathing
        ScaleTransition(
          scale: _logoScaleAnimation,
          child: AnimatedBuilder(
            animation: _breathingAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _breathingAnimation.value,
                child: child,
              );
            },
            child: FadeTransition(
              opacity: _logoFadeAnimation,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        FadeTransition(
          opacity: _textFadeAnimation,
          child: SlideTransition(
            position: _slideUpAnimation,
            child: Column(
              children: [
                const Text(
                  "DermaAI",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3436),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Intelligent Skin Analysis",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntroView() {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Enlarged Hero Image/Logo
          Container(
            width: screenWidth * 0.85, // 85% of screen width
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                 BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.15), // Reduced intensity
                    blurRadius: 20, // Reduced blur
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/logo2.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 50),
          const Text(
            "Your Personal\nSkin Health Expert",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Advanced AI scanning technology to help you monitor and understand your skin health anytime, anywhere.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _navigateToNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5), // Teal Accent Color
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                shadowColor: const Color(0xFF00BFA5).withValues(alpha: 0.4),
              ),
              child: const Text(
                "Get Started",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
