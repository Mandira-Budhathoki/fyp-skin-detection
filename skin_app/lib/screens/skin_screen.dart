import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
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
              const SizedBox(height: 8),
              _buildHeader(),
              const SizedBox(height: 12),
              _buildModernDashboard(),
              const SizedBox(height: 12),
              _buildPathologyCard(),
              const Spacer(),
              _buildQuickTips(),
              const SizedBox(height: 16),
              _buildMainActions(),
              const SizedBox(height: 16),
              _buildFunctionalRow(),
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
        _circleIcon(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
        const Text("SKIN DIAGNOSTICS", style: TextStyle(color: _SkinRef.deepText, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
        const SizedBox(width: 42), // keeps title centered
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: _SkinRef.sage, borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: _SkinRef.sage.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, child) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.5 * _pulseCtrl.value), width: 2)),
              child: const Icon(Icons.biotech_rounded, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 8),
          const Text("AI DERMA-SCANNER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
          const SizedBox(height: 2),
          const Text("Multiple medical layers active", style: TextStyle(color: _SkinRef.paleGreen, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPathologyCard() {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced from 24
      decoration: BoxDecoration(
        color: _SkinRef.paleGreen, borderRadius: BorderRadius.circular(24), // Reduced from 32
        border: Border.all(color: _SkinRef.sage.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.shield_rounded, color: _SkinRef.sage, size: 18),
              SizedBox(width: 10),
              Text("CLINICAL CAPABILITIES", style: TextStyle(color: _SkinRef.sage, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "This AI system is fine-tuned to detect Acne, Milia (White Bumps), Eczema, Rosacea, and various Skin Pathologies with neural-layer precision.",
            style: TextStyle(color: _SkinRef.deepText, fontSize: 12, height: 1.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTips() {
    return Row(
      children: [
        _tipChip(Icons.wb_sunny_rounded, 'Good Lighting'),
        const SizedBox(width: 10),
        _tipChip(Icons.center_focus_strong_rounded, 'Close-Up'),
        const SizedBox(width: 10),
        _tipChip(Icons.flash_off_rounded, 'No Flash'),
      ],
    );
  }

  Widget _tipChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _SkinRef.sage.withOpacity(0.15)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Icon(icon, color: _SkinRef.sage, size: 20),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF636E72), letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('START ANALYSIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _emojiBtn("Camera", "📷", _SkinRef.sage, Colors.white, () => _getImage(ImageSource.camera)),
            _emojiBtn("Gallery", "🖼️", Colors.white, _SkinRef.sage, () => _getImage(ImageSource.gallery), bordered: true),
          ],
        ),
      ],
    );
  }

  Widget _emojiBtn(String label, String emoji, Color bg, Color tc, VoidCallback tap, {bool bordered = false}) {
    return GestureDetector(
      onTap: tap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: bordered 
                ? Border.all(color: _SkinRef.sage.withOpacity(0.5), width: 2)
                : Border.all(color: Colors.transparent, width: 2),
              boxShadow: bg != Colors.white
                ? [BoxShadow(color: bg.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]
                : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5, color: Color(0xFF2D3436))),
        ],
      ),
    );
  }

  Widget _buildFunctionalRow() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _SkinRef.sage.withOpacity(0.15), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RESOURCES & SUPPORT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(Icons.medical_services_rounded, "Visit Doctor", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AppointmentScreen()))),
              _navItem(Icons.chat_bubble_rounded, "AI Chatbot", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotScreen()))),
              _navItem(Icons.help_center_rounded, "FAQs", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqScreen()))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _SkinRef.paleGreen,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _SkinRef.sage.withOpacity(0.2), width: 1.5),
              boxShadow: [BoxShadow(color: _SkinRef.sage.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Center(child: Icon(icon, color: _SkinRef.sage, size: 26)),
          ),
          const SizedBox(height: 7),
          Text(label, style: const TextStyle(color: _SkinRef.sage, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
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

        final isInvalid = result['status'] == 'warning'
            || result['status'] == 'error'
            || result['success'] == false
            || (result['prediction'] ?? '').toString().toLowerCase().contains('invalid')
            || (result['prediction'] ?? '').toString().toLowerCase().contains('unclear');

        if (isInvalid) {
          final errTitle = result['prediction'] ?? 'Invalid Image';
          final errMsg = result['message'] ?? 'No skin detected. Please upload a clear photo of actual skin.';
          _showInvalidImageSheet(errTitle, errMsg);
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SkinResultsScreen(image: widget.imageFile, results: result)));
        }
      }
    } catch (e) { 
      if (mounted) {
        setState(() => _isAnalyzing = false);
        _scanController.stop();
        _showInvalidImageSheet('Connection Error', 'Failed to connect to the AI server. Please check your internet connection and try again.');
      }
    }
  }

  void _showInvalidImageSheet(String title, String message) {
    final displayTitle = 'Unable to Process Image';
    final displayMsg = (message.toLowerCase().contains('connect') || message.toLowerCase().contains('server'))
        ? 'Something went wrong. Please try again with a clearer image.'
        : message;

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
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5EE),
                    shape: BoxShape.circle,
                    border: Border.all(color: _SkinRef.sage.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.image_search_rounded, color: _SkinRef.sage, size: 38),
                ),
                const SizedBox(height: 20),
                Text(displayTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2D3436)), textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Text(displayMsg, style: const TextStyle(fontSize: 13.5, color: Color(0xFF636E72), height: 1.6), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _SkinRef.paleGreen.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _SkinRef.sage.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Tips for a better scan:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF2D3436))),
                      SizedBox(height: 6),
                      Text('  Hold camera close to the skin area', style: TextStyle(fontSize: 11.5, color: Color(0xFF636E72), height: 1.5)),
                      Text('  Use good lighting and avoid dark rooms', style: TextStyle(fontSize: 11.5, color: Color(0xFF636E72), height: 1.5)),
                      Text('  Ensure the skin fills most of the frame', style: TextStyle(fontSize: 11.5, color: Color(0xFF636E72), height: 1.5)),
                      Text('  Do not upload food, objects or scenery', style: TextStyle(fontSize: 11.5, color: Color(0xFF636E72), height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _SkinRef.sage,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
          if (_isAnalyzing) Positioned.fill(child: AnimatedBuilder(animation: _scanController, builder: (context, child) => CustomPaint(painter: _SkinScanPainter(progress: _scanController.value)))),
          Positioned(top: 50, left: 16, child: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context))),
          Positioned(
            bottom: 40, left: 24, right: 24,
            child: GestureDetector(
              onTap: _isAnalyzing ? null : _analyzeImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 75,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_SkinRef.sage, Color(0xFF7A915A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: _SkinRef.sage.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 10)),
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isAnalyzing)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
                      ),
                    if (!_isAnalyzing) const SizedBox(width: 16),
                    Text(
                      _isAnalyzing ? "ANALYZING DERMIS..." : "INITIATE SKIN SCAN",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5),
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
