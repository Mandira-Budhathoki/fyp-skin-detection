import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:math' as math;
import '../data/wound_advice_provider.dart';
import 'wound_treatment_screen.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS (Modern Clinical Pro)
// ─────────────────────────────────────────────
class _T {
  static const bg        = Color(0xFFF8FAFC);
  static const surface   = Colors.white;
  static const card      = Colors.white;
  static const cardBorder= Color(0xFFE2E8F0);

  static const textPrim  = Color(0xFF0F172A);
  static const textSub   = Color(0xFF475569);
  static const textMuted = Color(0xFF94A3B8);

  static const primary   = Color(0xFF0066FF);
  static const emergency = Color(0xFFE11D48);
  static const warning   = Color(0xFFF59E0B);
  static const accent    = Color(0xFF7C3AED);

  static const r20 = Radius.circular(20);
}

class WoundResultsScreen extends StatefulWidget {
  final Map<String, dynamic> results;
  const WoundResultsScreen({super.key, required this.results});

  @override
  State<WoundResultsScreen> createState() => _WoundResultsScreenState();
}

class _WoundResultsScreenState extends State<WoundResultsScreen>
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
  late final String _message;
  late final File?  _imageFile;
  late final bool   _isEmergency;
  late final Color  _themeColor;

  late final List<Map<String, String>> _timeline;

  @override
  void initState() {
    super.initState();

    final advice = WoundAdviceProvider.getAdviceForWound(widget.results['prediction'] ?? '');
    _timeline = List<Map<String, String>>.from(advice['timeline'] ?? []);

    _prediction  = widget.results['prediction'] ?? 'Unknown';
    _confidence  = (widget.results['confidence'] ?? 0.0).toDouble();
    _message     = widget.results['message'] ?? '';
    _imageFile   = widget.results['imageFile'] as File?;
    _isEmergency = _prediction.toLowerCase().contains('bleeding') ||
                   _prediction.toLowerCase().contains('deep') ||
                   _prediction.toLowerCase().contains('infected');
    _themeColor  = _isEmergency ? _T.emergency : _T.primary;

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
          physics: const ClampingScrollPhysics(), // NO BOUNCE
          slivers: [
            SliverToBoxAdapter(child: _buildHero(mq)),
            SliverToBoxAdapter(child: _buildContentSheet()),
            const SliverToBoxAdapter(child: SizedBox(height: 60)), // Fixed bottom padding
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
            tag: 'wound_image',
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
                _StatusPill(label: _isEmergency ? "URGENT ACTION" : "STABLE", color: _themeColor, pulse: _isEmergency ? _pulse : null),
                const SizedBox(height: 8),
                Text(_prediction.toUpperCase(), style: TextStyle(color: _T.textPrim, fontSize: _prediction.length > 15 ? 24 : 30, fontWeight: FontWeight.w900)),
              ],
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
            const SizedBox(height: 10),
            _StatsRow(confidence: _confidence, color: _themeColor),
            const SizedBox(height: 16),
            _ObservationCard(message: _message, color: _themeColor),
            const SizedBox(height: 24),
            
            // ─────────────────────────────────────────────
            //  NEW FEATURE: HEALING TIMELINE
            // ─────────────────────────────────────────────
            if (!_prediction.contains("Uncertain") && _timeline.isNotEmpty) ...[
              _SectionTitle("RECOVERY TIMELINE"),
              const SizedBox(height: 16),
              _HealingTimeline(color: _themeColor, timeline: _timeline),
              const SizedBox(height: 32),
            ],

            // ─────────────────────────────────────────────
            //  COMPACT ACTION TILES (REPLACED BIG BUTTONS)
            // ─────────────────────────────────────────────
            _SectionTitle("QUICK ACTIONS"),
            const SizedBox(height: 16),
            Row(
              children: [
                _CompactAction(
                  icon: Icons.medical_services_rounded,
                  label: "Care Plan",
                  color: _themeColor,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WoundTreatmentScreen(prediction: _prediction, message: _message))),
                ),
                const SizedBox(width: 12),
                _CompactAction(
                  icon: Icons.local_hospital_rounded,
                  label: "Consult",
                  color: _T.textSub,
                  onTap: () => Navigator.pushNamed(context, '/appointment'),
                ),
                const SizedBox(width: 12),
                _CompactAction(icon: Icons.share_rounded, label: "Share", color: _T.accent, onTap: () {}),
              ],
            ),
            const SizedBox(height: 32),

            if (widget.results['ensemble'] != null && !_prediction.contains("Uncertain") && !_prediction.contains("Unclear"))
              _EnsembleCard(ensemble: widget.results['ensemble']!, color: _themeColor),
          ],
        ),
      ),
    );
  }

  Widget _SectionTitle(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _T.textMuted, letterSpacing: 1.5)),
  );
}

