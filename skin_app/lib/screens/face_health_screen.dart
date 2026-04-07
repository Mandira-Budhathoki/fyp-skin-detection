import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'chatbot_screen.dart';
import 'appointment_screen.dart';
import 'face_health_results_screen.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaceHealthScreen extends StatefulWidget {
  const FaceHealthScreen({super.key});

  @override
  State<FaceHealthScreen> createState() => _FaceHealthScreenState();
}

class _FaceHealthScreenState extends State<FaceHealthScreen> {
  final ImagePicker _picker = ImagePicker();

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
            builder: (context) =>
                _FaceHealthPreviewScreen(imageFile: File(pickedFile.path)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFFE87EA1), size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Face Health Hub',
          style: TextStyle(
            color: Color(0xFF1B263B),
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: const Color(0xFF2A9D8F).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFFE87EA1).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Precision Face Diagnostics',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Analyze skin vitality, facial structure, and\nemotional resonance with clinical-grade AI.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Model badges
                  _buildModelBadgesView(),

                  const SizedBox(height: 32),

                  // Camera / Gallery
                  Row(
                    children: [
                      Expanded(
                        child: _buildPremiumInputCard(
                          icon: Icons.camera_front_rounded,
                          title: 'Live Scan',
                          subtitle: 'Selfie Mode',
                          color: const Color(0xFF4F46E5),
                          onTap: () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPremiumInputCard(
                          icon: Icons.photo_size_select_actual_rounded,
                          title: 'Import',
                          subtitle: 'Gallery',
                          color: const Color(0xFFEC4899),
                          onTap: () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Action buttons
                  Row(
                    children: [
                      const Icon(Icons.medical_services_rounded, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 10),
                      const Text(
                        'PROFESSIONAL SUPPORT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildActionBtn(
                    icon: Icons.calendar_month_rounded,
                    title: 'Book Dermatologist',
                    color: const Color(0xFF4F46E5),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AppointmentScreen())),
                  ),
                  const SizedBox(height: 12),
                  _buildActionBtn(
                    icon: Icons.chat_bubble_rounded,
                    title: 'AI Health Assistant',
                    color: const Color(0xFF0D9488),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ChatbotScreen(category: 'skin')),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.gpp_maybe_rounded,
                            size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'AI-assisted screening only. Not a medical diagnosis.',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelBadgesView() {
    final models = [
      {'label': 'Skin Type', 'icon': Icons.water_drop_rounded, 'color': const Color(0xFF6366F1)},
      {'label': 'Acne', 'icon': Icons.face_retouching_natural_rounded, 'color': const Color(0xFFEC4899)},
      {'label': 'Spots', 'icon': Icons.center_focus_strong_rounded, 'color': const Color(0xFF8B5CF6)},
      {'label': 'Inflammation', 'icon': Icons.local_fire_department_rounded, 'color': const Color(0xFFEF4444)},
      {'label': 'Face Shape', 'icon': Icons.architecture_rounded, 'color': const Color(0xFF10B981)},
      {'label': 'Expression', 'icon': Icons.emoji_emotions_rounded, 'color': const Color(0xFFF59E0B)},
      {'label': 'Gender', 'icon': Icons.person_search_rounded, 'color': const Color(0xFF3B82F6)},
    ];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DIAGNOSTIC ENSEMBLE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: models
                .map<Widget>((m) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: (m['color'] as Color).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(m['icon'] as IconData, size: 12, color: m['color'] as Color),
                        const SizedBox(width: 6),
                        Text(
                          m['label'] as String,
                          style: TextStyle(color: (m['color'] as Color), fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumInputCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(32),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A))),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B263B))),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: Color(0xFF4A5568)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── PREVIEW SCREEN ──

class _FaceHealthPreviewScreen extends StatefulWidget {
  final File imageFile;
  const _FaceHealthPreviewScreen({required this.imageFile});

  @override
  State<_FaceHealthPreviewScreen> createState() =>
      _FaceHealthPreviewScreenState();
}

class _FaceHealthPreviewScreenState extends State<_FaceHealthPreviewScreen>
    with TickerProviderStateMixin {
  bool _isAnalyzing = false;
  String _currentStatus = 'INITIALIZING SCAN...';
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    setState(() {
      _isAnalyzing = true;
      _currentStatus = "CONNECTING TO ENGINE...";
    });
    _scanController.repeat();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      Map<String, dynamic>? finalResult;

      // Stream updates from the backend generator
      await for (final chunk in ApiService.analyzeFaceHealthStream(widget.imageFile.path, token)) {
        if (!mounted) break;
        
        if (chunk.containsKey('progress')) {
          setState(() => _currentStatus = chunk['progress']);
        } else if (chunk.containsKey('result')) {
          finalResult = chunk['result'];
        } else if (chunk.containsKey('error')) {
          finalResult = chunk;
        }
      }

      if (mounted) {
        setState(() => _isAnalyzing = false);
        _scanController.stop();

        if (finalResult != null && (finalResult['status'] == 'success' || finalResult['acne'] != null)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FaceHealthResultsScreen(
                imageFile: widget.imageFile,
                results: finalResult!,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(finalResult?['message'] ?? finalResult?['error'] ?? 'Analysis failed'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _currentStatus = 'INITIALIZING SCAN...';
        });
        _scanController.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
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
          // Image
          Image.file(widget.imageFile, fit: BoxFit.cover),

          // Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                  Colors.black.withOpacity(0.85),
                ],
              ),
            ),
          ),

          // Scanner overlay
          if (_isAnalyzing)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _scanController,
                builder: (context, child) => CustomPaint(
                  painter: _FaceScanPainter(progress: _scanController.value),
                ),
              ),
            ),

