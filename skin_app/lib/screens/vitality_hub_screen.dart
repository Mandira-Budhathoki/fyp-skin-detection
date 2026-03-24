import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dart:math' as math;

class VitalityHubScreen extends StatefulWidget {
  const VitalityHubScreen({Key? key}) : super(key: key);

  @override
  State<VitalityHubScreen> createState() => _VitalityHubScreenState();
}

class _VitalityHubScreenState extends State<VitalityHubScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _journalController = TextEditingController();
  
  // BMI Inputs
  double _height = 170.0;
  double _weight = 70.0;
  
  // Vitality Inputs
  double _sleepHours = 7.0;
  double _waterIntake = 2.0;
  int _stressLevel = 5;
  
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResults;
  List<dynamic> _journalEntries = [];
  String? _userId;

  // Selected Journal Entry for Update
  String? _editingEntryId;

  // Colors
  static const Color primaryNavy = Color(0xFF1B263B);
  static const Color accentTeal = Color(0xFF2A9D8F);
  static const Color accentOrange = Color(0xFFE76F51);
  static const Color accentPurple = Color(0xFF6D597A);
  static const Color bgSoft = Color(0xFFF8FAFB);

  // Quiz State
  String? _selectedQuizCategory;
  int _currentQuestionIndex = 0;
  int _quizScore = 0;
  bool _showQuizResult = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    if (_userId != null) {
      _loadJournal();
    }
  }

  Future<void> _loadJournal() async {
    if (_userId == null) return;
    final entries = await ApiService.getJournalHistory(_userId!);
    setState(() {
      _journalEntries = entries;
    });
  }

  Future<void> _runAnalysis() async {
    if (_userId == null) return;
    setState(() => _isAnalyzing = true);
    
    try {
      final res = await ApiService.analyzeVitality({
        'userId': _userId,
        'height': _height,
        'weight': _weight,
        'sleepHours': _sleepHours,
        'waterIntake': _waterIntake,
        'stressLevel': _stressLevel,
      });
      setState(() {
        _analysisResults = res;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _saveJournalEntry() async {
    if (_userId == null || _journalController.text.trim().isEmpty) return;
    
    if (_editingEntryId != null) {
      await ApiService.updateJournalEntry(_editingEntryId!, _journalController.text, 'neutral');
    } else {
      await ApiService.addJournalEntry(_userId!, _journalController.text, 'neutral');
    }
    
    _journalController.clear();
    setState(() => _editingEntryId = null);
    _loadJournal();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_editingEntryId != null ? "Entry updated!" : "Entry saved!")));
  }

  Future<void> _deleteJournalEntry(String id) async {
    await ApiService.deleteJournalEntry(id);
    _loadJournal();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Entry deleted")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        title: const Text('Holistic Health Hub', style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w900, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: primaryNavy,
          unselectedLabelColor: Colors.grey,
          indicatorColor: accentTeal,
          indicatorWeight: 4,
          tabs: const [
            Tab(icon: Icon(Icons.monitor_weight_outlined), text: 'BMI'),
            Tab(icon: Icon(Icons.bolt_rounded), text: 'Vitality'),
            Tab(icon: Icon(Icons.restaurant_menu_rounded), text: 'Diets'),
            Tab(icon: Icon(Icons.auto_stories_rounded), text: 'Articles'),
            Tab(icon: Icon(Icons.edit_note_rounded), text: 'Journal'),
            Tab(icon: Icon(Icons.quiz_rounded), text: 'Quiz'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildBMITab(),
          _buildVitalityTab(),
          _buildDietTab(),
          _buildReadingTab(),
          _buildJournalTab(),
          _buildQuizTab(),
        ],
      ),
    );
  }

  // --- BMI TAB ---
  Widget _buildBMITab() {
    double bmi = _weight / math.pow(_height / 100, 2);
    String status = "Normal";
    Color statusColor = Colors.green;
    String advice = "You are doing great! Maintain this balance.";

    if (bmi < 18.5) {
      status = "Underweight";
      statusColor = Colors.orange;
      advice = "Include protein-rich foods and complex carbs. Don't skip meals.";
    } else if (bmi >= 25 && bmi < 29.9) {
      status = "Overweight";
      statusColor = accentOrange;
      advice = "Increase physical activity and focus on whole foods.";
    } else if (bmi >= 30) {
      status = "Obese";
      statusColor = Colors.red;
      advice = "Consult a nutritionist for a structured plan. Focus on heart health.";
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildCard(
            child: Column(
              children: [
                const Text('YOUR BMI SCORE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                Text(bmi.toStringAsFixed(1), style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: statusColor)),
                Text(status, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: statusColor)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSlider("Height (cm)", _height, 100, 250, (v) => setState(() => _height = v), accentPurple),
          _buildSlider("Weight (kg)", _weight, 30, 200, (v) => setState(() => _weight = v), accentPurple),
          const SizedBox(height: 32),
          _buildCard(
            title: "Personalized Advice",
            color: statusColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(advice, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text("Eat more fiber-rich vegetables"),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text("Drink warm water before meals"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- VITALITY TAB ---
  Widget _buildVitalityTab() {
    double sleepPercent = (_sleepHours / 8).clamp(0.0, 1.0);
    double waterPercent = (_waterIntake / 3).clamp(0.0, 1.0);
    double stressPercent = ((11 - _stressLevel) / 10).clamp(0.0, 1.0);
    
    double score = (sleepPercent * 33.3) + (waterPercent * 33.3) + (stressPercent * 33.4);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildCard(
            color: accentPurple.withOpacity(0.05),
            child: Column(
              children: [
                const Text('VITALITY MARK', style: TextStyle(fontWeight: FontWeight.bold, color: primaryNavy, letterSpacing: 1.2)),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey[200],
                        color: accentPurple,
                      ),
                    ),
                    Text("${score.toInt()}%", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: accentPurple)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("Habit Balance Score", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryNavy)),
                const SizedBox(height: 24),
                _buildDynamicStatus(score),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSlider("Daily Sleep (Target 8h)", _sleepHours, 0, 12, (v) => setState(() => _sleepHours = v), accentPurple),
          _buildSlider("Water Intake (Target 3L)", _waterIntake, 0, 5, (v) => setState(() => _waterIntake = v), Colors.blue),
          _buildSlider("Stress Level (Lower is better)", _stressLevel.toDouble(), 1, 10, (v) => setState(() => _stressLevel = v.toInt()), accentOrange),
          const SizedBox(height: 24),
          _buildCard(
            title: "Performance Breakdown",
            child: SizedBox(
               height: 160,
               width: double.infinity,
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: [
                    _buildStatBar("Sleep Efficiency", sleepPercent, accentPurple),
                    _buildStatBar("Hydration Level", waterPercent, Colors.blue),
                    _buildStatBar("Stress Management", stressPercent, accentOrange),
                 ],
               ),
            )
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicStatus(double score) {
    String msg = "Good start!";
    IconData icon = Icons.stars_rounded;
    Color color = accentTeal;

    if (score >= 90) {
      msg = "Excellent Balance! Keep up the great habits for glowing skin.";
      icon = Icons.auto_awesome_rounded;
      color = accentTeal;
    } else if (score >= 70) {
      msg = "Great! Focus on improving one category (e.g., more water) to reach 90+%.";
      icon = Icons.thumb_up_rounded;
      color = Colors.blue;
    } else if (score >= 50) {
      msg = "Moderate. Your skin might feel tired. Try to prioritize 7-8h of sleep tonight.";
      icon = Icons.nights_stay_rounded;
      color = accentPurple;
    } else {
      msg = "Action Needed! High stress and low hydration are major skin triggers. Take a 5-min break.";
      icon = Icons.warning_amber_rounded;
      color = accentOrange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(msg, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            Text("${(percent * 100).toInt()}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.1),
            color: color,
          ),
        ),
      ],
    );
  }

  // --- DIET TAB ---
  Widget _buildDietTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildPlanHeader("Recommended Diet Categories"),
        const SizedBox(height: 16),
        _buildDietPlanItem("Clear Skin Diet", "Berries, Avocado, Walnuts, Green Tea", accentTeal, Icons.face_retouching_natural),
        _buildDietPlanItem("Muscle Recovery", "Eggs, Chicken, Lentils, Quinoa", accentPurple, Icons.fitness_center),
        _buildDietPlanItem("Hydration Boost", "Watermelon, Cucumber, Coconut Water", Colors.blue, Icons.opacity),
        _buildDietPlanItem("Immunity Shield", "Ginger, Garlic, Turmeric, Citrus", accentOrange, Icons.security),
        _buildDietPlanItem("Mind Calm Diet", "Dark Chocolate, Chamomile, Oats", Colors.brown, Icons.psychology),
      ],
    );
  }

  // --- READING TAB ---
  Widget _buildReadingTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildArticleCard(
          "The Myth of High BMI", 
          "Understand why muscle mass might skew your results.",
          "BMI is a great general indicator but doesn't account for muscle over fat. Always check your body fat percentage for a clearer picture.",
          accentPurple
        ),
        _buildArticleCard(
          "Sleep's Hidden Role in Skin Aging", 
          "How cortisol levels rise when you skip rest.",
          "When you lack sleep, your body produces more cortisol (the stress hormone). This can lead to increased inflammation and premature wrinkles.",
          accentTeal
        ),
        _buildArticleCard(
          "Stress Management Techniques", 
          "5-minute breathing exercises for a glowing face.",
          "Try the 4-7-8 method. Inhale for 4 seconds, hold for 7, and exhale for 8. This calms the nervous system instantly.",
          accentOrange
        ),
        _buildArticleCard(
          "The Science of Hydration", 
          "Natural moisture from within.",
          "Drinking water doesn't just quench thirst; it maintains skin elasticity and helps flush out toxins that cause breakouts.",
          Colors.blue
        ),
        _buildArticleCard(
          "Combating Digital Eye Strain", 
          "Skin health in the age of screens.",
          "Blue light from screens can affect your circadian rhythm, leading to poor sleep and puffy eyes. Dim your screens at night.",
          accentPurple
        ),
         _buildArticleCard(
          "Post-Workout Skincare", 
          "Best practices for after the gym.",
          "Sweat can clog pores. Always cleanse your face after exercise to prevent 'gym acne' and keep your glow intact.",
          accentOrange
        ),
      ],
    );
  }

  // --- JOURNAL TAB ---
  Widget _buildJournalTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _journalController,
                maxLines: 4,
                autocorrect: true,
                enableSuggestions: true,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: "Express yourself... what's on your mind?",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  suffixIcon: _editingEntryId != null 
                    ? IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setState(() {
                        _editingEntryId = null;
                        _journalController.clear();
                      }))
                    : null,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveJournalEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _editingEntryId != null ? accentOrange : primaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(_editingEntryId != null ? 'UPDATE ENTRY' : 'SAVE ENTRY', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: _journalEntries.length,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemBuilder: (context, index) {
              final e = _journalEntries[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e['content'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Text(e['timestamp'].toString().split('T').first ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                      onPressed: () {
                        setState(() {
                          _editingEntryId = e['id'];
                          _journalController.text = e['content'];
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                      onPressed: () => _deleteJournalEntry(e['id']),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- HELPERS ---

  Widget _buildCard({required Widget child, String? title, Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryNavy)),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double val, double min, double max, Function(double) onChanged, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryNavy, fontSize: 13)),
            Text(val.toStringAsFixed(1), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: val, min: min, max: max,
          activeColor: color,
          inactiveColor: color.withOpacity(0.1),
          onChanged: onChanged,
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildDietPlanItem(String title, String items, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.1))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(items, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ])),
        ],
      ),
    );
  }

  Widget _buildArticleCard(String title, String sub, String content, Color col) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryNavy, fontSize: 15)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      leading: Container(width: 4, height: 40, color: col),
      childrenPadding: const EdgeInsets.all(16),
      children: [Text(content, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.grey))],
    );
  }

  // --- QUIZ TAB ---
  final Map<String, List<Map<String, dynamic>>> _quizData = {
    "Skin Care": [
      {"q": "How often should you apply sunscreen?", "a": ["Every hour", "Every 2 hours", "Once a day"], "c": 1},
      {"q": "What is the best way to wash your face?", "a": ["Hot water", "Warm water", "Ice water"], "c": 1},
      {"q": "Vitamin C helps skin by...", "a": ["Burning fat", "Protecting against damage", "Changing color"], "c": 1},
      {"q": "Moisturizer should be applied to...", "a": ["Dry skin", "Damp skin", "Oily skin only"], "c": 1},
      {"q": "Sleep deprivation causes...", "a": ["Better glow", "Dark circles", "Stronger hair"], "c": 1},
      {"q": "True or False: SPF 50 is twice as strong as SPF 25?", "a": ["True", "False"], "c": 1},
      {"q": "High sugar intake can lead to...", "a": ["Better skin", "Breakouts", "Stronger nails"], "c": 1},
      {"q": "Which is a 'good' skin habit?", "a": ["Popping pimples", "Changing pillowcases", "Touching face"], "c": 1},
      {"q": "Dermatologists recommend daily...", "a": ["Face masks", "Sunscreen", "Tanning"], "c": 1},
      {"q": "Hyaluronic acid is used for...", "a": ["Exfoliation", "Hydration", "Sun protection"], "c": 1},
    ],
    "Wound Care": [
      {"q": "First step for a minor cut?", "a": ["Bandage it", "Wash with soap/water", "Apply alcohol"], "c": 1},
      {"q": "Should you pick a scab?", "a": ["Yes", "No"], "c": 1},
      {"q": "Signs of wound infection?", "a": ["Pus and redness", "Normal itching", "Cold skin"], "c": 0},
      {"q": "Best for a minor burn?", "a": ["Ice", "Cool running water", "Butter"], "c": 1},
      {"q": "How often to change a bandage?", "a": ["Every 3 days", "Daily or if wet", "Never"], "c": 1},
      {"q": "A 'Tetanus' shot is for...", "a": ["Viral fever", "Deep/dirty wounds", "Headaches"], "c": 1},
      {"q": "Keep a wound...", "a": ["Open & dry", "Moist & covered", "Wrapped in paper"], "c": 1},
      {"q": "When to see a doctor for a wound?", "a": ["If it stops bleeding", "If it won't stop bleeding", "If it scabs"], "c": 1},
      {"q": "Purpose of an antibiotic ointment?", "a": ["Stopping pain", "Preventing infection", "Fading scars"], "c": 1},
      {"q": "A puncture wound is...", "a": ["Surface scratch", "Deep narrow hole", "Wide scrape"], "c": 1},
    ],
    "Melanoma": [
      {"q": "What does 'ABCDE' in melanoma stand for?", "a": ["Aesthetic", "Asymmetry", "Action"], "c": 1},
      {"q": "Is melanoma the deadliest skin cancer?", "a": ["Yes", "No"], "c": 0},
      {"q": "Main cause of melanoma?", "a": ["Sugar", "UV Radiation", "Lack of sleep"], "c": 1},
      {"q": "Where can melanoma appear?", "a": ["Sun exposed areas", "Anywhere on body", "Only face"], "c": 1},
      {"q": "A normal mole is usually...", "a": ["Irregular", "Symmetrical", "Multi-colored"], "c": 1},
      {"q": "When to check your moles?", "a": ["Once a year", "Every month", "Never"], "c": 1},
      {"q": "Does skin color protect from melanoma?", "a": ["Yes, fully", "No, anyone can get it", "Only dark skin"], "c": 1},
      {"q": "What is 'Biopsy'?", "a": ["X-Ray", "Tissue sample testing", "Skin cream"], "c": 1},
      {"q": "Melanoma risk is higher if...", "a": ["You tan safely", "You had severe sunburns", "You eat fruit"], "c": 1},
      {"q": "Melanoma can start from...", "a": ["Existing moles", "Only new spots", "Both"], "c": 2},
    ],
    "Vitality": [
      {"q": "Daily water target for healthy skin?", "a": ["1 Liter", "2-3 Liters", "5+ Liters"], "c": 1},
      {"q": "Recommended sleep for adults?", "a": ["5 hours", "7-9 hours", "12 hours"], "c": 1},
      {"q": "Stress causes hormone called...", "a": ["Insulin", "Cortisol", "Melatonin"], "c": 1},
      {"q": "Best source of Vitamin D?", "a": ["Red meat", "Safe sun exposure", "Coffee"], "c": 1},
      {"q": "Exercise helps skin by...", "a": ["Clogging pores", "Improving circulation", "Thinning skin"], "c": 1},
      {"q": "Processed foods can cause...", "a": ["Better energy", "Inflammation", "Stronger bones"], "c": 1},
      {"q": "Deep breathing helps to...", "a": ["Increase stress", "Lower cortisol", "Stop digestion"], "c": 1},
      {"q": "Alcohol consumption can...", "a": ["Hydrate skin", "Dehydrate skin", "Clear acne"], "c": 1},
      {"q": "Best snack for vitality?", "a": ["Chips", "Nuts and seeds", "Soda"], "c": 1},
      {"q": "Morning routine should start with...", "a": ["Coffee", "Glass of water", "Screentime"], "c": 1},
    ]
  };

  Widget _buildQuizTab() {
    if (_selectedQuizCategory == null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text("Select a Quiz Category", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryNavy)),
          const SizedBox(height: 16),
          ..._quizData.keys.map((cat) => _buildQuizCategoryTile(cat)).toList(),
        ],
      );
    }

    if (_showQuizResult) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded, size: 100, color: Colors.amber),
            const SizedBox(height: 16),
            const Text("Quiz Completed!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryNavy)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(color: accentTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text("Your Score: $_quizScore / 10", style: const TextStyle(fontSize: 24, color: accentTeal, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => setState(() {
                _selectedQuizCategory = null;
                _showQuizResult = false;
                _currentQuestionIndex = 0;
                _quizScore = 0;
              }),
              style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text("TRY ANOTHER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    final questions = _quizData[_selectedQuizCategory]!;
    final q = questions[_currentQuestionIndex];
    
    // Category Colors
    Color catCol = accentTeal;
    if (_selectedQuizCategory == "Wound Care") catCol = accentOrange;
    if (_selectedQuizCategory == "Melanoma") catCol = accentPurple;
    if (_selectedQuizCategory == "Vitality") catCol = Colors.blue;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: () => setState(() => _selectedQuizCategory = null),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("$_selectedQuizCategory Quiz", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                  Text("Q: ${_currentQuestionIndex + 1}/10", style: TextStyle(fontWeight: FontWeight.bold, color: catCol)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: (_currentQuestionIndex + 1) / 10, color: catCol, backgroundColor: catCol.withOpacity(0.1), minHeight: 6),
          ),
          const SizedBox(height: 32),
          _buildCard(
            child: Text(q['q'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryNavy)),
          ),
          const SizedBox(height: 32),
          ...List.generate(q['a'].length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: () => _handleAnswer(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryNavy,
                  padding: const EdgeInsets.all(24),
                  elevation: 2,
                  shadowColor: Colors.black12,
                  side: BorderSide(color: catCol.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(q['a'][index], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                    Icon(Icons.play_arrow_rounded, color: catCol, size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _handleAnswer(int index) {
    final questions = _quizData[_selectedQuizCategory]!;
    final correct = questions[_currentQuestionIndex]['c'] == index;

    if (correct) {
      _quizScore++;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Row(children: [Text("WOW! Excellent ✅ 🌟", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), Spacer(), Icon(Icons.auto_awesome, color: Colors.white)]),
        backgroundColor: Colors.green, duration: Duration(milliseconds: 700),
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Row(children: [Text("Oops! Wrong Answer ❌ 😟", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), Spacer(), Icon(Icons.sentiment_very_dissatisfied, color: Colors.white)]),
        backgroundColor: Colors.redAccent, duration: Duration(milliseconds: 700),
        behavior: SnackBarBehavior.floating,
      ));
    }

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          if (_currentQuestionIndex < 9) {
            _currentQuestionIndex++;
          } else {
            _showQuizResult = true;
          }
        });
      }
    });
  }

  Widget _buildQuizCategoryTile(String title) {
    IconData icon = Icons.science_rounded;
    Color col = accentTeal;
    if (title == "Skin Care") { icon = Icons.face_retouching_natural; col = accentTeal; }
    if (title == "Wound Care") { icon = Icons.healing_rounded; col = accentOrange; }
    if (title == "Melanoma") { icon = Icons.visibility_rounded; col = accentPurple; }
    if (title == "Vitality") { icon = Icons.favorite_rounded; col = Colors.blue; }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        onTap: () => setState(() => _selectedQuizCategory = title),
        tileColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: col),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: primaryNavy)),
        subtitle: const Text("10 Questions • Intermittent difficulty", style: TextStyle(fontSize: 12)),
        trailing: Icon(Icons.play_circle_fill_rounded, color: col, size: 36),
      ),
    );
  }

  Widget _buildPlanHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy));
  }
}
