import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'skin_results_screen.dart';

// ─────────────────────────────────────────────
//  PREMIUM SAND & WOOD PALETTE (REQUESTED)
// ─────────────────────────────────────────────
class _Pal {
  static const wood     = Color(0xFF504B38); 
  static const olive    = Color(0xFFB9B28A); 
  static const khaki    = Color(0xFFEBE5C2); 
  static const sand     = Color(0xFFF8F3D9); 
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
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 100);
    
    if (pickedFile != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _SkinPreviewScreen(imageFile: File(pickedFile.path)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildB(120, -50, _Pal.sand.withOpacity(0.6), 200),
          _buildB(-70, 480, _Pal.khaki.withOpacity(0.3), 240),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 2),
                  _buildStatusPill(),
                  const SizedBox(height: 8),
                  _buildHeroScanner(),
                  const SizedBox(height: 12),
                  _buildDetectionEngine(),
                  const SizedBox(height: 12),
                  _buildProtocolNote(),
                  const Spacer(),
                  _buildActionCenter(),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildB(double l, double t, Color c, double s) => Positioned(left: l, top: t, child: Container(width: s, height: s, decoration: BoxDecoration(color: c, shape: BoxShape.circle)));

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: _Pal.wood, size: 18), onPressed: () => Navigator.pop(context)),
          const Text("SKIN DIAGNOSTICS", style: TextStyle(color: _Pal.wood, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2)),
          const Icon(Icons.verified_user_rounded, color: _Pal.olive, size: 18),
        ],
      ),
    );
  }

  Widget _buildStatusPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: _Pal.wood.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          const Text("NEURAL STABILITY: 99.8%", style: TextStyle(color: _Pal.wood, fontSize: 7, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildHeroScanner() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) => Container(
        height: 120, width: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _Pal.olive.withOpacity(0.6 * (1 - _pulseCtrl.value)), width: 25 * _pulseCtrl.value),
        ),
        child: const Center(
          child: Icon(Icons.center_focus_strong_rounded, color: _Pal.wood, size: 50),
        ),
      ),
    );
  }

  Widget _buildDetectionEngine() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("CLINICAL DETECTION ENGINE", style: TextStyle(color: _Pal.olive, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 4.2,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _diagChip("🔬", "Acne detection", _Pal.wood, Colors.white),
            _diagChip("🛡️", "Milia detection", _Pal.khaki, _Pal.wood),
            _diagChip("🧫", "Eczema pattern", _Pal.olive, Colors.white),
            _diagChip("🌡️", "Inflammation", _Pal.sand, _Pal.wood),
            _diagChip("🧬", "Healthy dermis", Colors.white, _Pal.wood),
            _diagChip("✨", "Texture health", Colors.white, _Pal.wood),
          ],
        ),
      ],
    );
  }

  Widget _diagChip(String emoji, String text, Color bg, Color tc) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: bg == Colors.white ? Border.all(color: Colors.black.withOpacity(0.05)) : null),
    child: Row(children: [Text(emoji, style: const TextStyle(fontSize: 10)), const SizedBox(width: 6), Expanded(child: Text(text, style: TextStyle(color: tc, fontSize: 8, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))]),
  );

  Widget _buildProtocolNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: _Pal.sand, borderRadius: BorderRadius.circular(18)),
      child: const Text(
        "FAZ-SKIN protocol cross-checks 6 trained neural layers to isolate Acne and Milia clusters with maximum clinical precision.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 9, color: _Pal.wood, height: 1.4, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildActionCenter() {
    return Column(
      children: [
        Row(
          children: [
            _actionBtn("SKIN SCAN", Icons.camera_alt_rounded, _Pal.wood, Colors.white, () => _getImage(ImageSource.camera)),
            const SizedBox(width: 10),
            _actionBtn("IMPORT", Icons.photo_library_rounded, _Pal.olive, Colors.white, () => _getImage(ImageSource.gallery)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: _Pal.khaki.withOpacity(0.3), borderRadius: BorderRadius.circular(15)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _smallBtn(Icons.chat_bubble_rounded, "CHAT"),
              _smallBtn(Icons.medical_services, "DOCTOR"),
              _smallBtn(Icons.help_outline, "FAQ"),
              _smallBtn(Icons.history_rounded, "REPORTS"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(String l, IconData i, Color c, Color tc, VoidCallback tap) => Expanded(
    child: GestureDetector(
      onTap: tap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, color: tc, size: 16), const SizedBox(width: 6), Text(l, style: TextStyle(color: tc, fontWeight: FontWeight.w900, fontSize: 10))]),
      ),
    ),
  );

  Widget _smallBtn(IconData i, String l) => Column(children: [
    Icon(i, color: _Pal.wood, size: 16),
    const SizedBox(height: 2),
    Text(l, style: const TextStyle(color: _Pal.wood, fontSize: 7, fontWeight: FontWeight.w900)),
  ]);
}

class _SkinPreviewScreen extends StatefulWidget {
  final File imageFile;
  const _SkinPreviewScreen({required this.imageFile});
  @override
  State<_SkinPreviewScreen> createState() => _SkinPreviewScreenState();
}

class _SkinPreviewScreenState extends State<_SkinPreviewScreen> with TickerProviderStateMixin {
  bool _isAnalyzing = false;
  String _currentStatus = 'SCANNING DERMIS...';
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
    setState(() { _isAnalyzing = true; });
    _scanController.repeat();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? prefs.getString('userToken');
      
      final result = await ApiService.analyzeSkinAcne(widget.imageFile.path, token);
      
      if (mounted) {
        setState(() => _isAnalyzing = false);
        _scanController.stop();
        if (result['status'] == 'error' || result['success'] == false) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Error analyzing image')));
        } else {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SkinResultsScreen(image: widget.imageFile, results: result)));
        }
      }
    } catch (e) { 
      if (mounted) {
        setState(() { _isAnalyzing = false; }); 
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
          Positioned(top: 50, left: 16, child: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18), onPressed: () => Navigator.pop(context))),
          Positioned(
            bottom: 40, left: 24, right: 24,
            child: ElevatedButton(
              onPressed: _isAnalyzing ? null : _analyzeImage,
              style: ElevatedButton.styleFrom(backgroundColor: _Pal.wood, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.all(22)),
              child: Text(_isAnalyzing ? _currentStatus : 'CONFIRM SCAN', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
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
    final paint = Paint()..color = _Pal.olive..strokeWidth = 3;
    double yPos = (size.height * progress) % size.height;
    canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), paint);
  }
  @override
  bool shouldRepaint(_SkinScanPainter old) => old.progress != progress;
}
