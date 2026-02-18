import 'dart:async';
import 'dart:math';
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
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late AnimationController _rotationController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  bool _showIntro = false;

  @override
  void initState() {
    super.initState();

    // 1. Main Entrance Controller (Controls the sequence)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // 2. Pulse Controller (Breathing logo)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // 3. Scan Controller (Vertical beam)
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // 4. Rotation Controller (Rings/Dots)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // -- Tweens --
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.2, curve: Curves.easeOutBack)),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.2, curve: Curves.easeIn)),
    );
    
    // Text enters later
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.3, 0.5, curve: Curves.easeIn)),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.3, 0.5, curve: Curves.easeOut)),
    );

    _mainController.forward();

    // Navigation Timer
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showIntro = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _scanController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _navigateToNext() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const IntroScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
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
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF5F7FA), Color(0xFFE4E9F2)],
                ),
              ),
            ),
          ),
          
          // Subtle bg shapes
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.teal.withValues(alpha: 0.05)),
            ),
          ),
          Positioned(
            bottom: -50, left: -50,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.pink.withValues(alpha: 0.05)),
            ),
          ),

          // Main Content Switcher
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: _showIntro ? _buildIntroView() : _buildBioMetricSplash(),
            ),
          ),
        ],
      ),
    );
  }

  // --- SPLASH SCREEN: BIO-METRIC SCANNER ---
  Widget _buildBioMetricSplash() {
    return SizedBox(
      width: 300,
      height: 400,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Rotating Rings & Dots
          AnimatedBuilder(
            animation: Listenable.merge([_rotationController, _scanController]),
            builder: (context, _) {
              return CustomPaint(
                size: const Size(280, 280),
                painter: BioMetricPainter(
                  rotation: _rotationController.value,
                  scan: _scanController.value,
                ),
              );
            },
          ),

          // 2. Central Logo with Pulse
          ScaleTransition(
            scale: _logoScale,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                 // Subtle breathing scale: 1.0 -> 1.05
                 double scale = 1.0 + (_pulseController.value * 0.05);
                 return Transform.scale(scale: scale, child: child);
              },
              child: FadeTransition(
                opacity: _logoFade,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Image.asset('assets/images/logo.png'),
                ),
              ),
            ),
          ),

          // 3. Text & Loading Status
          Positioned(
            bottom: 20,
            child: FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Column(
                  children: [
                    const Text(
                      "DermaAI",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Animated Loading Text
                    AnimatedBuilder(
                      animation: _scanController,
                      builder: (context, _) {
                        // Cycles text based on scan progress
                        String status = "Initializing...";
                        if (_scanController.value > 0.33) status = "Loading Models...";
                        if (_scanController.value > 0.66) status = "Verifying...";
                        
                        return Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade700,
                            letterSpacing: 2.0,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- INTRO SCREEN ---
  Widget _buildIntroView() {
    final double w = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Big Hero Image
          Container(
            width: w * 0.85, 
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                 BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
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
          const SizedBox(height: 16),
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
          // Action Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _navigateToNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                shadowColor: const Color(0xFF00BFA5).withValues(alpha: 0.4),
              ),
              child: const Text(
                "Get Started",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

// --- PAINTER FOR ANIMATION ---
class BioMetricPainter extends CustomPainter {
  final double rotation; // 0.0 -> 1.0 (continuous)
  final double scan;     // 0.0 -> 1.0 (continuous)

  BioMetricPainter({required this.rotation, required this.scan});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final Paint ringPaint = Paint()
      ..color = Colors.teal.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 1. Outer Dashed Ring (Slow Rotation)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * 2 * pi); // Full rotation
    _drawDashedCircle(canvas, 0, 0, radius, ringPaint);
    canvas.restore();

    // 2. Inner Solid Rings with varying opacity
    canvas.drawCircle(center, radius * 0.85, ringPaint..color = Colors.teal.withValues(alpha: 0.1));
    canvas.drawCircle(center, radius * 0.70, ringPaint..color = Colors.teal.withValues(alpha: 0.05));

    // 3. Orbiting Dots
    final Paint dotPaint = Paint()..color = Colors.tealAccent.shade400;
    
    // Dot 1 (Outer)
    double angle1 = rotation * 2 * pi;
    canvas.drawCircle(
      Offset(center.dx + cos(angle1) * radius, center.dy + sin(angle1) * radius),
      4, 
      dotPaint
    );

    // Dot 2 (Inner, Counter-Rotation)
    double angle2 = -(rotation * 4 * pi); // Faster, opposite direction
    double r2 = radius * 0.7;
    canvas.drawCircle(
      Offset(center.dx + cos(angle2) * r2, center.dy + sin(angle2) * r2),
      3, 
      dotPaint
    );

    // 4. Connectors (Simulated Networking)
    // Draw line from Dot 1 to Dot 2 if close enough? 
    // Or just static decorative glints. Let's do a scanning beam.

    // 5. Vertical Scanning Beam
    // A horizontal line or gradient rect that moves up and down
    double scanY = center.dy - radius + (scan * 2 * radius);
    
    // Make sure it bounces or wraps? Controller repeats 0->1. 
    // To bounce, use a Tween in the widget, but here we just wrap.
    // Let's make it a sine wave to bounce 
    double scanOffset = sin(scan * 2 * pi) * radius; // -R to +R
    double beamY = center.dy + scanOffset;

    final Paint beamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.teal.withValues(alpha: 0.0),
          Colors.teal.withValues(alpha: 0.5),
          Colors.teal.withValues(alpha: 0.0),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(center.dx - radius, beamY - 2, radius * 2, 4));

    canvas.drawRect(
      Rect.fromLTWH(center.dx - radius, beamY - 1, radius * 2, 2),
      beamPaint,
    );
  }

  void _drawDashedCircle(Canvas canvas, double x, double y, double radius, Paint paint) {
    const double dashWidth = 10;
    const double dashSpace = 10;
    double startAngle = 0;
    final double circumference = 2 * pi * radius;
    final int count = (circumference / (dashWidth + dashSpace)).floor();
    final double angleStep = (2 * pi) / count;
    final double dashAngle = (dashWidth / circumference) * 2 * pi;

    for (int i = 0; i < count; i++) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset(x, y), radius: radius),
          startAngle,
          dashAngle,
          false,
          paint,
        );
        startAngle += angleStep;
    }
  }

  @override
  bool shouldRepaint(covariant BioMetricPainter oldDelegate) {
     return oldDelegate.rotation != rotation || oldDelegate.scan != scan;
  }
}
