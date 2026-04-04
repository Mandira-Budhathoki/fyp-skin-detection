import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:math' as math;
import 'melanoma_info_provider.dart';
import 'melanoma_detail_screen.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS (Clinical Pro - Melanoma)
// ─────────────────────────────────────────────
class _T {
  static const bg        = Color(0xFFF8FAFC);
  static const surface   = Colors.white;
  static const cardBorder= Color(0xFFE2E8F0);

  static const textPrim  = Color(0xFF0F172A);
  static const textSub   = Color(0xFF475569);
  static const textMuted = Color(0xFF94A3B8);

  static const primary   = Color(0xFF0066FF); // Benign Blue
  static const highRisk  = Color(0xFFE11D48); // Melanoma Red
  static const warning   = Color(0xFFF59E0B); // Unclear Orange
  static const accent    = Color(0xFF7C3AED);
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
      body: ScrollConfiguration(
        behavior: _NoGlowBehavior(),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHero(mq)),
            SliverToBoxAdapter(child: _buildContentSheet()),
            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
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
    return SizedBox(
      height: mq.size.height * 0.38,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'melanoma_image',
            child: AnimatedBuilder(
              animation: _heroCtrl,
              builder: (_, child) => Transform.scale(scale: _heroScale.value, child: child),
              child: _imageFile != null ? Image.file(_imageFile!, fit: BoxFit.cover) : Container(color: _themeColor.withOpacity(0.1)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.2), Colors.transparent, _T.bg],
                stops: const [0, 0.5, 1],
              ),
            ),
          ),
          Positioned(
            left: 24, bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusPill(
                  label: _isUnclear ? "UNSTABLE SCAN" : (_isMelanoma ? "HIGH RISK VERDICT" : "BENIGN INDICATED"),
                  color: _themeColor,
                  pulse: (_isMelanoma || _isUnclear) ? _pulse : null,
                ),
                const SizedBox(height: 8),
                Text(_prediction.toUpperCase(), style: TextStyle(color: _T.textPrim, fontSize: _prediction.length > 15 ? 24 : 32, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Positioned(
            right: 24, bottom: 10,
            child: _ConfidenceArc(value: _confidence / 100, color: _themeColor),
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
            const SizedBox(height: 10),
            if (_isUnclear) _buildUnclearCard() else ...[
              _SectionTitle("DIFFERENTIAL DIAGNOSIS"),
              const SizedBox(height: 16),
              ..._top3.map((item) => _ProbabilityTile(label: item['label'], value: (item['confidence'] as num).toDouble(), color: _themeColor)).toList(),
              const SizedBox(height: 24),
              _ObservationCard(isHighRisk: _isMelanoma, color: _themeColor),
            ],

            const SizedBox(height: 32),
            _SectionTitle("QUICK ACTIONS"),
            const SizedBox(height: 16),
            Row(
              children: [
                _CompactAction(
                  icon: Icons.description_outlined,
                  label: "Report",
                  color: _T.accent,
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => MelanomaDetailScreen(
                        conditionName: widget.results['raw_class'] ?? (_isMelanoma ? 'Melanoma' : 'Benign'),
                        isHighRisk: _isMelanoma,
                      )));
                  },
                ),
                const SizedBox(width: 12),
                _CompactAction(
                  icon: Icons.calendar_today_rounded,
                  label: "Consult",
                  color: _T.textPrim,
                  onTap: () => Navigator.pushNamed(context, '/appointment'),
                ),
                const SizedBox(width: 12),
                _CompactAction(icon: Icons.share_rounded, label: "Share", color: _T.textSub, onTap: () {}),
              ],
            ),
            const SizedBox(height: 32),
            _PipelineCard(isMelanoma: _isMelanoma, isUnclear: _isUnclear),
            const SizedBox(height: 24),
            const Text(
              "Clinical AI screening is for diagnostic support only. Professional biopsy is required for definitive melanoma confirmation.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: _T.textMuted, height: 1.5, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnclearCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: _T.cardBorder)),
      child: Column(
        children: [
          const Icon(Icons.no_photography_rounded, color: _T.warning, size: 48),
          const SizedBox(height: 16),
          const Text("SCAN QUALITY POOR", style: TextStyle(fontWeight: FontWeight.w900, color: _T.textPrim, fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            "The system couldn't identify clear skin patterns. Please rescan with better lighting and focus.",
            textAlign: TextAlign.center,
            style: TextStyle(color: _T.textSub, fontSize: 13, height: 1.5),
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

class _ProbabilityTile extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _ProbabilityTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _T.cardBorder)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: _T.textPrim, fontSize: 13)),
              Text("${value.toStringAsFixed(1)}%", style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: value / 100, backgroundColor: _T.bg, valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 4),
          ),
        ],
      ),
    );
  }
}

class _ObservationCard extends StatelessWidget {
  final bool isHighRisk;
  final Color color;
  const _ObservationCard({required this.isHighRisk, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighRisk ? const Color(0xFFFFF1F2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isHighRisk ? Icons.warning_amber_rounded : Icons.check_circle_rounded, color: color, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isHighRisk 
                ? "This lesion shows critical ABCDE irregularities. Clinical dermoscopy is strongly recommended."
                : "The patterns detected appear benign. Continue to monitor for any changes in color or size.",
              style: TextStyle(color: isHighRisk ? const Color(0xFF9F1239) : const Color(0xFF166534), fontSize: 14, height: 1.5, fontWeight: FontWeight.w600),
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
  final VoidCallback onTap;
  const _CompactAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _T.cardBorder)),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: _T.textPrim, fontWeight: FontWeight.w900, fontSize: 11)),
            ],
          ),
        ),
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
  const _ConfidenceArc({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64, height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size(64, 64), painter: _ArcPaint(value: value, color: color)),
          Text("${(value * 100).toStringAsFixed(0)}%", style: const TextStyle(color: _T.textPrim, fontWeight: FontWeight.w900, fontSize: 14)),
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

class _PipelineCard extends StatelessWidget {
  final bool isMelanoma, isUnclear;
  const _PipelineCard({required this.isMelanoma, required this.isUnclear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: _T.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ENGINE CONSENSUS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _T.textMuted, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          _PipelineStep(title: "Primary Scorer", sub: "Deep Ensemble", active: true, color: isMelanoma ? _T.highRisk : Colors.green),
          _PipelineStep(title: "Pattern Linker", sub: "Neural Context", active: !isUnclear, color: Colors.blue),
          _PipelineStep(title: "Final Verdict", sub: "Clinical Weighted", active: true, color: _T.textPrim),
        ],
      ),
    );
  }
}

class _PipelineStep extends StatelessWidget {
  final String title, sub;
  final bool active;
  final Color color;
  const _PipelineStep({required this.title, required this.sub, required this.active, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(active ? Icons.check_circle_rounded : Icons.radio_button_off_rounded, color: active ? color : _T.cardBorder, size: 16),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(title, style: const TextStyle(color: _T.textPrim, fontWeight: FontWeight.bold, fontSize: 12)),
               Text(sub, style: const TextStyle(color: _T.textMuted, fontWeight: FontWeight.bold, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}
