import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../data/wound_advice_provider.dart';
import 'wound_treatment_screen.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS (Clinical Pathology Pro)
// ─────────────────────────────────────────────
class _T {
  static const bg        = Color(0xFFF8FAFC);
  static const surface   = Colors.white;
  static const border    = Color(0xFFE2E8F0);

  static const textHeader= Color(0xFF0F172A);
  static const textSub   = Color(0xFF475569);
  static const textMuted = Color(0xFF94A3B8);

  static const cyan      = Color(0xFF8CC7C4); // User Requested
  static const blue      = Color(0xFF1E3A8A); // Premium Royal Blue
  static const critical  = Color(0xFFBE123C); // Deep Clinical Red
  static const safe      = Color(0xFF10B981); // Emerald Green
}

class WoundResultsScreen extends StatefulWidget {
  final Map<String, dynamic> results;
  const WoundResultsScreen({super.key, required this.results});

  @override
  State<WoundResultsScreen> createState() => _WoundResultsScreenState();
}

class _WoundResultsScreenState extends State<WoundResultsScreen> with TickerProviderStateMixin {
  late final Map<String, dynamic> _prim;
  late final Map<String, dynamic>? _sec;
  late final String _agreement;
  late final bool _showSpecialist;

  late final String _prediction;
  late final double _confidence;
  late final String _message;
  late final File?  _imageFile;
  late final bool   _isEmergency;
  
  late final AnimationController _entryCtrl;
  late final Animation<double> _fade;

  // Translation Map for Secondary Terms (Enriched Content)
  final Map<String, Map<String, String>> _specialistLexicon = {
    'arterial_ulcer': {
      'medical': 'Arterial Ulcer',
      'simple': 'Circulation Sore',
      'desc': 'A deep-tissue sore caused by narrowed arteries, which significantly reduces the flow of oxygen-rich blood to the skin and prevents natural healing.',
      'advice': '1. Keep the affected limb warm to encourage blood flow.\n2. Do NOT use tight compression unless specifically told by a doctor.\n3. Avoid long periods of sitting or leg crossing.\n4. Seek urgent surgical review to check blood pressure in the limb.'
    },
    'venous_ulcer': {
      'medical': 'Venous Ulcer',
      'simple': 'Vein-related Sore',
      'desc': 'A skin sore that occurs when blood pools in the lower leg veins due to valve issues, causing high pressure and leakage into the surrounding tissue.',
      'advice': '1. Elevate your legs above heart level for 30 minutes, 3 times a day.\n2. Walk regularly to keep blood moving, but avoid standing still.\n3. If skin is dry, apply a gentle moisturizer to surrounding areas.\n4. Clinical compression therapy is usually the primary treatment.'
    },
    'diabetic_ulcer': {
      'medical': 'Diabetic Ulcer',
      'simple': 'Diabetic Foot/Skin Sore',
      'desc': 'A complex sore occurring in diabetic patients, often due to a combination of high blood sugar, nerve damage (neuropathy), and poor circulation.',
      'advice': '1. NEVER walk barefoot; always wear protective socks and shoes.\n2. Clean the area with mild soap and dry carefully between toes.\n3. Check blood glucose levels twice daily to ensure optimal healing.\n4. Have a podiatrist inspect the wound for signs of bone infection.'
    },
    'pressure_ulcer': {
      'medical': 'Pressure Ulcer',
      'simple': 'Bedsore',
      'desc': 'Localized damage to the skin and underlying soft tissue, usually over a bony prominent area, resulting from prolonged pressure or friction.',
      'advice': '1. Use specialized air-cushions or foam pads to redistribute weight.\n2. Reposition your body at least every 2 hours (off-loading).\n3. Keep the skin as clean and dry as possible to prevent further breakdown.\n4. Ensure high protein intake to support tissue regeneration.'
    },
    'surgical_wound': {
      'medical': 'Surgical Wound',
      'simple': 'Clinical Site',
      'desc': 'A precise incision made by a healthcare professional during an operation, currently in the process of healing and cellular reconstruction.',
      'advice': '1. Keep the primary dressing dry; avoid direct showering unless waterproofed.\n2. Do not pull at any visible sutures or staples.\n3. Watch for "Dehiscence" (edges opening up) or foul-smelling discharge.\n4. Follow your surgeon\'s specific post-op cleaning schedule strictly.'
    },
    'traumatic_wound': {
      'medical': 'Traumatic Wound',
      'simple': 'Accidental Injury',
      'desc': 'A sudden, non-surgical injury caused by external force, potentially involving jagged edges, debris exposure, or deep tissue bruising.',
      'advice': '1. Ensure all dirt and debris are gently irrigated out with saline.\n2. Apply a thin layer of antibiotic ointment for the first 3 days.\n3. Keep the area protected with sterile gauze to prevent secondary trauma.\n4. Monitor for "Spreading Redness"—a key sign of bacterial cellulitis.'
    },
  };

