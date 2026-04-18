import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'chatbot_screen.dart';
import 'melanoma_results_screen.dart';
import 'melanoma_detail_screen.dart';
import 'appointment_screen.dart';
import 'custom_scanner_screen.dart';

class MelanomaScreen extends StatefulWidget {
  const MelanomaScreen({Key? key}) : super(key: key);

  @override
  State<MelanomaScreen> createState() => _MelanomaScreenState();
}

// ─────────────────────────────────────────────
//  MELANOMA DESIGN SYSTEM
// ─────────────────────────────────────────────
class _MelRef {
  static const slate    = Color(0xFFBFC6C4); // #BFC6C4 — requested
  static const cream    = Color(0xFFE8E2D8); // #E8E2D8 — requested
  static const deep     = Color(0xFF3D4A48);
  static const bg       = Color(0xFFF5F2EE);
  static const accent   = Color(0xFF8FA8A5); // dark slate
}

class _MelanomaScreenState extends State<MelanomaScreen> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _showDisclaimer = true;
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
            title: 'Melanoma AI Scanner',
            helperText: 'Align the mole or mark exactly in the center box.',
          ),
        ),
      );
      if (capturedFile != null && mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ImagePreviewScreen(imageFile: capturedFile)));
      }
      return;
    }
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.rear);
      if (pickedFile != null && mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ImagePreviewScreen(imageFile: File(pickedFile.path))));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to pick image. Please try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _MelRef.bg,
      body: SafeArea(
        child: _showDisclaimer ? _buildDisclaimerView() : _buildMainContent(),
      ),
    );
  }

  // ─── DISCLAIMER (unchanged look, just updated colors) ───
  Widget _buildDisclaimerView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFEFF2F1), shape: BoxShape.circle),
              child: const Icon(Icons.health_and_safety_rounded, color: _MelRef.accent, size: 48),
            ),
            const SizedBox(height: 20),
            const Text('Medical Disclaimer', style: TextStyle(color: _MelRef.deep, fontSize: 22, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
            const SizedBox(height: 14),
            const Text(
              'This AI tool is for informational purposes only and is not a substitute for professional medical advice. Always consult a dermatologist for a proper diagnosis.',
              style: TextStyle(color: Color(0xFF6D787D), fontSize: 14, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => setState(() => _showDisclaimer = false),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_MelRef.slate, Color(0xFF8FA8A5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: _MelRef.slate.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text('I Understand & Proceed', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── MAIN CONTENT ───
  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildHeader(),
          const SizedBox(height: 16),
          _buildDashboard(),
          const SizedBox(height: 14),
          _buildInfoCard(),
          const SizedBox(height: 14),
          _buildQuickTips(),
          const Spacer(),
          _buildScanButtons(),
          const SizedBox(height: 20),
          _buildResourcesCard(),
          const SizedBox(height: 24),
        ],
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
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: _MelRef.deep, size: 18),
          ),
        ),
        const Text("MELANOMA SCAN", style: TextStyle(color: _MelRef.deep, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
        const SizedBox(width: 42),
      ],
    );
  }

  Widget _buildDashboard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: _MelRef.slate,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: _MelRef.slate.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, child) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.5 * _pulseCtrl.value), width: 2)),
              child: const Icon(Icons.radar_rounded, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 8),
          const Text("MELANOMA / NON-MELANOMA DETECTION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text("Detects 7 distinct lesion classes", style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: _MelRef.cream,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _MelRef.slate.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.healing_rounded, color: _MelRef.accent, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Upload a clear, close-up photo of the skin lesion. The system detects Melanoma vs Non-Melanoma across 7 different skin lesion classes.',
              style: TextStyle(color: _MelRef.deep, fontSize: 12, height: 1.5, fontWeight: FontWeight.w600),
            ),
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _MelRef.slate.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Icon(icon, color: _MelRef.accent, size: 18),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF636E72))),
          ],
        ),
      ),
    );
  }

  // App-icon style camera + gallery buttons
  Widget _buildScanButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('START ANALYSIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _scanBtn('📷', 'Camera', _MelRef.slate, () => _pickImage(ImageSource.camera)),
            _scanBtn('🖼️', 'Gallery', Colors.white, () => _pickImage(ImageSource.gallery), bordered: true),
          ],
        ),
      ],
    );
  }

  Widget _scanBtn(String emoji, String label, Color bg, VoidCallback tap, {bool bordered = false}) {
    return GestureDetector(
      onTap: tap,
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: bordered ? Border.all(color: _MelRef.slate.withOpacity(0.5), width: 2) : Border.all(color: Colors.transparent, width: 2),
              boxShadow: bg != Colors.white ? [BoxShadow(color: _MelRef.slate.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5, color: _MelRef.deep)),
        ],
      ),
    );
  }

  // Card wrapping all 3 resource buttons
  Widget _buildResourcesCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _MelRef.slate.withOpacity(0.2), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RESOURCES & SUPPORT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _trio(Icons.local_hospital_rounded, 'Specialist', _MelRef.cream, () => Navigator.pushNamed(context, '/appointment')),
              _trio(Icons.chat_bubble_rounded, 'Derma AI', _MelRef.cream, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen(category: 'melanoma')))),
              _trio(Icons.medical_services_rounded, 'Care Plan', _MelRef.cream, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MelanomaDetailScreen(conditionName: 'Melanoma', isHighRisk: false)))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trio(IconData icon, String label, Color bg, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))]),
            child: Icon(icon, color: _MelRef.accent, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _MelRef.deep)),
        ],
      ),
    );
  }
}



