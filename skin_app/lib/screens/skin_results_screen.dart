import 'package:flutter/material.dart';
import 'dart:io';
import '../services/api_service.dart';

// ─────────────────────────────────────────────
//  PREMIUM EARTH & WOOD THEME TOKENS
// ─────────────────────────────────────────────
class _ResRef {
  static const deepWood  = Color(0xFF2D2A1E);
  static const oak       = Color(0xFF504B38);
  static const clay      = Color(0xFF8E806A);
  static const sand      = Color(0xFFF8F3D9);
  static const gold      = Color(0xFFC6A664);
  static const bgStart   = Color(0xFFFDFCF7);
  static const bgEnd     = Color(0xFFF5F1E1);
  
  // Status Colors
  static const clear     = Color(0xFF769F8B);
  static const warning   = Color(0xFFD4A373);
  static const serious   = Color(0xFFB06F6F);
}

class SkinResultsScreen extends StatefulWidget {
  final Map<String, dynamic> results;
  final File? image;

  const SkinResultsScreen({super.key, required this.results, this.image});

  @override
  State<SkinResultsScreen> createState() => _SkinResultsScreenState();
}

class _SkinResultsScreenState extends State<SkinResultsScreen> with TickerProviderStateMixin {
  late final String _mainTitle;
  late final double _mainConfidence;
  late final String? _overlayUrl;
  late final List<dynamic> _otherFindings;
  late final List<dynamic> _recommendations;
  late final Color _accent;

  @override
  void initState() {
    super.initState();
    
    // Determine the "Winner" (Highest confidence pathology)
    final acneStatus = widget.results['acne_status'] ?? widget.results['prediction'] ?? 'Clear Skin (Healthy)';
    final acneConf = (widget.results['acne_confidence'] ?? widget.results['confidence'] ?? 0.0).toDouble();
    final conditions = List<dynamic>.from(widget.results['other_conditions'] ?? []);
    
    // Find if any "Other Condition" is stronger than Acne
    dynamic winner;
    double maxConf = acneConf;
    String winnerLabel = acneStatus;

    for (var c in conditions) {
      double cConf = (c['confidence'] ?? 0.0).toDouble();
      if (cConf > maxConf) {
        maxConf = cConf;
        winner = c;
        winnerLabel = _simplify(c['label'].toString());
      }
    }

    _mainTitle = winnerLabel;
    _mainConfidence = maxConf;
    _overlayUrl = widget.results['processed_url'] != null ? _buildFullUrl(widget.results['processed_url']) : null;
    _recommendations = widget.results['recommendations'] ?? [];

    // Filter "Others" to NOT include the winner
    _otherFindings = [];
    if (winner == null) {
      // Acne was the winner, show other things
      _otherFindings.addAll(conditions);
    } else {
      // Something else won, show Acne and other things (if they meet threshold)
      _otherFindings.add({'label': acneStatus, 'confidence': acneConf, 'key': 'acne'});
      for (var c in conditions) {
        if (c != winner) _otherFindings.add(c);
      }
    }
    
    // Sort others by confidence
    _otherFindings.sort((a, b) => (b['confidence'] ?? 0.0).compareTo(a['confidence'] ?? 0.0));
    // ONLY show things > 20% in the secondary list as requested ("when depicted then only say that")
    _otherFindings.removeWhere((c) => (c['confidence'] ?? 0.0) < 20);

    // Color logic
    String lowerT = _mainTitle.toUpperCase();
    if (lowerT.contains('SEVERE') || lowerT.contains('CARCINOMA') || lowerT.contains('INVALID') || lowerT.contains('UNCLEAR')) {
      _accent = _ResRef.serious;
    } else if (lowerT.contains('MODERATE') || lowerT.contains('ECCZEMA') || lowerT.contains('MILIA')) {
      _accent = _ResRef.warning;
    } else {
      _accent = _ResRef.clear;
    }
  }

  String _buildFullUrl(String? path) {
    if (path == null) return '';
    if (path.startsWith('http')) return path;
    return ApiService.useTunnel
        ? "${ApiService.tunnelUrl}$path"
        : "http://${ApiService.serverIp}:8000$path";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [_ResRef.bgStart, _ResRef.bgEnd],
          ),
        ),
        child: Column(
          children: [
            _buildHeroPortal(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _buildVerificationHeader(),
                    const SizedBox(height: 12),
                    _buildPrimaryDiagnostic(),
                    if (_otherFindings.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _sectionLabel("SUPPORTING PATHOLOGY DEPICITON"),
                      const SizedBox(height: 16),
                      ..._otherFindings.map((c) => _ConditionCard(c: c)),
                    ],
                    const SizedBox(height: 24),
                    _sectionLabel("NEURAL RECOMMENDATIONS"),
                    const SizedBox(height: 16),
                    ..._recommendations.map((r) => _RecommendationCard(r: r)),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroPortal() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _ResRef.deepWood,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
        image: DecorationImage(
          image: _overlayUrl != null ? NetworkImage(_overlayUrl!) : (widget.image != null ? FileImage(widget.image!) : const AssetImage('assets/placeholder.png')) as ImageProvider,
          fit: BoxFit.cover,
          opacity: 0.85,
        ),
        boxShadow: [BoxShadow(color: _ResRef.deepWood.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.4), Colors.transparent, _ResRef.deepWood.withOpacity(0.6)],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
            ),
          ),
          Positioned(
            top: 50, left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
          Positioned(
            bottom: 30, left: 24, right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _accent.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                  child: const Text("DIAGNOSTIC LOG ACTIVE", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
                const SizedBox(height: 10),
                Text(_mainTitle.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("NEURAL VERIFICATION LOG", style: TextStyle(color: _ResRef.clay, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(width: 8),
        Container(width: 40, height: 1, color: _ResRef.gold.withOpacity(0.3)),
      ],
    );
  }

  Widget _buildPrimaryDiagnostic() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("INTEGRITY SCORE", style: TextStyle(color: _ResRef.clay, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  SizedBox(height: 4),
                  Text("BIOMETRIC ACCURACY", style: TextStyle(color: _ResRef.deepWood, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              Text("${_mainConfidence.toStringAsFixed(1)}%", style: const TextStyle(color: _ResRef.gold, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: _mainConfidence / 100, backgroundColor: _ResRef.sand, color: _ResRef.gold, minHeight: 6, borderRadius: BorderRadius.circular(10)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Align(alignment: Alignment.centerLeft, child: Text(label, style: const TextStyle(color: _ResRef.clay, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)));

  Widget _buildActionButtons() {
    return Column(
      children: [
        _primaryAct("CONSULT SPECIALIST", Icons.medical_services_rounded, _ResRef.deepWood, Colors.white, () => Navigator.pushNamed(context, '/appointment')),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _secondaryAct("AI CHAT", Icons.forum_rounded, () => Navigator.pushNamed(context, '/chatbot'))),
          ],
        ),
      ],
    );
  }

  Widget _primaryAct(String l, IconData i, Color bg, Color tc, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: bg.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(i, color: tc, size: 20), const SizedBox(width: 12), Text(l, style: TextStyle(color: tc, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5))],
        ),
      ),
    );
  }

  Widget _secondaryAct(String l, IconData i, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _ResRef.deepWood.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(i, color: _ResRef.deepWood, size: 18), const SizedBox(width: 8), Text(l, style: const TextStyle(color: _ResRef.deepWood, fontWeight: FontWeight.w900, fontSize: 10))],
        ),
      ),
    );
  }
}

