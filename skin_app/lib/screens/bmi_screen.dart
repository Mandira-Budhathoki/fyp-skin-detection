import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({Key? key}) : super(key: key);

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> with TickerProviderStateMixin {
  // Color tokens
  static const Color navy = Color(0xFF1B263B);
  static const Color teal = Color(0xFF2A9D8F);
  static const Color orange = Color(0xFFE76F51);
  static const Color purple = Color(0xFF6D597A);
  static const Color bg = Color(0xFFF8FAFB);

  // Units
  bool _useCm = true; // false = feet/inches

  // Metric
  double _heightCm = 170.0;
  double _weightKg = 70.0;

  // Imperial
  int _feet = 5;
  int _inches = 7;
  double _weightLbs = 154.0;

  bool _isSaving = false;
  String? _userId;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _loadUser();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userId = prefs.getString('userId'));
  }

  double get _bmi {
    double hM;
    double wKg;
    if (_useCm) {
      hM = _heightCm / 100.0;
      wKg = _weightKg;
    } else {
      final totalInches = (_feet * 12) + _inches;
      hM = totalInches * 0.0254;
      wKg = _weightLbs * 0.453592;
    }
    if (hM <= 0) return 0;
    return wKg / (hM * hM);
  }

  String get _status {
    final b = _bmi;
    if (b <= 0) return 'Enter Values';
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal';
    if (b < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color get _statusColor {
    final b = _bmi;
    if (b <= 0) return Colors.grey;
    if (b < 18.5) return const Color(0xFFFFB347);
    if (b < 25.0) return teal;
    if (b < 30.0) return orange;
    return Colors.red;
  }

  double get _gaugePercent {
    final b = _bmi.clamp(10.0, 40.0);
    return ((b - 10) / 30.0).clamp(0.0, 1.0);
  }

  List<Map<String, dynamic>> get _personalizedAdvice {
    final b = _bmi;
    if (b <= 0) {
      return [
        {'icon': Icons.info_outline, 'text': 'Enter your height and weight to get personalized advice.', 'color': Colors.grey}
      ];
    }
    if (b < 18.5) {
      return [
        {'icon': Icons.restaurant_outlined, 'title': 'Eat More Calories', 'text': 'Focus on calorie-dense, nutritious foods like nuts, avocado, whole grains, and dairy.', 'color': const Color(0xFFFFB347)},
        {'icon': Icons.fitness_center, 'title': 'Strength Training', 'text': 'Build muscle mass with resistance exercises 3-4x per week.', 'color': purple},
        {'icon': Icons.local_drink_outlined, 'title': 'Protein Intake', 'text': 'Aim for 1.6-2.2g of protein per kg body weight daily.', 'color': teal},
        {'icon': Icons.medical_services_outlined, 'title': 'Consult a Doctor', 'text': 'If BMI is consistently low, rule out underlying medical conditions.', 'color': orange},
        {'icon': Icons.bedtime_outlined, 'title': 'Rest & Recovery', 'text': 'Adequate sleep (7-9 hrs) supports weight gain and muscle repair.', 'color': navy},
      ];
    }
    if (b < 25.0) {
      return [
        {'icon': Icons.check_circle_outline, 'title': 'Great Weight!', 'text': 'Your BMI is in the healthy range. Keep maintaining this balance.', 'color': teal},
        {'icon': Icons.directions_run, 'title': 'Stay Active', 'text': 'Aim for 150 min of moderate exercise each week to maintain weight.', 'color': purple},
        {'icon': Icons.eco_outlined, 'title': 'Balanced Diet', 'text': 'Continue eating whole foods: vegetables, lean proteins, and complex carbs.', 'color': teal},
        {'icon': Icons.water_drop_outlined, 'title': 'Hydration', 'text': 'Drink 2-3 liters of water daily for optimal skin and body function.', 'color': Colors.blue},
        {'icon': Icons.spa_outlined, 'title': 'Stress Management', 'text': 'Keep stress low with meditation or yoga to maintain hormonal balance.', 'color': orange},
      ];
    }
    if (b < 30.0) {
      return [
        {'icon': Icons.trending_down, 'title': 'Moderate Reduction', 'text': 'Aim for a 500 calorie daily deficit for safe 0.5kg/week weight loss.', 'color': orange},
        {'icon': Icons.restaurant_menu, 'title': 'Diet Changes', 'text': 'Reduce processed foods, sugar, and trans fats. Add more fiber-rich vegetables.', 'color': orange},
        {'icon': Icons.directions_walk, 'title': 'Increase Activity', 'text': 'Start with 30-minute daily walks, then gradually add cardio.', 'color': purple},
        {'icon': Icons.nightlight_round, 'title': 'Sleep Patterns', 'text': 'Poor sleep elevates cortisol (weight-gain hormone). Prioritize 7-8 hrs sleep.', 'color': navy},
        {'icon': Icons.monitor_heart_outlined, 'title': 'Health Checks', 'text': 'Monitor blood pressure and cholesterol with regular checkups.', 'color': Colors.red},
      ];
    }
    return [
      {'icon': Icons.warning_amber_rounded, 'title': 'Seek Medical Guidance', 'text': 'A BMI over 30 increases risk for diabetes, heart disease, and joint issues.', 'color': Colors.red},
      {'icon': Icons.local_hospital_outlined, 'title': 'Consult a Nutritionist', 'text': 'Get a personalized meal plan from a registered dietitian.', 'color': orange},
      {'icon': Icons.pool_outlined, 'title': 'Low-Impact Exercise', 'text': 'Swimming or cycling reduces joint strain while burning calories effectively.', 'color': teal},
      {'icon': Icons.psychology_outlined, 'title': 'Behavioral Support', 'text': 'Consider a therapist or support group for emotional eating patterns.', 'color': purple},
      {'icon': Icons.science_outlined, 'title': 'Medical Options', 'text': 'Ask your doctor about medically supervised weight loss if lifestyle changes are insufficient.', 'color': Colors.red},
    ];
  }

  Widget _stepper({
    required String label,
    required String value,
    required String unit,
    required VoidCallback onInc,
    required VoidCallback onDec,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
                      TextSpan(text: ' $unit', style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: onInc,
                child: Container(
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.keyboard_arrow_up_rounded, color: color, size: 22),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onDec,
                child: Container(
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in first.')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final heightCm = _useCm ? _heightCm : ((_feet * 12 + _inches) * 2.54);
      final weightKg = _useCm ? _weightKg : (_weightLbs * 0.453592);
      await ApiService.analyzeVitality({
        'userId': _userId,
        'height': heightCm,
        'weight': weightKg,
        'sleepHours': 7,
        'waterIntake': 2,
        'stressLevel': 5,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: teal,
          content: const Text('BMI & health stats saved!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save. Check connection.')));
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final bmi = _bmi;
    final color = _statusColor;
    final advice = _personalizedAdvice;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('BMI Calculator', style: TextStyle(color: navy, fontWeight: FontWeight.w900, fontSize: 20)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() {
                _useCm = !_useCm;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: navy.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_useCm ? 'cm / kg' : 'ft / lbs',
                    style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── BMI Gauge Card ──
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text('YOUR BMI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: CircularProgressIndicator(
                            value: _gaugePercent,
                            strokeWidth: 14,
                            backgroundColor: color.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              bmi > 0 ? bmi.toStringAsFixed(1) : '--',
                              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: color),
                            ),
                            Text(_status, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // BMI scale bar
                  _buildBmiScale(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Unit Toggle ──
            _buildUnitToggle(),
            const SizedBox(height: 20),

            // ── Inputs ──
            if (_useCm) ...[
              _stepper(
                label: 'Height',
                value: _heightCm.toStringAsFixed(0),
                unit: 'cm',
                icon: Icons.height_rounded,
                color: purple,
                onInc: () => setState(() => _heightCm = math.min(_heightCm + 1, 250)),
                onDec: () => setState(() => _heightCm = math.max(_heightCm - 1, 50)),
              ),
              const SizedBox(height: 14),
              _stepper(
                label: 'Weight',
                value: _weightKg.toStringAsFixed(1),
                unit: 'kg',
                icon: Icons.monitor_weight_outlined,
                color: teal,
                onInc: () => setState(() => _weightKg = math.min(_weightKg + 0.5, 300)),
                onDec: () => setState(() => _weightKg = math.max(_weightKg - 0.5, 20)),
              ),
            ] else ...[
              _stepper(
                label: 'Feet',
                value: '$_feet',
                unit: 'ft',
                icon: Icons.straighten_rounded,
                color: purple,
                onInc: () => setState(() => _feet = math.min(_feet + 1, 8)),
                onDec: () => setState(() => _feet = math.max(_feet - 1, 3)),
              ),
              const SizedBox(height: 10),
              _stepper(
                label: 'Inches',
                value: '$_inches',
                unit: 'in',
                icon: Icons.height_rounded,
                color: purple,
                onInc: () => setState(() => _inches = math.min(_inches + 1, 11)),
                onDec: () => setState(() => _inches = math.max(_inches - 1, 0)),
              ),
              const SizedBox(height: 14),
              _stepper(
                label: 'Weight',
                value: _weightLbs.toStringAsFixed(1),
                unit: 'lbs',
                icon: Icons.monitor_weight_outlined,
                color: teal,
                onInc: () => setState(() => _weightLbs = math.min(_weightLbs + 1, 660)),
                onDec: () => setState(() => _weightLbs = math.max(_weightLbs - 1, 44)),
              ),
            ],

            const SizedBox(height: 28),

            // ── Personalized Advice ──
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.lightbulb_outline_rounded, color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text('Personalized Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: navy)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...advice.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item['title'] != null)
                                Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: navy)),
                              if (item['title'] != null) const SizedBox(height: 2),
                              Text(item['text'] as String, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Ideal Weight Card ──
            if (bmi > 0) _buildIdealWeightCard(),

            const SizedBox(height: 28),

            // ── Save Button ──
            GestureDetector(
              onTap: _isSaving ? null : _save,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Center(
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.save_outlined, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text('SAVE HEALTH STATS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
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

  Widget _buildBmiScale() {
    final ranges = [
      {'label': 'Under', 'color': const Color(0xFFFFB347), 'max': 18.5},
      {'label': 'Normal', 'color': teal, 'max': 25.0},
      {'label': 'Over', 'color': orange, 'max': 30.0},
      {'label': 'Obese', 'color': Colors.red, 'max': 40.0},
    ];
    return Row(
      children: ranges.map((r) {
        final isActive = _status == r['label'] as String ||
            (_status == 'Underweight' && r['label'] == 'Under') ||
            (_status == 'Overweight' && r['label'] == 'Over');
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isActive ? 8 : 6,
                  decoration: BoxDecoration(
                    color: isActive ? r['color'] as Color : (r['color'] as Color).withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(r['label'] as String,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? r['color'] as Color : Colors.grey)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUnitToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(child: _toggleBtn('Metric (cm / kg)', _useCm, () => setState(() => _useCm = true))),
          Expanded(child: _toggleBtn('Imperial (ft / lbs)', !_useCm, () => setState(() => _useCm = false))),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? navy : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  color: active ? Colors.white : Colors.grey,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildIdealWeightCard() {
    double idealMin, idealMax;
    String unit;
    if (_useCm) {
      final hM = _heightCm / 100;
      idealMin = 18.5 * hM * hM;
      idealMax = 24.9 * hM * hM;
      unit = 'kg';
    } else {
      final totalInches = (_feet * 12 + _inches).toDouble();
      final hM = totalInches * 0.0254;
      final minKg = 18.5 * hM * hM;
      final maxKg = 24.9 * hM * hM;
      idealMin = minKg / 0.453592;
      idealMax = maxKg / 0.453592;
      unit = 'lbs';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: teal.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: teal.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: teal.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.balance_outlined, color: teal, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ideal Weight Range', style: TextStyle(fontWeight: FontWeight.bold, color: navy, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  '${idealMin.toStringAsFixed(1)} – ${idealMax.toStringAsFixed(1)} $unit',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: teal),
                ),
                Text('For your height & healthy BMI (18.5–24.9)',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
