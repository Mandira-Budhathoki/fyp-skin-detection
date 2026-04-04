import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../services/api_service.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS (Clinical Pro - General Skin)
// ─────────────────────────────────────────────
class _T {
  static const bg        = Color(0xFFF8FAFC);
  static const surface   = Colors.white;
  static const cardBorder= Color(0xFFE2E8F0);

  static const textPrim  = Color(0xFF0F172A);
  static const textSub   = Color(0xFF475569);
  static const textMuted = Color(0xFF94A3B8);

  static const primary   = Color(0xFF0066FF); // Clear/Mild
  static const warning   = Color(0xFFF59E0B); // Moderate/Other
  static const highRisk  = Color(0xFFE11D48); // Severe
  static const accent    = Color(0xFF7C3AED);
}

class SkinResultsScreen extends StatefulWidget {
  final Map<String, dynamic> results;
  final File? image;

  const SkinResultsScreen({super.key, required this.results, this.image});

  @override
  State<SkinResultsScreen> createState() => _SkinResultsScreenState();
}

class _SkinResultsScreenState extends State<SkinResultsScreen> with TickerProviderStateMixin {
  late final AnimationController _heroCtrl;
  late final AnimationController _contentCtrl;
  late final Animation<double> _heroScale;
  late final Animation<double> _contentSlide;
  late final Animation<double> _contentFade;

  late final String _acneStatus;
  late final double _acneConf;
  late final String? _processedUrl;
  late final List<dynamic> _otherConditions;
  late final Color _themeColor;

