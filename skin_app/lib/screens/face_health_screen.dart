import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import 'chatbot_screen.dart';
import 'appointment_screen.dart';

class FaceHealthScreen extends StatefulWidget {
  const FaceHealthScreen({Key? key}) : super(key: key);

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
      backgroundColor: const Color(0xFF0F1923),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A2832),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFFE87EA1), size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Face Health',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
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
                color: const Color(0xFFE87EA1).withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF7C5CBF).withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 6),

                  // Subtitle
                  const Text(
                    'Detect skin type, acne, inflammation\n& more with multi-model AI analysis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8AABB8),
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Model badges
                  _buildModelBadges(),

                  const SizedBox(height: 20),

                  // Camera / Gallery
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputCard(
                          icon: Icons.face_6_rounded,
                          title: 'Selfie',
                          subtitle: 'Front Camera',
                          color: const Color(0xFFE87EA1),
                          onTap: () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildInputCard(
                          icon: Icons.photo_library_rounded,
                          title: 'Gallery',
                          subtitle: 'From Library',
                          color: const Color(0xFF7C5CBF),
                          onTap: () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Tips
                  _buildTipsCard(),

                  const Spacer(),

                  // Action buttons
                  const Text(
                    'RESOURCES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Color(0xFF4A90A4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildActionBtn(
                    icon: Icons.calendar_today_rounded,
                    title: 'Book Appointment',
                    color: const Color(0xFF7C5CBF),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AppointmentScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildActionBtn(
                    icon: Icons.smart_toy_outlined,
                    title: 'Consult AI Chatbot',
                    color: const Color(0xFF2A9D8F),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ChatbotScreen(category: 'skin')),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Disclaimer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 12, color: Color(0xFF4A5568)),
                      const SizedBox(width: 6),
                      Text(
                        'Non-medical AI analysis. Consult a specialist.',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelBadges() {
    final models = [
      {'label': 'Skin Type', 'icon': '🧴'},
      {'label': 'Acne', 'icon': '🫛'},
      {'label': 'Spots', 'icon': '🎯'},
      {'label': 'Inflammation', 'icon': '🔥'},
      {'label': 'Conditions', 'icon': '🔬'},
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2832),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE87EA1).withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ANALYZES WITH 5 AI MODELS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Color(0xFFE87EA1),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: models
                .map((m) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1923),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFE87EA1).withOpacity(0.2)),
                      ),
                      child: Text(
                        '${m['icon']}  ${m['label']}',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2832),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PHOTO TIPS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Color(0xFF4A90A4),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTip(Icons.light_mode_outlined, 'Bright Light'),
              _buildTip(Icons.face_outlined, 'No Makeup'),
              _buildTip(Icons.remove_red_eye_outlined, 'No Glasses'),
              _buildTip(Icons.center_focus_strong_outlined, 'Face Only'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTip(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4A90A4)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF8AABB8),
                fontWeight: FontWeight.w600)),
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
      color: const Color(0xFF1A2832),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF8AABB8))),
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
      color: const Color(0xFF1A2832),
      borderRadius: BorderRadius.circular(16),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
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
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
        vsync: this, duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    setState(() => _isAnalyzing = true);
    _scanController.repeat();

    // TODO: Call FaceHealthAnalyzer API once backend is ready
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() => _isAnalyzing = false);
      _scanController.stop();
      _scanController.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Face Health models integrating soon! 🚀'),
          backgroundColor: Color(0xFFE87EA1),
        ),
      );
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
                    const Text(
                      'RUNNING 5 AI MODELS...',
                      style: TextStyle(
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
