import 'package:flutter/material.dart';
import 'appointment_screen.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MODERN MEDICAL PREMIUM — Clean, Professional, Sophisticated
// ═══════════════════════════════════════════════════════════════════════════

class DoctorBioScreen extends StatefulWidget {
  final dynamic doctor;
  const DoctorBioScreen({super.key, required this.doctor});

  @override
  State<DoctorBioScreen> createState() => _DoctorBioScreenState();
}

class _DoctorBioScreenState extends State<DoctorBioScreen> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  double _scrollOffset = 0.0;

  // Sophisticated 4-Color Palette (Blue-free)
  static const Color primary    = Color(0xFF1E293B); // Deep Slate
  static const Color accent     = Color(0xFF0D9488); // Teal
  static const Color warning    = Color(0xFFD97706); // Amber
  static const Color background = Color(0xFFF1F5F9); // Light Gray
  
  static const Color textMain   = Color(0xFF0F172A);
  static const Color textMuted  = Color(0xFF64748B);
  static const Color white      = Colors.white;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    
    _animationController.forward();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double rating = (widget.doctor['rating'] ?? 4.8).toDouble();
    final int reviews = (widget.doctor['reviewsCount'] ?? 120);
    final int expYrs = (widget.doctor['experience'] ?? 10);
    final String name = widget.doctor['name']?.startsWith('Dr.') == true 
        ? widget.doctor['name'] 
        : 'Dr. ${widget.doctor['name'] ?? 'Doctor'}';
    final String spec = widget.doctor['specialization'] ?? 'Dermatologist';
    final String qual = widget.doctor['qualification'] ?? 'MBBS, MD (Dermatology)';
    final String about = widget.doctor['about'] ?? 'Highly experienced specialist dedicated to providing world-class care and personalized consultations.';
    final String lang = widget.doctor['languages'] ?? 'English, Nepali';

    // Image Logic
    final String docImage = widget.doctor['imageUrl'] ?? 'assets/images/doctor_placeholder.png';

    return Scaffold(
      backgroundColor: background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _scrollOffset > 100 ? primary : Colors.black26,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHero(name, spec, rating, reviews, docImage),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedSection(0, _buildStatsRow(expYrs, reviews)),
                  const SizedBox(height: 32),
                  _buildAnimatedSection(1, Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('About Doctor'),
                      const SizedBox(height: 16),
                      _buildAboutCard(about),
                    ],
                  )),
                  const SizedBox(height: 32),
                  _buildAnimatedSection(2, Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Credentials & Expertise'),
                      const SizedBox(height: 16),
                      _buildInfoCard(qual, lang),
                    ],
                  )),
                  const SizedBox(height: 32),
                  _buildAnimatedSection(3, Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReviewsHeader(rating, reviews),
                      const SizedBox(height: 16),
                      _buildReviewPreviewList(),
                    ],
                  )),
                  const SizedBox(height: 60), // Extra bottom safe space
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, anim) {
        final double delay = index * 0.15;
        final double start = (delay).clamp(0.0, 1.0);
        final double end = (start + 0.4).clamp(0.0, 1.0);
        
        final curve = CurvedAnimation(
          parent: _animationController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        );

        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - curve.value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: const TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildAboutCard(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: textMain.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 10))],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, color: textMuted, height: 1.6),
      ),
    );
  }

  Widget _buildHero(String name, String spec, double rating, int reviews, String image) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          size: const Size(double.infinity, 420),
          painter: _GeometricPatternPainter(offset: _scrollOffset, color: accent),
        ),
        Container(
          height: 420,
          width: double.infinity,
          decoration: const BoxDecoration(color: primary),
          child: Hero(
            tag: 'doctor_image_${widget.doctor['_id']}',
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.2), Colors.transparent, Colors.black.withOpacity(0.9)],
              ).createShader(rect),
              blendMode: BlendMode.darken,
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => Container(
                  color: accent.withOpacity(0.1),
                  child: const Icon(Icons.person, size: 120, color: white),
                ),
              ),
            ),
          ),
        ),

        // Floating Doctor Info Card
        Positioned(
          bottom: -60,
          left: 24,
          right: 24,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: textMain.withOpacity(0.07),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textMain, letterSpacing: -1.0),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(width: 8, height: 2, color: warning),
                              const SizedBox(width: 8),
                              Text(
                                spec.toUpperCase(),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: accent, letterSpacing: 1.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.verified_rounded, color: Colors.green, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: background),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSubStat(Icons.star_rounded, warning, '$rating ($reviews reviews)'),
                    _buildSubStat(Icons.location_on_rounded, accent, 'Specialist Clinic'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubStat(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(int exp, int patients) {
    return Row(
      children: [
        _buildStatBox('Experience', '$exp+', 'Years'),
        const SizedBox(width: 16),
        _buildStatBox('Patients', '${patients * 10}+', 'Served'),
        const SizedBox(width: 16),
        _buildStatBox('Success', '99%', 'Rate'),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: textMain.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.w800)),
            Text(unit, style: const TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: textMain,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildAboutText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        color: textMuted,
        height: 1.6,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildInfoCard(String qual, String lang) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: textMain.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 12))],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.school_rounded, 'Qualifications', qual),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.translate_rounded, 'Languages Spoken', lang),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: accent, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: textMain, fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsHeader(double rating, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionHeader('Patient Feedback'),
        TextButton(
          onPressed: () => _showAllReviewsDialog(),
          child: const Text('View All', style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  void _showAllReviewsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: textMuted.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text("Patient Reviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textMain)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildReviewCard('Binod Shrestha', '2 days ago', 5, "Excellent surgeon. Explains everything very clearly and the recovery was much faster than expected."),
                  _buildReviewCard('Sita Thapa', '1 week ago', 4, "The doctor was very patient and professional. Highly recommended for pediatric skin issues."),
                  _buildReviewCard('Ramesh Karki', '2 weeks ago', 5, "Best clinic experience in Kathmandu. Dr. Rai is truly an expert in his field."),
                  _buildReviewCard('Anju Sharma', '1 month ago', 5, "Great results with my acne treatment. The staff is also very friendly."),
                  _buildReviewCard('Prakash Gurung', '1 month ago', 4, "Detailed consultation. A bit of a wait but worth it."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewPreviewList() {
    return Column(
      children: [
        _buildReviewCard('Binod Shrestha', '2 days ago', 5, "Extremely professional and knowledgeable. The treatment recommended worked perfectly."),
        const SizedBox(height: 16),
        _buildReviewCard('Sita Thapa', '1 week ago', 4, "The doctor was very patient with my kids. Very happy with the results."),
      ],
    );
  }

  Widget _buildReviewCard(String name, String date, int stars, String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: textMain.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: background,
                child: Text(name[0], style: const TextStyle(color: accent, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: textMain)),
                    Text(date, style: const TextStyle(color: textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(Icons.star_rounded, color: i < stars ? warning : textMuted.withOpacity(0.2), size: 16)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(color: textMuted, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CUSTOM PAINTER — Geometric Background Pattern
// ═══════════════════════════════════════════════════════════════════════════
class _GeometricPatternPainter extends CustomPainter {
  final double offset;
  final Color color;

  _GeometricPatternPainter({required this.offset, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw subtle diagonal lines
    for (int i = -5; i < 15; i++) {
      final startX = i * 60.0 + offset * 0.1;
      final path = Path()
        ..moveTo(startX, 0)
        ..lineTo(startX + size.height * 0.5, size.height);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_GeometricPatternPainter oldDelegate) =>
      offset != oldDelegate.offset;
}