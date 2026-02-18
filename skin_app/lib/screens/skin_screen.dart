import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'chatbot_screen.dart';
import 'faq_screen.dart';

class SkinScreen extends StatefulWidget {
  const SkinScreen({Key? key}) : super(key: key);

  @override
  State<SkinScreen> createState() => _SkinScreenState();
}

class _SkinScreenState extends State<SkinScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to adapt to screen height
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Soft Gray-Blue
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
                  color: Color(0xFF2980B9), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Face Analysis',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Decorative Circles (Blue/Cyan)
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF1ABC9C).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main Content - Compact Layout
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header Area (Instead of just AppBar title)
                  const SizedBox(height: 10),
                  const Text(
                    'Analyze your skin with AI-powered precision.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const Spacer(flex: 1),

                  // 2. Input Methods (Hero Section)
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputCard(
                          icon: Icons.face_retouching_natural_rounded,
                          title: 'Selfie',
                          subtitle: 'Live Camera',
                          color: const Color(0xFF3498DB),
                          onTap: () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInputCard(
                          icon: Icons.photo_library_rounded,
                          title: 'Gallery',
                          subtitle: 'From Library',
                          color: const Color(0xFF1ABC9C),
                          onTap: () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 1),

                  // 3. Photo Tips (Horizontal & Minimal)
                  _buildCompactTipsRow(),

                  const Spacer(flex: 2),

                  // 4. Action Area
                  const Text(
                    'RESOURCES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Color(0xFF95A5A6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPremiumActionButton(
                    icon: Icons.calendar_today_rounded,
                    title: 'Book Appointment',
                    color: const Color(0xFF8E44AD),
                    onTap: () => Navigator.pushNamed(context, '/appointment'),
                  ),
                  const SizedBox(height: 12),
                  _buildPremiumActionButton(
                    icon: Icons.smart_toy_outlined,
                    title: 'Consult AI Chatbot',
                    color: const Color(0xFF16A085),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChatbotScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPremiumActionButton(
                    icon: Icons.menu_book_rounded,
                    title: 'Skin Guide & FAQs',
                    color: const Color(0xFFE67E22), // Orange
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FaqScreen(),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // 5. Disclaimer (Minimalist)
                  _buildMinimalDisclaimer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalDisclaimer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFBDC3C7)),
          const SizedBox(width: 8),
          Text(
            'Non-medical AI analysis. Consult a specialist.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTipsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUICK TIPS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Color(0xFF3498DB),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallTip(Icons.light_mode_outlined, 'Bright Light'),
              _buildSmallTip(Icons.face_outlined, 'No Makeup'),
              _buildSmallTip(Icons.center_focus_strong_outlined, 'Centered'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTip(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF7F8C8D)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF7F8C8D), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildInputCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
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
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
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
        preferredCameraDevice: source == ImageSource.camera 
          ? CameraDevice.front 
          : CameraDevice.rear,
      );

      if (pickedFile != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _SkinImagePreviewScreen(
              imageFile: File(pickedFile.path),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

// ============================================
// PREVIEW SCREEN
// ============================================

class _SkinImagePreviewScreen extends StatefulWidget {
  final File imageFile;

  const _SkinImagePreviewScreen({required this.imageFile});

  @override
  State<_SkinImagePreviewScreen> createState() =>
      _SkinImagePreviewScreenState();
}

class _SkinImagePreviewScreenState extends State<_SkinImagePreviewScreen>
    with TickerProviderStateMixin {
  bool _isAnalyzing = false;
  late AnimationController _scanController;
  final TransformationController _transformationController = TransformationController();

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
    _transformationController.dispose();
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
          '/skin-results',
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
          InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(
              widget.imageFile,
              fit: BoxFit.cover,
            ),
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
                    painter: SkinScannerPainter( // Using Skin variant
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
                  'Face Analysis',
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
                       "MAPPING FACIAL FEATURES...",
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
                            : const Color(0xFF3498DB), // Blue
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: _isAnalyzing ? 0 : 10,
                        shadowColor: const Color(0xFF3498DB).withValues(alpha: 0.5),
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
                              'ANALYZE SKIN',
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
// BIO-METRIC SCANNER PAINTER (Custom for Skin)
// ============================================

class SkinScannerPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  SkinScannerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Blue/Cyan Theme for Skin Analysis
    final Paint linePaint = Paint()
      ..color = const Color(0xFF3498DB).withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // 1. Moving Scan Line
    double yPos = size.height * sin(progress * pi); 
    yPos = (size.height * progress) % size.height;
    
    // Scan Beam Effect
    Rect beamRect = Rect.fromLTWH(0, yPos - 40, size.width, 80);
    final Shader beamShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
         Colors.transparent,
         const Color(0xFF3498DB).withValues(alpha: 0.5),
         const Color(0xFF1ABC9C).withValues(alpha: 0.5), // Teal mix
         Colors.transparent,
      ],
    ).createShader(beamRect);
    
    Paint beamPaint = Paint()..shader = beamShader;
    canvas.drawRect(beamRect, beamPaint);
    
    canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), linePaint);
    
    // 2. Face Guide Outline (Subtle visual aid)
    // Draw a rounded rect in the center to suggest face placement
    final Paint guidePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    double guideWidth = size.width * 0.7;
    double guideHeight = size.height * 0.5;
    double guideLeft = (size.width - guideWidth) / 2;
    double guideTop = (size.height - guideHeight) / 2;

    RRect faceGuide = RRect.fromRectAndRadius(
      Rect.fromLTWH(guideLeft, guideTop, guideWidth, guideHeight),
      const Radius.circular(100), // Very rounded for face shape
    );
    canvas.drawRRect(faceGuide, guidePaint);


    // 3. Corner Brackets (HUD style)
    double bracketLen = 30;
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
  }

  @override
  bool shouldRepaint(covariant SkinScannerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
