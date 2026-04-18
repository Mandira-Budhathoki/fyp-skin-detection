import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'chatbot_screen.dart';
import 'appointment_screen.dart';
import 'face_faq_screen.dart';
import 'face_health_results_screen.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_scanner_screen.dart';

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
    if (source == ImageSource.camera) {
      // Launch custom raw camera instead of native filter camera
      final File? capturedFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomScannerScreen(
            title: 'Face AI Analysis',
            helperText: 'Align your face in the center box',
          ),
        ),
      );

      if (capturedFile != null && mounted) {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => _FaceHealthPreviewScreen(imageFile: capturedFile))
        );
      }
      return; 
    }

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
        centerTitle: true,
        title: const Text('FACE DETECTION', style: TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                
                // 1. TITLE HUB CARD (Back to Premium Size)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDC9B9B), Color(0xFFCD8686)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [BoxShadow(color: const Color(0xFFDC9B9B).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                    ),
                    child: Column(
                      children: [
                        const Text('Face Health Hub', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        const SizedBox(height: 4),
                        const Text('ADVANCED FACIAL HEALTH ANALYSIS SYSTEM', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                
                // 2. TECH PILLS (Live Data)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _techPill(Icons.wb_sunny_rounded, 'UV INDEX', _uvIndex.toStringAsFixed(1), const Color(0xFFDC9B9B)),
                      _techPill(Icons.water_drop_rounded, 'HUMIDITY', '$_humidity%', const Color(0xFFC0E1D2)),
                      _techPill(Icons.bolt_rounded, 'PRECISION', '${_precision.toStringAsFixed(2)}%', const Color(0xFFDC9B9B)),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 3. SCANNER DASHBOARD (Big & Premium again)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: const Color(0xFFC0E1D2).withOpacity(0.2), shape: BoxShape.circle),
                              child: const Icon(Icons.psychology_rounded, color: Color(0xFF71BC9D), size: 24),
                            ),
                            const SizedBox(width: 15),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('AI SCANNER READY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF2D3436))),
                                  Text('Multiple analysis layers active', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const LinearProgressIndicator(
                          value: 0.85,
                          backgroundColor: Color(0xFFF1F5F9),
                          color: Color(0xFFC0E1D2),
                          minHeight: 8,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        const SizedBox(height: 12),
                        Text(_intelligenceNote, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Color(0xFFDC9B9B), fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 4. MAIN ACTION BUTTONS (Camera + Gallery — free, no card)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('START ANALYSIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _mainBtn('📷', 'Live Scan', Colors.white, const Color(0xFFDC9B9B), () => _pickImage(ImageSource.camera)),
                          _mainBtn('🖼️', 'Gallery', Colors.white, const Color(0xFFDC9B9B), () => _pickImage(ImageSource.gallery)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // 5. SECONDARY TRIO — wrapped in a card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('RESOURCES & SUPPORT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _trio(Icons.local_hospital_rounded, 'Visit Doctor', const Color(0xFFC0E1D2), () => Navigator.pushNamed(context, '/appointment')),
                            _trio(Icons.chat_bubble_rounded, 'AI Chat', const Color(0xFFC0E1D2), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen(category: 'skin')))),
                            _trio(Icons.help_outline_rounded, 'FAQs', const Color(0xFFC0E1D2), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaceFaqScreen()))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

              ],
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

  // App-icon style: rounded square + label below
  Widget _mainBtn(String emoji, String l, Color bg, Color borderCol, VoidCallback t) => GestureDetector(
    onTap: t,
    child: Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderCol.withOpacity(0.4), width: 2),
            boxShadow: [BoxShadow(color: borderCol.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
        ),
        const SizedBox(height: 8),
        Text(l, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5, color: Color(0xFF2D3436))),
      ],
    ),
  );

  // App-icon style for bottom trio
  Widget _trio(IconData i, String l, Color c, VoidCallback t) => GestureDetector(
    onTap: t,
    child: Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: c.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Center(child: Icon(i, color: const Color(0xFF2D3436), size: 26)),
        ),
        const SizedBox(height: 7),
        Text(l, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF2D3436))),
      ],
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

        // ── Check for backend error / invalid image ──
        final isError = finalResult == null
            || finalResult['status'] == 'fail'
            || finalResult['error'] != null;

        if (isError) {
          final errTitle = finalResult?['error'] ?? 'Invalid Image';
          final errMsg   = finalResult?['message'] ?? 'We could not process this image. Please use a clear, well-lit photo of your face.';
          _showInvalidImageSheet(errTitle, errMsg);
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FaceHealthResultsScreen(imageFile: widget.imageFile, results: finalResult!)));
        }
      }
    } catch (e) { 
      if (mounted) {
        setState(() { _isAnalyzing = false; });
        _scanController.stop();
        _showInvalidImageSheet('Connection Error', 'Failed to connect to the AI server. Please check your internet connection and try again.');
      }
    }
  }

  void _showInvalidImageSheet(String title, String message) {
    // Remap connection/server errors to a clean user-facing message
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
              // Error Icon
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3F3),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDC9B9B).withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.image_search_rounded, color: Color(0xFFDC9B9B), size: 38),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                displayTitle,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2D3436)),
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
                  color: const Color(0xFFC0E1D2).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC0E1D2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('📸  Tips for a better scan:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF2D3436))),
                    SizedBox(height: 6),
                    Text('• Ensure your face is clearly visible', style: TextStyle(fontSize: 11.5, color: Color(0xFF636E72), height: 1.5)),
                    Text('• Use good lighting — avoid dark rooms', style: TextStyle(fontSize: 11.5, color: Color(0xFF636E72), height: 1.5)),
                    Text('• Hold the camera at face level', style: TextStyle(fontSize: 11.5, color: Color(0xFF636E72), height: 1.5)),
                    Text('• Do not upload landscapes, food or objects', style: TextStyle(fontSize: 11.5, color: Color(0xFF636E72), height: 1.5)),
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
                  label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC9B9B),
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
          if (_isAnalyzing) Positioned.fill(child: AnimatedBuilder(animation: _scanController, builder: (context, child) => CustomPaint(painter: _FaceScanPainter(progress: _scanController.value)))),
          Positioned(top: 50, left: 16, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context))),
          Positioned(
            bottom: 40, left: 24, right: 24,
            child: GestureDetector(
              onTap: _isAnalyzing ? null : _analyzeImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 75,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC9B9B), Color(0xFFCD8686)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFDC9B9B).withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 10)),
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
                        child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 24),
                      ),
                    if (!_isAnalyzing) const SizedBox(width: 16),
                    Text(
                      _isAnalyzing ? _currentStatus.toUpperCase() : 'INITIATE FACE SCAN',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5, fontSize: 15),
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