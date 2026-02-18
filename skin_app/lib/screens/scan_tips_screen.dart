// lib/screens/scan_tips_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dashboard_screen.dart';

class ScanTipsScreen extends StatefulWidget {
  const ScanTipsScreen({Key? key}) : super(key: key);

  @override
  State<ScanTipsScreen> createState() => _ScanTipsScreenState();
}

class _ScanTipsScreenState extends State<ScanTipsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _cardAnimations;
  late Animation<double> _buttonAnimation;

  int _currentTipIndex = 0;
  Timer? _autoScrollTimer;

  final List<TipItem> tips = [
    TipItem(
      emoji: '📷',
      title: 'Face the Camera',
      description: 'Keep your face centered and look straight at the camera',
      color: const Color(0xFF6366F1),
    ),
    TipItem(
      emoji: '💡',
      title: 'Good Lighting',
      description: 'Avoid shadows and ensure proper lighting',
      color: const Color(0xFFEC4899),
    ),
    TipItem(
      emoji: '✨',
      title: 'Clean Camera Lens',
      description: 'Wipe the lens for clear, sharp images',
      color: const Color(0xFF10B981),
    ),
    TipItem(
      emoji: '🎯',
      title: 'Show Area Clearly',
      description: 'Keep lesion or wound fully visible',
      color: const Color(0xFFF59E0B),
    ),
    TipItem(
      emoji: '🖼️',
      title: 'Clear Background',
      description: 'Avoid clutter and distractions',
      color: const Color(0xFF8B5CF6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAutoScroll();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _cardAnimations = List.generate(
      tips.length,
      (i) => CurvedAnimation(
        parent: _animationController,
        curve: Interval(i * 0.1, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _buttonAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
    );

    // Start after first frame to avoid tiny negative values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animationController.forward();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % tips.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildAdvancedHero(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildGlassHeader(),
                        const SizedBox(height: 24),
                        Expanded(
                          child: ListView.builder(
                            itemCount: tips.length,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 20),
                            itemBuilder: (context, i) => _buildAdvancedTipCard(tips[i], i),
                          ),
                        ),
                        _buildRefinedButtons(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedHero() {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF2C3E50),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/logo4.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.2),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFFF4F7F9),
                    const Color(0xFFF4F7F9).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SCAN PROTOCOL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.0,
                    color: Color(0xFF3498DB),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Follow these guidelines\nfor precise analysis',
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 24,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset('assets/images/logo4.png', height: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: Color(0xFF1ABC9C), size: 20),
          const SizedBox(width: 12),
          const Text(
            'Protocol for Best Accuracy',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF34495E),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTipCard(TipItem tip, int index) {
    return AnimatedBuilder(
      animation: _cardAnimations[index],
      builder: (_, child) {
        final opacity = _cardAnimations[index].value.clamp(0.0, 1.0);
        final translateY = 30 * (1 - opacity);

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: _currentTipIndex == index
                ? const Color(0xFF3498DB).withOpacity(0.3)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 6,
                  color: _currentTipIndex == index ? const Color(0xFF3498DB) : Colors.transparent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4F8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(tip.emoji, style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tip.title.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                tip.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRefinedButtons() {
    return AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (_, child) {
        final opacity = _buttonAnimation.value.clamp(0.0, 1.0);
        return Opacity(opacity: opacity, child: child);
      },
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'BACK',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 1.5,
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3498DB).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 1.5,
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

// ================= MODEL =================
class TipItem {
  final String emoji;
  final String title;
  final String description;
  final Color color;

  TipItem({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}
