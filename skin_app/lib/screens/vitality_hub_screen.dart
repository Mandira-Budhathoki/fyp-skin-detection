import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bmi_screen.dart';
import 'vitality_screen.dart';
import 'diet_screen.dart';
import 'articles_screen.dart';
import 'journal_screen.dart';
import 'quiz_screen.dart';
import '../services/api_service.dart';

class VitalityHubScreen extends StatefulWidget {
  const VitalityHubScreen({Key? key}) : super(key: key);

  @override
  State<VitalityHubScreen> createState() => _VitalityHubScreenState();
}

class _VitalityHubScreenState extends State<VitalityHubScreen>
    with TickerProviderStateMixin {
  // ── Colour palette ─────────────────────────────
  static const Color navy   = Color(0xFF1B263B);
  static const Color teal   = Color(0xFF2A9D8F);
  static const Color orange = Color(0xFFE76F51);
  static const Color purple = Color(0xFF7C5CBF);
  static const Color blue   = Color(0xFF3A86FF);
  static const Color gold   = Color(0xFFFFB700);
  static const Color bg     = Color(0xFFF8FAFB);

  String _userName = 'User';
  String? _userId;
  Map<String, dynamic>? _lastVitality;
  bool _loadingStats = true;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _loadData();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName') ?? 'User';
    final uid  = prefs.getString('userId');
    setState(() { _userName = name.split(' ').first; _userId = uid; });

    if (uid != null) {
      try {
        final result = await ApiService.analyzeVitality({
          'userId': uid,
          'height': 170.0,
          'weight': 70.0,
          'sleepHours': 7.0,
          'waterIntake': 2.0,
          'sunExposure': 2.0,
        });
        if (mounted) setState(() => _lastVitality = result);
      } catch (_) {}
    }
    if (mounted) setState(() => _loadingStats = false);
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    if (h < 21) return 'Good Evening';
    return 'Good Night';
  }

  Future<void> _push(Widget screen) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => screen,
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  // ── Feature definitions ────────────────────────
  List<Map<String, dynamic>> get _features => [
    {
      'title': 'BMI Calculator',
      'subtitle': 'Track weight, height & get health advice',
      'icon': Icons.monitor_weight_outlined,
      'gradient': [const Color(0xFF8E6EE0), const Color(0xFF6B48C8)],
      'color': purple,
      'tag': 'BMI & Stats',
      'screen': const BmiScreen(),
      'badge': null,
    },
    {
      'title': 'Step & Water Tracker',
      'subtitle': 'Track your live steps and daily water',
      'icon': Icons.directions_walk_rounded,
      'gradient': [const Color(0xFF9AB17A), const Color(0xFF1F6F5F)],
      'color': const Color(0xFF1F6F5F),
      'tag': 'Live Score',
      'screen': const VitalityScreen(),
      'badge': null,
    },
    {
      'title': 'Nutrition & Diets',
      'subtitle': 'Meal plans, superfoods & avoidance lists',
      'icon': Icons.restaurant_menu_rounded,
      'gradient': [const Color(0xFF38B2AC), const Color(0xFF1E706A)],
      'color': teal,
      'tag': '5 Diet Plans',
      'screen': const DietScreen(),
      'badge': null,
    },
    {
      'title': 'Health Articles',
      'subtitle': 'Live PubMed research on skin & melanoma',
      'icon': Icons.auto_stories_rounded,
      'gradient': [const Color(0xFFFFC107), const Color(0xFFE08E00)],
      'color': gold,
      'tag': 'Real Papers',
      'screen': const ArticlesScreen(),
      'badge': 'LIVE',
    },
    {
      'title': 'Health Journal',
      'subtitle': 'Reflect, track moods & maintain streaks',
      'icon': Icons.auto_stories_rounded,
      'gradient': [const Color(0xFF53629E), const Color(0xFF473472)],
      'color': const Color(0xFF473472),
      'tag': 'Personal',
      'screen': const JournalScreen(),
      'badge': null,
    },
    {
      'title': 'Knowledge Quiz',
      'subtitle': 'Test yourself on skin & wound health',
      'icon': Icons.quiz_rounded,
      'gradient': [const Color(0xFF2D3B55), const Color(0xFF0F172A)],
      'color': navy,
      'tag': 'High Score',
      'screen': const QuizScreen(),
      'badge': 'NEW',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final safeTop    = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // ── Static Interactive Header (Does not shrink) ──
            _buildHeroHeader(safeTop, context),

            // ── Scrollable Content below the static header ──
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // ── Section header ──
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                      child: Center(
                        child: Text(
                          'Interactive Health Tools',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: navy, letterSpacing: 0.5),
                        ),
                      ),
                    ),

                    // ── Feature grid (3 items per row) ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, 
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.9, // Shorter/smaller buttons
                        ),
                        itemCount: _features.length,
                        itemBuilder: (_, i) => _buildFeatureCard(_features[i], i),
                      ),
                    ),

                    // ── Tips banner ──
                    _buildTipsBanner(),

                    // ── Quick stats row (Benchmarks) ──
                    _buildQuickStats(),

                    SizedBox(height: safeBottom + 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  STATIC HEADER WITH INTERACTIVE CARD
  // ──────────────────────────────────────────────
  Widget _buildHeroHeader(double safeTop, BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/cubes.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, safeTop + 10, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Minimal AppBar Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    const Text('Holistic Health Hub', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                    const SizedBox(width: 40), // Balances the row
                  ],
                ),
                const SizedBox(height: 16),
                
                // Interactive Welcome Card
                Material(
                  color: const Color(0xFFFAFDD6),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFAED6C1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.maps_ugc_rounded, color: navy, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$_greeting, $_userName!', style: TextStyle(fontSize: 12, color: navy.withOpacity(0.7), fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    const Text('Your Wellness Tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: navy, letterSpacing: -0.5)),
                                  ],
                                ),
                              ),
                              Icon(Icons.touch_app_rounded, color: navy.withOpacity(0.3), size: 20),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Explore your wellness journey! Use these 6 interactive tools to measure your BMI, track daily vitality, test your knowledge, and read medical insights.',
                            style: TextStyle(fontSize: 12, color: navy.withOpacity(0.8), height: 1.5, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  FEATURE BUTTONS (Real tactile button feel, 3-column)
  // ──────────────────────────────────────────────
  Widget _buildFeatureCard(Map<String, dynamic> f, int index) {
    final Color color = f['color'] as Color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // The real button part
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              elevation: 4,
              shadowColor: color.withOpacity(0.2),
              child: InkWell(
                onTap: () => _push(f['screen'] as Widget),
                borderRadius: BorderRadius.circular(22),
                splashColor: color.withOpacity(0.1),
                highlightColor: color.withOpacity(0.05),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: color.withOpacity(0.15), width: 1.5),
                  ),
                  child: Center(
                    child: Icon(f['icon'] as IconData, color: color, size: 36),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // The label below
        Text(
          f['title'],
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: navy, height: 1.2),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  //  TIPS BANNER
  // ──────────────────────────────────────────────
  Widget _buildTipsBanner() {
    final tips = [
      {'icon': Icons.water_drop_outlined, 'tip': 'Drink a glass of water right now — hydration directly improves skin elasticity.'},
      {'icon': Icons.wb_sunny_outlined, 'tip': 'Apply SPF 30+ every morning, even on cloudy days — UV causes 80% of skin aging.'},
      {'icon': Icons.restaurant_menu_rounded, 'tip': 'Add avocado or salmon to today\'s meal for omega-3s that reduce skin inflammation.'},
      {'icon': Icons.bedtime_outlined, 'tip': 'Aim for 7-9 hours tonight — sleep is when your skin repairs at the cellular level.'},
      {'icon': Icons.self_improvement_rounded, 'tip': 'A 10-minute mindfulness session can lower cortisol (skin stress hormone) by 20%.'},
    ];
    final tip = tips[DateTime.now().minute % tips.length];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [teal.withOpacity(0.12), blue.withOpacity(0.08)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: teal.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(tip['icon'] as IconData, size: 32, color: teal),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Wellness Tip', style: TextStyle(fontWeight: FontWeight.w900, color: teal, fontSize: 13, letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  Text(tip['tip'] as String, style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.4, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  QUICK STATS / HEALTH BENCHMARKS 
  // ──────────────────────────────────────────────
  Widget _buildQuickStats() {
    final stats = [
      {'label': 'BMI Range', 'value': '18.5 – 24.9', 'sub': 'Healthy target', 'color': teal, 'icon': Icons.fitness_center_rounded},
      {'label': 'Daily Water', 'value': '2 – 3 Liters', 'sub': 'Recommended', 'color': blue, 'icon': Icons.local_drink_rounded},
      {'label': 'Sleep Goal', 'value': '7 – 9 Hours', 'sub': 'Per night', 'color': purple, 'icon': Icons.nights_stay_rounded},
      {'label': 'SPF Daily', 'value': 'SPF 30+', 'sub': 'Broad spectrum', 'color': gold, 'icon': Icons.shield_outlined},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 20, decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 10),
              const Text('Health Benchmarks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: navy)),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.0,
            ),
            itemCount: stats.length,
            itemBuilder: (_, i) {
              final s = stats[i];
              final c = s['color'] as Color;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: Icon(s['icon'] as IconData, color: c, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(s['value'] as String, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: c)),
                          Text(s['label'] as String, style: const TextStyle(fontSize: 10, color: navy, fontWeight: FontWeight.w700)),
                          Text(s['sub'] as String, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
