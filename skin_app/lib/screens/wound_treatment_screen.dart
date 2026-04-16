import 'package:flutter/material.dart';
import '../data/wound_advice_provider.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS (Modern Clinical Pro)
// ─────────────────────────────────────────────
class _T {
  static const bg        = Color(0xFFF1F8F8);
  static const surface   = Colors.white;
  static const cardBorder= Color(0xFFE2E8F0);

  static const textPrim  = Color(0xFF0F172A);
  static const textSub   = Color(0xFF475569);
  static const textMuted = Color(0xFF94A3B8);

  static const primary   = Color(0xFF8CC7C4); // Teal
  static const deep      = Color(0xFF2C687B); // Deep Teal
  static const emergency = Color(0xFFE11D48);
  static const warning   = Color(0xFFF59E0B);
}

class WoundTreatmentScreen extends StatelessWidget {
  final String prediction;
  final String message;

  const WoundTreatmentScreen({
    super.key, 
    required this.prediction,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final advice = WoundAdviceProvider.getAdviceForWound(prediction);
    final String title = advice['title'] as String;
    final List<String> steps = List<String>.from(advice['steps']);
    final String warning = advice['warning'] as String;
    
    final bool isEmergency = prediction.toLowerCase().contains('bleeding') ||
                             prediction.toLowerCase().contains('deep') ||
                             prediction.toLowerCase().contains('infected');
                             
    final Color themeColor = isEmergency ? _T.emergency : _T.primary;

    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "RECOVERY GUIDE",
          style: TextStyle(color: _T.textPrim, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _T.textPrim, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ScrollConfiguration(
        behavior: _NoGlowBehavior(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(), // NO BOUNCE
          child: Column(
            children: [
              // 🏷️ HEADER SECTION
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: themeColor.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.health_and_safety_rounded, color: themeColor, size: 48),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _T.textPrim, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 12),
                    _StatusTag(label: isEmergency ? "URGENT PROTOCOL" : "CARE PROTOCOL", color: themeColor),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle("CLINICAL INSIGHT"),
                    const SizedBox(height: 12),
                    _InfoCard(message: message, prediction: prediction),
                    
                    const SizedBox(height: 32),

                    _SectionTitle("RECOVERY STEPS"),
                    const SizedBox(height: 16),
                    ...steps.asMap().entries.map((entry) => _StepRow(index: entry.key + 1, step: entry.value, color: themeColor)).toList(),

                    const SizedBox(height: 32),

                    _AlertCard(warning: warning),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/appointment'),
                        icon: const Icon(Icons.local_hospital_rounded, size: 18),
                        label: const Text("VISIT DOCTOR", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _T.deep,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("CLOSE RECOVERY GUIDE", style: TextStyle(color: _T.textMuted, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _SectionTitle(String text) => Text(
    text,
    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _T.textMuted, letterSpacing: 2),
  );
}

class _StatusTag extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String message;
  final String prediction;
  const _InfoCard({required this.message, required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8CC7C4), Color(0xFF2C687B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF8CC7C4).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.biotech_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'AI CLINICAL OBSERVATION',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
                ),
              ],
            ),
          ),
          // Observation text
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.isNotEmpty
                  ? message
                  : 'Analysis indicates a $prediction-type wound pattern. Standard healing protocols should be initiated. Monitor daily for changes in appearance, exudate, or pain levels.',
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF2C687B),
                height: 1.65,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int index;
  final String step;
  final Color color;
  const _StepRow({required this.index, required this.step, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _T.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Text(index.toString(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13)),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const SizedBox(height: 6),
                 Text(
                  step,
                  style: const TextStyle(fontSize: 14, color: _T.textSub, height: 1.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String warning;
  const _AlertCard({required this.warning});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _T.emergency.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error_rounded, color: _T.emergency, size: 24),
              const SizedBox(width: 12),
              const Text("SAFETY FIRST", style: TextStyle(color: _T.emergency, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            warning,
            style: const TextStyle(color: Color(0xFF9F1239), fontSize: 14, height: 1.6, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Text(
            "This guide is powered by AI and must be verified by a medical doctor.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF9F1239), fontSize: 10, fontStyle: FontStyle.italic),
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