class _ConditionCard extends StatelessWidget {
  final dynamic c;
  const _ConditionCard({required this.c});
  @override
  Widget build(BuildContext context) {
    final key = (c['key'] ?? '').toString().toLowerCase();
    final label = _simplify(c['label'].toString()).toUpperCase();
    
    IconData icon = Icons.emergency_rounded;
    Color color = _ResRef.clay;

    if (label.contains('CARCINOMA') || key.contains('carcinoma')) {
      icon = Icons.warning_rounded;
      color = _ResRef.serious;
    } else if (label.contains('MILIA') || key.contains('milia')) {
      icon = Icons.grain_rounded;
      color = _ResRef.gold;
    } else if (label.contains('ECCZEMA') || key.contains('eczema')) {
      icon = Icons.water_drop_rounded;
      color = Color(0xFF8E806A);
    } else if (label.contains('ROSACEA') || key.contains('rosacea')) {
      icon = Icons.face_retouching_natural_rounded;
      color = Color(0xFFB06F6F);
    } else if (label.contains('ACNE') || key.contains('acne')) {
      icon = Icons.spa_rounded;
      color = _ResRef.clear;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(color: _ResRef.deepWood, fontWeight: FontWeight.w900, fontSize: 12))),
          Text("${(c['confidence'] ?? 0.0).toStringAsFixed(1)}%", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatefulWidget {
  final dynamic r;
  const _RecommendationCard({required this.r});

  @override
  State<_RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<_RecommendationCard> {
  bool _isExpanded = true; // Default to true so users see medical advice immediately

  @override
  Widget build(BuildContext context) {
    final type = (widget.r['type'] ?? '').toString();
    final iconName = (widget.r['icon'] ?? '').toString();
    
    Color bgColor = Colors.white;
    Color accentColor = _ResRef.clay;
    IconData icon = Icons.info_outline_rounded;
    
    if (type == 'urgent') {
      bgColor = const Color(0xFFFFF5F5);
      accentColor = _ResRef.serious;
    } else if (type == 'treatment') {
      bgColor = const Color(0xFFF4F9F6);
      accentColor = _ResRef.clear;
    } else if (type == 'prevention') {
      bgColor = const Color(0xFFFEF9F3);
      accentColor = _ResRef.warning;
    } else if (type == 'health') {
      bgColor = const Color(0xFFFDFBF7);
      accentColor = _ResRef.oak;
    }
    
    if (iconName == 'warning') icon = Icons.warning_rounded;
    else if (iconName == 'medical') icon = Icons.medical_services_rounded;
    else if (iconName == 'sunny') icon = Icons.wb_sunny_rounded;
    else if (iconName == 'fire') icon = Icons.local_fire_department_rounded;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor, 
          borderRadius: BorderRadius.circular(32), 
          border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            if (_isExpanded)
              BoxShadow(
                color: accentColor.withOpacity(0.15), 
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.toUpperCase(),
                        style: TextStyle(color: accentColor.withOpacity(0.8), fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1.2)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.r['title'].toString().toUpperCase(), 
                        style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)
                      ),
                    ],
                  )
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: accentColor,
                    size: 20,
                  ),
                )
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.format_quote_rounded, color: accentColor.withOpacity(0.3), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.r['description'], 
                            style: const TextStyle(color: _ResRef.deepWood, fontSize: 14, height: 1.6, fontWeight: FontWeight.w600)
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        ),
      ),
    );
  }
}

String _simplify(String l) {
  if (l.contains('Carcinoma')) return "Carcinoma (Skin Cancer)";
  if (l.contains('Milia')) return "Milia (White Bumps)";
  if (l.contains('Eczema')) return "Eczema (Rash/Itch)";
  if (l.contains('Rosacea')) return "Rosacea (Redness)";
  if (l.contains('Keratosis')) return "Keratosis (Scaly Skin)";
  if (l.contains('Acne')) return "Acne (Breakouts)";
  if (l.contains('Clear')) return "Clear Skin (Healthy)";
  return l;
}

