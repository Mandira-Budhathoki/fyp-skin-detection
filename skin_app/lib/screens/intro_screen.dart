import 'package:flutter/material.dart';
import 'scan_tips_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Melanoma Detection",
      description:
          "Early detection is key. Our AI analyzes moles and lesions to identify potential risks of melanoma instantly.",
      // Using a color placeholder. Replace 'assets/images/melanoma_real.png' with your real image.
      imagePath: 'assets/images/intro_melanoma.png', 
      themeColor: const Color(0xFFE91E63), // Pink/Red
      icon: Icons.health_and_safety_outlined,
    ),
    OnboardingData(
      title: "Wound Analysis",
      description:
          "Monitor wound healing progress and detect signs of infection early with advanced visual analysis.",
      imagePath: 'assets/images/intro_wound.png',
      themeColor: const Color(0xFFFF9800), // Orange/Amber
      icon: Icons.healing_outlined,
    ),
    OnboardingData(
      title: "Skin Condition Check",
      description:
          "Identify various skin conditions like acne, eczema, and more to get personalized care recommendations.",
      imagePath: 'assets/images/intro_skin.png',
      themeColor: const Color(0xFF2196F3), // Blue
      icon: Icons.face_retouching_natural_outlined,
    ),
    OnboardingData(
      title: "Track Your Health",
      description:
          "Keep a secure history of your scans to monitor changes over time and share reports with your doctor.",
      imagePath: 'assets/images/intro_track.png',
      themeColor: const Color(0xFF009688), // Teal/Green
      icon: Icons.insights_outlined,
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _onGetStarted();
    }
  }

  void _onGetStarted() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanTipsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Current theme color based on page
    final Color currentColor = _pages[_currentPage].themeColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient Transition
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  currentColor.withValues(alpha: 0.05), // Very subtle tint
                ],
              ),
            ),
          ),

          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              
              _buildBottomControls(currentColor),
            ],
          ),
          
          // Skip Button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _onGetStarted,
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: const Text(
                "Skip",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // IMAGE PLACEHOLDER area
          // You said "not image by yourself", so I'm putting a placeholder structure here.
          // You can uncomment the Image.asset part when you have the files.
          Container(
            height: 280, 
            width: double.infinity,
            decoration: BoxDecoration(
              color: data.themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Icon as placeholder for the "Real Image"
                Icon(
                  data.icon, 
                  size: 100, 
                  color: data.themeColor.withValues(alpha: 0.5),
                ),
                // Uncomment this when you add your real images to assets:
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(30),
                //   child: Image.asset(
                //     data.imagePath,
                //     fit: BoxFit.cover,
                //     width: double.infinity,
                //     height: double.infinity,
                //     errorBuilder: (c, e, s) => const SizedBox(), // Hide if missing
                //   ),
                // ),
              ],
            ),
          ),
          
          const SizedBox(height: 50),
          
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3436),
              shadows: [
                Shadow(
                  color: data.themeColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(Color themeColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50, left: 30, right: 30),
      child: Column(
        children: [
          // Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 32 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? themeColor
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          
          // Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: themeColor.withValues(alpha: 0.4),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _currentPage == _pages.length - 1 ? "Get Started" : "Next",
                  key: ValueKey<String>(_currentPage == _pages.length - 1 ? "start" : "next"),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
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

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;
  final Color themeColor;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.themeColor,
    required this.icon,
  });
}
