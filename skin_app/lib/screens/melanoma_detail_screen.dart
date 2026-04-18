import 'package:flutter/material.dart';
import 'melanoma_info_provider.dart';

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

  static const primary   = Color(0xFF0066FF);
  static const highRisk  = Color(0xFFE11D48);
  static const warning   = Color(0xFFF59E0B);
  static const accent    = Color(0xFF7C3AED);
}

class MelanomaDetailScreen extends StatelessWidget {
  final String conditionName;
  final bool isHighRisk;

  const MelanomaDetailScreen({
    super.key,
    required this.conditionName,
    required this.isHighRisk,
  });

  @override
    Widget build(BuildContext context) {
      final info = MelanomaInfoProvider.getInfoForClass(conditionName);
      final Color themeColor = isHighRisk ? _T.highRisk : _T.primary;
  
      return Scaffold(
        backgroundColor: _T.bg,
        body: ScrollConfiguration(
          behavior: _NoGlowBehavior(),
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              // 🧪 PREMIUM CLINICAL HEADER
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                elevation: 0,
                backgroundColor: themeColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isHighRisk 
                              ? [const Color(0xFFE11D48), const Color(0xFF9F1239)] 
                              : [const Color(0xFF0066FF), const Color(0xFF1E40AF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Positioned(right: -20, bottom: -20, child: Icon(isHighRisk ? Icons.warning_amber_rounded : Icons.shield_rounded, size: 180, color: Colors.white.withOpacity(0.1))),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Text("PATHOLOGY DOSSIER", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                            const SizedBox(height: 8),
                            Text(conditionName.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.3))),
                              child: Text(isHighRisk ? "URGENT ACTIONS REQUIRED" : "STANDARD CARE PROTOCOL", style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
  
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isHighRisk) ...[
                        _AlertCard(message: "Immediate board-certified dermatological biopsy is required for high-risk features."),
                        const SizedBox(height: 32),
                      ],
  
                      _SectionTitle("CLINICAL ANALYSIS"),
                      const SizedBox(height: 16),
                      if (info != null) ...[
                        _DetailTile(title: 'Medical Classification', content: info['Type']!, icon: Icons.biotech_rounded, color: _T.accent),
                        _DetailTile(title: 'Primary Etiology', content: info['Cause']!, icon: Icons.wb_sunny_rounded, color: _T.warning),
                        _DetailTile(title: 'Diagnostic Symptoms', content: info['Symptoms']!, icon: Icons.troubleshoot_rounded, color: Colors.blue),
                        _DetailTile(title: 'Recommended Therapy', content: info['Treatment']!, icon: Icons.medical_services_rounded, color: Colors.green),
                      ] else
                        const Center(child: Text('No dossier data available.', style: TextStyle(color: _T.textMuted))),
  
                      const SizedBox(height: 40),
  
                      // PRIMARY CTA
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/appointment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _T.textPrim,
                          minimumSize: const Size(double.infinity, 64),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 8,
                          shadowColor: _T.textPrim.withOpacity(0.3),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 20, color: Colors.white),
                            const SizedBox(width: 12),
                            Text("BOOK CLINICAL EVALUATION", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Colors.white)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
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

class _DetailTile extends StatelessWidget {
  final String title, content;
  final IconData icon;
  final Color color;
  const _DetailTile({required this.title, required this.content, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: _T.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Text(title.toUpperCase(), style: TextStyle(color: _T.textPrim, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),
          Text(content, style: const TextStyle(color: _T.textSub, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String message;
  const _AlertCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(24), border: Border.all(color: _T.highRisk.withOpacity(0.2))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_rounded, color: _T.highRisk, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(message, style: const TextStyle(color: Color(0xFF9F1239), fontSize: 14, height: 1.5, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}
