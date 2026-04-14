import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CustomScannerScreen extends StatefulWidget {
  final String title;
  final String helperText;

  const CustomScannerScreen({
    Key? key, 
    this.title = 'AI Raw Scanner',
    this.helperText = 'Align your face/skin within the frame.',
  }) : super(key: key);

  @override
  State<CustomScannerScreen> createState() => _CustomScannerScreenState();
}

class _CustomScannerScreenState extends State<CustomScannerScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;
  bool _isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Find back camera by default for rawest sensor, can toggle
        final initialCamera = _cameras!.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras!.first,
        );
        _isFrontCamera = initialCamera.lensDirection == CameraLensDirection.front;
        await _setupController(initialCamera);
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  Future<void> _setupController(CameraDescription camera) async {
    // ResolutionPreset.max forces the camera to use the highest quality raw sensor output
    // bypassing processing features meant for lower-res previews.
    _controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      // Lock focus and exposure if supported
      await _controller!.setFocusMode(FocusMode.auto);
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint("Controller init error: $e");
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras == null || _cameras!.length < 2 || _controller == null) return;
    setState(() { _isInitializing = true; });
    
    final newDirection = _isFrontCamera ? CameraLensDirection.back : CameraLensDirection.front;
    final newCamera = _cameras!.firstWhere(
      (c) => c.lensDirection == newDirection,
      orElse: () => _cameras!.first,
    );
    
    _isFrontCamera = newCamera.lensDirection == CameraLensDirection.front;
    await _controller!.dispose();
    await _setupController(newCamera);
  }

  Future<void> _captureRawImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    try {
      final XFile image = await _controller!.takePicture();
      if (mounted) {
        Navigator.pop(context, File(image.path));
      }
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing || _controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Accessing Raw Sensor...', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Viewfinder (no stretch, mirrored for front cam)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenAspect = constraints.maxWidth / constraints.maxHeight;
                final cameraAspect = 1 / _controller!.value.aspectRatio;
                // Scale to COVER the screen (no black bars, crop overflow)
                final scale = cameraAspect > screenAspect
                    ? constraints.maxHeight / (constraints.maxWidth / cameraAspect)
                    : constraints.maxWidth / (constraints.maxHeight * cameraAspect);

                return ClipRect(
                  child: Transform.scale(
                    scale: scale > 1 ? scale : 1 / scale,
                    child: Center(
                      child: CameraPreview(_controller!),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. UI Overlay (Targeting Reticle)
          Positioned.fill(
             child: CustomPaint(
               painter: _ScannerOverlayPainter(),
             ),
          ),

          // 3. Top Info Bar
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 28),
                  onPressed: _toggleCamera,
                ),
              ],
            ),
          ),

          // 4. Instructions
          Positioned(
            bottom: 150,
            left: 20,
            right: 20,
            child: Text(
              widget.helperText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 2))],
              ),
            ),
          ),

          // 5. Capture Button
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _captureRawImage,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: Container(
                      height: 64,
                      width: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
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

// ─────────────────────────────────────────────
//  Scanner Targeting Reticle UI
// ─────────────────────────────────────────────
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Darken everything outside the center block
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.5);
    final holeRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.75,
      height: size.height * 0.5,
    );
    
    // Draw semi-transparent background with a clear hole
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    canvas.drawRect(holeRect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    // Draw scanning corners
    final cornerPaint = Paint()
      ..color = const Color(0xFF00BFA5) // Teal accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const cornerLength = 30.0;
    
    // Top-Left
    canvas.drawLine(holeRect.topLeft, holeRect.topLeft + const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(holeRect.topLeft, holeRect.topLeft + const Offset(0, cornerLength), cornerPaint);

    // Top-Right
    canvas.drawLine(holeRect.topRight, holeRect.topRight + const Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(holeRect.topRight, holeRect.topRight + const Offset(0, cornerLength), cornerPaint);

    // Bottom-Left
    canvas.drawLine(holeRect.bottomLeft, holeRect.bottomLeft + const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(holeRect.bottomLeft, holeRect.bottomLeft + const Offset(0, -cornerLength), cornerPaint);

    // Bottom-Right
    canvas.drawLine(holeRect.bottomRight, holeRect.bottomRight + const Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(holeRect.bottomRight, holeRect.bottomRight + const Offset(0, -cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
