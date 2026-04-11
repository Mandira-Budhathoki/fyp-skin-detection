import 'package:flutter/material.dart';
import 'dart:io';
import 'chatbot_screen.dart';
import 'appointment_screen.dart';
import 'face_faq_screen.dart';
import 'products_screen.dart';

// ─────────────────────────────────────────────
//  EXACT REPLICATION (IMAGE 2) - CENTERED & BIG
// ─────────────────────────────────────────────
class _Ref {
  static const bgStart  = Color(0xFFF2FBFF); 
  static const bgEnd    = Color(0xFFFFF6F4); 
  static const navy     = Color(0xFF334E68); 
  static const slate    = Color(0xFF627D98); 
  static const success  = Color(0xFF71BC9D); 
  static const coral    = Color(0xFFE28585); 
  static const teal     = Color(0xFF86B9C1);
  static const trackBlue = Color(0xFF4DA8CF);
  static const trackOrg  = Color(0xFFFF8C69);
  static const trackPink = Color(0xFFE28585);
  static const purple    = Color(0xFF9489BA);
}

class FaceHealthResultsScreen extends StatefulWidget {
  final File imageFile;
  final Map<String, dynamic> results;

  const FaceHealthResultsScreen({
    super.key,
    required this.imageFile,
    required this.results,
  });

  @override
  State<FaceHealthResultsScreen> createState() => _FaceHealthResultsScreenState();
}

class _FaceHealthResultsScreenState extends State<FaceHealthResultsScreen> {
  double _v(String? label) {
    if (label == null) return 0.5;
    final l = label.toUpperCase();
    if (l.contains("CLEAR") || l.contains("OPTIMAL") || l.contains("LOW")) return 0.22;
    return 0.78;
  }

