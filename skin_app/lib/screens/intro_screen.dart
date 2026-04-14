import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'scan_tips_screen.dart';

// ───────────────────────────────────────────────────────
//  PREMIUM PALETTE — Each page has a unique vibe
// ───────────────────────────────────────────────────────
class _Pal {
  // Page 1 – Melanoma (Soft, clinical blue-grey)
  static const indigoBg    = Color(0xFFF7F9FB);
  static const indigoAccent = Color(0xFF4A6572);

  // Page 2 – Wound (Soft, muted peach)
  static const amberBg     = Color(0xFFFDFBF7);
  static const amberAccent = Color(0xFFD49A89);

  // Page 3 – Face Analysis (Very light baby blue)
  static const oceanBg     = Color(0xFFF4F8FA);
  static const oceanAccent = Color(0xFF6B9AC4);

  // Page 4 – Skin Conditions (Soft blush)
  static const roseBg      = Color(0xFFFDF8F9);
  static const roseAccent  = Color(0xFFC88295);

  // Page 5 – Health Hub (Soft, pale sage green)
  static const mintBg      = Color(0xFFF5FAF7);
  static const mintAccent  = Color(0xFF6E9F88);

  static const textPrim    = Color(0xFF2D3142);
  static const textSub     = Color(0xFF7A8292);
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {

  late PageController _pageController;
  int _currentPage = 0;

  late AnimationController _entranceController;
  late AnimationController _floatController;
  late AnimationController _particleController;
  late AnimationController _iconPulseController;
  late AnimationController _morphController;

  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;
  late Animation<double> _floatAnim;

  final List<OnboardingData> _pages = [
    // ──── 1. MELANOMA DETECTION ────
    OnboardingData(
      title: "Melanoma\nDetection",
      description:
          "AI-powered screening to classify skin lesions as melanoma or 6 other different skin types. Scan any mole or mark for instant risk analysis with clinical-grade precision.",
      accentColor: _Pal.indigoAccent,
      bgColor: _Pal.indigoBg,
      icon: Icons.biotech_outlined,
      particleColor: _Pal.indigoAccent,
      secondaryIcon: Icons.shield_outlined,
    ),
    // ──── 2. WOUND ANALYSIS ────
    OnboardingData(
      title: "Recovery\nInsights",
      description:
          "Sophisticated wound analysis to track healing trajectories and detect subtle signs of infection. Monitor your recovery journey with confidence.",
      accentColor: _Pal.amberAccent,
      bgColor: _Pal.amberBg,
      icon: Icons.healing_outlined,
      particleColor: _Pal.amberAccent,
      secondaryIcon: Icons.trending_up_outlined,
    ),
    // ──── 3. FACE ANALYSIS ────
    OnboardingData(
      title: "Face\nAnalysis",
      description:
          "Complete facial health profiling — detect your skin type, emotions, face shape for ideal haircuts, acne severity, and spots. Personalized insights in seconds.",
      accentColor: _Pal.oceanAccent,
      bgColor: _Pal.oceanBg,
      icon: Icons.face_retouching_natural_outlined,
      particleColor: _Pal.oceanAccent,
      secondaryIcon: Icons.auto_awesome_outlined,
    ),
    // ──── 4. SKIN CONDITIONS ────
    OnboardingData(
      title: "Skin Condition\nCheck",
      description:
          "Identify common conditions like acne, milia, eczema, rosacea, and keratosis. Get an AI-driven breakdown with confidence scores and care guidance.",
      accentColor: _Pal.roseAccent,
      bgColor: _Pal.roseBg,
      icon: Icons.medical_services_outlined,
      particleColor: _Pal.roseAccent,
      secondaryIcon: Icons.local_hospital_outlined,
    ),
    // ──── 5. HEALTH HUB ────
    OnboardingData(
      title: "Health\nHub",
      description:
          "Your personal wellness command center — BMI tracking, vitality scores, curated diet plans, health articles, mood journals, and interactive quizzes.",
      accentColor: _Pal.mintAccent,
      bgColor: _Pal.mintBg,
      icon: Icons.dashboard_customize_outlined,
      particleColor: _Pal.mintAccent,
      secondaryIcon: Icons.insights_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    _pageController = PageController();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _iconPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _entranceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _entranceSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _floatAnim = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceController.dispose();
    _floatController.dispose();
    _particleController.dispose();
    _iconPulseController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _entranceController.reset();
    _entranceController.forward();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
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
    final data = _pages[_currentPage];

    return Scaffold(
      backgroundColor: data.bgColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        color: data.bgColor,
        child: Stack(
          children: [
            // Animated particles
            AnimatedBuilder(
              animation: _particleController,
              builder: (_, __) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _PremiumParticlePainter(
                  progress: _particleController.value,
                  color: data.particleColor,
                  pageIndex: _currentPage,
                ),
              ),
            ),

            // Morphing gradient blob
            Positioned(
              top: MediaQuery.of(context).size.height * 0.06,
              left: MediaQuery.of(context).size.width * 0.05,
              child: AnimatedBuilder(
                animation: _morphController,
                builder: (_, __) {
                  final shift = _morphController.value * 40 - 20;
                  return Transform.translate(
                    offset: Offset(shift, -shift * 0.5),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            data.accentColor.withValues(alpha: 0.12),
                            data.accentColor.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Secondary decorative blob (bottom-right)
            Positioned(
              bottom: -80,
              right: -60,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      data.accentColor.withValues(alpha: 0.08),
                      data.accentColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // PageView for swipe left/right
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final pageData = _pages[index];
                return SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(pageData),
                      Expanded(flex: 5, child: _buildIconVisual(pageData, index)),
                      Expanded(flex: 4, child: _buildTextContent(pageData, index)),
                      _buildBottomBar(pageData),
                    ],
                  ),
                );
              },
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
          // Page indicator with animated bar
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: data.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentPage + 1} of ${_pages.length}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: data.accentColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _onGetStarted,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                border: Border.all(
                    color: data.accentColor.withValues(alpha: 0.15), width: 1),
                borderRadius: BorderRadius.circular(20),
                color: data.accentColor.withValues(alpha: 0.06),
              ),
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: data.accentColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconVisual(OnboardingData data, int pageIndex) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_floatController, _iconPulseController, _particleController]),
        builder: (_, __) {
          // Different float direction per page
          final floatX = pageIndex.isEven ? 0.0 : sin(_floatController.value * pi) * 6;
          final floatY = _floatAnim.value;

          return Transform.translate(
            offset: Offset(floatX, floatY),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outermost hexagonal-feel ring (animated)
                Transform.rotate(
                  angle: _particleController.value * pi * (pageIndex.isEven ? 1 : -1),
                  child: Container(
                    width: 260 + (_iconPulseController.value * 14),
                    height: 260 + (_iconPulseController.value * 14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: data.accentColor.withValues(
                            alpha: 0.08 + _iconPulseController.value * 0.08),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                // Middle ring with dash effect
                Transform.rotate(
                  angle: -_particleController.value * pi * 0.5,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: data.accentColor.withValues(alpha: 0.15),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
                // Core icon circle with glassmorphism
                Container(
                  width: 144,
                  height: 144,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: data.accentColor.withValues(alpha: 0.2),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: data.accentColor.withValues(alpha: 0.15),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    data.icon,
                    size: 60,
                    color: data.accentColor,
                  ),
                ),

                // Orbiting dot 1 (main orbit)
                Transform.rotate(
                  angle: _particleController.value * 2 * pi,
                  child: Transform.translate(
                    offset: const Offset(105, 0),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: data.accentColor,
                        boxShadow: [
                          BoxShadow(
                            color: data.accentColor.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Orbiting dot 2 (counter-orbit, faster)
                Transform.rotate(
                  angle: -_particleController.value * 3 * pi,
                  child: Transform.translate(
                    offset: const Offset(80, 0),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: data.accentColor.withValues(alpha: 0.6),
                        boxShadow: [
                          BoxShadow(
                            color: data.accentColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Secondary icon (floating top-right)
                Transform.rotate(
                  angle: _particleController.value * 1.5 * pi,
                  child: Transform.translate(
                    offset: const Offset(60, -85),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: data.accentColor.withValues(alpha: 0.2),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Icon(
                        data.secondaryIcon,
                        size: 18,
                        color: data.accentColor,
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

  Widget _buildTextContent(OnboardingData data, int pageIndex) {
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
              // Accent bar with gradient
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      data.accentColor,
                      data.accentColor.withValues(alpha: 0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                data.title,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: _Pal.textPrim,
                  height: 1.08,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                data.description,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.60,
                  color: _Pal.textSub,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(OnboardingData data) {
    final bool isLast = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 44),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tappable dot indicators with unique shape
          Row(
            children: List.generate(
              _pages.length,
              (index) => GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(right: 6),
                  height: 6,
                  width: _currentPage == index ? 28 : 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? data.accentColor
                        : data.accentColor.withValues(alpha: 0.2),
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
              width: isLast ? 170 : 70,
              height: 66,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    data.accentColor,
                    data.accentColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(33),
                boxShadow: [
                  BoxShadow(
                    color: data.accentColor.withValues(alpha: 0.35),
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
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
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

// ───────────────────────────────────────────────────────
//  PREMIUM PARTICLE PAINTER — Different patterns per page
// ───────────────────────────────────────────────────────
class _PremiumParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final int pageIndex;

  _PremiumParticlePainter({
    required this.progress,
    required this.color,
    required this.pageIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42 + pageIndex * 7);
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw particles with unique movement per page
    for (int i = 0; i < 28; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.15 + rng.nextDouble() * 0.35;
      final radius = 1.2 + rng.nextDouble() * 2.5;
      final opacity = 0.06 + rng.nextDouble() * 0.12;

      double y;
      double xOff = 0;

      switch (pageIndex % 5) {
        case 0: // Vertical rise
          y = (baseY - (progress * speed * size.height * 0.4)) % size.height;
          break;
        case 1: // Diagonal drift
          y = (baseY - (progress * speed * size.height * 0.3)) % size.height;
          xOff = sin(progress * pi * 2 + i) * 15;
          break;
        case 2: // Circular float
          y = baseY + sin(progress * 2 * pi + i * 0.5) * 20;
          xOff = cos(progress * 2 * pi + i * 0.3) * 15;
          break;
        case 3: // Gentle wave
          y = baseY + sin(progress * 3 * pi + x * 0.01) * 25;
          break;
        default: // Sparkle (scale pulsing)
          y = baseY;
          xOff = sin(progress * 4 * pi + i) * 8;
      }

      paint.color = color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x + xOff, y), radius, paint);
    }

    // Draw a few connecting lines for a "network" feel
    if (pageIndex == 0 || pageIndex == 3) {
      final linePaint = Paint()
        ..color = color.withValues(alpha: 0.04)
        ..strokeWidth = 0.8;
      for (int i = 0; i < 6; i++) {
        final x1 = rng.nextDouble() * size.width;
        final y1 = rng.nextDouble() * size.height;
        final x2 = x1 + rng.nextDouble() * 80 - 40;
        final y2 = y1 + rng.nextDouble() * 80 - 40;
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumParticlePainter old) =>
      old.progress != progress || old.color != color || old.pageIndex != pageIndex;
}

// ───────────────────────────────────────────────────────
//  DATA MODEL
// ───────────────────────────────────────────────────────
class OnboardingData {
  final String title;
  final String description;
  final Color accentColor;
  final Color bgColor;
  final IconData icon;
  final Color particleColor;
  final IconData secondaryIcon;

  OnboardingData({
    required this.title,
    required this.description,
    required this.accentColor,
    required this.bgColor,
    required this.icon,
    required this.particleColor,
    required this.secondaryIcon,
  });
}
