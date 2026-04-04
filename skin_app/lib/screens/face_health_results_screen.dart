import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'chatbot_screen.dart';
import 'appointment_screen.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS (Clinical Pro - Face Health)
// ─────────────────────────────────────────────
class _T {
  static const bg        = Color(0xFFF8FAFC);
  static const surface   = Colors.white;
  static const cardBorder= Color(0xFFE2E8F0);

  static const textPrim  = Color(0xFF0F172A);
  static const textSub   = Color(0xFF475569);
  static const textMuted = Color(0xFF94A3B8);

  static const primary   = Color(0xFF0066FF);
  static const pink      = Color(0xFFE11D48);
  static const teal      = Color(0xFF0D9488);
  static const accent    = Color(0xFF7C3AED);
}

class FaceHealthResultsScreen extends StatelessWidget {
  final File imageFile;
  final Map<String, dynamic> results;

  const FaceHealthResultsScreen({
    Key? key,
    required this.imageFile,
    required this.results,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: _T.bg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: ScrollConfiguration(
        behavior: _NoGlowBehavior(),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(), // NO BOUNCE
          slivers: [
            SliverToBoxAdapter(child: _buildHero(mq)),
            SliverToBoxAdapter(child: _buildContent(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(Icons.close_rounded, color: _T.textPrim, size: 16),
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
          Image.file(imageFile, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.2), Colors.transparent, _T.bg],
                stops: const [0, 0.4, 1],
              ),
            ),
          ),
          Positioned(
            left: 24, bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusPill(label: "FACE SCAN COMPLETE", color: _T.teal),
                const SizedBox(height: 12),
                Text(
                  "Visual Health Report",
                  style: const TextStyle(color: _T.textPrim, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _ResultGrid(results: results),
          const SizedBox(height: 24),
          _InsightCard(results: results),
          const SizedBox(height: 32),
          
          _SectionTitle("QUICK ACTIONS"),
          const SizedBox(height: 16),
          Row(
            children: [
              _CompactAction(
                icon: Icons.chat_bubble_outline_rounded,
                label: "AI Chat",
                color: _T.teal,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen(category: 'skin'))),
              ),
              const SizedBox(width: 12),
              _CompactAction(
                icon: Icons.calendar_today_rounded,
                label: "Expert",
                color: _T.pink,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentScreen())),
              ),
              const SizedBox(width: 12),
              _CompactAction(icon: Icons.share_rounded, label: "Share", color: _T.accent, onTap: () {}),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            "Screening is based on visual patterns. Clinical assessment in person is required for dermatological conditions.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: _T.textMuted, height: 1.5, fontStyle: FontStyle.italic),
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

class _ResultGrid extends StatelessWidget {
  final Map<String, dynamic> results;
  const _ResultGrid({required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row("Skin Type", results['skin_type'], Icons.opacity_rounded, const Color(0xFF4A90A4), 
             "Acne Info", results['acne'], Icons.face_6_rounded, _T.pink),
        const SizedBox(height: 12),
        _row("Inflammation", results['inflammation'], Icons.local_fire_department_rounded, Colors.orangeAccent,
             "Blemishes", results['spots'], Icons.center_focus_strong_rounded, _T.accent),
        const SizedBox(height: 12),
        _row("Face Shape", results['face_shape'], Icons.architecture_rounded, _T.teal,
             "Expression", results['emotion'], Icons.emoji_emotions_rounded, Colors.amberAccent),
      ],
    );
  }

  Widget _row(String t1, dynamic d1, IconData i1, Color c1, String t2, dynamic d2, IconData i2, Color c2) {
    return Row(
      children: [
        Expanded(child: _tile(t1, d1, i1, c1)),
        const SizedBox(width: 12),
        Expanded(child: _tile(t2, d2, i2, c2)),
      ],
    );
  }

  Widget _tile(String title, dynamic data, IconData icon, Color color) {
    if (data == null) return const SizedBox();
    final label = data['label'] ?? "N/A";
    final conf = data['confidence']?.toString() ?? "0";
    final isUnclear = label.toString().contains("Inconclusive");

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _T.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isUnclear ? Icons.warning_amber_rounded : icon, color: isUnclear ? Colors.orange : color, size: 16),
              const Spacer(),
              if (!isUnclear) Text("$conf%", style: TextStyle(color: _T.textMuted, fontSize: 10, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 16),
          Text(title.toUpperCase(), style: const TextStyle(color: _T.textMuted, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          Text(label, style: TextStyle(color: _T.textPrim, fontSize: 15, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final Map<String, dynamic> results;
  const _InsightCard({required this.results});

  @override
  Widget build(BuildContext context) {
    final msg = _generate(results);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: _T.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 18),
            SizedBox(width: 10),
            Text("CLINICAL INSIGHTS", style: TextStyle(color: _T.textPrim, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
          ]),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(color: _T.textSub, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _generate(Map<String, dynamic> res) {
    final skin = res['skin_type']?['label']?.toString().toLowerCase() ?? "";
    final acne = res['acne']?['label']?.toString().toLowerCase() ?? "";
    if (acne.contains('severe')) return "Severe acne detected. Avoid physical scrubs and consult a dermatologist for prescription-grade care.";
    if (skin.contains('oily')) return "Oily patterns identified. Maintaining a consistent wash routine with salicylic acid is recommended.";
    if (skin.contains('dry')) return "Dry patches detected. Ensure daily hydration and a rich moisturizer to protect the skin barrier.";
    return "Stable skin profile. Use daily UV protection and a gentle cleanser to maintain these results.";
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