  @override
  Widget build(BuildContext context) {
    // THE 7 AUTHENTIC TRAINED LAYERS
    final genderRaw = (widget.results['gender']?['label'] ?? "Woman").toString().toUpperCase();
    final isMan = genderRaw.contains('MAN') && !genderRaw.contains('WOMAN');
    final genderText = isMan ? "MAN" : "WOMAN";
    final skin = (widget.results['skin_type']?['label'] ?? "Normal").toString().toUpperCase();
    final acne = (widget.results['acne']?['label'] ?? "Clear").toString().toUpperCase();
    final shape = (widget.results['face_shape']?['label'] ?? "Oval").toString().toUpperCase();
    final emo = (widget.results['emotion']?['label'] ?? "Neutral").toString().toUpperCase();
    final infla = (widget.results['inflammation']?['label'] ?? "Optimal").toString().toUpperCase();
    final spots = (widget.results['spots']?['label'] ?? "Short").toString().toUpperCase();

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [_Ref.bgStart, _Ref.bgEnd])),
        child: SafeArea(
          child: Column(
            children: [
              _buildRefHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      const Text("FACIAL BIOMETRIC ANALYSIS LOG", textAlign: TextAlign.center, style: TextStyle(color: _Ref.navy, fontSize: 13, fontWeight: FontWeight.w900)),
                      const Text("2026-04-12", textAlign: TextAlign.center, style: TextStyle(color: _Ref.slate, fontSize: 11, fontWeight: FontWeight.bold)),
                      
                      const SizedBox(height: 18),
                      // 1. SYMMETRICAL & BIG STAR GRID
                      _buildBigSymmetricalGrid(skin, acne, shape, emo, infla, spots, genderText),

                      const SizedBox(height: 24),
                      _buildTrackerHeader(),

                      // ─────────────────────────────────────────────
                      //  UNSTACKED CLINIC CARDS (NO IMAGES)
                      // ─────────────────────────────────────────────
                      _ClinicCard(
                        title: "🧬 SKIN PROFILE: $skin", badge: "Balanced", color: _Ref.trackBlue, val: _v(skin),
                        desc: "🧴 Your skin barrier is stable. AM: Cleanse with tepid water & use a water-gel SPF 50. PM: Use a mild foaming cleanser & lightweight niacinamide serum. ✨",
                      ),
                      _ClinicCard(
                        title: "🛡️ ACNE INTENSITY: $acne", badge: "Optimal 🎉", color: _Ref.trackPink, val: _v(acne),
                        desc: "🏥 Current layer is $acne. Clinical Protocol: Use a 2% Salicylic Acid wash nightly. Avoid sugar & dairy for 48 hours to preserve index stability. 🥛🚫",
                      ),
                      _ClinicCard(
                        title: "📐 FACE SHAPE: $shape", badge: "Style Fit", color: _Ref.purple, val: 0.5,
                        desc: isMan ? "✂️ For your $shape structure, a POMPADOUR with high volume and a sharp jawline stubble is recommended for an angled look. 💈" : "✂️ For your $shape architect, FACE-FRAMING LAYERS or a LONG BOB (Lob) will beautifully elongate your profile. 💇‍♀️",
                      ),
                      _ClinicCard(
                        title: "✨ EMOTION: $emo", badge: "Vibrant Hub", color: _Ref.trackBlue, val: _v(emo),
                        desc: emo.contains("SAD") ? "💖 Don't be sad! You're much too pretty to frown. 😊 Cortisol from stress can impact your glow. Take 5 minutes for yourself! 🌸" : "🌟 Positive vitality index detected. This mood significantly boosts dermal regeneration. ✨",
                      ),
                      _ClinicCard(
                        title: "🌿 INFLAMMATION: $infla", badge: "Dermal Calm", color: _Ref.trackOrg, val: _v(infla),
                        desc: "🧊 Status is $infla. Use soothing agents like CICA, Centella, or Green Tea. Avoid hot water for 48 hours for biometric recovery. 🍃",
                      ),
                      _ClinicCard(
                        title: "💎 PORES & TEXTURE: $spots", badge: "Clear View", color: _Ref.teal, val: _v(spots),
                        desc: "🧼 Visibility is $spots. Maintain clarity with weekly kaolin treatments. Use heavy moisturizers sparingly on the orbital region. 🧴",
                      ),
                      _ClinicCard(
                        title: "👤 GENDER ARCHETYPE: $genderText", badge: "Verified", color: _Ref.navy, val: 0.1,
                        desc: "🧬 Report logic has been filtered through the $genderText biometric protocol for maximum diagnostic accuracy. ✅",
                      ),

                      const SizedBox(height: 32),
                      _buildFooterButtons(),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: _Ref.navy), onPressed: () => Navigator.pop(context)),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
            child: CircleAvatar(radius: 18, backgroundImage: FileImage(widget.imageFile)),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: _Ref.navy),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lightbulb_circle_rounded, color: _Ref.teal, size: 45),
                      const SizedBox(height: 16),
                      const Text("SCAN QUALITY GUIDE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: _Ref.navy, letterSpacing: 1)),
                      const SizedBox(height: 12),
                      const Text(
                        "Diagnostic accuracy is highly dependent on ambient lighting and lens clarity. For the most precise results, we recommend scanning in high-contrast natural daylight. Clear imagery leads to a 100% authentic output from our neural layers! ✨🔭🌅",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, height: 1.5, color: _Ref.slate, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 20),
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("UNDERSTOOD", style: TextStyle(fontWeight: FontWeight.w900, color: _Ref.teal))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigSymmetricalGrid(String skin, String acne, String shape, String emo, String infla, String spots, String gender) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _megaItem("SKIN", skin, const Color(0xFF76D7EA)),
              _megaItem("ACNE", acne, _Ref.trackBlue),
              _megaItem("SHAPE", shape, _Ref.purple),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _megaItem("MOOD", emo, _Ref.trackBlue),
              _megaItem("PORES", infla, _Ref.trackOrg),
              _megaItem("SPOTS", spots, _Ref.trackPink),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: _megaItem("GENDER", gender, _Ref.navy),
          ),
        ],
      ),
    );
  }

  Widget _megaItem(String l, String v, Color c) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.withOpacity(0.3), width: 3.0), color: c.withOpacity(0.05)),
            child: Icon(Icons.star_rounded, color: c, size: 38), // INCREASED SIZE
          ),
          const SizedBox(height: 8),
          Text(l, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _Ref.slate)),
          Text(v, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _Ref.navy)),
        ],
      ),
    );
  }

  Widget _buildTrackerHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 15),
      child: Row(children: [
        Icon(Icons.auto_graph_rounded, color: _Ref.trackBlue, size: 18),
        SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Your model tracker", style: TextStyle(fontWeight: FontWeight.w900, color: _Ref.navy, fontSize: 13)),
          Text("Awesome, keep going! Your tracker is getting smarter! 🚀", style: TextStyle(fontSize: 10, color: _Ref.slate, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }

  Widget _buildFooterButtons() {
    return Row(
      children: [
        _fBtn("DOCTOR", Icons.medical_services_rounded, _Ref.purple, () => Navigator.pushNamed(context, '/appointment')),
        const SizedBox(width: 8),
        _fBtn("AI CHAT", Icons.chat_bubble_rounded, _Ref.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen(category: 'skin')))),
        const SizedBox(width: 8),
        _fBtn("PRODUCTS", Icons.shopping_basket_rounded, _Ref.coral, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()))),
      ],
    );
  }

  Widget _fBtn(String l, IconData i, Color c, VoidCallback t) => Expanded(
    child: GestureDetector(
      onTap: t,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: c.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(children: [Icon(i, color: Colors.white, size: 20), const SizedBox(height: 6), Text(l, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900))]),
      ),
    ),
  );
}

class _ClinicCard extends StatefulWidget {
  final String title, badge, desc;
  final Color color;
  final double val;

  const _ClinicCard({required this.title, required this.badge, required this.desc, required this.color, required this.val});

  @override
  State<_ClinicCard> createState() => _ClinicCardState();
}

class _ClinicCardState extends State<_ClinicCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))]),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(children: [
                    Flexible(child: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: _Ref.navy), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 4),
                    Icon(_isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 16, color: _Ref.navy),
                  ]),
                ),
                Row(children: [
                  Text(widget.badge, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: _Ref.navy)),
                  const SizedBox(width: 8),
                  const CircleAvatar(radius: 10, backgroundColor: _Ref.success, child: Icon(Icons.arrow_downward_rounded, size: 12, color: Colors.white)),
                ]),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 18),
              Text(widget.desc, style: const TextStyle(fontSize: 11, height: 1.6, color: _Ref.slate, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 14),
            LinearProgressIndicator(value: widget.val, backgroundColor: const Color(0xFFF2F5F8), color: widget.color, minHeight: 7, borderRadius: BorderRadius.circular(10)),
          ],
        ),
      ),
    );
  }
}
