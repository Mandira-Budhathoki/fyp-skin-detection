import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'scan_tips_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  int _currentPage = 0; // source of truth

  late AnimationController _entranceController;
  late AnimationController _floatController;
  late AnimationController _particleController;
  late AnimationController _iconPulseController;

  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;
  late Animation<double> _floatAnim;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Melanoma\nDetection",
      description:
          "Early detection is key. Our AI analyzes moles and lesions to identify potential risks instantly.",
      imagePath: 'assets/images/intro_melanoma.png',
      accentColor: const Color(0xFFE2A96F),
      bgColor: const Color(0xFF1E1B2E), // lighter deep purple
      icon: Icons.health_and_safety_outlined,
      particleColor: const Color(0xFFE2A96F),
    ),
    OnboardingData(
      title: "Wound\nAnalysis",
      description:
          "Monitor healing progress and detect signs of infection early with advanced visual analysis.",
      imagePath: 'assets/images/intro_wound.png',
      accentColor: const Color(0xFF7EB8A4),
      bgColor: const Color(0xFF152220), // lighter deep green
      icon: Icons.healing_outlined,
      particleColor: const Color(0xFF7EB8A4),
    ),
    OnboardingData(
      title: "Skin Condition\nCheck",
      description:
          "Identify acne, eczema, and more to get personalized care recommendations tailored for you.",
      imagePath: 'assets/images/intro_skin.png',
      accentColor: const Color(0xFFB8A7D9),
      bgColor: const Color(0xFF1C1828), // lighter deep lavender
      icon: Icons.face_retouching_natural_outlined,
      particleColor: const Color(0xFFB8A7D9),
    ),
    OnboardingData(
      title: "Track Your\nHealth",
      description:
          "Keep a secure history of your scans to monitor changes over time and share with your doctor.",
      imagePath: 'assets/images/intro_track.png',
      accentColor: const Color(0xFF00BFA5),
      bgColor: const Color(0xFF0F2220), // lighter deep teal
      icon: Icons.insights_outlined,
      particleColor: const Color(0xFF00BFA5),
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _iconPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _entranceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _entranceSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _floatAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    _particleController.dispose();
    _iconPulseController.dispose();
    super.dispose();
  }

  // ✅ FIX: only use _currentPage (int), never _pageController.page
  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _entranceController.reset();
    _entranceController.forward();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _onPageChanged(_currentPage + 1);
    } else {
      _onGetStarted();
    }
  }

  void _onGetStarted() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ScanTipsScreen(),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final data = _pages[_currentPage];

    return Scaffold(
      backgroundColor: data.bgColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        color: data.bgColor,
        child: Stack(
          children: [
            // Floating particles
            AnimatedBuilder(
              animation: _particleController,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: ParticlePainter(
                  progress: _particleController.value,
                  color: data.particleColor,
                ),
              ),
            ),

            // Radial glow blob
            Positioned(
              top: size.height * 0.04,
              left: size.width * 0.1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      data.accentColor.withValues(alpha: 0.2),
                      data.accentColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Main UI
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! < 0) { // swipe left
                  if (_currentPage < _pages.length - 1) {
                    _onPageChanged(_currentPage + 1);
                  }
                } else if (details.primaryVelocity! > 0) { // swipe right
                  if (_currentPage > 0) {
                    _onPageChanged(_currentPage - 1);
                  }
                }
              },
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(data),
                    Expanded(flex: 5, child: _buildIconVisual(data)),
                    Expanded(flex: 4, child: _buildTextContent(data)),
                    _buildBottomBar(data),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '0${_currentPage + 1}  /  0${_pages.length}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: data.accentColor.withValues(alpha: 0.9),
              letterSpacing: 2.5,
            ),
          ),
          GestureDetector(
            onTap: _onGetStarted,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15), width: 1),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withValues(alpha: 0.06),
              ),
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconVisual(OnboardingData data) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_floatController, _iconPulseController, _particleController]),
        builder: (_, __) {
          return Transform.translate(
            offset: Offset(0, _floatAnim.value),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outermost pulse ring
                Container(
                  width: 240 + (_iconPulseController.value * 12),
                  height: 240 + (_iconPulseController.value * 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: data.accentColor.withValues(
                          alpha: 0.06 + _iconPulseController.value * 0.06),
                      width: 1,
                    ),
                  ),
                ),
                // Middle ring
                Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: data.accentColor.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                ),
                // Core icon circle
                Container(
                  width: 136,
                  height: 136,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: data.accentColor.withValues(alpha: 0.12),
                    border: Border.all(
                      color: data.accentColor.withValues(alpha: 0.32),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: data.accentColor.withValues(alpha: 0.28),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    data.icon,
                    size: 58,
                    color: data.accentColor,
                  ),
                ),

                // Orbiting dot 1
                Transform.rotate(
                  angle: _particleController.value * 2 * pi,
                  child: Transform.translate(
                    offset: const Offset(95, 0),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: data.accentColor,
                        boxShadow: [
                          BoxShadow(
                            color: data.accentColor.withValues(alpha: 0.7),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Orbiting dot 2 (counter)
                Transform.rotate(
                  angle:
                      -(_particleController.value * 1.5 * 2 * pi) + pi / 3,
                  child: Transform.translate(
                    offset: const Offset(68, 0),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: data.accentColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextContent(OnboardingData data) {
    return FadeTransition(
      opacity: _entranceFade,
      child: SlideTransition(
        position: _entranceSlide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                  color: data.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                data.description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.75,
                  color: Colors.white.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(OnboardingData data) {
    // ✅ FIX: use _currentPage int — never touch _pageController.page
    final bool isLast = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 44),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tappable dot indicators
          Row(
            children: List.generate(
              _pages.length,
              (index) => GestureDetector(
                onTap: () => _onPageChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(right: 7),
                  height: 6,
                  width: _currentPage == index ? 30 : 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? data.accentColor
                        : Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),

          // Next / Get Started pill button
          GestureDetector(
            onTap: _onNext,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOut,
              width: isLast ? 158 : 66,
              height: 66,
              decoration: BoxDecoration(
                color: data.accentColor,
                borderRadius: BorderRadius.circular(33),
                boxShadow: [
                  BoxShadow(
                    color: data.accentColor.withValues(alpha: 0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: isLast
                      ? const Text(
                          'Get Started',
                          key: ValueKey('start'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        )
                      : const Icon(
                          Icons.arrow_forward_rounded,
                          key: ValueKey('arrow'),
                          color: Colors.white,
                          size: 28,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------
// PARTICLE PAINTER
// -------------------------------------------------------
class ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  ParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 28; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.25 + rng.nextDouble() * 0.6;
      final radius = 1.0 + rng.nextDouble() * 2.2;
      final opacity = 0.06 + rng.nextDouble() * 0.15;

      final y =
          (baseY - (progress * speed * size.height * 0.35)) % size.height;

      paint.color = color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter old) =>
      old.progress != progress || old.color != color;
}

// -------------------------------------------------------
// DATA MODEL
// -------------------------------------------------------
class OnboardingData {
  final String title;
  final String description;
  final String imagePath;
  final Color accentColor;
  final Color bgColor;
  final IconData icon;
  final Color particleColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.accentColor,
    required this.bgColor,
    required this.icon,
    required this.particleColor,
  });
}