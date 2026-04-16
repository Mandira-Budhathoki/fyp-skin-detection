import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chatbot_screen.dart';
import 'wound_faq_screen.dart';
import 'wound_results_screen.dart';
import '../services/api_service.dart';
import 'custom_scanner_screen.dart';

// ─────────────────────────────────────────────
//  WOUND DESIGN SYSTEM
// ─────────────────────────────────────────────
class _WRef {
  static const cyan      = Color(0xFFB4D3D9); // Requested #B4D3D9
  static const purple    = Color(0xFFBDA6CE); // Requested #BDA6CE
  static const deep      = Color(0xFF2D3436);
  static const bg        = Color(0xFFF9FAFB);
  static const surface   = Colors.white;
}

class WoundScreen extends StatefulWidget {
  const WoundScreen({Key? key}) : super(key: key);

  @override
  State<WoundScreen> createState() => _WoundScreenState();
}

class _WoundScreenState extends State<WoundScreen> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final File? capturedFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomScannerScreen(
            title: 'Wound AI Scanner',
            helperText: 'Align the wound clearly within the grid.',
          ),
        ),
      );
      if (capturedFile != null && mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => _WoundImagePreviewScreen(imageFile: capturedFile)));
      }
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 100);
      if (pickedFile != null && mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => _WoundImagePreviewScreen(imageFile: File(pickedFile.path))));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to pick image.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _WRef.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildHeader(),
              const SizedBox(height: 8),
              _buildModernDashboard(),
              const SizedBox(height: 10),
              _buildEmergencyGuard(),
              const SizedBox(height: 10),
              _buildDetectionCapabilities(),
              const SizedBox(height: 16),
              _buildScanInterface(),
              const SizedBox(height: 10),
              _buildQuickResources(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: _WRef.deep, size: 18),
          ),
        ),
        const Text("WOUND INTELLIGENCE", style: TextStyle(color: _WRef.deep, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
        const SizedBox(width: 42),
      ],
    );
  }

  Widget _buildModernDashboard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_WRef.cyan, _WRef.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: _WRef.purple.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, child) => Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.5 * _pulseCtrl.value), width: 2)),
              child: const Icon(Icons.healing_rounded, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 12),
          const Text("WOUND INTELLIGENCE ENGINE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text("Advanced Tissue & Classification Analysis", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmergencyGuard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2), // Light Red Bg
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EMERGENCY NOTICE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 11)),
                SizedBox(height: 4),
                Text(
                  'If you experience heavy bleeding, deep lacerations, or signs of severe infection, seek medical attention immediately.',
                  style: TextStyle(color: Color(0xFF9F1239), fontSize: 12, height: 1.4, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionCapabilities() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _WRef.cyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('SYSTEM CAPABILITIES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _WRef.purple, letterSpacing: 1)),
          SizedBox(height: 8),
          Text(
            'Our AI analyzes various wound types including Burns, Lacerations, Surgical Incisions, Diabetic Ulcers, and Pressure Sores for healing progress.',
            style: TextStyle(fontSize: 12, color: _WRef.deep, height: 1.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildScanInterface() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('INITIATE NEW SCAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _scanCard('📸', 'Camera', _WRef.cyan, () => _pickImage(ImageSource.camera)),
            _scanCard('🖼️', 'Gallery', Colors.white, () => _pickImage(ImageSource.gallery), bordered: true),
          ],
        ),
      ],
    );
  }

  Widget _scanCard(String emoji, String label, Color bg, VoidCallback tap, {bool bordered = false}) {
    return GestureDetector(
      onTap: tap,
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(24),
              border: bordered ? Border.all(color: _WRef.cyan.withOpacity(0.5), width: 2) : Border.all(color: Colors.transparent, width: 2),
              boxShadow: bg != Colors.white 
                ? [BoxShadow(color: _WRef.cyan.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))] 
                : [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5, color: _WRef.deep)),
        ],
      ),
    );
  }

  Widget _buildQuickResources() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _WRef.purple.withOpacity(0.1), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RESOURCES & SUPPORT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _resourceBtn(Icons.help_outline_rounded, 'FAQs', _WRef.cyan, 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WoundFaqScreen()))),
              _resourceBtn(Icons.chat_bubble_rounded, 'Chatbot AI', _WRef.purple, 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen(category: 'wound')))),
              _resourceBtn(Icons.local_hospital_rounded, 'Visit Doctor', _WRef.cyan, 
                () => Navigator.pushNamed(context, '/appointment')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resourceBtn(IconData icon, String label, Color color, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: _WRef.deep)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PREVIEW SCREEN
// ─────────────────────────────────────────────

class _WoundImagePreviewScreen extends StatefulWidget {
  final File imageFile;
  const _WoundImagePreviewScreen({required this.imageFile});

  @override
  State<_WoundImagePreviewScreen> createState() => _WoundImagePreviewScreenState();
}

class _WoundImagePreviewScreenState extends State<_WoundImagePreviewScreen> with TickerProviderStateMixin {
  bool _isAnalyzing = false;
  String _currentStatus = 'INITIALIZING SCAN...';
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    setState(() => _isAnalyzing = true);
    _scanController.repeat();

    final List<String> stages = [
      "DETECTING WOUND BOUNDARIES...",
      "EXTRACTING TISSUE FEATURES...",
      "RUNNING MULTI-SCALE ANALYSIS...",
      "CALCULATING HEALING INDEX...",
      "FINALIZING CLINICAL DATA...",
    ];
    int stageIndex = 0;
    _scanController.addListener(() {
      if (!mounted) return;
      double val = _scanController.value;
      int newIdx = (val * stages.length).floor().clamp(0, stages.length - 1);
      if (stageIndex != newIdx) {
        stageIndex = newIdx;
        setState(() => _currentStatus = stages[stageIndex]);
      }
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('userToken');

      final result = await ApiService.analyzeWound(widget.imageFile.path, token);

      if (mounted) {
        setState(() => _isAnalyzing = false);
        _scanController.stop();

        final primaryLabel = (result['primary'] != null && result['primary']['label'] != null)
            ? result['primary']['label'].toString().toLowerCase()
            : '';
            
        final isInvalid = result['status'] == 'fail' || result['error'] != null || primaryLabel.contains('unclear') || primaryLabel.contains('not a wound');

        if (isInvalid) {
          _showInvalidDialog();
        } else if (result['status'] == 'success') {
          result['imageFile'] = widget.imageFile;
          Navigator.pushReplacementNamed(context, '/wound-results', arguments: result);
        } else {
          _showInvalidDialog(serverError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        _scanController.stop();
        _showInvalidDialog(serverError: true);
      }
    }
  }

  void _showInvalidDialog({bool serverError = false}) {
    if (!mounted) return;

    final displayTitle = serverError ? 'Connection Error' : 'Invalid Wound Image';
    final displayMsg = serverError
        ? 'Could not connect to the analysis server. Please check your connection and try again.'
        : 'No wound pattern was detected in this image. Please upload a clear, close-up photo of the injured area.';

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: _WRef.cyan.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: _WRef.cyan.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.hide_image_outlined, color: _WRef.cyan, size: 38),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  displayTitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _WRef.deep),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Message
                Text(
                  displayMsg,
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF636E72), height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Tips Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _WRef.cyan.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _WRef.cyan.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('📸  Tips for a better scan:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: _WRef.deep)),
                      SizedBox(height: 6),
                      Text('• Ensure the wound is clearly visible', style: TextStyle(fontSize: 11.5, color: Color(0xFF636E72), height: 1.5)),
                      Text('• Use good lighting — avoid dark rooms', style: TextStyle(fontSize: 11.5, color: Color(0xFF636E72), height: 1.5)),
                      Text('• Keep the camera close and in focus', style: TextStyle(fontSize: 11.5, color: Color(0xFF636E72), height: 1.5)),
                      Text('• Do not upload faces unless zoomed in', style: TextStyle(fontSize: 11.5, color: Color(0xFF636E72), height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                // Try Again Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Try Another Image', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _WRef.cyan,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(widget.imageFile, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.6), Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
          ),
          if (_isAnalyzing)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _scanController,
                builder: (context, child) => CustomPaint(painter: WoundScannerPainter(progress: _scanController.value)),
              ),
            ),
          Positioned(
            top: 50, left: 20, right: 20,
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: _isAnalyzing ? null : () => Navigator.pop(context)),
                const Spacer(),
                const Text('PREVIEW', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isAnalyzing) ...[
                    Text(_currentStatus, style: const TextStyle(color: _WRef.cyan, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    const SizedBox(height: 20),
                  ],
                  if (!_isAnalyzing)
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _analyzeImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _WRef.cyan,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 10,
                          shadowColor: _WRef.cyan.withOpacity(0.5),
                        ),
                        child: const Text('START ANALYSIS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
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

class WoundScannerPainter extends CustomPainter {
  final double progress;
  WoundScannerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()..color = _WRef.cyan.withOpacity(0.8)..strokeWidth = 2.0;
    double yPos = (size.height * progress) % size.height;
    Rect beamRect = Rect.fromLTWH(0, yPos - 30, size.width, 60);
    final Shader beamShader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Colors.transparent, _WRef.cyan.withOpacity(0.5), Colors.transparent],
    ).createShader(beamRect);
    canvas.drawRect(beamRect, Paint()..shader = beamShader);
    canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
