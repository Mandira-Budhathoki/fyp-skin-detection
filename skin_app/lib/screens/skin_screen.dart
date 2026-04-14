import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'skin_results_screen.dart';
import 'custom_scanner_screen.dart';
import 'appointment_screen.dart';
import 'chatbot_screen.dart';
import 'faq_screen.dart';

// ─────────────────────────────────────────────
//  PREMIUM SAGE & GREEN DESIGN SYSTEM
// ─────────────────────────────────────────────
class _SkinRef {
  static const sage      = Color(0xFF9AB17A); // Requested #9AB17A
  static const paleGreen = Color(0xFFE5EEE4); // Requested #E5EEE4
  static const deepText  = Color(0xFF2D3436);
  static const bgSoft    = Color(0xFFFBFCFB);
}

class SkinScreen extends StatefulWidget {
  const SkinScreen({super.key});

  @override
  State<SkinScreen> createState() => _SkinScreenState();
}

class _SkinScreenState extends State<SkinScreen> with TickerProviderStateMixin {
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

  Future<void> _getImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final File? capturedFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomScannerScreen(
            title: 'Dermal AI Analyzer',
            helperText: 'Align the skin area clearly in the frame.',
          ),
        ),
      );
      if (capturedFile != null && mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => _SkinPreviewScreen(imageFile: capturedFile)));
      }
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 100);
    if (pickedFile != null && mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => _SkinPreviewScreen(imageFile: File(pickedFile.path))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SkinRef.bgSoft,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildModernDashboard(),
              const SizedBox(height: 24),
              _buildPathologyCard(),
              const Spacer(),
              _buildMainActions(),
              const SizedBox(height: 24),
              _buildFunctionalRow(),
              const SizedBox(height: 20),
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
        _circleIcon(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
        const Text("SKIN DIAGNOSTICS", style: TextStyle(color: _SkinRef.deepText, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
        _circleIcon(Icons.qr_code_scanner_rounded, null, color: _SkinRef.sage),
      ],
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback? tap, {Color color = _SkinRef.deepText}) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildModernDashboard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: _SkinRef.sage, borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: _SkinRef.sage.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, child) => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.5 * _pulseCtrl.value), width: 2)),
              child: const Icon(Icons.biotech_rounded, color: Colors.white, size: 50),
            ),
          ),
          const SizedBox(height: 20),
          const Text("AI DERMA-SCANNER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
          const Text("Multiple medical layers active", style: TextStyle(color: _SkinRef.paleGreen, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPathologyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _SkinRef.paleGreen, borderRadius: BorderRadius.circular(32),
        border: Border.all(color: _SkinRef.sage.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.shield_rounded, color: _SkinRef.sage, size: 20),
              SizedBox(width: 12),
              Text("CLINICAL CAPABILITIES", style: TextStyle(color: _SkinRef.sage, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "This AI system is fine-tuned to detect Acne, Milia (White Bumps), Eczema, Rosacea, and various Skin Pathologies with neural-layer precision.",
            style: TextStyle(color: _SkinRef.deepText, fontSize: 13, height: 1.6, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActions() {
    return Row(
      children: [
        Expanded(child: _emojiBtn("CAMERA", "📷", _SkinRef.sage, Colors.white, () => _getImage(ImageSource.camera))),
        const SizedBox(width: 16),
        Expanded(child: _emojiBtn("GALLERY", "🖼️", Colors.white, _SkinRef.sage, () => _getImage(ImageSource.gallery), bordered: true)),
      ],
    );
  }

  Widget _emojiBtn(String label, String emoji, Color bg, Color tc, VoidCallback tap, {bool bordered = false}) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(24),
          border: bordered ? Border.all(color: _SkinRef.sage.withOpacity(0.2)) : null,
          boxShadow: bg != Colors.white ? [BoxShadow(color: bg.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: tc, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionalRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: _SkinRef.sage.withOpacity(0.1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.medical_services_rounded, "VISIT DOCTOR", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AppointmentScreen()))),
          _navItem(Icons.chat_bubble_rounded, "AI CHATBOT", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotScreen()))),
          _navItem(Icons.help_center_rounded, "FAQs", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqScreen()))),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Column(
        children: [
          Icon(icon, color: _SkinRef.sage, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: _SkinRef.sage, fontSize: 8, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PREVIEW SCREEN
// ─────────────────────────────────────────────
class _SkinPreviewScreen extends StatefulWidget {
  final File imageFile;
  const _SkinPreviewScreen({required this.imageFile});
  @override
  State<_SkinPreviewScreen> createState() => _SkinPreviewScreenState();
}

class _SkinPreviewScreenState extends State<_SkinPreviewScreen> with TickerProviderStateMixin {
  bool _isAnalyzing = false;
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? prefs.getString('userToken');
      final result = await ApiService.analyzeSkinAcne(widget.imageFile.path, token);
      
      if (mounted) {
        setState(() => _isAnalyzing = false);
        _scanController.stop();
        if (result['status'] == 'error' || result['success'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Analysis Failed')));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SkinResultsScreen(image: widget.imageFile, results: result)));
        }
      }
    } catch (e) { 
      if (mounted) {
        setState(() => _isAnalyzing = false);
        _scanController.stop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
          Image.file(widget.imageFile, fit: BoxFit.cover),
          if (_isAnalyzing) Positioned.fill(child: AnimatedBuilder(animation: _scanController, builder: (context, child) => CustomPaint(painter: _SkinScanPainter(progress: _scanController.value)))),
          Positioned(top: 50, left: 16, child: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context))),
          Positioned(
            bottom: 40, left: 30, right: 30,
            child: GestureDetector(
              onTap: _isAnalyzing ? null : _analyzeImage,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: _SkinRef.sage,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: _SkinRef.sage.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Center(
                  child: Text(
                    _isAnalyzing ? "ANALYZING DERMIS..." : "CONFIRM BIOMETRIC SCAN",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
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

class _SkinScanPainter extends CustomPainter {
  final double progress;
  _SkinScanPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _SkinRef.paleGreen..strokeWidth = 4..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    double yPos = (size.height * progress) % size.height;
    canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), paint);
  }
  @override
  bool shouldRepaint(_SkinScanPainter old) => old.progress != progress;
}
