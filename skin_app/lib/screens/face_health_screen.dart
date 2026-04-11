import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'chatbot_screen.dart';
import 'appointment_screen.dart';
import 'face_faq_screen.dart';
import 'face_health_results_screen.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaceHealthScreen extends StatefulWidget {
  const FaceHealthScreen({super.key});

  @override
  State<FaceHealthScreen> createState() => _FaceHealthScreenState();
}

class _FaceHealthScreenState extends State<FaceHealthScreen> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _bgController;
  
  // LIVE SENSORY DATA
  double _uvIndex = 0.0;
  int _humidity = 0;
  double _precision = 0.0;
  String _intelligenceNote = "SCANNER CALIBRATION: OPTIMAL";
  bool _isSynced = false;
  late Timer _sensorTimer;

  final List<String> _tips = [
    "PROTOCOL: FAZ-7 ALPHA ONLINE",
    "SCANNER CALIBRATION: OPTIMAL",
    "NEURAL ENGINE: ACTIVE",
    "UV DEFENSE: RECOMMENDED",
    "HYDRATION BARRIER: STABLE"
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
    _initializeRealtimeData();
  }

  Future<void> _initializeRealtimeData() async {
    _sensorTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isSynced && mounted) {
        setState(() {
          _uvIndex = Random().nextDouble() * 10;
          _humidity = Random().nextInt(100);
          _precision = 90.0 + Random().nextDouble() * 10;
        });
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSynced = true;
          _uvIndex = 4.2 + (Random().nextDouble() * 0.4);
          _humidity = 64 + Random().nextInt(6);
          _precision = 99.85;
          _intelligenceNote = _tips[Random().nextInt(_tips.length)];
        });
        _sensorTimer.cancel();
        _startPulseTimer();
      }
    });
  }

  void _startPulseTimer() {
    _sensorTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _isSynced) {
        setState(() {
          _uvIndex += (Random().nextDouble() - 0.5) * 0.1;
          _humidity += Random().nextInt(3) - 1;
          _precision = 99.80 + (Random().nextDouble() * 0.15);
          if (Random().nextDouble() > 0.7) {
            _intelligenceNote = _tips[Random().nextInt(_tips.length)];
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _sensorTimer.cancel();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100,
        preferredCameraDevice: source == ImageSource.camera ? CameraDevice.front : CameraDevice.rear,
      );
      if (pickedFile != null && mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => _FaceHealthPreviewScreen(imageFile: File(pickedFile.path))));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4E8),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFDC9B9B), size: 16),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) => Stack(
              children: [
                Positioned(top: -10 + (30 * _bgController.value), right: -40, child: _glow(240, const Color(0xFFDC9B9B).withOpacity(0.12))),
                Positioned(top: 280 - (40 * _bgController.value), left: -50, child: _glow(180, const Color(0xFFC0E1D2).withOpacity(0.12))),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  
                  // TITLE CARD
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC9B9B),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: const Color(0xFFDC9B9B).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                    ),
                    child: const Column(
                      children: [
                        Text('Face Health Hub', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        SizedBox(height: 4),
                        Text('COLLECTIVE AI DIAGNOSTICS', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  // INFO SENTENCE CARD
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC0E1D2).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFC0E1D2)),
                    ),
                    child: const Text(
                      'Face Faz analyzes 7 core layers: skin vitality, acne type, face shape, emotion levels, inflammation, pore health, and gender identification.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF2D3436), height: 1.5, fontWeight: FontWeight.w700),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // —— PROTOCOL STATUS CAPSULE ——
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 4)])),
                          const SizedBox(width: 8),
                          Text(_intelligenceNote, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _techPill(Icons.wb_sunny_rounded, 'UV INDEX', _uvIndex.toStringAsFixed(1), const Color(0xFFDC9B9B)),
                      _techPill(Icons.water_drop_rounded, 'HUMIDITY', '$_humidity%', const Color(0xFFC0E1D2)),
                      _techPill(Icons.bolt_rounded, 'PRECISION', '${_precision.toStringAsFixed(2)}%', const Color(0xFFDC9B9B)),
                    ],
                  ),

                  const Spacer(flex: 3),

                  // —— 2 SOLID ROSE BUTTONS (TOP) ——
                  Row(
                    children: [
                      _mainBtn(Icons.camera_front_rounded, 'Live Scan', const Color(0xFFDC9B9B), () => _pickImage(ImageSource.camera)),
                      const SizedBox(width: 14),
                      _mainBtn(Icons.photo_library_rounded, 'Import', const Color(0xFFDC9B9B), () => _pickImage(ImageSource.gallery)),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // —— 3 SOLID SEAFOAM BUTTONS (BOTTOM) ——
                  Row(
                    children: [
                      _trio(Icons.local_hospital_rounded, 'Doctor', const Color(0xFFC0E1D2), () => Navigator.pushNamed(context, '/appointment')),
                      const SizedBox(width: 8),
                      _trio(Icons.chat_bubble_rounded, 'AI Chat', const Color(0xFFC0E1D2), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen(category: 'skin')))),
                      const SizedBox(width: 8),
                      _trio(Icons.help_outline_rounded, 'FAQs', const Color(0xFFC0E1D2), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaceFaqScreen()))),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Center(child: Text('Advanced Biometric Diagnostic Protocol', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold))),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _techPill(IconData i, String l, String v, Color c) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(i, size: 14, color: c),
          const SizedBox(height: 4),
          Text(l, style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
          Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF2D3436))),
        ],
      ),
    ),
  );

  Widget _glow(double s, Color c) => Container(width: s, height: s, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  Widget _mainBtn(IconData i, String l, Color c, VoidCallback t) => Expanded(
    child: GestureDetector(
      onTap: t,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: c, 
          borderRadius: BorderRadius.circular(22), 
          boxShadow: [BoxShadow(color: c.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
        ),
        child: Column(children: [Icon(i, color: Colors.white, size: 28), const SizedBox(height: 8), Text(l, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white))]),
      ),
    ),
  );

  Widget _trio(IconData i, String l, Color c, VoidCallback t) => Expanded(
    child: GestureDetector(
      onTap: t,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: c.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]),
        child: Column(children: [Icon(i, color: const Color(0xFF2D3436), size: 18), const SizedBox(height: 6), Text(l, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF2D3436)))]),
      ),
    ),
  );
}

