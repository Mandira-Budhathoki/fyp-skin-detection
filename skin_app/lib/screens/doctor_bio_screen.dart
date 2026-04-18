import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'appointment_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NEXT-GEN MEDICAL UI: DYNAMIC SPECIALIST DOCTOR BIO
// Logic: Specialization-based content injection for unique profiles
// ─────────────────────────────────────────────────────────────────────────────

class DoctorBioScreen extends StatefulWidget {
  final dynamic doctor;
  const DoctorBioScreen({super.key, required this.doctor});

  @override
  State<DoctorBioScreen> createState() => _DoctorBioScreenState();
}

class _DoctorBioScreenState extends State<DoctorBioScreen> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() => setState(() => _scrollOffset = _scrollController.offset);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── BRAND TOKENS (Refined Palette) ──────────────────────────────────
  static const Color cPrimary    = Color(0xFF81A6C6); 
  static const Color cAccent     = Color(0xFFAACDDC);
  static const Color cSecondary  = Color(0xFFD2C4B4);
  static const Color cHighlights = Color(0xFFF3E3D0);
  static const Color cSurface    = Color(0xFFFFFFFF);
  static const Color cBg         = Color(0xFFF9F7F5); // Warm tinted background
  static const Color cTextMain   = Color(0xFF34495E);
  static const Color cTextMuted  = Color(0xFF7F8C8D);
  static const Color cSuccess    = Color(0xFF27AE60);
  static const Color cWarning    = Color(0xFFF39C12);

  // ── DYNAMIC DATA CONTENT FACTORY ───────────────────────────────────────
  Map<String, dynamic> _getSpecialistContent(String spec) {
    final s = spec.toLowerCase();
    
    if (s.contains('melanoma') || s.contains('cancer')) {
      return {
        'bio': "World-renowned oncology specialist dedicated to the early detection and non-invasive treatment of malignant melanoma. Utilizing state-of-the-art AI dermoscopy and molecular mapping.",
        'expertise': [
          {'t': 'Dermoscopy', 'i': Icons.biotech_rounded},
          {'t': 'Mole Mapping', 'i': Icons.map_rounded},
          {'t': 'Onco-Surgery', 'i': Icons.healing_rounded},
          {'t': 'AI Diagnostics', 'i': Icons.auto_awesome_rounded},
        ],
        'awards': [
          {'t': 'Melanoma Research Award', 'y': '2023'},
          {'t': 'Oncology Excellence', 'y': '2021'},
        ],
        'training': [
          {'t': 'PhD in Skin Oncology', 's': 'Stanford Medical'},
          {'t': 'Fellowship in Dermoscopy', 's': 'Royal College of Surgeons'},
        ]
      };
    } else if (s.contains('aesthetic') || s.contains('cosmetic') || s.contains('laser')) {
      return {
        'bio': "Pioneer in minimal-invasive aesthetic medicine. Specializing in advanced laser resurfacing, regenerative skin therapies, and facial architecture restoration for a natural, youthful look.",
        'expertise': [
          {'t': 'Laser Therapy', 'i': Icons.bolt_rounded},
          {'t': 'Regenerative Med', 'i': Icons.refresh_rounded},
          {'t': 'Peels & Fillers', 'i': Icons.face_retouching_natural_rounded},
          {'t': 'Aesthetic Surgery', 'i': Icons.content_cut_rounded},
        ],
        'awards': [
          {'t': 'Best Cosmetic Surgeon', 'y': '2024'},
          {'t': 'Innovation in Laser', 'y': '2022'},
        ],
        'training': [
          {'t': 'Master of Aesthetic Surgery', 's': 'Paris Medical Institute'},
          {'t': 'Board Certified Dermatologist', 's': 'International Skin Academy'},
        ]
      };
    } else if (s.contains('pediatric') || s.contains('child') || s.contains('kids')) {
      return {
        'bio': "Expert in child-focused dermatology with a gentle approach. Specializing in pediatric eczema, congenital moles, and genetic skin conditions with 15+ years of dedicated service to young patients.",
        'expertise': [
          {'t': 'Gentle Care', 'i': Icons.child_care_rounded},
          {'t': 'Eczema Control', 'i': Icons.opacity_rounded},
          {'t': 'Genetic Mapping', 'i': Icons.biotech_rounded},
          {'t': 'Newborn Support', 'i': Icons.baby_changing_station_rounded},
        ],
        'awards': [
          {'t': 'Pediatrician of the Year', 'y': '2023'},
          {'t': 'Compassionate Care Award', 'y': '2022'},
        ],
        'training': [
          {'t': 'Doctorate in Pediatric Derm', 's': 'Johns Hopkins University'},
          {'t': 'Clinical Residency', 's': 'Kathmandu Children’s Hospital'},
        ]
      };
    } else {
      // General Dermatologist / Default
      return {
        'bio': "Comprehensive dermatology expert focusing on adult skin health, acne management, and preventive care. Dedicated to providing evidence-based treatment plans tailored to each unique skin profile.",
        'expertise': [
          {'t': 'Acne Solutions', 'i': Icons.face_retouching_natural_rounded},
          {'t': 'Chronic Care', 'i': Icons.medical_services_rounded},
          {'t': 'General Diagnosis', 'i': Icons.search_rounded},
          {'t': 'Preventive Derm', 'i': Icons.shield_rounded},
        ],
        'awards': [
          {'t': 'Clinical Excellence', 'y': '2023'},
          {'t': 'Patient Choice Award', 'y': '2022'},
        ],
        'training': [
          {'t': 'MBBS, MD Dermatology', 's': 'Institute of Medicine, T.U.'},
          {'t': 'Dermatology Specialized', 's': 'Nepal Medical Council'},
        ]
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map doc = widget.doctor is Map ? widget.doctor : {};
    final String name = (doc['name'] ?? 'Consultant').toString().startsWith('Dr.') 
        ? doc['name'] : 'Dr. ${doc['name'] ?? 'Specialist'}';
    final String spec = doc['specialization'] ?? 'Dermatologist';
    final String qual = doc['qualification'] ?? 'MBBS, MD';
    final String exp  = "${doc['experience'] ?? '10'}+ Yrs";
    final String rating = (doc['rating'] ?? 4.8).toString();
    final String reviews = "${doc['reviewsCount'] ?? 120} Reviews";
    final String img = doc['imageUrl'] ?? 'assets/images/doctor1.jpeg';

    // Inject Dynamic Content
    final content = _getSpecialistContent(spec);

    return Scaffold(
      backgroundColor: cBg,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                _buildFocusedHeader(name, spec, rating, reviews, img, exp),
                _buildEnhancedBody(content['bio'], content['expertise'], content['training'], content['awards']),
                const SizedBox(height: 120), // Richer bottom padding for complete feel
              ],
            ),
          ),
          _buildMinimalTopBar(),
          _buildTactileBottomBar(),
        ],
      ),
    );
  }

  Widget _buildFocusedHeader(String name, String spec, String rating, String reviews, String img, String exp) {
    return Container(
      height: 380,
      child: Stack(
        children: [
          Container(
            height: 270, 
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [cPrimary, cSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40)),
            ),
          ),
          Positioned(
            top: 130,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cSurface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: cPrimary.withOpacity(0.12), blurRadius: 40, offset: const Offset(0, 15)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: cBg, width: 4),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
                          image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: cTextMain, letterSpacing: -0.5)),
                            const SizedBox(height: 2),
                            Text(spec, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cTextMuted)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: cSuccess.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                              child: const Text("VERIFIED SPECIALIST", style: TextStyle(color: cSuccess, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _headerMetric(Icons.star_rounded, cWarning, rating, "Rating"),
                      _verticalDivider(),
                      _headerMetric(Icons.groups_rounded, cPrimary, "1.2k+", "Patients"),
                      _verticalDivider(),
                      _headerMetric(Icons.workspace_premium_rounded, cAccent, exp, "Exp."),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerMetric(IconData icon, Color color, String val, String label) {
    return Column(
      children: [
        Row(children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(val, style: const TextStyle(color: cTextMain, fontWeight: FontWeight.w900, fontSize: 13)),
        ]),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: cTextMuted, fontSize: 10, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _verticalDivider() => Container(width: 1, height: 24, color: Colors.black.withOpacity(0.05));

  Widget _buildEnhancedBody(String bio, List<dynamic> expertise, List<dynamic> training, List<dynamic> awards) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("PROFESSIONAL BIO"),
          const SizedBox(height: 12),
          Text(bio, style: const TextStyle(color: cTextMuted, fontSize: 14, height: 1.6)),

          const SizedBox(height: 32),
          _label("KEY SPECIALIZATIONS"),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: expertise.map((e) => _chip(e['t'], e['i'])).toList(),
          ),

          const SizedBox(height: 32),
          _label("EDUCATION & TRAINING"),
          const SizedBox(height: 12),
          ...training.map((t) => _docCard(t['t'], t['s'], Icons.school_rounded)).toList(),

          const SizedBox(height: 32),
          _label("STARS & REWARDS"), // Added more variety
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: awards.map((a) => _award(a['t'], a['y'])).toList(),
          ),

          const SizedBox(height: 40), // Satisfaction buffer
        ],
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: cPrimary, letterSpacing: 1.5));

  Widget _chip(String t, IconData i) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: cBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cPrimary.withOpacity(0.05))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(i, size: 14, color: cAccent),
          const SizedBox(width: 6),
          Text(t, style: const TextStyle(color: cTextMain, fontWeight: FontWeight.w700, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _docCard(String t, String s, IconData i) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.04))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: cAccent.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: Icon(i, color: cAccent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: cTextMain)),
            Text(s, style: const TextStyle(fontSize: 12, color: cTextMuted, fontWeight: FontWeight.w600)),
          ])),
        ],
      ),
    );
  }

  Widget _award(String t, String y) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: cSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: cWarning.withOpacity(0.2))),
      child: Row(children: [
        const Icon(Icons.stars_rounded, color: cWarning, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: cTextMain), overflow: TextOverflow.ellipsis),
            Text(y, style: const TextStyle(fontSize: 10, color: cTextMuted, fontWeight: FontWeight.w700)),
          ],
        )),
      ]),
    );
  }

  Widget _buildMinimalTopBar() {
    final bool isDark = _scrollOffset > 50;
    return Positioned(
      top: 0, left: 0, right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5, bottom: 10, left: 16, right: 16),
        color: isDark ? cPrimary : Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _topBtn(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
            if (isDark) const Text("Doctor Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
            _topBtn(Icons.bookmark_border_rounded, () {}),
          ],
        ),
      ),
    );
  }

  Widget _topBtn(IconData i, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.15), shape: BoxShape.circle),
        child: Icon(i, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildTactileBottomBar() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 20),
        decoration: BoxDecoration(
          color: cSurface,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, -12))],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentScreen(initialDoctor: widget.doctor))),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [cPrimary, cAccent]),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: cPrimary.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8))],
            ),
            child: const Center(child: Text("Schedule Consultation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5))),
          ),
        ),
      ),
    );
  }
}