import 'package:flutter/material.dart';
import 'dart:io';
import 'chatbot_screen.dart';
import 'appointment_screen.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS (Premium Clinical - Face Health)
// ─────────────────────────────────────────────
class _T {
  static const bg          = Color(0xFFF1F5F9);
  static const cardBorder  = Color(0xFFE2E8F0);

  static const textPrim    = Color(0xFF0F172A);
  static const textSub     = Color(0xFF475569);
  static const textMuted   = Color(0xFF94A3B8);

  static const primary     = Color(0xFF4F46E5);
  static const secondary   = Color(0xFFE11D48);
  static const accent      = Color(0xFF0D9488);
  static const warning     = Color(0xFFF59E0B);
}

class FaceHealthResultsScreen extends StatelessWidget {
  final File imageFile;
  final Map<String, dynamic> results;

  const FaceHealthResultsScreen({
    super.key,
    required this.imageFile,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final gender = (results['gender']?['label'] ?? "Analysis").toString().toUpperCase();
    
    return Scaffold(
      backgroundColor: _T.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, mq, gender),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const _SectionHeader(title: "CORE DIAGNOSTICS", icon: Icons.analytics_rounded),
                  const SizedBox(height: 16),
                  _ResultGrid(results: results),
                  const SizedBox(height: 32),
                  
                  const _SectionHeader(title: "PERSONALIZED RECOMMENDATIONS", icon: Icons.auto_awesome_rounded),
                  const SizedBox(height: 16),
                  _RecommendationsList(results: results),
                  const SizedBox(height: 32),
                  
                  const _QuickActions(),
                  const SizedBox(height: 48),
                  const _MedicalDisclaimer(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, MediaQueryData mq, String gender) {
    return SliverAppBar(
      expandedHeight: mq.size.height * 0.45,
      pinned: true,
      elevation: 0,
      backgroundColor: _T.primary,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.close_rounded, color: _T.textPrim, size: 20),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(imageFile, fit: BoxFit.cover),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    _T.bg.withOpacity(0.8),
                    _T.bg
                  ],
                  stops: const [0.0, 0.3, 0.85, 1.0],
                ),
              ),
            ),
            // Floating Gender Badge
            Positioned(
              left: 20, bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _T.primary,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: _T.primary.withOpacity(0.3), blurRadius: 10)]
                    ),
                    child: Text(
                      gender,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Face Health Analysis",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: _T.textPrim,
                      letterSpacing: -1.2,
                      shadows: [Shadow(color: Colors.white.withOpacity(0.5), offset: const Offset(0, 2), blurRadius: 10)]
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _T.textMuted),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _T.textMuted, letterSpacing: 1.5),
        ),
      ],
    );
  }
}