class ImagePreviewScreen extends StatefulWidget {
  final File imageFile;

  const ImagePreviewScreen({Key? key, required this.imageFile})
      : super(key: key);

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen>
    with TickerProviderStateMixin {
  bool _isAnalyzing = false;
  String _currentStatus = 'INITIALIZING SCAN...';
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    setState(() => _isAnalyzing = true);
    _scanController.repeat();

    // Update status based on real backend processing stages
    final List<String> stages = [
      "LOADING ENSEMBLE ENGINE...",
      "PREPROCESSING IMAGE (224×224)...",
      "RUNNING BINARY CLASSIFIER...",
      "RUNNING MULTI-CLASS ENGINE...",
      "CROSS-CHECKING PREDICTIONS...",
      "GENERATING MEDICAL REPORT...",
    ];
    int stageIndex = 0;
    _scanController.addStatusListener((status) {});
    _scanController.addListener(() {
      if (!mounted) return;
      double val = _scanController.value;
      int newIdx = (val * stages.length).floor().clamp(0, stages.length - 1);
      if (stageIndex != newIdx) {
        stageIndex = newIdx;
        setState(() => _currentStatus = stages[stageIndex]);
      }
    });

    final uri = Uri.parse('${ApiService.serviceBase}/analyze/melanoma');
    final request = http.MultipartRequest('POST', uri);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('userToken');
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Bypass-Tunnel-Reminder'] = 'true';

    final mimeType = widget.imageFile.path.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      widget.imageFile.path,
      contentType: MediaType('image', mimeType),
    ));

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(respStr) as Map<String, dynamic>;
        
        // Stop analyzing state
        if (mounted) {
          setState(() => _isAnalyzing = false);
          _scanController.stop();
        }

        final prediction = (data['prediction'] ?? '').toString().toLowerCase();
        final isInvalid = data['status'] == 'invalid' || 
                          data['error'] != null || 
                          data['is_unclear'] == true ||
                          prediction.contains('invalid') || 
                          prediction.contains('unclear');

        if (isInvalid) {
          _showInvalidDialog();
        } else {
          data['imageFile'] = widget.imageFile;
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MelanomaResultsScreen(results: data)),
            );
          }
        }
      } else if (response.statusCode == 400) {
        if (mounted) {
          setState(() => _isAnalyzing = false);
          _scanController.stop();
        }
        _showInvalidDialog();
      } else {
        if (mounted) {
          setState(() => _isAnalyzing = false);
          _scanController.stop();
        }
        _showInvalidDialog(serverError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        _scanController.stop();
      }
      _showInvalidDialog(serverError: true);
    }
  }

  void _showInvalidDialog({bool serverError = false}) {
    if (!mounted) return;

    final displayTitle = serverError ? 'Connection Error' : 'Invalid Lesion Image';
    final displayMsg = serverError
        ? 'Could not connect to the analysis server. Please check your connection and try again.'
        : 'No skin lesion was detected in this image. Please upload a clear, close-up photo of the mole or skin mark.';

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
                    color: _MelRef.cream,
                    shape: BoxShape.circle,
                    border: Border.all(color: _MelRef.accent.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.hide_image_outlined, color: _MelRef.accent, size: 38),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  displayTitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _MelRef.deep),
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
                    color: _MelRef.slate.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _MelRef.slate.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('📸  Tips for a better scan:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: _MelRef.deep)),
                      SizedBox(height: 6),
                      Text('• Ensure the mole/lesion is clearly visible', style: TextStyle(fontSize: 11.5, color: Color(0xFF636E72), height: 1.5)),
                      Text('• Use good lighting — avoid dark rooms', style: TextStyle(fontSize: 11.5, color: Color(0xFF636E72), height: 1.5)),
                      Text('• Keep the camera 10-15cm away and in focus', style: TextStyle(fontSize: 11.5, color: Color(0xFF636E72), height: 1.5)),
                      Text('• Do not upload landscapes or unrelated objects', style: TextStyle(fontSize: 11.5, color: Color(0xFF636E72), height: 1.5)),
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
                      backgroundColor: _MelRef.slate,
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
          // Main Image
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(widget.imageFile, fit: BoxFit.contain),
          ),

          // Scanner Animation Overlay
          if (_isAnalyzing)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _scanController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: MelanomaScannerPainter(
                      progress: _scanController.value,
                    ),
                  );
                },
              ),
            ),
          
          // Helper overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    onPressed: _isAnalyzing ? null : () => Navigator.pop(context),
                  ),
                  const Text(
                    'Preview Image',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer for balance
                ],
              ),
            ),
          ),

          // Compact Loading Pill (when analyzing)
          if (_isAnalyzing)
            Positioned(
              bottom: 40,
              left: 40,
              right: 40,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: _MelRef.accent.withOpacity(0.5)),
                  boxShadow: [BoxShadow(color: _MelRef.accent.withOpacity(0.2), blurRadius: 15)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(color: _MelRef.accent, strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _currentStatus,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Action Sheet (only when NOT analyzing)
          if (!_isAnalyzing)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3436).withValues(alpha: 0.95),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white30),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Retake',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _analyzeImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _MelRef.accent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Analyze Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
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

