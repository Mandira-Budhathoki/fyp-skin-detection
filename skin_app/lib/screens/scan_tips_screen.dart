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
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHero(height * 0.30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: tips.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, i) => _buildTipCard(tips[i], i),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HERO =================
  Widget _buildHero(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/logo4.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.35),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Scan Guidelines',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Follow these tips for accurate results',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF667EEA).withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Text(
        'Essential Tips for Best Results',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3748),
        ),
      ),
    );
  }

  // ================= TIP CARD =================
  Widget _buildTipCard(TipItem tip, int index) {
    return AnimatedBuilder(
      animation: _cardAnimations[index],
      builder: (_, child) {
        final opacity = _cardAnimations[index].value.clamp(0.0, 1.0);
        final offsetY = 40 * (1 - opacity);

        return Transform.translate(
          offset: Offset(0, offsetY),
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _currentTipIndex == index
                ? tip.color.withOpacity(0.4)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: tip.color.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: tip.color,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(tip.emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tip.description,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BUTTONS =================
  Widget _buildButtons() {
    return AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (_, child) {
        final opacity = _buttonAnimation.value.clamp(0.0, 1.0);
        final scale = _buttonAnimation.value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('BACK'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              },
              child: const Text('CONTINUE'),
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
