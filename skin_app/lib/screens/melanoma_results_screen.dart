import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'melanoma_info_provider.dart';
import 'melanoma_detail_screen.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS (Clinical Soft - Melanoma)
// ─────────────────────────────────────────────
class _T {
  static const bg        = Color(0xFFF6F4E8); // Cream
  static const surface   = Colors.white;
  static const cardBorder= Color(0xFFE5EEE4); // Pale Green border

  static const textPrim  = Color(0xFF2D3436);
  static const textSub   = Color(0xFF636E72);
  static const textMuted = Color(0xFFAEB8B8);

  static const primary   = Color(0xFFC0E1D2); // Seafoam (Benign)
  static const highRisk  = Color(0xFFDC9B9B); // Rose (Melanoma)
  static const warning   = Color(0xFFE2A96F); // Keeping a soft orange for warnings
  static const accent    = Color(0xFFDC9B9B);
}

class MelanomaResultsScreen extends StatefulWidget {
  final Map<String, dynamic> results;
  const MelanomaResultsScreen({super.key, required this.results});

  @override
  State<MelanomaResultsScreen> createState() => _MelanomaResultsScreenState();
}

class _MelanomaResultsScreenState extends State<MelanomaResultsScreen>
    with TickerProviderStateMixin {

  late final AnimationController _heroCtrl;
  late final AnimationController _contentCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _heroScale;
  late final Animation<double> _contentSlide;
  late final Animation<double> _contentFade;
  late final Animation<double> _pulse;

  final ScreenshotController _screenshotController = ScreenshotController();

  late final String _prediction;
  late final double _confidence;
  late final bool   _isMelanoma;
  late final bool   _isUnclear;
  late final List<dynamic> _top3;
  late final File?  _imageFile;
  late final Color  _themeColor;

  @override
  void initState() {
    super.initState();

    _prediction = widget.results['prediction'] ?? 'Unknown';
    _confidence = (widget.results['confidence'] ?? 0.0).toDouble();
    _isMelanoma = widget.results['is_melanoma'] ?? false;
    _isUnclear  = widget.results['is_unclear'] ?? (_prediction.contains("Unclear"));
    _top3       = widget.results['top3_classes'] ?? [];
    _imageFile  = widget.results['imageFile'] as File?;

    _themeColor = _isUnclear ? _T.warning : (_isMelanoma ? _T.highRisk : _T.primary);

    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _heroScale = Tween<double>(begin: 1.05, end: 1.0).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));

    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _contentSlide = Tween<double>(begin: 30, end: 0).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));
    _contentFade = Tween<double>(begin: 0, end: 1).animate(_contentCtrl);

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.96, end: 1.0).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _heroCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () => _contentCtrl.forward());
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _contentCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: _T.bg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: _T.bg, // Backing for screenshot
          child: ScrollConfiguration(
            behavior: _NoGlowBehavior(),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHero(mq)),
                SliverToBoxAdapter(child: _buildContentSheet()),
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: _T.textPrim, size: 14),
        ),
      ),
    ),
  );

  Widget _buildHero(MediaQueryData mq) {
    final dateStr = DateFormat('MMMM d, yyyy').format(DateTime.now());
    return Padding(
      padding: EdgeInsets.only(top: mq.padding.top + 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("ANALYZED IMAGE", style: TextStyle(color: _T.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                Text(dateStr, style: const TextStyle(color: _T.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            height: mq.size.height * 0.35,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                // Main Photo with Large Radius
                Positioned.fill(
                  child: Hero(
                    tag: 'melanoma_image',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: AnimatedBuilder(
                        animation: _heroCtrl,
                        builder: (_, child) => Transform.scale(scale: _heroScale.value, child: child),
                        child: _imageFile != null 
                          ? Image.file(_imageFile!, fit: BoxFit.cover) 
                          : Container(color: _themeColor.withOpacity(0.1)),
                      ),
                    ),
                  ),
                ),
                // Percentage Badge (Circle above/on picture)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _ConfidenceArc(value: _confidence / 100, color: _themeColor, size: 60),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("${_confidence.toStringAsFixed(1)}", style: TextStyle(color: _T.textPrim, fontSize: 13, fontWeight: FontWeight.w900, height: 1)),
                            const Text("%", style: TextStyle(color: _T.textMuted, fontSize: 8, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Scan Status Overlay (Top Left)
                Positioned(
                  top: 20,
                  left: 20,
                  child: _StatusPill(
                    label: _isUnclear ? "POOR SCAN" : (_isMelanoma ? "HIGH RISK" : "BENIGN"),
                    color: _themeColor,
                    pulse: (_isMelanoma || _isUnclear) ? _pulse : null,
                  ),
                ),
                // Bottom Gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        begin: Alignment.center, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _prediction.toUpperCase(), 
              style: TextStyle(
                color: _T.textPrim, 
                fontSize: _prediction.length > 15 ? 24 : 32, 
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSheet() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _contentCtrl,
        builder: (_, child) => Transform.translate(offset: Offset(0, _contentSlide.value), child: Opacity(opacity: _contentFade.value, child: child)),
        child: Column(
          children: [
            if (_isUnclear) ...[
              const SizedBox(height: 20),
              _buildUnclearCard(),
            ] else ...[
              const SizedBox(height: 24),
              _SectionTitle("TOP PREDICTIONS"),
              const SizedBox(height: 16),
              ...List.generate(_top3.length, (index) {
                final item = _top3[index];
                return _ProbabilityCard(
                  rank: index + 1,
                  label: item['label'],
                  value: (item['confidence'] as num).toDouble(),
                  color: index == 0 ? _themeColor : _T.textMuted,
                );
              }),
              const SizedBox(height: 24),
              _ActionCard(
                icon: Icons.info_outline_rounded,
                title: _isMelanoma ? "Immediate Action Recommended" : "Routine Checkup Advised",
                subtitle: _isMelanoma 
                  ? "Schedule a dermatologist appointment within 1-2 weeks for professional evaluation and biopsy."
                  : "Monitor the spot for any changes in size, shape, or color over time.",
                color: _isMelanoma ? _T.highRisk : _T.primary,
              ),
              const SizedBox(height: 12),
              const _ActionCard(
                icon: Icons.security_rounded,
                title: "Early Detection Matters",
                subtitle: "Early-stage melanoma has a 99% five-year survival rate. Prompt medical evaluation significantly improves outcomes.",
                color: Color(0xFFF59E0B),
              ),
            ],

            const SizedBox(height: 32),
            _SectionTitle("QUICK ACTIONS"),
            const SizedBox(height: 16),
            Row(
              children: [
                _CompactAction(
                  icon: Icons.assignment_rounded,
                  label: "Report",
                  color: Colors.white,
                  bgColor: const Color(0xFF0066FF),
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => MelanomaDetailScreen(
                        conditionName: widget.results['raw_class'] ?? (_isMelanoma ? 'Melanoma' : 'Benign'),
                        isHighRisk: _isMelanoma,
                      )));
                  },
                ),
                const SizedBox(width: 12),
                _CompactAction(
                  icon: Icons.chat_bubble_rounded,
                  label: "Consult",
                  color: _T.textPrim,
                  bgColor: Colors.white,
                  onTap: () => Navigator.pushNamed(context, '/appointment'),
                ),
                const SizedBox(width: 12),
                _CompactAction(
                  icon: Icons.share_rounded,
                  label: "Share",
                  color: _T.textPrim,
                  bgColor: Colors.white,
                  onTap: _shareResults,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _DisclaimerCard(),
          ],
        ),
      ),
    );
  }

  Future<void> _shareResults() async {
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/melanoma_scan_result.png').create();
        await imagePath.writeAsBytes(image);
        
        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: 'SkinHealth AI: My Melanoma Screening Result. Early detection saves lives! #SkinHealth #Dermatology',
        );
      }
    } catch (e) {
      debugPrint("Sharing error: $e");
    }
  }

  Widget _buildUnclearCard() {
    final backendMsg = widget.results['message'] ?? '';
    final isInvalid = _prediction.contains('Invalid') || _prediction.contains('Wrong Image Type');

    final title = isInvalid ? "NOT A SKIN LESION" : "IMAGE UNCLEAR";
    final icon = isInvalid ? Icons.block_rounded : Icons.no_photography_rounded;
    final desc = backendMsg.isNotEmpty
        ? backendMsg
        : "We couldn't detect a valid skin lesion. Please upload a focused, well-lit close-up of a specific mole or spot.";
    final tip = isInvalid
        ? "Zoom into one specific mole or spot only"
        : "Use rear camera, good lighting, 10-15cm away";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _T.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3E0),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _T.warning, size: 42),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: _T.textPrim, fontSize: 16, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _T.textSub, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: _T.warning, size: 16),
                const SizedBox(width: 8),
                Text("Tip: $tip", style: const TextStyle(color: _T.warning, fontWeight: FontWeight.w700, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _SectionTitle(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _T.textMuted, letterSpacing: 1.5)),
  );
}