  @override
  void initState() {
    super.initState();
    final ensemble = widget.results['ensemble'] as Map<String, dynamic>?;
    _prim = ensemble?['primary'] as Map<String, dynamic>? ?? {
      'label': widget.results['prediction'] ?? 'Unknown Lesion',
      'score': (widget.results['confidence'] ?? 0.0).toDouble()
    };
    _sec = ensemble?['secondary'] as Map<String, dynamic>?;
    _agreement = widget.results['agreement'] ?? 'Primary Scan';

    _prediction  = _prim['label'] ?? 'Unknown Lesion';
    _confidence  = (_prim['score'] ?? 0.0).toDouble();
    _message     = widget.results['message'] ?? '';
    _imageFile   = widget.results['imageFile'] as File?;
    _isEmergency = _prediction.toLowerCase().contains('bleeding') || 
                   _prediction.toLowerCase().contains('deep') || 
                   _prediction.toLowerCase().contains('infected');

    // Smart Visibility: Show if secondary is a high-risk category with decent score
    final sLabel = _sec?['label']?.toString().toLowerCase() ?? '';
    final sScore = (_sec?['score'] ?? 0.0).toDouble();
    _showSpecialist = sScore > 45 && sLabel != 'normal_skin';

    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReportHeader(),
              const SizedBox(height: 20),
              _buildHeroImageSection(),
              const SizedBox(height: 24),
              _buildPathologyCard(),
              if (_showSpecialist) ...[
                const SizedBox(height: 16),
                _buildVerificationCard(),
              ],
              const SizedBox(height: 16),
              _buildInfectionWatchCard(),
              const SizedBox(height: 16),
              _buildDoctorPrescribedProtocol(),
              if (_showSpecialist) ...[
                const SizedBox(height: 16),
                _buildSpecialistAdviceCard(),
              ],
              const SizedBox(height: 24),
              _buildClinicalFooter(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _T.textHeader, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          const Text("WOUND PATHOLOGY", style: TextStyle(color: _T.textHeader, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2)),
          Text(DateFormat('MMM dd, yyyy | HH:mm').format(DateTime.now()), style: const TextStyle(color: _T.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Dynamic data based on wound type
  Map<String, dynamic> get _woundInfo {
    final p = _prediction.toLowerCase();
    if (p.contains('burn')) {
      return {
        'emoji': '🔥',
        'watchTitle': 'BURN WATCH — DANGER SIGNS',
        'watchColor': const Color(0xFFFF6B35),
        'watchBg': const Color(0xFFFFF4F0),
        'flags': [
          ['Blistering & Peeling', 'Large fluid-filled blisters may signal 2nd-degree or deeper burn'],
          ['Charred or White Skin', 'Pain-free blackened/white areas = full-thickness (3rd degree) — ER NOW'],
          ['Chemical Exposure', 'If from chemical contact, flush with water for 20+ min immediately'],
        ],
        'steps': [
          ['💧', 'Cool Running Water', 'Hold under cool (not ice cold) water for 10–20 minutes immediately.'],
          ['🚫', 'DO NOT Use Ice', 'Ice worsens tissue damage. Avoid butter, toothpaste, or home remedies.'],
          ['🩹', 'Non-Stick Dressing', 'Cover loosely with sterile non-adherent gauze or cling film.'],
          ['💊', 'Pain Management', 'Take OTC analgesics (ibuprofen/paracetamol). Seek care for 2nd+ degree burns.'],
        ],
      };
    } else if (p.contains('lacerat') || p.contains('cut')) {
      return {
        'emoji': '🩸',
        'watchTitle': 'LACERATION WATCH — RED FLAGS',
        'watchColor': const Color(0xFFDC2626),
        'watchBg': const Color(0xFFFFF1F2),
        'flags': [
          ['Uncontrolled Bleeding', 'If bleeding does not stop after 10 min of pressure — go to ER'],
          ['Deep / Gaping Wound', 'If edges are far apart or you can see fat/muscle, you need stitches'],
          ['Numbness Near Wound', 'Nerve damage possible — seek immediate evaluation'],
        ],
        'steps': [
          ['✋', 'Direct Pressure', 'Apply firm, constant pressure with a clean cloth for 10–15 minutes.'],
          ['🧼', 'Irrigate Thoroughly', 'Rinse with clean running water for 5+ min to remove debris.'],
          ['🩹', 'Closure', 'Small cuts: steri-strips. Large cuts: require professional sutures.'],
          ['💉', 'Tetanus Check', 'Ensure tetanus vaccination is up to date. Get a booster if unsure.'],
        ],
      };
    } else if (p.contains('abras') || p.contains('graze')) {
      return {
        'emoji': '🛡️',
        'watchTitle': 'ABRASION WATCH — SIGNS TO MONITOR',
        'watchColor': const Color(0xFFD97706),
        'watchBg': const Color(0xFFFFFBEB),
        'flags': [
          ['Embedded Debris', 'Dirt or gravel not removed can lead to serious infection ("traumatic tattoo")'],
          ['Increasing Redness', 'Spreading redness around the wound after 24h signals infection'],
          ['Pus or Foul Odor', 'Any yellow/green discharge means bacterial infection — visit a clinic'],
        ],
        'steps': [
          ['🚿', 'Irrigate Gently', 'Rinse with saline or clean water. Use a soft cloth to remove debris.'],
          ['🔬', 'Antiseptic', 'Apply dilute antiseptic solution (povidone-iodine or chlorhexidine).'],
          ['🩹', 'Moist Healing', 'Keep covered with a moist dressing — moist wounds heal 50% faster.'],
          ['☀️', 'Sun Protection', 'Protect healed skin from UV for 6 months to prevent dark scarring.'],
        ],
      };
    } else if (p.contains('ulcer') || p.contains('diabetic') || p.contains('pressure')) {
      return {
        'emoji': '⚠️',
        'watchTitle': 'ULCER WATCH — CRITICAL FLAGS',
        'watchColor': const Color(0xFFDC2626),
        'watchBg': const Color(0xFFFFF1F2),
        'flags': [
          ['Black/Dark Tissue', 'Necrotic (dead) tissue = critical. Requires urgent surgical debridement.'],
          ['Spreading Redness', 'Cellulitis spreading beyond the ulcer border needs IV antibiotics.'],
          ['Foul Smell + Pus', 'Signs of anaerobic infection — hospital admission may be required.'],
        ],
        'steps': [
          ['🧹', 'Debridement', 'Dead tissue must be removed by a clinician — do not attempt at home.'],
          ['💧', 'Moist Wound Care', 'Use advanced dressings (hydrocolloid/foam) to maintain a moist environment.'],
          ['🩺', 'Offloading', 'Redistribute pressure. Use special footwear or repositioning schedules.'],
          ['🩸', 'BSL Control', 'For diabetic ulcers, strict blood sugar control is #1 priority for healing.'],
        ],
      };
    } else { // Generic / bruise / surgical
      return {
        'emoji': '🩺',
        'watchTitle': 'INFECTION WATCH — RED FLAGS',
        'watchColor': Colors.orange,
        'watchBg': const Color(0xFFFFF7ED),
        'flags': [
          ['Elevated Local Temp', 'Feeling heat around the site can signal early infection'],
          ['Unusual Exudate', 'Yellow/Green discharge or foul odor = bacterial infection'],
          ['Spreading Erythema', 'Expanding redness beyond the wound border'],
        ],
        'steps': [
          ['🧼', 'Irrigation', 'Clean the area with sterile saline solution twice daily.'],
          ['💊', 'Antiseptic Ointment', 'Apply prescribed antibiotic ointment as directed.'],
          ['🩹', 'Sterile Dressing', 'Keep covered with clean, non-adherent sterile gauze.'],
          ['📅', 'Monitor Progress', 'Track healing daily. Swelling/redness worsening after 48h = seek care.'],
        ],
      };
    }
  }

  Widget _buildReportHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_T.cyan, _T.purple], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          const Text("STATUS: SCAN COMPLETE", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildHeroImageSection() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: _imageFile != null 
              ? Image.file(_imageFile!, fit: BoxFit.cover) 
              : Container(color: _T.cyan.withOpacity(0.1)),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
          ),
          Positioned(
            bottom: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _T.cyan),
              ),
              child: Row(
                children: [
                  const Text("AI ANALYSIS COMPLETE", style: TextStyle(color: _T.textHeader, fontWeight: FontWeight.w900, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathologyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _T.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: Text("PRIMARY SCAN FINDING", style: TextStyle(color: _T.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2))),
              _buildUrgencyBadge(),
            ],
          ),
          const SizedBox(height: 8),
          Text(_prediction.toUpperCase(), style: const TextStyle(color: _T.textHeader, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          const Text("AI OBSERVATION NOTES", style: TextStyle(color: _T.textHeader, fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            _message.isNotEmpty ? _message : "Automated analysis detected wound tissue with characteristic features. Monitor wound boundaries and tissue response daily for optimal healing.",
            style: const TextStyle(color: _T.textSub, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard() {
    final sLabelKey = _sec!['label'].toString().toLowerCase();
    final sLabelDisplay = sLabelKey.replaceAll('_', ' ');
    final bool theyAgree = _prediction.toLowerCase() == sLabelDisplay;
    
    // Get clinical friendly term
    final Map<String, String>? lexicon = _specialistLexicon[sLabelKey];
    final String friendlyName = lexicon?['simple'] ?? sLabelDisplay.toUpperCase();
    final String friendlyDesc = lexicon?['desc'] ?? "A medical-level tissue pattern was detected.";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _T.cyan.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: _T.cyan.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(theyAgree ? Icons.verified_user_rounded : Icons.biotech_rounded, color: _T.cyan, size: 20),
              const SizedBox(width: 10),
              const Text("CLINICAL CROSS-CHECK", style: TextStyle(color: _T.textHeader, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              const Spacer(),
              if (theyAgree)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _T.safe.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Text("DOUBLE-CHECKED", style: TextStyle(color: _T.safe, fontSize: 8, fontWeight: FontWeight.w900)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _verificationRow("Main Specialist", _prediction, _confidence),
          const SizedBox(height: 12),
          _verificationRow("Secondary Review", "${lexicon?['medical'] ?? friendlyName} (${lexicon?['simple'] ?? ''})", _sec!['score']),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _T.bg, borderRadius: BorderRadius.circular(12)),
            child: Text(
              friendlyDesc,
              style: TextStyle(color: _T.textSub, fontSize: 11, fontWeight: FontWeight.w600, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            theyAgree 
                ? "Both AI models found the same pattern. This increases our confidence in the identification."
                : "Different features were detected by our secondary model. We have provided a balanced result.",
            style: TextStyle(color: _T.textMuted, fontSize: 10.5, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _verificationRow(String specialist, String label, double score) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: _T.bg, shape: BoxShape.circle),
          child: Center(child: Text(specialist[0], style: const TextStyle(color: _T.cyan, fontSize: 12, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(specialist, style: const TextStyle(color: _T.textSub, fontSize: 10, fontWeight: FontWeight.w800)),
              Text(label, style: const TextStyle(color: _T.textHeader, fontSize: 12, fontWeight: FontWeight.w900, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        Text("${score.toStringAsFixed(1)}%", style: const TextStyle(color: _T.cyan, fontWeight: FontWeight.w900, fontSize: 13)),
      ],
    );
  }

  Widget _buildSpecialistAdviceCard() {
    final Map<String, String>? lexicon = _specialistLexicon[_sec!['label'].toString().toLowerCase()];
    if (lexicon == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_T.blue, _T.blue.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: _T.blue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "SPECIALIST ADVICE: ${lexicon['medical']!.toUpperCase()} (${lexicon['simple']!.toUpperCase()})",
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            lexicon['advice']!,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.6, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.white70, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "This is specialized advice based on the Secondary Review. Priority: High.",
                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _isEmergency ? _T.critical.withOpacity(0.1) : _T.safe.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _isEmergency ? _T.critical.withOpacity(0.3) : _T.safe.withOpacity(0.3)),
      ),
      child: Text(
        _isEmergency ? "HIGH RISK" : "OBSERVATION",
        style: TextStyle(color: _isEmergency ? _T.critical : _T.safe, fontSize: 9, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildInfectionWatchCard() {
    final info = _woundInfo;
    final Color watchColor = info['watchColor'] as Color;
    final Color watchBg = info['watchBg'] as Color;
    final List flags = info['flags'] as List;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: watchBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: watchColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: watchColor, size: 18),
              const SizedBox(width: 10),
              Text(info['watchTitle'], style: TextStyle(color: watchColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          ...flags.map<Widget>((f) => _buildInfectionTile(f[0], f[1], watchColor)).toList(),
        ],
      ),
    );
  }

  Widget _buildInfectionTile(String title, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin: const EdgeInsets.only(top: 5), width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                Text(desc, style: TextStyle(color: color.withOpacity(0.75), fontSize: 11, fontWeight: FontWeight.w500, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorPrescribedProtocol() {
    final steps = (_woundInfo['steps'] as List).cast<List>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _T.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_rounded, color: _T.purple, size: 20),
              const SizedBox(width: 12),
              const Text("CLINICAL PROTOCOL", style: TextStyle(color: _T.textHeader, fontSize: 14, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 6),
          Text("Tailored for: ${_prediction}", style: const TextStyle(color: _T.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((e) => _protocolStep("${e.key + 1}", e.value[0], e.value[1], e.value[2])).toList(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => WoundTreatmentScreen(prediction: _prediction, message: _message)));
              },
              icon: const Icon(Icons.medical_services_rounded, size: 18),
              label: const Text("VIEW FULL CARE PLAN", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _T.purple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _protocolStep(String num, String emoji, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: _T.cyan.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: _T.textHeader, fontSize: 13, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: _T.textSub, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _T.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_user_rounded, color: _T.cyan, size: 28),
          const SizedBox(height: 12),
          const Text(
            "AI-GENERATED PATHOLOGY REPORT",
            style: TextStyle(color: _T.textHeader, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          const Text(
            "This report is generated by a clinical-grade ensemble model. For definitive medical diagnosis, please present this data to a certified healthcare professional.",
            textAlign: TextAlign.center,
            style: TextStyle(color: _T.textMuted, fontSize: 10, height: 1.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/appointment'),
            icon: const Icon(Icons.local_hospital_rounded, size: 18),
            label: const Text("VISIT DOCTOR"),
            style: OutlinedButton.styleFrom(
              foregroundColor: _T.purple,
              side: const BorderSide(color: _T.purple),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