class _ResultGrid extends StatelessWidget {
  final Map<String, dynamic> results;
  const _ResultGrid({required this.results});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildCard("Skin Type", results['skin_type'], Icons.water_drop_rounded, const Color(0xFF6366F1), constraints.maxWidth),
          _buildCard("Acne Status", results['acne'], Icons.face_retouching_natural_rounded, const Color(0xFFEC4899), constraints.maxWidth),
          _buildCard("Face Shape", results['face_shape'], Icons.architecture_rounded, const Color(0xFF10B981), constraints.maxWidth),
          _buildCard("Expression", results['emotion'], Icons.emoji_emotions_rounded, const Color(0xFFF59E0B), constraints.maxWidth),
          _buildCard("Inflammation", results['inflammation'], Icons.local_fire_department_rounded, const Color(0xFFEF4444), constraints.maxWidth),
          _buildCard("Pores/Spots", results['spots'], Icons.center_focus_strong_rounded, const Color(0xFF8B5CF6), constraints.maxWidth),
          _buildCard("Gender", results['gender'], Icons.person_search_rounded, const Color(0xFF3B82F6), constraints.maxWidth),
        ],
      );
    });
  }

  Widget _buildCard(String title, dynamic data, IconData icon, Color color, double maxWidth) {
    if (data == null) return const SizedBox();
    final label = data['label'] ?? "N/A";
    final conf = data['confidence']?.toString() ?? "0";
    final isPoor = label.toString().contains("Inconclusive");
    
    return Container(
      width: (maxWidth - 12) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _T.cardBorder),
        boxShadow: [BoxShadow(color: color.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              if (!isPoor) Text("$conf%", style: TextStyle(color: _T.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 18),
          Text(title.toUpperCase(), style: const TextStyle(color: _T.textMuted, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: isPoor ? _T.warning : _T.textPrim, fontSize: 15, fontWeight: FontWeight.w900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RecommendationsList extends StatelessWidget {
  final Map<String, dynamic> results;
  const _RecommendationsList({required this.results});

  @override
  Widget build(BuildContext context) {
    final faceShape = (results['face_shape']?['label'] ?? "").toString().toLowerCase();
    final emotion = (results['emotion']?['label'] ?? "").toString().toLowerCase();
    final skinType = (results['skin_type']?['label'] ?? "").toString().toLowerCase();
    
    final acne = (results['acne']?['label'] ?? "").toString().toLowerCase();
    final spots = (results['spots']?['label'] ?? "").toString().toLowerCase();
    final inflammation = (results['inflammation']?['label'] ?? "").toString().toLowerCase();
    
    return Column(
      children: [
        _buildFaceShapeRec(faceShape),
        const SizedBox(height: 16),
        _buildEmotionalSupport(emotion),
        const SizedBox(height: 16),
        _buildSkincareRec(skinType),
        
        if (acne.contains('mild') || acne.contains('moderate') || acne.contains('severe')) ...[
          const SizedBox(height: 16),
          _buildAcneRec(acne),
        ],
        
        if (spots.contains('mild') || spots.contains('moderate') || spots.contains('severe')) ...[
          const SizedBox(height: 16),
          _buildSpotsRec(spots),
        ],
        
        if (inflammation.isNotEmpty && !inflammation.contains('healthy') && !inflammation.contains('no inflammation') && !inflammation.contains('inconclusive')) ...[
          const SizedBox(height: 16),
          _buildInflammationRec(inflammation),
        ],
      ],
    );
  }

  Widget _buildAcneRec(String acne) {
    String title = "Acne Care Plan";
    String description = "Acne detected. Focus on a gentle routine.";
    IconData icon = Icons.face_retouching_natural_rounded;
    Color color = const Color(0xFFEC4899); // Rose

    if (acne.contains("severe")) {
      description = "Severe acne patterns identified. To prevent scarring, avoid physical scrubs. A dermatologist can prescribe stronger treatments like Isotretinoin or topical retinoids.";
    } else if (acne.contains("moderate")) {
      description = "Moderate acne detected. Incorporate Benzoyl Peroxide or Salicylic Acid into your routine. Ensure your moisturizer is non-comedogenic.";
    } else if (acne.contains("mild")) {
      description = "Mild acne spots found. Keep your skin clean, avoid touching your face, and use a gentle BHA exfoliator twice a week.";
    }

    return _RecommendationTile(title: title, description: description, icon: icon, color: color, label: "ACNE: ${acne.toUpperCase()}");
  }

  Widget _buildSpotsRec(String spots) {
    String title = "Blemishes & Pores";
    String description = "Address uneven texture and spots.";
    IconData icon = Icons.center_focus_strong_rounded;
    Color color = const Color(0xFF8B5CF6); // Purple

    if (spots.contains("severe")) {
      description = "Significant spotting or prominent pores detected. Consider clinical treatments like chemical peels or microneedling. Daily Vitamin C serum and Retinol can help fade spots.";
    } else if (spots.contains("moderate")) {
      description = "Moderate spots or pores visible. Niacinamide (Vitamin B3) is excellent for reducing pore appearance and lightening dark spots.";
    } else {
      description = "Mild spots detected. Chemical exfoliation with AHAs (like Lactic or Glycolic acid) can improve overall skin texture gradually.";
    }

    return _RecommendationTile(title: title, description: description, icon: icon, color: color, label: "SPOTS: ${spots.toUpperCase()}");
  }

  Widget _buildInflammationRec(String inflammation) {
    String title = "Inflammation Alert";
    String description = "Skin irritation detected.";
    IconData icon = Icons.local_fire_department_rounded;
    Color color = const Color(0xFFEF4444); // Red

    if (inflammation.contains("eczema")) {
      description = "Signs consistent with Eczema or inflammation. Prioritize skin barrier repair with colloidal oatmeal, ceramides, and fragrance-free thick creams.";
    } else if (inflammation.contains("psoriasis")) {
      description = "Scaly patterns detected that may indicate Psoriasis. Avoid harsh soaps. Consult a dermatologist for specialized treatments like coal tar or prescription creams.";
    } else if (inflammation.contains("ringworm")) {
      description = "Circular patches detected, suggesting possible fungal infection (Tinea). Over-the-counter anti-fungal creams may help, but seek a professional diagnosis.";
    } else {
      description = "General skin inflammation detected. Use soothing ingredients like Aloe Vera, Centella Asiatica (Cica), and avoid active ingredients until the redness subsides.";
    }

    return _RecommendationTile(title: title, description: description, icon: icon, color: color, label: "ISSUE: ${inflammation.toUpperCase()}");
  }

  Widget _buildFaceShapeRec(String shape) {
    String title = "Recommended Haircut";
    String description = "Analyze your face shape to find the perfect style.";
    IconData icon = Icons.content_cut_rounded;
    Color color = const Color(0xFF10B981);

    if (shape.contains("oval")) {
      description = "Oval faces are highly versatile. For men, a classic fade with a pompadour looks great. For women, long layers or a blunt bob adds elegance. Avoid heavy bangs that could hide your balanced features.";
    } else if (shape.contains("round")) {
      description = "Round faces look best with styles that add height and volume. Try an undercut or a textured pompadour for men. For women, long layers or an asymmetrical pixie cut helps elongate the face.";
    } else if (shape.contains("square")) {
      description = "Square faces have strong jawlines. Soften the edges with side-swept bangs or a textured crew cut for men. Women benefit from long, wispy layers or a soft bob that hits below the jaw.";
    } else if (shape.contains("heart")) {
      description = "Heart shapes have wider foreheads. Try a side-parted look or a messy fringe for men. Women look stunning in shoulder-length waves or a graduated bob to balance the chin.";
    } else if (shape.contains("oblong")) {
      description = "Oblong faces need balance. Avoid high volume on top. For men, a clean side part or fringe is ideal. Women should try voluminous curls or a shoulder-length cut with bangs.";
    }

    return _RecommendationTile(title: title, description: description, icon: icon, color: color, label: "FACE SHAPE: ${shape.toUpperCase()}");
  }

  Widget _buildEmotionalSupport(String emotion) {
    String title = "AI Mood Insight";
    String description = "Your expression looks neutral. Remember to smile today!";
    IconData icon = Icons.sentiment_satisfied_alt_rounded;
    Color color = const Color(0xFFF59E0B);

    if (emotion.contains("sad")) {
      description = "You seem a little down today. Remember, it's okay to have quiet moments. 'Don't worry, be happy!' Why not treat yourself to something you love? You've got this!";
      icon = Icons.volunteer_activism_rounded;
    } else if (emotion.contains("happy")) {
      description = "Your glow is amazing! Your positive energy is contagious. Keep sharing that beautiful smile with the world.";
    } else if (emotion.contains("angry")) {
      description = "Feeling a bit tense? Take deep breaths. A 5-minute meditation can help clear your mind and soothe your soul.";
    } else if (emotion.contains("surprise")) {
      description = "Whoa! That's a look of wonder. Stay curious and keep exploring new possibilities today!";
    }

    return _RecommendationTile(title: title, description: description, icon: icon, color: color, label: "MOOD: ${emotion.toUpperCase()}");
  }

  Widget _buildSkincareRec(String skin) {
    String title = "Skincare & UV Routine";
    String description = "Protect your skin based on your profile.";
    IconData icon = Icons.wb_sunny_rounded;
    Color color = const Color(0xFF6366F1);

    if (skin.contains("oily")) {
      description = "Oily skin needs lightweight, non-comedogenic sunscreen (Gel-based). Look for Matte SPF 50+. Use a Salicylic Acid cleanser twice daily to manage sebum without stripping moisture.";
    } else if (skin.contains("dry")) {
      description = "Dry skin requires extra hydration. Use a Cream-based moisturizing sunscreen with Ceramides or Hyaluronic Acid. Avoid harsh soaps; use a milky cleanser instead.";
    } else if (skin.contains("combination")) {
      description = "Combination skin works well with Fluid sunscreens. Use a balanced routine: hydrating on cheeks and mattifying on the T-zone.";
    } else {
      description = "Maintain your healthy skin with a Broad Spectrum SPF 30+. Consistency is key for long-term vitality.";
    }

    return _RecommendationTile(title: title, description: description, icon: icon, color: color, label: "SKIN: ${skin.toUpperCase()}");
  }
}

class _RecommendationTile extends StatelessWidget {
  final String title, description, label;
  final IconData icon;
  final Color color;

  const _RecommendationTile({required this.title, required this.description, required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _T.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text(title, style: const TextStyle(color: _T.textPrim, fontSize: 16, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(description, style: const TextStyle(color: _T.textSub, fontSize: 13, height: 1.6, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: _T.bg, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: _T.textMuted),
                const SizedBox(width: 8),
                const Text("LEARN MORE ", style: TextStyle(color: _T.textMuted, fontSize: 10, fontWeight: FontWeight.w900)),
                Icon(Icons.arrow_forward_ios_rounded, size: 8, color: _T.textMuted.withOpacity(0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: "QUICK ACTIONS", icon: Icons.bolt_rounded),
        const SizedBox(height: 16),
        Row(
          children: [
            _ActionBtn(
              icon: Icons.chat_bubble_rounded, label: "AI Chat", color: _T.accent,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen(category: 'skin'))),
            ),
            const SizedBox(width: 12),
            _ActionBtn(
              icon: Icons.calendar_month_rounded, label: "Expert", color: _T.secondary,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentScreen())),
            ),
            const SizedBox(width: 12),
            _ActionBtn(icon: Icons.share_rounded, label: "Export", color: _T.primary, onTap: () {}),
          ],
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _T.cardBorder),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(color: _T.textPrim, fontWeight: FontWeight.w900, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicalDisclaimer extends StatelessWidget {
  const _MedicalDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _T.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _T.cardBorder.withOpacity(0.5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.gpp_maybe_rounded, color: _T.textMuted, size: 18),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              "This AI assessment is for guidance only. It does not replace clinical diagnosis. Consult a certified dermatologist for medical treatment.",
              style: TextStyle(fontSize: 11, color: _T.textMuted, height: 1.5, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