  @override
  void initState() {
    super.initState();

    _acneStatus = widget.results['acne_status'] ?? widget.results['prediction'] ?? 'Analysis Complete';
    _acneConf = (widget.results['acne_confidence'] ?? widget.results['confidence'] ?? 0.0).toDouble();
    _processedUrl = widget.results['processed_url'] != null ? _buildFullUrl(widget.results['processed_url']) : null;
    _otherConditions = widget.results['other_conditions'] ?? [];

    if (_acneStatus.contains('Moderate') || _otherConditions.isNotEmpty) {
      _themeColor = _T.warning;
    } else if (_acneStatus.contains('Severe')) {
      _themeColor = _T.highRisk;
    } else {
      _themeColor = _T.primary;
    }

    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _heroScale = Tween<double>(begin: 1.05, end: 1.0).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));

    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _contentSlide = Tween<double>(begin: 30, end: 0).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));
    _contentFade = Tween<double>(begin: 0, end: 1).animate(_contentCtrl);

    _heroCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () => _contentCtrl.forward());
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  String _buildFullUrl(String? path) {
    if (path == null) return '';
    if (path.startsWith('http')) return path;
    if (path.startsWith('/api')) {
      return ApiService.useTunnel
          ? "${ApiService.tunnelUrl}$path"
          : "http://${ApiService.serverIp}:8000$path";
    }
    return path;
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
            SliverToBoxAdapter(child: _buildContent()),
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
      height: mq.size.height * 0.4,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _heroCtrl,
            builder: (_, child) => Transform.scale(scale: _heroScale.value, child: child),
            child: _buildHeroImage(),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.2), Colors.transparent, _T.bg],
                stops: const [0, 0.4, 1],
              ),
            ),
          ),
          if (_processedUrl != null)
            Positioned(
              top: 50, right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 12),
                    SizedBox(width: 6),
                    Text('XAI HEATMAP', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 24, bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusPill(label: _themeColor == _T.highRisk ? "ATTENTION NEEDED" : "SCAN COMPLETE", color: _themeColor),
                const SizedBox(height: 8),
                Text(
                  _acneStatus.toUpperCase(),
                  style: TextStyle(color: _T.textPrim, fontSize: _acneStatus.length > 15 ? 24 : 32, fontWeight: FontWeight.w900, letterSpacing: -1.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    if (_processedUrl != null) {
      return Image.network(_processedUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => widget.image != null ? Image.file(widget.image!, fit: BoxFit.cover) : Container(color: _T.cardBorder));
    }
    if (widget.image != null) {
      return Image.file(widget.image!, fit: BoxFit.cover);
    }
    return Container(color: _themeColor.withOpacity(0.1));
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _contentCtrl,
        builder: (_, child) => Transform.translate(offset: Offset(0, _contentSlide.value), child: Opacity(opacity: _contentFade.value, child: child)),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _ConfidenceRow(confidence: _acneConf, color: _themeColor),
            const SizedBox(height: 16),
            if (_processedUrl != null) ...[
              _ExplainabilityCard(),
              const SizedBox(height: 16),
            ],
            if (_otherConditions.isNotEmpty) ...[
              _SectionTitle("OTHER CONDITIONS DETECTED"),
              const SizedBox(height: 12),
              ..._otherConditions.map((c) => _ConditionTile(condition: c)).toList(),
              const SizedBox(height: 24),
            ] else ...[
              _InsightCard(status: _acneStatus, color: _themeColor),
              const SizedBox(height: 24),
            ],
            
            _SectionTitle("QUICK ACTIONS"),
            const SizedBox(height: 16),
            Row(
              children: [
                _CompactAction(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: "AI Guide",
                  color: _T.accent,
                  onTap: () => Navigator.pushNamed(context, '/chatbot'),
                ),
                const SizedBox(width: 12),
                _CompactAction(
                  icon: Icons.local_hospital_rounded,
                  label: "Consult",
                  color: _T.textPrim,
                  onTap: () => Navigator.pushNamed(context, '/appointment'),
                ),
                const SizedBox(width: 12),
                _CompactAction(icon: Icons.share_rounded, label: "Share", color: _T.textSub, onTap: () {}),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              "Screening is based on visual patterns. Clinical assessment in person is always recommended.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: _T.textMuted, height: 1.5, fontStyle: FontStyle.italic),
            ),
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
//  WIDGET COMPONENTS
// ─────────────────────────────────────────────

class _ConfidenceRow extends StatelessWidget {
  final double confidence;
  final Color color;
  const _ConfidenceRow({required this.confidence, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _T.cardBorder)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.analytics_rounded, color: color, size: 18),
                const SizedBox(height: 12),
                Text("${confidence.toStringAsFixed(1)}%", style: const TextStyle(color: _T.textPrim, fontWeight: FontWeight.w900, fontSize: 16)),
                const Text("CONFIDENCE SCORE", style: TextStyle(color: _T.textMuted, fontWeight: FontWeight.bold, fontSize: 8, letterSpacing: 1)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExplainabilityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.cyan.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.cyan.withOpacity(0.2))),
      child: Row(
        children: [
          const Icon(Icons.help_outline_rounded, color: Colors.cyan, size: 18),
          const SizedBox(width: 12),
          const Expanded(child: Text("The heatmap overlay on the image above indicates areas the AI focused on.", style: TextStyle(color: _T.textSub, fontSize: 12, height: 1.4))),
        ],
      ),
    );
  }
}

class _ConditionTile extends StatelessWidget {
  final dynamic condition;
  const _ConditionTile({required this.condition});

  @override
  Widget build(BuildContext context) {
    double conf = (condition['confidence'] ?? 0.0).toDouble();
    String label = condition['label'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _T.cardBorder)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _T.warning.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.warning_amber_rounded, color: _T.warning, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: _T.textPrim, fontSize: 12))),
          Text("${conf.toStringAsFixed(1)}%", style: const TextStyle(fontWeight: FontWeight.w900, color: _T.warning, fontSize: 14)),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String status;
  final Color color;
  const _InsightCard({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    String desc = 'No significant issues detected. Your skin looks clear!';
    if (status.contains('Moderate')) {
      desc = 'Significant acne detected. Consider a consistent skincare routine or consulting a dermatologist.';
    } else if (status.contains('Mild')) {
      desc = 'Some signs of acne detected. Maintain good hygiene and a gentle skincare routine.';
    }

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
          Text(desc, style: const TextStyle(color: _T.textSub, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500)),
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
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
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
  }
}

class _NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}