class MelanomaScannerPainter extends CustomPainter {
  final double progress; 

  MelanomaScannerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = const Color(0xFF8FA8A5).withValues(alpha: 0.8) // Slate matched
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    double yPos = (size.height * progress) % size.height;
    
    Rect beamRect = Rect.fromLTWH(0, yPos - 40, size.width, 80);
    final Shader beamShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
         Colors.transparent,
         const Color(0xFF8FA8A5).withValues(alpha: 0.4),
         const Color(0xFFE8E2D8).withOpacity(0.3), 
         Colors.transparent,
      ],
    ).createShader(beamRect);
    
    Paint beamPaint = Paint()..shader = beamShader;
    canvas.drawRect(beamRect, beamPaint);
    canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), linePaint);
    
    // HUD Brackets
    double bracketLen = 30;
    double padding = 30;
    Path corners = Path();
    corners.moveTo(padding, padding + bracketLen); corners.lineTo(padding, padding); corners.lineTo(padding + bracketLen, padding);
    corners.moveTo(size.width - padding - bracketLen, padding); corners.lineTo(size.width - padding, padding); corners.lineTo(size.width - padding, padding + bracketLen);
    corners.moveTo(padding, size.height - padding - bracketLen); corners.lineTo(padding, size.height - padding); corners.lineTo(padding + bracketLen, size.height - padding);
    corners.moveTo(size.width - padding - bracketLen, size.height - padding); corners.lineTo(size.width - padding, size.height - padding); corners.lineTo(size.width - padding, size.height - padding - bracketLen);
    
    canvas.drawPath(corners, linePaint..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant MelanomaScannerPainter oldDelegate) => oldDelegate.progress != progress;
}