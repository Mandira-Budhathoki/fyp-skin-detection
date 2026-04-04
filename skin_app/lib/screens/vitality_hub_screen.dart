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
          'stressLevel': 5,
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
      'subtitle': 'Track weight, height & get personalized advice',
      'icon': Icons.monitor_weight_outlined,
      'gradient': [const Color(0xFF7C5CBF), const Color(0xFF5E3E9E)],
      'color': purple,
      'tag': 'cm & ft/in',
      'screen': const BmiScreen(),
      'badge': null,
    },
    {
      'title': 'Vitality Tracker',
      'subtitle': 'Sleep, hydration & stress habit scoring',
      'icon': Icons.bolt_rounded,
      'gradient': [const Color(0xFF3A86FF), const Color(0xFF1D6CE0)],
      'color': blue,
      'tag': 'Live Score',
      'screen': const VitalityScreen(),
      'badge': null,
    },
    {
      'title': 'Nutrition & Diets',
      'subtitle': 'Meal plans, superfoods & foods to avoid',
      'icon': Icons.restaurant_menu_rounded,
      'gradient': [const Color(0xFF2A9D8F), const Color(0xFF1A7A6E)],
      'color': teal,
      'tag': '5 Diet Plans',
      'screen': const DietScreen(),
      'badge': null,
    },
    {
      'title': 'Health Articles',
      'subtitle': 'Live PubMed research on skin, wounds & melanoma',
      'icon': Icons.auto_stories_rounded,
      'gradient': [const Color(0xFFFFB700), const Color(0xFFE09500)],
      'color': gold,
      'tag': 'Real Papers',
      'screen': const ArticlesScreen(),
      'badge': 'LIVE',
    },
    {
      'title': 'Health Journal',
      'subtitle': 'Daily entries, moods, to-do list & calendar',
      'icon': Icons.edit_note_rounded,
      'gradient': [const Color(0xFFE76F51), const Color(0xFFD4472A)],
      'color': orange,
      'tag': 'CRUD + Calendar',
      'screen': const JournalScreen(),
      'badge': null,
    },
    {
      'title': 'Knowledge Quiz',
      'subtitle': 'Test yourself on skin, wounds & melanoma',
      'icon': Icons.quiz_rounded,
      'gradient': [const Color(0xFF1B263B), const Color(0xFF2D3B55)],
      'color': navy,
      'tag': '50 Questions',
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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Hero SliverAppBar ──
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              backgroundColor: navy,
              leading: Padding(
                padding: EdgeInsets.only(top: safeTop > 0 ? 0 : 0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeroHeader(safeTop),
                collapseMode: CollapseMode.parallax,
              ),
              title: const Text('Holistic Health Hub',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            ),

            // ── Vitality snapshot strip ──
            SliverToBoxAdapter(child: _buildSnapshotStrip()),

            // ── Section header ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Container(width: 4, height: 20, decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(width: 10),
                    const Text('Your Wellness Tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: navy)),
                  ],
                ),
              ),
            ),

            // ── Feature grid ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildFeatureCard(_features[i], i),
                  childCount: _features.length,
                ),
              ),
            ),

            // ── Tips banner ──
            SliverToBoxAdapter(child: _buildTipsBanner()),

            // ── Quick stats row ──
            SliverToBoxAdapter(child: _buildQuickStats()),

            SliverToBoxAdapter(child: SizedBox(height: safeBottom + 24)),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  HERO HEADER
  // ──────────────────────────────────────────────
  Widget _buildHeroHeader(double safeTop) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B263B), Color(0xFF2D4263)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(top: -40, right: -40, child: _decCircle(180, Colors.white, 0.03)),
          Positioned(bottom: -20, left: -30, child: _decCircle(140, teal, 0.08)),
          Positioned(top: 40, right: 30, child: _decCircle(60, purple, 0.15)),

          Padding(
            padding: EdgeInsets.fromLTRB(20, safeTop + 60, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('$_greeting, $_userName 👋',
                    style: const TextStyle(fontSize: 13, color: Colors.white60, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                const Text('Holistic Health Hub',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                const SizedBox(height: 6),
                const Text('Track, learn, and improve your total wellness in one place.',
                    style: TextStyle(fontSize: 13, color: Colors.white54, height: 1.4)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _heroPill(Icons.hub_rounded, '6 Tools'),
                    const SizedBox(width: 10),
                    _heroPill(Icons.article_outlined, 'Live Articles'),
                    const SizedBox(width: 10),
                    _heroPill(Icons.quiz_rounded, '50 Q&A'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _decCircle(double size, Color color, double opacity) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color.withOpacity(opacity), shape: BoxShape.circle),
    );
  }

  Widget _heroPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white70),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  SNAPSHOT STRIP
  // ──────────────────────────────────────────────
  Widget _buildSnapshotStrip() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _snapItem(Icons.monitor_weight_outlined, 'BMI', '--', Colors.grey, () => _push(const BmiScreen()))),
          _snapDivider(),
          Expanded(child: _snapItem(Icons.bolt_rounded, 'Vitality', '--', blue, () => _push(const VitalityScreen()))),
          _snapDivider(),
          Expanded(child: _snapItem(Icons.edit_note_rounded, 'Entries', '--', orange, () => _push(const JournalScreen()))),
          _snapDivider(),
          Expanded(child: _snapItem(Icons.quiz_rounded, 'Quiz', 'Start', navy, () => _push(const QuizScreen()))),
        ],
      ),
    );
  }

  Widget _snapItem(IconData icon, String label, String value, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _snapDivider() => Container(width: 1, height: 40, color: Colors.grey.shade100, margin: const EdgeInsets.symmetric(horizontal: 4));

  // ──────────────────────────────────────────────
  //  FEATURE CARD
  // ──────────────────────────────────────────────
  Widget _buildFeatureCard(Map<String, dynamic> f, int index) {
    final List<Color> grad = List<Color>.from(f['gradient']);
    final Color color      = f['color'] as Color;
    final String? badge    = f['badge'] as String?;

    return GestureDetector(
      onTap: () => _push(f['screen'] as Widget),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 6)),
          ],
        ),
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              right: -15,
              bottom: -15,
              child: Opacity(
                opacity: 0.06,
                child: Icon(f['icon'] as IconData, size: 100, color: color),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: grad, begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: grad.first.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Icon(f['icon'] as IconData, color: Colors.white, size: 24),
                  ),

                  const SizedBox(height: 12),

                  Text(f['title'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: navy, height: 1.2)),
                  const SizedBox(height: 4),
                  Text(f['subtitle'],
                      style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.3),
                      maxLines: 2, overflow: TextOverflow.ellipsis),

                  const Spacer(),

                  // Tag pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(f['tag'], style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // Badge (LIVE / NEW)
            if (badge != null)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: badge == 'LIVE' ? Colors.red : teal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  TIPS BANNER
  // ──────────────────────────────────────────────
  Widget _buildTipsBanner() {
    final tips = [
      {'icon': '💧', 'tip': 'Drink a glass of water right now — hydration directly improves skin elasticity.'},
      {'icon': '☀️', 'tip': 'Apply SPF 30+ every morning, even on cloudy days — UV causes 80% of skin aging.'},
      {'icon': '🥑', 'tip': 'Add avocado or salmon to today\'s meal for omega-3s that reduce skin inflammation.'},
      {'icon': '😴', 'tip': 'Aim for 7-9 hours tonight — sleep is when your skin repairs at the cellular level.'},
      {'icon': '🌿', 'tip': 'A 10-minute mindfulness session can lower cortisol (skin stress hormone) by 20%.'},
    ];
    final tip = tips[DateTime.now().minute % tips.length];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [teal.withOpacity(0.12), blue.withOpacity(0.08)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: teal.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Text(tip['icon']!, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Wellness Tip', style: TextStyle(fontWeight: FontWeight.bold, color: teal, fontSize: 12, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(tip['tip']!, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  QUICK STATS
  // ──────────────────────────────────────────────
  Widget _buildQuickStats() {
    final stats = [
      {'label': 'BMI Range', 'value': '18.5 – 24.9', 'sub': 'Healthy target', 'color': teal, 'icon': Icons.check_circle_outline_rounded},
      {'label': 'Daily Water', 'value': '2 – 3 Liters', 'sub': 'Recommended', 'color': blue, 'icon': Icons.water_drop_outlined},
      {'label': 'Sleep Goal', 'value': '7 – 9 Hours', 'sub': 'Per night', 'color': purple, 'icon': Icons.bedtime_outlined},
      {'label': 'SPF Daily', 'value': 'SPF 30+', 'sub': 'Broad spectrum', 'color': gold, 'icon': Icons.wb_sunny_outlined},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
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
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.9,
            ),
            itemCount: stats.length,
            itemBuilder: (_, i) {
              final s = stats[i];
              final c = s['color'] as Color;
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(s['icon'] as IconData, color: c, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(s['value'] as String, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: c)),
                          Text(s['label'] as String, style: const TextStyle(fontSize: 10, color: navy, fontWeight: FontWeight.w600)),
                          Text(s['sub'] as String, style: TextStyle(fontSize: 9, color: Colors.grey[400])),
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
