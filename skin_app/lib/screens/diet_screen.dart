import 'package:flutter/material.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({Key? key}) : super(key: key);

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> with TickerProviderStateMixin {
  static const Color navy = Color(0xFF1B263B);
  static const Color teal = Color(0xFF2A9D8F);
  static const Color orange = Color(0xFFE76F51);
  static const Color purple = Color(0xFF7C5CBF);
  static const Color blue = Color(0xFF3A86FF);
  static const Color bg = Color(0xFFF8FAFB);

  String _activeGoal = 'All';
  late TabController _tabController;

  static const List<String> _goals = ['All', 'Clear Skin', 'Weight Loss', 'Energy', 'Immunity', 'Recovery'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _mealPlans = [
    {
      'goal': 'Clear Skin',
      'title': 'Clear Skin Diet',
      'subtitle': 'Anti-inflammatory foods for radiant skin',
      'color': teal,
      'icon': Icons.face_retouching_natural_rounded,
      'gradient': [Color(0xFF2A9D8F), Color(0xFF1A7A6E)],
      'meals': [
        {'time': 'Breakfast', 'icon': Icons.wb_sunny_outlined, 'foods': ['Oat porridge with berries', 'Green tea (no sugar)', 'Walnuts (10 pcs)']},
        {'time': 'Lunch', 'icon': Icons.lunch_dining_outlined, 'foods': ['Grilled salmon with leafy greens', 'Avocado toast (whole grain)', 'Cucumber water']},
        {'time': 'Dinner', 'icon': Icons.nightlight_outlined, 'foods': ['Sweet potato bowl with quinoa', 'Spinach & tomato salad', 'Turmeric milk']},
        {'time': 'Snacks', 'icon': Icons.apple_outlined, 'foods': ['Dark chocolate (70%+)', 'Brazil nuts (3 pcs)', 'Blueberries']},
      ],
      'nutrients': ['Omega-3', 'Zinc', 'Vit C', 'Antioxidants'],
      'tip': 'Avoid dairy and high-glycemic foods — they are the #1 trigger for adult acne.',
    },
    {
      'goal': 'Weight Loss',
      'title': 'Lean Body Plan',
      'subtitle': 'High protein, lower carb, calorie deficit',
      'color': orange,
      'icon': Icons.trending_down_rounded,
      'gradient': [Color(0xFFE76F51), Color(0xFFD4472A)],
      'meals': [
        {'time': 'Breakfast', 'icon': Icons.wb_sunny_outlined, 'foods': ['3 egg whites + 1 whole egg omelette', 'Spinach & mushroom', 'Black coffee']},
        {'time': 'Lunch', 'icon': Icons.lunch_dining_outlined, 'foods': ['Grilled chicken breast (200g)', 'Steamed broccoli & beans', 'Brown rice (½ cup)']},
        {'time': 'Dinner', 'icon': Icons.nightlight_outlined, 'foods': ['Lentil soup with veggies', 'Plain Greek yogurt', 'Herbal tea']},
        {'time': 'Snacks', 'icon': Icons.apple_outlined, 'foods': ['Apple with almond butter', 'Boiled egg', 'Protein shake (if needed)']},
      ],
      'nutrients': ['Protein', 'Fiber', 'Iron', 'B12'],
      'tip': 'The 16:8 intermittent fasting window can boost fat burning without muscle loss.',
    },
    {
      'goal': 'Energy',
      'title': 'All-Day Energy Plan',
      'subtitle': 'Complex carbs and iron-rich foods',
      'color': const Color(0xFFFFB700),
      'icon': Icons.bolt_rounded,
      'gradient': [Color(0xFFFFB700), Color(0xFFE09500)],
      'meals': [
        {'time': 'Breakfast', 'icon': Icons.wb_sunny_outlined, 'foods': ['Overnight oats with banana', 'Peanut butter (1 tbsp)', 'Orange juice (fresh)']},
        {'time': 'Lunch', 'icon': Icons.lunch_dining_outlined, 'foods': ['Whole wheat pasta with lean meat', 'Kidney beans salad', 'Pomegranate juice']},
        {'time': 'Dinner', 'icon': Icons.nightlight_outlined, 'foods': ['Chicken & vegetable stir-fry', 'Basmati rice', 'Warm water with lemon']},
        {'time': 'Snacks', 'icon': Icons.apple_outlined, 'foods': ['Dates (3-4 pcs)', 'Mixed nuts', 'Banana smoothie']},
      ],
      'nutrients': ['Iron', 'Magnesium', 'B Vitamins', 'Carbs'],
      'tip': 'Complex carbs release energy slowly — never skip breakfast to maintain stable blood sugar.',
    },
    {
      'goal': 'Immunity',
      'title': 'Immunity Shield',
      'subtitle': 'Vitamin-rich foods to fight infections',
      'color': purple,
      'icon': Icons.shield_rounded,
      'gradient': [Color(0xFF7C5CBF), Color(0xFF5E3E9E)],
      'meals': [
        {'time': 'Breakfast', 'icon': Icons.wb_sunny_outlined, 'foods': ['Citrus fruit bowl (orange, grapefruit)', 'Warm ginger-lemon tea', 'Whole grain toast']},
        {'time': 'Lunch', 'icon': Icons.lunch_dining_outlined, 'foods': ['Garlic-ginger chicken soup', 'Broccoli & bell pepper stir-fry', 'Probiotic yogurt']},
        {'time': 'Dinner', 'icon': Icons.nightlight_outlined, 'foods': ['Turmeric lentil curry', 'Brown rice', 'Warm golden milk']},
        {'time': 'Snacks', 'icon': Icons.apple_outlined, 'foods': ['Kiwi fruit', 'Sunflower seeds', 'Elderberry supplement (optional)']},
      ],
      'nutrients': ['Vit C', 'Vit D', 'Zinc', 'Probiotics'],
      'tip': 'Garlic contains allicin — a potent antimicrobial compound that activates immune cells.',
    },
    {
      'goal': 'Recovery',
      'title': 'Muscle Recovery Plan',
      'subtitle': 'Post-workout nutrition for muscle repair',
      'color': blue,
      'icon': Icons.fitness_center_rounded,
      'gradient': [Color(0xFF3A86FF), Color(0xFF2563EB)],
      'meals': [
        {'time': 'Pre-Workout', 'icon': Icons.flash_on_rounded, 'foods': ['Banana + peanut butter', 'Black coffee', 'Oats with honey']},
        {'time': 'Post-Workout', 'icon': Icons.lunch_dining_outlined, 'foods': ['Whey protein + banana shake', 'Grilled chicken + sweet potato', 'Chocolate milk (quick recovery)']},
        {'time': 'Dinner', 'icon': Icons.nightlight_outlined, 'foods': ['Salmon fillet + asparagus', 'Quinoa', 'Cherry juice (anti-inflammatory)']},
        {'time': 'Before Bed', 'icon': Icons.nightlight_round_rounded, 'foods': ['Cottage cheese (casein protein)', 'Almonds', 'Chamomile tea']},
      ],
      'nutrients': ['Protein', 'Creatine', 'Leucine', 'Glutamine'],
      'tip': 'Consume 30-40g of protein within 45 mins post-workout for maximum muscle protein synthesis.',
    },
  ];

  final List<Map<String, dynamic>> _avoidFoods = [
    {'food': 'Processed Sugar', 'reason': 'Triggers glycation, damaging collagen and causing wrinkles & acne.', 'icon': Icons.cookie_outlined, 'color': Colors.red},
    {'food': 'Trans Fats (Fried)', 'reason': 'Causes systemic inflammation affecting skin, joints, and arteries.', 'icon': Icons.no_food_rounded, 'color': orange},
    {'food': 'Excess Dairy', 'reason': 'Contains IGF-1 which stimulates sebum overproduction in skin.', 'icon': Icons.no_drinks_rounded, 'color': purple},
    {'food': 'Alcohol', 'reason': 'Dehydrates skin, depletes zinc & B vitamins, worsening skin conditions.', 'icon': Icons.local_bar_outlined, 'color': const Color(0xFFE63946)},
    {'food': 'High-Glycemic Carbs', 'reason': 'White bread, pasta spike insulin — direct trigger for hormonal acne.', 'icon': Icons.breakfast_dining_rounded, 'color': const Color(0xFFFFB700)},
    {'food': 'Excessive Salt', 'reason': 'Causes water retention, puffiness and worsens eczema symptoms.', 'icon': Icons.grain_rounded, 'color': Colors.blueGrey},
  ];

  final List<Map<String, dynamic>> _superfoods = [
    {'name': 'Salmon', 'benefit': 'Rich in omega-3 EPA/DHA — reduces inflammation & skin redness', 'icon': '🐟', 'color': orange},
    {'name': 'Avocado', 'benefit': 'Healthy fats + Vit E — deep hydration and UV protection booster', 'icon': '🥑', 'color': teal},
    {'name': 'Blueberries', 'benefit': 'Highest antioxidant content — fights free radicals that age skin', 'icon': '🫐', 'color': purple},
    {'name': 'Turmeric', 'benefit': 'Curcumin blocks NF-kB — powerful anti-inflammatory for wounds', 'icon': '🌿', 'color': const Color(0xFFFFB700)},
    {'name': 'Green Tea', 'benefit': 'EGCG reduces sebum + has UV-protective and antibacterial effects', 'icon': '🍵', 'color': teal},
    {'name': 'Walnuts', 'benefit': 'Only nut with omega-3 ALA + zinc — supports wound healing', 'icon': '🫘', 'color': Colors.brown},
    {'name': 'Sweet Potato', 'benefit': 'Beta-carotene converts to Vit A — repairs skin cells naturally', 'icon': '🍠', 'color': orange},
    {'name': 'Broccoli', 'benefit': 'Sulforaphane triggers skin antioxidant defenses against UV damage', 'icon': '🥦', 'color': teal},
  ];

  List<Map<String, dynamic>> get _filteredPlans {
    if (_activeGoal == 'All') return _mealPlans;
    return _mealPlans.where((p) => p['goal'] == _activeGoal).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nutrition & Diets', style: TextStyle(color: navy, fontWeight: FontWeight.w900, fontSize: 20)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: navy,
          unselectedLabelColor: Colors.grey,
          indicatorColor: teal,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Meal Plans'),
            Tab(text: 'Superfoods'),
            Tab(text: 'Avoid'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const ClampingScrollPhysics(),
        children: [
          _buildMealPlansTab(),
          _buildSuperfoodsTab(),
          _buildAvoidTab(),
        ],
      ),
    );
  }

  Widget _buildMealPlansTab() {
    return Column(
      children: [
        // Goal filter pills
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 14),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _goals.map((g) {
                final active = g == _activeGoal;
                return GestureDetector(
                  onTap: () => setState(() => _activeGoal = g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? navy : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? navy : Colors.grey.shade300),
                    ),
                    child: Text(g, style: TextStyle(
                      color: active ? Colors.white : Colors.grey[600],
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    )),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: _filteredPlans.length,
            itemBuilder: (_, i) => _buildMealCard(_filteredPlans[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(Map<String, dynamic> plan) {
    final color = plan['color'] as Color;
    final List<String> nutrients = List<String>.from(plan['nutrients']);
    final List<Map<String, dynamic>> meals = List<Map<String, dynamic>>.from(plan['meals']);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: List<Color>.from(plan['gradient']), begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                  child: Icon(plan['icon'] as IconData, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                      Text(plan['subtitle'], style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nutrient pills
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: nutrients.map((n) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Text(n, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                  )).toList(),
                ),

                const SizedBox(height: 16),

                // Meals
                ...meals.map((meal) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(meal['icon'] as IconData, color: color, size: 18),
                          const SizedBox(width: 8),
                          Text(meal['time'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...(meal['foods'] as List<String>).map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 4),
                        child: Row(
                          children: [
                            Container(width: 5, height: 5, decoration: BoxDecoration(color: color.withOpacity(0.5), shape: BoxShape.circle)),
                            const SizedBox(width: 10),
                            Text(f, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                          ],
                        ),
                      )),
                    ],
                  ),
                )),

                // Pro Tip
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.15)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, color: color, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(plan['tip'], style: TextStyle(fontSize: 12.5, color: Colors.grey[700], height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuperfoodsTab() {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Hero banner
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF2A9D8F), Color(0xFF1A7A6E)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🌟 Skin Superfoods', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
              SizedBox(height: 6),
              Text('Science-backed foods shown to significantly improve skin health, wound healing, and melanoma prevention.',
                  style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4)),
            ],
          ),
        ),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.82,
          ),
          itemCount: _superfoods.length,
          itemBuilder: (_, i) {
            final sf = _superfoods[i];
            final color = sf['color'] as Color;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sf['icon'], style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  Text(sf['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: navy)),
                  const SizedBox(height: 6),
                  Text(sf['benefit'], style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4)),
                  const Spacer(),
                  Container(
                    height: 3,
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAvoidTab() {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFE76F51), Color(0xFFD4472A)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('⚠️ Foods to Avoid', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
              SizedBox(height: 6),
              Text('These foods are clinically linked to inflammation, skin degradation, and impaired wound healing.',
                  style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4)),
            ],
          ),
        ),

        ..._avoidFoods.map((item) {
          final color = item['color'] as Color;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.15)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: Icon(item['icon'] as IconData, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(item['food'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: navy)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Text('AVOID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(item['reason'], style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: teal.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: teal.withOpacity(0.2)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('💡 Golden Rule', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: navy)),
              SizedBox(height: 8),
              Text(
                'The 80/20 principle: eat whole, nutrient-dense foods 80% of the time and allow yourself flexibility 20% of the time. Consistency matters more than perfection.',
                style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
