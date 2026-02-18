import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'chatbot_screen.dart';
import 'wound_faq_screen.dart';


class WoundScreen extends StatefulWidget {
  const WoundScreen({Key? key}) : super(key: key);

  @override
  State<WoundScreen> createState() => _WoundScreenState();
}

class _WoundScreenState extends State<WoundScreen> {
  final ImagePicker _picker = ImagePicker();
  
  // Animation variables could be added here for entrance effects
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Soft Gray-Blue like Melanoma Screen
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFFC0392B), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Wound Analysis',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Decorative Circles (Red/Amber for Wound Theme)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withValues(alpha: 0.1), // Soft Red
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF39C12).withValues(alpha: 0.1), // Soft Amber
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  
                  // 1. Emergency Disclaimer Card
                  _buildEmergencyCard(),
                  
                  const SizedBox(height: 30),
                  
                  // 2. Camera/Gallery Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputCard(
                          icon: Icons.camera_alt_outlined,
                          title: 'Camera',
                          color: const Color(0xFFE74C3C), // Red
                          onTap: () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInputCard(
                          icon: Icons.photo_library_outlined,
                          title: 'Gallery',
                          color: const Color(0xFFE67E22), // Orange
                          onTap: () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 3. Real Action Buttons (Chat & Appointment)
                  _buildRealActionButton(
                    icon: Icons.calendar_month_rounded,
                    title: 'Book Appointment',
                    subtitle: 'Schedule a visit with a specialist',
                    color: const Color(0xFF8E44AD), // Purple
                    onTap: () => Navigator.pushNamed(context, '/appointment'),
                  ),
                  const SizedBox(height: 16),
                  _buildRealActionButton(
                    icon: Icons.smart_toy_rounded,
                    title: 'Chat with AI Assistant',
                    subtitle: 'Get instant answers to your doubts',
                    color: const Color(0xFF16A085), // Teal
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChatbotScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRealActionButton(
                    icon: Icons.auto_stories_rounded,
                    title: 'Wound Care Guide',
                    subtitle: '20+ Essential FAQs & Tips',
                    color: const Color(0xFFF39C12), // Amber/Orange
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WoundFaqScreen()),
                    ),
                  ),

                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Components ---

  Widget _buildEmergencyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE74C3C).withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE74C3C).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEDEC), // Light Red Bg
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFE74C3C),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emergency Notice',
                  style: TextStyle(
                    color: Color(0xFFC0392B),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'For severe bleeding or deep wounds, call emergency services immediately.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (pickedFile != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _WoundImagePreviewScreen(
              imageFile: File(pickedFile.path),
            ),
          ),
        );
      }
    } catch (e) {
      // Handle error
    }
  }
}

// ============================================
// PREVIEW SCREEN WITH BIO-METRIC SCANNER
// ============================================

class _WoundImagePreviewScreen extends StatefulWidget {
  final File imageFile;

  const _WoundImagePreviewScreen({required this.imageFile});

  @override
  State<_WoundImagePreviewScreen> createState() =>
      _WoundImagePreviewScreenState();
}

class _WoundImagePreviewScreenState extends State<_WoundImagePreviewScreen>
    with TickerProviderStateMixin {
  bool _isAnalyzing = false;
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Slow, detailed scan
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    setState(() => _isAnalyzing = true);
    _scanController.repeat(); // Start animation loop

    try {
      final bytes = await widget.imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Simulate network request
      await Future.delayed(const Duration(seconds: 4));

      if (mounted) {
        Navigator.pushNamed(
          context,
          '/wound-results',
          arguments: {
            'image': widget.imageFile,
            'imagePath': widget.imageFile.path,
            'base64Image': base64Image,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        _scanController.stop();
        _scanController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Image
          Image.file(
            widget.imageFile,
            fit: BoxFit.cover,
          ),

          // 2. Overlay Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),

          // 3. Scanner Animation Overlay (Only when analyzing)
          if (_isAnalyzing)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _scanController,
                builder: (context, child) {
                   return CustomPaint(
                    painter: WoundScannerPainter(
                      progress: _scanController.value,
                    ),
                  );
                },
              ),
            ),

          // 4. Header
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _isAnalyzing ? null : () => Navigator.pop(context),
                ),
                const Spacer(),
                const Text(
                  'Analysis Preview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // 5. Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   if (_isAnalyzing) ...[
                     const Text(
                       "ANALYZING TISSUE STRUCTURE...",
                       style: TextStyle(
                         color: Colors.cyanAccent,
                         fontSize: 14,
                         letterSpacing: 2.0,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                     const SizedBox(height: 20),
                   ],
                   
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isAnalyzing ? null : _analyzeImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAnalyzing
                            ? Colors.grey[800]
                            : const Color(0xFFE74C3C), // Red
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: _isAnalyzing ? 0 : 10,
                        shadowColor: const Color(0xFFE74C3C).withValues(alpha: 0.5),
                      ),
                      child: _isAnalyzing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'START SCAN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// BIO-METRIC SCANNER PAINTER (Custom for Wound)
// ============================================

class WoundScannerPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  WoundScannerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;



    // 1. Moving Scan Line
    double yPos = size.height * sin(progress * pi); // Oscillates up and down
    // Map -1..1 to 0..height
    yPos = (size.height * progress) % size.height;
    
    // Scan Beam Effect
    Rect beamRect = Rect.fromLTWH(0, yPos - 30, size.width, 60);
    final Shader beamShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
         Colors.transparent,
         Colors.cyanAccent.withValues(alpha: 0.6),
         Colors.transparent,
      ],
    ).createShader(beamRect);
    
    Paint beamPaint = Paint()..shader = beamShader;
    canvas.drawRect(beamRect, beamPaint);
    
    canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), linePaint);
    
    // 2. Corner Brackets (HUD style)
    double bracketLen = 40;
    double padding = 20;
    
    Path corners = Path();
    // Top Left
    corners.moveTo(padding, padding + bracketLen);
    corners.lineTo(padding, padding);
    corners.lineTo(padding + bracketLen, padding);
    
    // Top Right
    corners.moveTo(size.width - padding - bracketLen, padding);
    corners.lineTo(size.width - padding, padding);
    corners.lineTo(size.width - padding, padding + bracketLen);
    
    // Bottom Left
    corners.moveTo(padding, size.height - padding - bracketLen);
    corners.lineTo(padding, size.height - padding);
    corners.lineTo(padding + bracketLen, size.height - padding);
    
    // Bottom Right
    corners.moveTo(size.width - padding - bracketLen, size.height - padding);
    corners.lineTo(size.width - padding, size.height - padding);
    corners.lineTo(size.width - padding, size.height - padding - bracketLen);
    
    canvas.drawPath(corners, linePaint..strokeWidth = 4);
    
    // 3. Grid Lines (Faint)
    Paint gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;
      
    double step = 80;
    for(double x = 0; x < size.width; x+=step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for(double y = 0; y < size.height; y+=step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WoundScannerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