// ─────────────────────────────────────────────
//  WIDGET COMPONENTS
// ─────────────────────────────────────────────

class _ProbabilityCard extends StatelessWidget {
  final int rank;
  final String label;
  final double value;
  final Color color;
  const _ProbabilityCard({required this.rank, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _T.cardBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text("$rank", style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: _T.textPrim, fontSize: 14)),
              const Spacer(),
              Text("${value.toStringAsFixed(1)}%", style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value / 100, 
              backgroundColor: _T.bg, 
              valueColor: AlwaysStoppedAnimation<Color>(color), 
              minHeight: 6
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color.withOpacity(0.8), fontSize: 15, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(color: color.withOpacity(0.7), fontSize: 13, height: 1.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  const _CompactAction({required this.icon, required this.label, required this.color, required this.bgColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: bgColor, 
            borderRadius: BorderRadius.circular(20), 
            border: Border.all(color: _T.cardBorder),
            boxShadow: bgColor != Colors.white ? [
              BoxShadow(color: bgColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
            ] : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.privacy_tip_rounded, color: _T.textMuted, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Clinical AI Screening Disclaimer", style: TextStyle(color: _T.textPrim, fontSize: 12, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(
                  "This AI screening is for diagnostic support only. Professional biopsy is required for definitive melanoma confirmation. This tool does not replace professional medical evaluation. Always consult a board-certified dermatologist for clinical diagnosis and treatment.",
                  style: TextStyle(color: _T.textSub.withOpacity(0.8), fontSize: 11, height: 1.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Animation<double>? pulse;
  const _StatusPill({required this.label, required this.color, this.pulse});

  @override
  Widget build(BuildContext context) {
    Widget pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: _T.textPrim, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
        ],
      ),
    );
    return pulse != null ? AnimatedBuilder(animation: pulse!, builder: (_, child) => Transform.scale(scale: pulse!.value, child: child), child: pill) : pill;
  }
}

class _ConfidenceArc extends StatelessWidget {
  final double value;
  final Color color;
  final double size;
  const _ConfidenceArc({required this.value, required this.color, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size(size, size), painter: _ArcPaint(value: value, color: color)),
        ],
      ),
    );
  }
}

class _ArcPaint extends CustomPainter {
  final double value;
  final Color color;
  _ArcPaint({required this.value, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(center, radius, Paint()..color = _T.cardBorder..strokeWidth = 4..style = PaintingStyle.stroke);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * value, false, Paint()..color = color..strokeWidth = 4..strokeCap = StrokeCap.round..style = PaintingStyle.stroke);
  }
  @override
  bool shouldRepaint(_ArcPaint old) => old.value != value;
}

class _NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}
