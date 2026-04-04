import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class VitalityScreen extends StatefulWidget {
  const VitalityScreen({Key? key}) : super(key: key);

  @override
  State<VitalityScreen> createState() => _VitalityScreenState();
}

class _VitalityScreenState extends State<VitalityScreen>
    with TickerProviderStateMixin {
  static const Color navy = Color(0xFF1B263B);
  static const Color teal = Color(0xFF2A9D8F);
  static const Color orange = Color(0xFFE76F51);
  static const Color purple = Color(0xFF7C5CBF);
  static const Color blue = Color(0xFF3A86FF);
  static const Color bg = Color(0xFFF8FAFB);

  double _sleep = 7.0;
  double _water = 2.0;
  int _stress = 5;

  bool _isSaving = false;
  String? _userId;

  late AnimationController _ringController;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _ringAnim = CurvedAnimation(parent: _ringController, curve: Curves.easeOutCubic);
    _ringController.forward();
    _loadUser();
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userId = prefs.getString('userId'));
  }

  double get _score {
    final s = (_sleep / 8.0).clamp(0.0, 1.0) * 33.3;
    final w = (_water / 3.0).clamp(0.0, 1.0) * 33.3;
    final st = ((11 - _stress) / 10.0).clamp(0.0, 1.0) * 33.4;
    return s + w + st;
  }

  Color get _scoreColor {
    final sc = _score;
    if (sc >= 85) return teal;
    if (sc >= 65) return blue;
    if (sc >= 45) return purple;
    return orange;
  }

  String get _scoreLabel {
    final sc = _score;
    if (sc >= 85) return 'Excellent';
    if (sc >= 65) return 'Good';
    if (sc >= 45) return 'Moderate';
    return 'Needs Work';
  }

  Future<void> _save() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in first.')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ApiService.analyzeVitality({
        'userId': _userId,
        'height': 170.0,
        'weight': 70.0,
        'sleepHours': _sleep,
        'waterIntake': _water,
        'stressLevel': _stress,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: teal,
          content: const Text('Vitality stats saved!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save. Check connection.')));
    }
    if (mounted) setState(() => _isSaving = false);
  }

  Widget _metricStepper({
    required String label,
    required String value,
    required String unit,
    required String target,
    required IconData icon,
    required Color color,
    required VoidCallback onInc,
    required VoidCallback onDec,
    required double progress,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(text: value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
                        TextSpan(text: '  $unit', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      ]),
                    ),
                    Text('Target: $target', style: TextStyle(fontSize: 11, color: color.withOpacity(0.7), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Column(
                children: [
                  _stepBtn(Icons.add_rounded, color, onInc),
                  const SizedBox(height: 6),
                  _stepBtn(Icons.remove_rounded, color, onDec),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sc = _score;
    final sColor = _scoreColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Vitality Tracker', style: TextStyle(color: navy, fontWeight: FontWeight.w900, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score Ring
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [sColor.withOpacity(0.1), sColor.withOpacity(0.03)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: sColor.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  const Text('VITALITY SCORE', style: TextStyle(fontSize: 12, letterSpacing: 1.5, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _ringAnim,
                    builder: (_, __) => Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: CircularProgressIndicator(
                            value: (sc / 100) * _ringAnim.value,
                            strokeWidth: 14,
                            backgroundColor: sColor.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation(sColor),
                          ),
                        ),
                        Column(
                          children: [
                            Text('${sc.toInt()}%', style: TextStyle(fontSize: 46, fontWeight: FontWeight.w900, color: sColor)),
                            Text(_scoreLabel, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: sColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildScoreMessage(),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Metric Steppers
            _metricStepper(
              label: 'Sleep',
              value: _sleep.toStringAsFixed(1),
              unit: 'hours',
              target: '8h/day',
              icon: Icons.bedtime_rounded,
              color: purple,
              progress: (_sleep / 8.0).clamp(0.0, 1.0),
              onInc: () => setState(() => _sleep = math.min(_sleep + 0.5, 14)),
              onDec: () => setState(() => _sleep = math.max(_sleep - 0.5, 0)),
            ),

            _metricStepper(
              label: 'Water Intake',
              value: _water.toStringAsFixed(1),
              unit: 'liters',
              target: '3L/day',
              icon: Icons.water_drop_rounded,
              color: blue,
              progress: (_water / 3.0).clamp(0.0, 1.0),
              onInc: () => setState(() => _water = math.min(_water + 0.25, 6)),
              onDec: () => setState(() => _water = math.max(_water - 0.25, 0)),
            ),

            _metricStepper(
              label: 'Stress Level',
              value: '$_stress',
              unit: '/ 10',
              target: 'Below 4',
              icon: Icons.self_improvement_rounded,
              color: orange,
              progress: ((11 - _stress) / 10.0).clamp(0.0, 1.0),
              onInc: () => setState(() => _stress = math.min(_stress + 1, 10)),
              onDec: () => setState(() => _stress = math.max(_stress - 1, 1)),
            ),

            const SizedBox(height: 8),

            // Tips Section
            _buildTipsSection(),

            const SizedBox(height: 24),

            // Breakdown
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Score Breakdown', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: navy)),
                  const SizedBox(height: 16),
                  _bar('Sleep Efficiency', (_sleep / 8.0).clamp(0.0, 1.0), purple),
                  const SizedBox(height: 12),
                  _bar('Hydration Level', (_water / 3.0).clamp(0.0, 1.0), blue),
                  const SizedBox(height: 12),
                  _bar('Stress Management', ((11 - _stress) / 10.0).clamp(0.0, 1.0), orange),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            GestureDetector(
              onTap: _isSaving ? null : _save,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF7C5CBF), Color(0xFF3A86FF)]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: purple.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Center(
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text('SAVE VITALITY STATS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreMessage() {
    final sc = _score;
    IconData icon;
    String msg;
    Color color;

    if (sc >= 85) {
      icon = Icons.auto_awesome_rounded;
      msg = 'Outstanding! Your habits are giving your skin a radiant, healthy glow.';
      color = teal;
    } else if (sc >= 65) {
      icon = Icons.thumb_up_alt_rounded;
      msg = 'Great! Tweak one area (try drinking more water) to push past 85%.';
      color = blue;
    } else if (sc >= 45) {
      icon = Icons.nights_stay_rounded;
      msg = 'Moderate. Your skin may look tired. Prioritize 7-8h of quality sleep tonight.';
      color = purple;
    } else {
      icon = Icons.warning_amber_rounded;
      msg = 'Action needed! High stress + low hydration are major triggers for skin issues.';
      color = orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(msg, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    final tips = [
      if (_sleep < 7) {'icon': Icons.bedtime_outlined, 'color': purple, 'tip': 'Try the 4-7-8 breathing technique before bed for faster sleep onset.'},
      if (_water < 2) {'icon': Icons.water_drop_outlined, 'color': blue, 'tip': 'Keep a water bottle visible at your desk — visual cues increase intake by 30%.'},
      if (_stress > 6) {'icon': Icons.spa_outlined, 'color': orange, 'tip': 'A 10-minute mindfulness session can lower cortisol by up to 20%.'},
      if (_sleep >= 7) {'icon': Icons.star_rounded, 'color': teal, 'tip': 'Great sleep! Consistent sleep times improve skin repair cycle efficiency.'},
      if (_water >= 2.5) {'icon': Icons.water_drop_rounded, 'color': blue, 'tip': 'Well hydrated! This supports collagen production and skin elasticity.'},
    ];

    if (tips.isEmpty) return const SizedBox();

    return Column(
      children: tips.take(3).map((t) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: (t['color'] as Color).withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (t['color'] as Color).withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(t['icon'] as IconData, color: t['color'] as Color, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(t['tip'] as String, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4))),
          ],
        ),
      )).toList(),
    );
  }

  Widget _bar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
            Text('${(value * 100).toInt()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