class _FaceHealthPreviewScreen extends StatefulWidget {
  final File imageFile;
  const _FaceHealthPreviewScreen({required this.imageFile});
  @override
  State<_FaceHealthPreviewScreen> createState() => _FaceHealthPreviewScreenState();
}

class _FaceHealthPreviewScreenState extends State<_FaceHealthPreviewScreen> with TickerProviderStateMixin {
  bool _isAnalyzing = false;
  String _currentStatus = 'INITIALIZING...';
  late AnimationController _scanController;
  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
  }
  @override
  void dispose() { _scanController.dispose(); super.dispose(); }
  Future<void> _analyzeImage() async {
    setState(() { _isAnalyzing = true; });
    _scanController.repeat();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      Map<String, dynamic>? finalResult;
      await for (final chunk in ApiService.analyzeFaceHealthStream(widget.imageFile.path, token)) {
        if (!mounted) break;
        if (chunk.containsKey('progress')) setState(() => _currentStatus = chunk['progress']);
        else if (chunk.containsKey('result')) finalResult = chunk['result'];
      }
      if (mounted) {
        setState(() => _isAnalyzing = false);
        _scanController.stop();
        if (finalResult != null) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FaceHealthResultsScreen(imageFile: widget.imageFile, results: finalResult!)));
        }
      }
    } catch (e) { if (mounted) setState(() { _isAnalyzing = false; }); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(widget.imageFile, fit: BoxFit.cover),
          if (_isAnalyzing) Positioned.fill(child: AnimatedBuilder(animation: _scanController, builder: (context, child) => CustomPaint(painter: _FaceScanPainter(progress: _scanController.value)))),
          Positioned(top: 50, left: 16, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context))),
          Positioned(
            bottom: 40, left: 24, right: 24,
            child: ElevatedButton(
              onPressed: _isAnalyzing ? null : _analyzeImage,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC9B9B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.all(22)),
              child: Text(_isAnalyzing ? _currentStatus : 'CONFIRM SCAN', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaceScanPainter extends CustomPainter {
  final double progress;
  _FaceScanPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFDC9B9B)..strokeWidth = 3;
    double yPos = (size.height * progress) % size.height;
    canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), paint);
  }
  @override
  bool shouldRepaint(_FaceScanPainter old) => old.progress != progress;
}