// ─────────────────────────────────────────────
//  COMPACT WIDGETS
// ─────────────────────────────────────────────

class _HealingTimeline extends StatelessWidget {
  final Color color;
  final List<Map<String, String>> timeline;
  const _HealingTimeline({required this.color, required this.timeline});

  @override
  Widget build(BuildContext context) {
    if (timeline.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: _T.cardBorder)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < timeline.length; i++) ...[
            _TimelineNode(
              day: timeline[i]['day']!,
              task: timeline[i]['task']!,
              color: i == 0 ? color : _T.textMuted,
              isDone: i == 0,
            ),
            if (i < timeline.length - 1) _TimelineArrow(),
          ],
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final String day, task;
  final Color color;
  final bool isDone;
  const _TimelineNode({required this.day, required this.task, required this.color, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: isDone ? color : Colors.transparent, shape: BoxShape.circle, border: Border.all(color: isDone ? color : _T.cardBorder, width: 2)),
          child: Center(child: Text(day, style: TextStyle(color: isDone ? Colors.white : _T.textMuted, fontWeight: FontWeight.bold, fontSize: 12))),
        ),
        const SizedBox(height: 8),
        Text(task, style: TextStyle(color: isDone ? _T.textPrim : _T.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _TimelineArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.arrow_forward_rounded, color: _T.cardBorder, size: 16);
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

class _StatsRow extends StatelessWidget {
  final double confidence;
  final Color color;
  const _StatsRow({required this.confidence, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(icon: Icons.analytics_rounded, label: "CONFIDENCE", value: "${confidence.toStringAsFixed(1)}%", color: color),
        const SizedBox(width: 12),
        _StatTile(icon: Icons.speed_rounded, label: "ANALYSIS", value: "2-Phase", color: _T.warning),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatTile({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _T.cardBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(color: _T.textPrim, fontWeight: FontWeight.w900, fontSize: 15)),
            Text(label, style: const TextStyle(color: _T.textMuted, fontWeight: FontWeight.bold, fontSize: 8)),
          ],
        ),
      ),
    );
  }
}

class _ObservationCard extends StatelessWidget {
  final String message;
  final Color color;
  const _ObservationCard({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: _T.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.auto_awesome_rounded, color: color, size: 18),
            const SizedBox(width: 10),
            const Text("AI OBSERVATION", style: TextStyle(color: _T.textPrim, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
          ]),
          const SizedBox(height: 16),
          Text(message.isNotEmpty ? message : "Our AI suggests normal recovery. Monitor daily for changes.", style: const TextStyle(color: _T.textSub, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _EnsembleCard extends StatelessWidget {
  final Map<String, dynamic> ensemble;
  final Color color;
  const _EnsembleCard({required this.ensemble, required this.color});

  @override
  Widget build(BuildContext context) {
    final p = ensemble['primary'];
    final s = ensemble['secondary'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: _T.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.verified_rounded, color: _T.accent, size: 18),
            SizedBox(width: 10),
            Text("VERIFICATION LAYERS", style: TextStyle(color: _T.textPrim, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
          ]),
          const SizedBox(height: 20),
          if (p != null) _buildP(p, "P1", color),
          if (s != null) ...[const SizedBox(height: 16), _buildP(s, "P2", _T.accent)],
        ],
      ),
    );
  }

  Widget _buildP(dynamic d, String t, Color c) {
    double s = (d['score'] as num).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(t, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 10)),
          Text("${s.toStringAsFixed(1)}%", style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 11)),
        ]),
        const SizedBox(height: 4),
        Text(d['label'] ?? 'Unknown', style: const TextStyle(color: _T.textPrim, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: s / 100, backgroundColor: _T.cardBorder, valueColor: AlwaysStoppedAnimation<Color>(c), minHeight: 4)),
      ],
    );
  }
}

class _NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}