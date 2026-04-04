import 'package:flutter/material.dart';
import 'dart:math' as math;

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  static const Color navy   = Color(0xFF1B263B);
  static const Color teal   = Color(0xFF2A9D8F);
  static const Color orange = Color(0xFFE76F51);
  static const Color purple = Color(0xFF7C5CBF);
  static const Color blue   = Color(0xFF3A86FF);
  static const Color bg     = Color(0xFFF8FAFB);

  String? _selectedCategory;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _revealed = false;
  bool _quizDone = false;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;
  late AnimationController _scoreController;
  late Animation<double> _scoreAnim;

  static const Map<String, Map<String, dynamic>> _categories = {
    'Skin Care': {
      'icon': Icons.face_retouching_natural_rounded,
      'gradient': [Color(0xFF2A9D8F), Color(0xFF1A7A6E)],
      'color': Color(0xFF2A9D8F),
      'description': '10 questions on skincare routines, ingredients & science',
    },
    'Wound Care': {
      'icon': Icons.healing_rounded,
      'gradient': [Color(0xFFE76F51), Color(0xFFD4472A)],
      'color': Color(0xFFE76F51),
      'description': '10 questions on wound treatment, first aid & recovery',
    },
    'Melanoma': {
      'icon': Icons.biotech_rounded,
      'gradient': [Color(0xFF7C5CBF), Color(0xFF5E3E9E)],
      'color': Color(0xFF7C5CBF),
      'description': '10 questions on skin cancer detection & prevention',
    },
    'Nutrition': {
      'icon': Icons.restaurant_rounded,
      'gradient': [Color(0xFFFFB700), Color(0xFFE09500)],
      'color': Color(0xFFFFB700),
      'description': '10 questions on diet, nutrients & skin health',
    },
    'UV & Sun Safety': {
      'icon': Icons.wb_sunny_rounded,
      'gradient': [Color(0xFFFF6B6B), Color(0xFFE63946)],
      'color': Color(0xFFFF6B6B),
      'description': '10 questions on UV protection, SPF & sun safety',
    },
  };

  static const Map<String, List<Map<String, dynamic>>> _questions = {
    'Skin Care': [
      {'q': 'How often should you reapply sunscreen?', 'a': ['Every 30 min', 'Every 2 hours', 'Once at morning', 'Every 4 hours'], 'c': 1, 'exp': 'Sunscreen degrades with UV exposure and sweating. Reapply every 2 hours, or after swimming.'},
      {'q': 'What does SPF stand for in sunscreen?', 'a': ['Skin Protection Formula', 'Sun Protection Factor', 'Solar Power Filter', 'Sunburn Prevention Factor'], 'c': 1, 'exp': 'SPF = Sun Protection Factor. It measures how well sunscreen protects against UVB rays that cause sunburn.'},
      {'q': 'Which vitamin is a powerful antioxidant for skin?', 'a': ['Vitamin D', 'Vitamin K', 'Vitamin C', 'Vitamin B12'], 'c': 2, 'exp': 'Vitamin C is a potent antioxidant that neutralizes free radicals, boosts collagen synthesis, and brightens skin.'},
      {'q': 'When is the BEST time to apply moisturizer?', 'a': ['On dry skin', 'On damp skin', 'Before washing', 'Before sunscreen only'], 'c': 1, 'exp': 'Damp skin absorbs moisture much better. Apply within 60 seconds of washing your face to lock in hydration.'},
      {'q': 'What skin type is most prone to acne?', 'a': ['Dry skin', 'Combination skin', 'Oily skin', 'Sensitive skin'], 'c': 2, 'exp': 'Oily skin produces excess sebum that can clog pores, creating an environment where acne bacteria thrive.'},
      {'q': 'Hyaluronic acid primarily provides what benefit?', 'a': ['Sun protection', 'Exfoliation', 'Deep hydration', 'Reduces pores'], 'c': 2, 'exp': 'Hyaluronic acid holds up to 1000x its weight in water, making it the gold standard hydrating ingredient.'},
      {'q': 'True or False: SPF 50 gives twice the protection of SPF 25?', 'a': ['True', 'False — the difference is small', 'True for UVA only', 'False — SPF 25 is better'], 'c': 1, 'exp': 'SPF 50 blocks ~98% vs SPF 25 blocking ~96% UVB. The difference is minimal — consistency matters more than SPF number.'},
      {'q': 'Which habit is BEST for reducing skin pores?', 'a': ['Hot steam daily', 'Regular cleansing & retinol', 'Ice cubes every morning', 'Squeezing blackheads'], 'c': 1, 'exp': 'Retinoids (retinol) are clinically proven to reduce pore appearance by increasing cell turnover and collagen.'},
      {'q': 'What does a retinoid (Retinol) primarily do?', 'a': ['Hydrates deeply', 'Speeds skin cell renewal', 'Kills acne bacteria', 'Adds SPF protection'], 'c': 1, 'exp': 'Retinoids accelerate skin cell turnover, reducing wrinkles, acne and hyperpigmentation — the gold standard in anti-aging.'},
      {'q': 'High sugar intake affects skin by...', 'a': ['Improving glow', 'Causing glycation (collagen damage)', 'Reducing oiliness', 'Boosting hydration'], 'c': 1, 'exp': 'Sugar triggers glycation — glucose bonds with collagen proteins, making them stiff and causing wrinkles and dullness.'},
    ],
    'Wound Care': [
      {'q': 'The FIRST step when treating a minor cut is?', 'a': ['Apply antibiotic cream', 'Wash with clean water & soap', 'Cover with bandage', 'Apply alcohol directly'], 'c': 1, 'exp': 'Always clean the wound first to remove bacteria and debris. Bandaging a dirty wound traps bacteria inside.'},
      {'q': 'Should you pick or remove a scab?', 'a': ['Yes, to speed healing', 'No — scabs protect healing tissue', 'Only if it is large', 'Only at night'], 'c': 1, 'exp': 'Scabs are natural biological bandages. Removing them disrupts new skin growth and significantly increases scarring.'},
      {'q': 'Which sign indicates a wound is infected?', 'a': ['Normal itching', 'Cold skin around wound', 'Pus, spreading redness & warmth', 'Dry scab formation'], 'c': 2, 'exp': 'Classic infection signs: pus, increasing redness, warmth, swelling, and worsening pain. See a doctor immediately.'},
      {'q': 'Best immediate treatment for a minor burn?', 'a': ['Apply butter or oil', 'Ice directly on burn', 'Cool running water for 10-20 min', 'Pop any blisters'], 'c': 2, 'exp': 'Cool (not cold) running water for 10-20 minutes is the evidence-based first aid for minor burns. Never use ice — it causes ice burn.'},
      {'q': 'How frequently should wound dressings be changed?', 'a': ['Every 5-7 days', 'Daily or when wet/dirty', 'Only when doctor says', 'Never — leave it'], 'c': 1, 'exp': 'Changing dressings daily or when damp prevents bacterial growth and allows wound inspection for infection signs.'},
      {'q': 'What is the purpose of a Tetanus shot after a wound?', 'a': ['Reduce scarring', 'Prevent viral fever', 'Prevent Tetanus bacteria in deep wounds', 'Speed up clotting'], 'c': 2, 'exp': 'Tetanus bacteria (Clostridium tetani) thrive in anaerobic deep/dirty wounds. Vaccination prevents life-threatening muscle spasms.'},
      {'q': 'What environment promotes fastest wound healing?', 'a': ['Open and completely dry', 'Moist and covered', 'Wet with antiseptic', 'Exposed to fresh air only'], 'c': 1, 'exp': 'Moist wound healing (via dressings) is proven to speed healing by 40-50% compared to keeping wounds dry.'},
      {'q': 'When should you seek medical attention for a wound?', 'a': ['If bleeding stops naturally', 'If wound is less than 1cm', 'If bleeding won\'t stop after 10 min', 'If it itches'], 'c': 2, 'exp': 'Wounds bleeding for more than 10 minutes despite direct pressure need professional medical evaluation — may need stitches.'},
      {'q': 'Which wound type carries the HIGHEST infection risk?', 'a': ['Surface abrasion (scrape)', 'Paper cut', 'Puncture wound', 'Clean surgical incision'], 'c': 2, 'exp': 'Puncture wounds create deep narrow channels that are hard to clean, trap bacteria in an oxygen-poor environment ideal for infection.'},
      {'q': 'Antibiotic ointment on wounds primarily...', 'a': ['Speeds clotting', 'Prevents bacterial infection & keeps moist', 'Fades scars', 'Reduces pain'], 'c': 1, 'exp': 'Antibiotic ointments (like Neosporin/Bacitracin) create a barrier against bacteria while maintaining optimal moist healing conditions.'},
    ],
    'Melanoma': [
      {'q': 'Melanoma originates from which skin cells?', 'a': ['Keratinocytes', 'Melanocytes', 'Fibroblasts', 'Lymphocytes'], 'c': 1, 'exp': 'Melanoma arises from melanocytes — the pigment-producing cells in skin. UV radiation damages their DNA, causing malignant transformation.'},
      {'q': 'What is the "ABCDE" rule used for?', 'a': ['Skin care routine', 'Identifying suspicious moles', 'Wound care steps', 'Moisturizer application'], 'c': 1, 'exp': 'ABCDE: Asymmetry, Border irregularity, Color variation, Diameter >6mm, Evolving. These are warning signs when examining moles.'},
      {'q': 'The biggest risk factor for melanoma is...', 'a': ['Poor diet', 'Low Vitamin C', 'Ultraviolet (UV) radiation exposure', 'High stress levels'], 'c': 2, 'exp': 'UV radiation from the sun and tanning beds is the #1 preventable cause of melanoma, causing DNA damage in melanocytes.'},
      {'q': 'Which letter in ABCDE refers to a mole growing over time?', 'a': ['A - Asymmetry', 'B - Border', 'C - Color', 'E - Evolving'], 'c': 3, 'exp': '"E" stands for Evolving — any mole that is changing in size, shape, color, or is bleeding should be immediately evaluated.'},
      {'q': 'Melanoma is most dangerous because it...', 'a': ['Causes extreme pain', 'Spreads (metastasizes) to other organs', 'Is always visible', 'Only affects older people'], 'c': 1, 'exp': 'Melanoma can metastasize through lymph nodes and blood to lungs, brain, liver and bone. Early detection is critical for survival.'},
      {'q': 'What SPF is recommended for melanoma prevention?', 'a': ['SPF 10+', 'SPF 15+', 'SPF 30+ broad-spectrum', 'Any SPF is fine'], 'c': 2, 'exp': 'Dermatologists recommend minimum SPF 30+ broad-spectrum (UVA+UVB) protection applied daily for melanoma prevention.'},
      {'q': 'Who is at HIGHEST risk for melanoma?', 'a': ['People with very dark skin', 'People with fair skin, light eyes, many moles', 'People who rarely go outdoors', 'Young children only'], 'c': 1, 'exp': 'Fair-skinned individuals with light eyes and many moles have less melanin protection and higher UV sensitivity — highest risk group.'},
      {'q': 'The most effective tool for early melanoma detection is?', 'a': ['X-ray', 'Regular self-skin exams + dermatologist check', 'Blood test', 'Biopsy only'], 'c': 1, 'exp': 'Monthly self-exams and annual dermatologist checks with dermoscopy enable detection at Stage 0-1 when 5-year survival rates exceed 98%.'},
      {'q': 'Melanoma can appear in which unexpected locations?', 'a': ['Only sun-exposed areas', 'Eyes, nail beds, and mucous membranes', 'Only on the back', 'Only on the face'], 'c': 1, 'exp': 'Subungual, ocular, and mucosal melanomas appear in areas not exposed to sun, making regular full-body exams critical.'},
      {'q': 'Tanning beds increase melanoma risk by approximately...', 'a': ['5%', '20% if used once', '75% with regular use', 'No significant increase'], 'c': 2, 'exp': 'The WHO classifies tanning beds as Group 1 carcinogens. Regular use increases melanoma risk by up to 75% — they are extremely dangerous.'},
    ],
    'Nutrition': [
      {'q': 'Which omega fatty acid is most beneficial for skin inflammation?', 'a': ['Omega-6', 'Omega-3 (EPA/DHA)', 'Omega-9', 'Trans fatty acids'], 'c': 1, 'exp': 'Omega-3 EPA/DHA from fatty fish reduces inflammatory cytokines that trigger eczema, psoriasis, and inflammatory acne.'},
      {'q': 'Vitamin A\'s main function in skin is...', 'a': ['Hydration', 'Cell renewal and repair', 'UV protection', 'Collagen destruction'], 'c': 1, 'exp': 'Vitamin A (retinol) is essential for keratinocyte differentiation and skin cell renewal — deficiency causes dry, rough skin.'},
      {'q': 'Which mineral is ESSENTIAL for wound healing?', 'a': ['Calcium', 'Iron only', 'Zinc', 'Potassium'], 'c': 2, 'exp': 'Zinc is required for over 300 enzymatic reactions including collagen synthesis, immune function, and skin cell repair.'},
      {'q': 'Collagen production requires which vitamin as a cofactor?', 'a': ['Vitamin D', 'Vitamin C', 'Vitamin E', 'Vitamin B6'], 'c': 1, 'exp': 'Vitamin C is an irreplaceable cofactor for prolyl hydroxylase — the enzyme that cross-links collagen fibrils for structural strength.'},
      {'q': 'Which food is highest in antioxidants for skin health?', 'a': ['White rice', 'Blueberries', 'White bread', 'Processed cheese'], 'c': 1, 'exp': 'Blueberries have one of the highest ORAC (antioxidant) scores — flavonoids protect skin cells from UV-induced oxidative damage.'},
      {'q': 'Excess sugar damages skin through which process?', 'a': ['Dehydration', 'Glycation — damages collagen', 'Direct cell death', 'Vitamin depletion'], 'c': 1, 'exp': 'Advanced Glycation End-products (AGEs) from excess sugar cross-link collagen and elastin, making them rigid and causing wrinkles.'},
      {'q': 'How much water should an average adult drink daily for skin health?', 'a': ['500ml - 1L', '1L - 1.5L', '2L - 3L', '5L+'], 'c': 2, 'exp': '2-3 liters of water daily maintains skin turgor, supports toxin removal through kidneys, and sustains the skin\'s moisture barrier.'},
      {'q': 'Probiotics benefit skin by...', 'a': ['Directly moisturizing skin', 'Reducing gut inflammation linked to skin conditions', 'Adding UV protection', 'Increasing sebum production'], 'c': 1, 'exp': 'The gut-skin axis means probiotic bacteria reduce systemic inflammation that manifests as eczema, rosacea, and acne.'},
      {'q': 'Which food triggers hormonal acne most commonly?', 'a': ['Avocado', 'High-GI foods and dairy', 'Salmon', 'Broccoli'], 'c': 1, 'exp': 'High-glycemic foods spike insulin and IGF-1, directly stimulating sebaceous glands. Dairy contains hormones that worsen hormonal acne.'},
      {'q': 'Beta-carotene (in carrots & sweet potato) converts in body to...', 'a': ['Vitamin C', 'Vitamin K', 'Vitamin A', 'Collagen'], 'c': 2, 'exp': 'Beta-carotene is a provitamin A that converts to retinol — essential for skin cell renewal and maintaining healthy epithelial tissue.'},
    ],
    'UV & Sun Safety': [
      {'q': 'UV radiation from the sun is divided into which types?', 'a': ['UVA and UVB only', 'UVA, UVB and UVC', 'UVX and UVY', 'Blue and Red UV'], 'c': 1, 'exp': 'UVA (aging), UVB (burning), UVC (absorbed by atmosphere). Both UVA and UVB reach Earth and require broad-spectrum protection.'},
      {'q': 'UVA rays primarily cause...', 'a': ['Sunburn', 'Skin aging and deep damage', 'Eye irritation only', 'Vitamin D production'], 'c': 1, 'exp': 'UVA penetrates deeper into the dermis, causing photoaging, wrinkles, and DNA damage leading to melanoma — present even through clouds and glass.'},
      {'q': 'What does "broad spectrum" sunscreen mean?', 'a': ['Higher SPF', 'Works in swimming', 'Protects against both UVA and UVB', 'Lasts 24 hours'], 'c': 2, 'exp': 'Broad spectrum means the formulation protects against BOTH UVA (aging rays) and UVB (burning rays) — always choose broad-spectrum.'},
      {'q': 'Peak UV hours when sun is most dangerous are...', 'a': ['6am - 9am', '10am - 4pm', '5pm - 8pm', 'Midnight - 3am'], 'c': 1, 'exp': 'UV index is highest between 10am-4pm when the sun is most overhead and rays travel the shortest atmospheric distance.'},
      {'q': 'Can you get sunburned on a cloudy day?', 'a': ['No — clouds block all UV', 'Yes — 80% of UV passes through clouds', 'Only in summer', 'Only with thin clouds'], 'c': 1, 'exp': 'Up to 80% of UV radiation penetrates cloud cover. Many serious sunburns happen on overcast days when people skip sunscreen.'},
      {'q': 'Minimum amount of sunscreen for full face coverage?', 'a': ['A few drops', 'Half a teaspoon (about 1/4 tsp per area)', 'Full tablespoon', '1 full palm'], 'c': 1, 'exp': 'Most people apply only 25-50% of the recommended amount. Use ¼ teaspoon for face/neck and 1 oz (shot glass) for body.'},
      {'q': 'Which SPF is considered the minimum for daily use by dermatologists?', 'a': ['SPF 8', 'SPF 15', 'SPF 30', 'SPF 100'], 'c': 2, 'exp': 'SPF 30 blocks 97% of UVB rays and is the minimum recommended by the American Academy of Dermatology for daily use.'},
      {'q': 'Chemical vs. physical sunscreen — which works immediately?', 'a': ['Chemical (works instantly)', 'Physical/mineral (works instantly)', 'Both take 30 minutes', 'Neither works immediately'], 'c': 1, 'exp': 'Physical/mineral sunscreens (zinc oxide, titanium dioxide) sit on top of skin and reflect UV immediately. Chemical sunscreens need 20-30 min to activate.'},
      {'q': 'UV radiation can penetrate through...', 'a': ['Nothing — only in full sun', 'Car windows and light clothing', 'Only glass walls', 'Nothing indoors'], 'c': 1, 'exp': 'UVA penetrates standard car windows. Up to 50% of UV can pass through lightweight fabrics. Wear UPF-rated clothing for extended outdoor exposure.'},
      {'q': 'The UV Index scale ranges from...', 'a': ['0-5', '0-11+', '1-20', '0-100'], 'c': 1, 'exp': 'UV Index 0-2 = Low, 3-5 = Moderate, 6-7 = High, 8-10 = Very High, 11+ = Extreme. Check daily before outdoor activities.'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _scoreController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scoreAnim = CurvedAnimation(parent: _scoreController, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _startQuiz(String category) {
    setState(() {
      _selectedCategory = category;
      _currentIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _revealed = false;
      _quizDone = false;
    });
    _slideController.forward(from: 0);
  }

  void _selectAnswer(int idx) {
    if (_revealed) return;
    setState(() {
      _selectedAnswer = idx;
      _revealed = true;
      final correct = _questions[_selectedCategory!]![_currentIndex]['c'] as int;
      if (idx == correct) _score++;
    });
  }

  void _nextQuestion() {
    final questions = _questions[_selectedCategory!]!;
    if (_currentIndex < questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _revealed = false;
      });
      _slideController.forward(from: 0);
    } else {
      setState(() => _quizDone = true);
      _scoreController.forward(from: 0);
    }
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
          onPressed: () {
            if (_selectedCategory != null) {
              setState(() { _selectedCategory = null; _quizDone = false; });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _quizDone ? 'Results' : _selectedCategory ?? 'Health Quiz',
          style: const TextStyle(color: navy, fontWeight: FontWeight.w900, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _selectedCategory == null
            ? _buildCategoryPicker()
            : _quizDone
                ? _buildResultScreen()
                : _buildQuizScreen(),
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  CATEGORY PICKER
  // ══════════════════════════════════════════════
  Widget _buildCategoryPicker() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1B263B), Color(0xFF2D3B55)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                Icon(Icons.quiz_rounded, color: Colors.white, size: 40),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Test Your Knowledge', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                      SizedBox(height: 4),
                      Text('5 categories · 10 questions each\nScience-backed answers with explanations',
                          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('Choose a Category', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: navy)),
          const SizedBox(height: 14),

          ..._categories.entries.map((entry) {
            final cat = entry.value;
            final List<Color> gradient = List<Color>.from(cat['gradient']);
            final color = cat['color'] as Color;
            final questions = _questions[entry.key]!;

            return GestureDetector(
              onTap: () => _startQuiz(entry.key),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(cat['icon'] as IconData, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: navy)),
                          const SizedBox(height: 4),
                          Text(cat['description'], style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.3)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _pill('${questions.length} Questions', color),
                              const SizedBox(width: 6),
                              _pill('With Explanations', teal),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }

  // ══════════════════════════════════════════════
  //  QUIZ SCREEN
  // ══════════════════════════════════════════════
  Widget _buildQuizScreen() {
    final questions = _questions[_selectedCategory!]!;
    final q = questions[_currentIndex];
    final answers = List<String>.from(q['a']);
    final correctIdx = q['c'] as int;
    final catData = _categories[_selectedCategory!]!;
    final catColor = catData['color'] as Color;
    final progress = (_currentIndex + 1) / questions.length;

    return Column(
      children: [
        // Progress header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: catColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(_selectedCategory!, style: TextStyle(color: catColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  Text('${_currentIndex + 1} / ${questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: navy, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text('Score: $_score', style: const TextStyle(color: teal, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: catColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(catColor),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: List<Color>.from(catData['gradient'])),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(catData['icon'] as IconData, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text('Question ${_currentIndex + 1}',
                                style: TextStyle(color: catColor, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(q['q'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy, height: 1.4)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Answer options
                  ...answers.asMap().entries.map((entry) {
                    final i = entry.key;
                    final ans = entry.value;
                    Color bgColor = Colors.white;
                    Color borderColor = Colors.grey.shade200;
                    Widget? trailingIcon;

                    if (_revealed) {
                      if (i == correctIdx) {
                        bgColor = const Color(0xFFE8F8F5);
                        borderColor = teal;
                        trailingIcon = Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: teal, shape: BoxShape.circle),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                        );
                      } else if (i == _selectedAnswer && i != correctIdx) {
                        bgColor = const Color(0xFFFFF0ED);
                        borderColor = orange;
                        trailingIcon = Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: orange, shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                        );
                      }
                    } else if (i == _selectedAnswer) {
                      bgColor = catColor.withOpacity(0.08);
                      borderColor = catColor;
                    }

                    return GestureDetector(
                      onTap: () => _selectAnswer(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: _revealed && (i == correctIdx || i == _selectedAnswer) ? 2 : 1),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: _revealed && i == correctIdx ? teal : borderColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + i),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _revealed && i == correctIdx ? Colors.white : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(ans, style: const TextStyle(fontSize: 14, color: navy, fontWeight: FontWeight.w500))),
                            if (trailingIcon != null) trailingIcon,
                          ],
                        ),
                      ),
                    );
                  }),

                  // Explanation
                  if (_revealed) ...[
                    const SizedBox(height: 16),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: navy.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: navy.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb_rounded, color: Color(0xFFFFB700), size: 20),
                              const SizedBox(width: 8),
                              const Text('Explanation', style: TextStyle(fontWeight: FontWeight.bold, color: navy, fontSize: 14)),
                              const Spacer(),
                              if (_selectedAnswer == correctIdx)
                                const Row(children: [
                                  Icon(Icons.star_rounded, color: Color(0xFFFFB700), size: 18),
                                  Text(' +1 point', style: TextStyle(color: Color(0xFFFFB700), fontWeight: FontWeight.bold, fontSize: 12)),
                                ]),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(q['exp'], style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: _nextQuestion,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: List<Color>.from(catData['gradient'])),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: catColor.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Center(
                          child: Text(
                            _currentIndex < questions.length - 1 ? 'NEXT QUESTION →' : 'SEE RESULTS →',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  //  RESULT SCREEN
  // ══════════════════════════════════════════════
  Widget _buildResultScreen() {
    final questions = _questions[_selectedCategory!]!;
    final pct = (_score / questions.length * 100).round();
    final catData = _categories[_selectedCategory!]!;
    final List<Color> gradient = List<Color>.from(catData['gradient']);
    final catColor = catData['color'] as Color;

    String grade, msg;
    IconData icon;
    if (pct >= 90) { grade = 'A+'; msg = 'Outstanding! You\'re a skin health expert! 🏆'; icon = Icons.emoji_events_rounded; }
    else if (pct >= 70) { grade = 'B'; msg = 'Great job! Review the explanations for perfect score. ⭐'; icon = Icons.thumb_up_rounded; }
    else if (pct >= 50) { grade = 'C'; msg = 'Not bad! Check the explanations to strengthen your knowledge. 📚'; icon = Icons.menu_book_rounded; }
    else { grade = 'D'; msg = 'Keep learning! Retake the quiz after reviewing the topics. 💪'; icon = Icons.refresh_rounded; }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Score card
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 52),
                const SizedBox(height: 14),
                ScaleTransition(
                  scale: _scoreAnim,
                  child: Text(grade, style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
                Text('$_score / ${questions.length} correct', style: const TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text('$pct% Score', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                  child: Text(msg, textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats breakdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statChip('Correct', '$_score', teal, Icons.check_circle_outline_rounded),
                    _statChip('Wrong', '${questions.length - _score}', orange, Icons.cancel_outlined),
                    _statChip('Accuracy', '$pct%', catColor, Icons.analytics_outlined),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Retake button
          GestureDetector(
            onTap: () => _startQuiz(_selectedCategory!),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: catColor.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('RETAKE QUIZ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Back to categories
          GestureDetector(
            onTap: () => setState(() { _selectedCategory = null; _quizDone = false; }),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: navy.withOpacity(0.15)),
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.grid_view_rounded, color: navy, size: 20),
                    SizedBox(width: 8),
                    Text('CHANGE CATEGORY', style: TextStyle(color: navy, fontWeight: FontWeight.w900, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