          // Header
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _isAnalyzing ? null : () => Navigator.pop(context),
                ),
                const Spacer(),
                const Text('Face Health Analysis',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isAnalyzing) ...[
                    Text(
                      _currentStatus,
                      style: const TextStyle(
                          color: Color(0xFFE87EA1),
                          fontSize: 13,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isAnalyzing ? null : _analyzeImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAnalyzing
                            ? Colors.grey[800]
                            : const Color(0xFFE87EA1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 10,
                        shadowColor:
                            const Color(0xFFE87EA1).withOpacity(0.4),
                      ),
                      child: _isAnalyzing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('ANALYZE FACE HEALTH',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: Colors.white)),
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

class _FaceScanPainter extends CustomPainter {
  final double progress;
  _FaceScanPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE87EA1).withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double yPos = (size.height * progress) % size.height;

    final beamRect = Rect.fromLTWH(0, yPos - 40, size.width, 80);
    final beamShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        const Color(0xFFE87EA1).withOpacity(0.4),
        const Color(0xFF7C5CBF).withOpacity(0.4),
        Colors.transparent,
      ],
    ).createShader(beamRect);
    canvas.drawRect(beamRect, Paint()..shader = beamShader);
    canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), paint);

    // Face oval guide
    final guidePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.42),
          width: size.width * 0.55,
          height: size.height * 0.5),
      guidePaint,
    );

    // Corner brackets
    const pad = 20.0;
    const len = 28.0;
    final corners = Path()
      ..moveTo(pad, pad + len)
      ..lineTo(pad, pad)
      ..lineTo(pad + len, pad)
      ..moveTo(size.width - pad - len, pad)
      ..lineTo(size.width - pad, pad)
      ..lineTo(size.width - pad, pad + len)
      ..moveTo(pad, size.height - pad - len)
      ..lineTo(pad, size.height - pad)
      ..lineTo(pad + len, size.height - pad)
      ..moveTo(size.width - pad - len, size.height - pad)
      ..lineTo(size.width - pad, size.height - pad)
      ..lineTo(size.width - pad, size.height - pad - len);
    canvas.drawPath(corners, paint..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(_FaceScanPainter old) => old.progress != progress;
}
