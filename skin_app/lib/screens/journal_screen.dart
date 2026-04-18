import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> with TickerProviderStateMixin {
  // "Bloom & Earth" Multi-Color Palette
  static const Color cPlum      = Color(0xFF574964); // Deep Purple
  static const Color cRose      = Color(0xFFC8AAAA); // Rose
  static const Color cDusty     = Color(0xFF9F8383); // Dusty Brown
  static const Color cSand      = Color(0xFFD6C0B3); // Beige
  static const Color cPeach     = Color(0xFFFFDAB3); // Peach
  static const Color cTerra     = Color(0xFFAB886D); // Terra-cotta
  static const Color cBg        = Color(0xFFFDF8F5);

  final List<Color> _palette = [cPeach, cSand, cRose, cDusty, cTerra];

  late TabController _tabController;

  // ── Journal state ─────────────────────────────
  String? _userId;
  List<Map<String, dynamic>> _allEntries = [];
  bool _loadingEntries = false;
  String? _editingEntryId;
  final TextEditingController _journalCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedMood = 'balanced';
  bool _isBold = false;
  bool _isItalic = false;
  List<String> _selectedTags = [];

  // Filter State
  String _searchQuery = '';
  String? _filterTag;
  String? _filterMood;

  // ── Calendar & Streak ─────────────────────────
  DateTime _focusedDay = DateTime.now();
  Map<String, List<Map<String, dynamic>>> _dayMap = {};
  int _currentStreak = 0;
  int _longestStreak = 0;

  // ── Pagination ────────────────────────────────
  int _currentPage = 0;
  static const int _pageSize = 8; 

  // ── To-Do Records (7-Day History) ───────────────
  Map<String, List<Map<String, dynamic>>> _todoHistory = {};
  DateTime _selectedTodoDate = DateTime.now();
  final TextEditingController _todoCtrl = TextEditingController();

  static const List<Map<String, dynamic>> _moods = [
    {'key': 'excellent', 'label': 'Joyful',  'emoji': '✨', 'color': cRose},
    {'key': 'balanced',  'label': 'Calm',    'emoji': '🌿', 'color': cTerra},
    {'key': 'stressed',  'label': 'Tired',   'emoji': '💫', 'color': cDusty},
    {'key': 'fatigued',  'label': 'Gloomy',  'emoji': '☁️', 'color': cPlum},
  ];

  static const List<String> _tagOptions = ['Skin', 'Sleep', 'Diet', 'Exercise', 'Meds', 'Mental', 'Win'];
  static const List<String> _todoSuggestions = ['Drink 3L Water', 'Apply Sunscreen', '15m Meditation', 'Eat Vegetables', '8h Sleep', 'Skincare Routine'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _journalCtrl.dispose();
    _searchCtrl.dispose();
    _todoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userId = prefs.getString('userId'));
    await _loadJournal();
    await _loadTodoHistory();
  }

  Future<void> _loadTodoHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('todo_history_json');
    if (data != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(data);
        final history = <String, List<Map<String, dynamic>>>{};
        decoded.forEach((key, value) => history[key] = List<Map<String, dynamic>>.from(value));
        setState(() => _todoHistory = history);
      } catch (_) {}
    }
  }

  Future<void> _saveTodoHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('todo_history_json', jsonEncode(_todoHistory));
  }

  Future<void> _loadJournal() async {
    if (_userId == null) return;
    setState(() => _loadingEntries = true);
    try {
      final entries = await ApiService.getJournalHistory(_userId!);
      final mapped = List<Map<String, dynamic>>.from(entries);
      final dayMap = <String, List<Map<String, dynamic>>>{};
      for (final e in mapped) {
        final ts = e['timestamp']?.toString() ?? '';
        if (ts.isNotEmpty) {
           final dayKey = ts.split('T').first;
           dayMap.putIfAbsent(dayKey, () => []).add(e);
        }
      }
      if (mounted) {
        setState(() { 
          _allEntries = mapped; 
          _dayMap = dayMap; 
          _calculateStreaks();
          _loadingEntries = false; 
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingEntries = false);
    }
  }

  void _calculateStreaks() {
    if (_dayMap.isEmpty) { _currentStreak = 0; _longestStreak = 0; return; }
    List<DateTime> loggedDays = _dayMap.keys.map((k) => DateTime.parse(k)).toList()..sort((a, b) => b.compareTo(a));
    DateTime todayDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime yesterdayDate = todayDate.subtract(const Duration(days: 1));
    int current = 0; DateTime? checkDate;
    bool hasToday = loggedDays.any((d) => d.year == todayDate.year && d.month == todayDate.month && d.day == todayDate.day);
    bool hasYesterday = loggedDays.any((d) => d.year == yesterdayDate.year && d.month == yesterdayDate.month && d.day == yesterdayDate.day);
    if (hasToday) checkDate = todayDate; else if (hasYesterday) checkDate = yesterdayDate;
    if (checkDate != null) {
      for (int i = 0; i < 365; i++) {
        DateTime target = checkDate!.subtract(Duration(days: i));
        if (loggedDays.any((d) => d.year == target.year && d.month == target.month && d.day == target.day)) current++;
        else break;
      }
    }
    int maxS = 0, tempS = 0;
    if (loggedDays.isNotEmpty) {
      tempS = 1; maxS = 1;
      for (int i = 0; i < loggedDays.length - 1; i++) {
        final diff = loggedDays[i].difference(loggedDays[i+1]).inDays;
        if (diff == 1) { tempS++; if (tempS > maxS) maxS = tempS; }
        else if (diff > 1) tempS = 1;
      }
    }
    _currentStreak = current; _longestStreak = maxS;
  }

  Future<void> _saveEntry() async {
    if (_userId == null) { _snack('Session expired.', Colors.red); return; }
    final raw = _journalCtrl.text.trim();
    if (raw.isEmpty) {
       _snack('Please write your journal entry first before saving!', Colors.orangeAccent);
       return;
    }
    String content = raw;
    if (_isBold) content = '**$content**';
    if (_isItalic) content = '_${content}_';
    if (_selectedTags.isNotEmpty) content += '\n[${_selectedTags.join(', ')}]';
    try {
      if (_editingEntryId != null) await ApiService.updateJournalEntry(_editingEntryId!, content, _selectedMood);
      else await ApiService.addJournalEntry(_userId!, content, _selectedMood);
      _journalCtrl.clear();
      setState(() { _editingEntryId = null; _isBold = false; _isItalic = false; _selectedTags = []; });
      await _loadJournal();
      _snack('Diary Entry Saved!', cTerra);
    } catch (e) { _snack('Failed to sync.', Colors.red); }
  }

  Future<void> _deleteEntry(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete?', style: TextStyle(color: cPlum, fontWeight: FontWeight.bold)),
        content: const Text('Remove this memory forever?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try { await ApiService.deleteJournalEntry(id); await _loadJournal(); _snack('Moment deleted.', cDusty); } catch (_) { _snack('Error.', Colors.red); }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }

  List<Map<String, dynamic>> get _filteredEntries {
    var list = _allEntries;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((e) => (e['content'] ?? '').toString().toLowerCase().contains(q)).toList();
    }
    if (_filterMood != null) list = list.where((e) => e['mood'] == _filterMood).toList();
    if (_filterTag != null) {
      list = list.where((e) => _parseTags(e['content']?.toString() ?? '').contains(_filterTag)).toList();
    }
    return list;
  }
  List<Map<String, dynamic>> get _pagedEntries {
    final src = _filteredEntries;
    final start = _currentPage * _pageSize;
    if (start >= src.length) return [];
    return src.sublist(start, (start + _pageSize).clamp(0, src.length));
  }
  int get _totalPages => ((_filteredEntries.length) / _pageSize).ceil().clamp(1, 999);
  String _displayContent(String raw) => raw.replaceAll(RegExp(r'\*\*|\*|_'), '').replaceAll(RegExp(r'\n\[.*?\]'), '');
  List<String> _parseTags(String raw) {
    final match = RegExp(r'\[([^\]]+)\]').firstMatch(raw);
    return match == null ? [] : match.group(1)!.split(', ').map((t) => t.trim()).toList();
  }
  bool _isBoldEntry(String raw) => raw.startsWith('**');
  bool _isItalicEntry(String raw) => raw.startsWith('_');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBg,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: cPlum, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Wellness Diary', style: TextStyle(color: cPlum, fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController, labelColor: cPlum, unselectedLabelColor: Colors.grey,
          indicatorColor: cTerra, indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
          tabs: const [Tab(text: 'WRITE'), Tab(text: 'LOGS'), Tab(text: 'METRICS'), Tab(text: 'TO DO')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildWriteTab(), _buildHistoryTab(), _buildInsightsTab(), _buildTodoListTab()],
      ),
    );
  }

  Widget _buildWriteTab() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildRainbowHeader(),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: cSand.withOpacity(0.5))),
            child: Column(children: [
              TextField(
                controller: _journalCtrl, maxLines: 8,
                style: TextStyle(fontSize: 15, color: cPlum, fontWeight: _isBold ? FontWeight.bold : FontWeight.normal, fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal),
                decoration: const InputDecoration(hintText: 'Dear Diary, today I felt...', border: InputBorder.none),
              ),
              const Divider(color: cSand),
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _moods.map((m) {
                final active = _selectedMood == m['key'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = m['key']),
                  child: Container(margin: const EdgeInsets.all(4), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: active ? m['color'] as Color : cBg, borderRadius: BorderRadius.circular(12)), child: Text(m['emoji'] as String, style: const TextStyle(fontSize: 24))),
                );
              }).toList())),
              const SizedBox(height: 12),
              Wrap(spacing: 6, children: _tagOptions.map((t) {
                final active = _selectedTags.contains(t);
                return ActionChip(label: Text(t, style: TextStyle(fontSize: 10, color: active ? Colors.white : cPlum)), backgroundColor: active ? cTerra : cPeach, onPressed: () => setState(() => active ? _selectedTags.remove(t) : _selectedTags.add(t)));
              }).toList()),
              const SizedBox(height: 20),
              GestureDetector(onTap: _saveEntry, child: Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: cPlum, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('SAVE RECORD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
            ]),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildRainbowHeader() {
    return Row(
      children: [
        _miniBox(cPeach, '$_currentStreak', 'Streak'), const SizedBox(width: 8),
        _miniBox(cSand, '${_allEntries.length}', 'Logs'), const SizedBox(width: 8),
        _miniBox(cRose, '$_longestStreak', 'Best'),
      ],
    );
  }

  Widget _miniBox(Color c, String val, String lab) {
    return Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(16)), child: Column(children: [Text(val, style: const TextStyle(fontWeight: FontWeight.w900, color: cPlum, fontSize: 18)), Text(lab, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: cPlum))])));
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: TextField(controller: _searchCtrl, onChanged: (v) => setState(() => _searchQuery = v), decoration: const InputDecoration(icon: Icon(Icons.search, size: 18), hintText: 'Search...', border: InputBorder.none))),
        ),
        Expanded(
          child: _loadingEntries ? const Center(child: CircularProgressIndicator()) : (_pagedEntries.isEmpty ? const Center(child: Text('No entries found.')) : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 60),
            physics: const ClampingScrollPhysics(),
            itemCount: _pagedEntries.length,
            itemBuilder: (ctx, idx) => _buildCompactCard(_pagedEntries[idx], idx),
          )),
        ),
        if (_totalPages > 1) _buildPagination(),
      ],
    );
  }

  Widget _buildCompactCard(Map<String, dynamic> e, int idx) {
    final c = _palette[idx % _palette.length];
    final mood = e['mood']?.toString() ?? 'balanced';
    final content = e['content']?.toString() ?? '';
    final tags = _parseTags(content);
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(_moodEmoji(mood), style: const TextStyle(fontSize: 18)), const SizedBox(width: 8),
          Text(DateFormat('MMM d').format(DateTime.parse(e['timestamp'])), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: cPlum)),
          const Spacer(),
          GestureDetector(
            onTap: () { 
              setState(() { 
                _editingEntryId = e['id']; 
                _journalCtrl.text = _displayContent(e['content'] ?? ''); 
                _selectedMood = mood; 
                _selectedTags = tags; 
              }); 
              _tabController.animateTo(0); 
            }, 
            child: const Icon(Icons.edit_note_rounded, size: 20, color: cPlum)
          ),
          const SizedBox(width: 12),
          GestureDetector(onTap: () => _deleteEntry(e['id']), child: const Icon(Icons.delete_outline_rounded, size: 18, color: cPlum)),
        ]),
        const SizedBox(height: 8),
        Text(_displayContent(content), maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: cPlum, fontSize: 13, height: 1.4)),
        if (tags.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Wrap(spacing: 4, children: tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(4)), child: Text(t, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: cPlum)))).toList())),
      ]),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        _buildCalendarComponent(), const SizedBox(height: 20),
        _insightBox(cPeach, 'MOOD FLOW', _buildLineChart()), const SizedBox(height: 20),
        _insightBox(cSand, 'TOP TOPICS', _buildBarChart()),
        const SizedBox(height: 60),
      ]),
    );
  }

  Widget _insightBox(Color c, String title, Widget child) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: cPlum, fontSize: 11)), const SizedBox(height: 16), child]));
  }

  Widget _buildTodoListTab() {
    final k = _selectedTodoDate.toIso8601String().split('T').first;
    final list = _todoHistory[k] ?? [];
    return Column(children: [
      Container(height: 80, color: Colors.white, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: 7, itemBuilder: (ctx, i) {
        final d = DateTime.now().subtract(Duration(days: i)); final sel = d.day == _selectedTodoDate.day;
        return GestureDetector(onTap: () => setState(() => _selectedTodoDate = d), child: Container(width: 50, margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10), decoration: BoxDecoration(color: sel ? cTerra : cPeach, borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(DateFormat('E').format(d).toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)), Text('${d.day}', style: const TextStyle(fontWeight: FontWeight.bold))])));
      })),
      Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _todoSuggestions.map((s) => GestureDetector(onTap: () { _todoCtrl.text = s; _addTodo(); }, child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: cRose, borderRadius: BorderRadius.circular(20)), child: Text('+ $s', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))))).toList())),
      ),
      if (_selectedTodoDate.day == DateTime.now().day) Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: TextField(controller: _todoCtrl, onSubmitted: (_) => _addTodo(), decoration: InputDecoration(hintText: 'Add to do...', suffixIcon: IconButton(onPressed: _addTodo, icon: const Icon(Icons.add_circle, color: cPlum))))),
      Expanded(child: ListView.builder(padding: const EdgeInsets.fromLTRB(16, 20, 16, 60), physics: const ClampingScrollPhysics(), itemCount: list.length, itemBuilder: (ctx, i) {
        final t = list[i]; final done = t['done'] as bool;
        return Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: done ? cSand : cPeach, borderRadius: BorderRadius.circular(12)), child: ListTile(leading: Checkbox(value: done, onChanged: (v) { setState(() => t['done'] = v); _saveTodoHistory(); }), title: Text(t['text'], style: TextStyle(decoration: done ? TextDecoration.lineThrough : null, color: cPlum, fontWeight: FontWeight.bold)), trailing: IconButton(onPressed: () { setState(() => list.removeAt(i)); _saveTodoHistory(); }, icon: const Icon(Icons.close, size: 16))));
      }))
    ]);
  }

  void _addTodo() {
    final t = _todoCtrl.text.trim(); if (t.isEmpty) return;
    final k = _selectedTodoDate.toIso8601String().split('T').first;
    setState(() { _todoHistory.putIfAbsent(k, () => []).add({'text': t, 'done': false, 'id': DateTime.now().toIso8601String()}); _todoCtrl.clear(); });
    _saveTodoHistory();
  }

  Widget _buildCalendarComponent() {
    final days = DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final first = DateTime(_focusedDay.year, _focusedDay.month, 1); final offset = (first.weekday % 7);
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        IconButton(onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1)), icon: const Icon(Icons.chevron_left)),
        Text(DateFormat('MMMM yyyy').format(_focusedDay), style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1)), icon: const Icon(Icons.chevron_right)),
      ]),
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7), itemCount: offset + days, itemBuilder: (ctx, i) {
        if (i < offset) return const SizedBox(); final d = i - offset + 1; final key = DateTime(_focusedDay.year, _focusedDay.month, d).toIso8601String().split('T').first;
        return Center(child: Container(width: 30, height: 30, decoration: BoxDecoration(color: _dayMap.containsKey(key) ? cRose : Colors.transparent, shape: BoxShape.circle), child: Center(child: Text('$d', style: TextStyle(fontWeight: FontWeight.bold, color: _dayMap.containsKey(key) ? Colors.white : cPlum)))));
      })
    ]));
  }

  Widget _buildLineChart() {
    if (_allEntries.isEmpty) return const SizedBox();
    final last = (_allEntries.toList()..sort((a,b) => b['timestamp'].compareTo(a['timestamp']))).take(7).toList().reversed.toList();
    return SizedBox(height: 100, child: LineChart(LineChartData(gridData: const FlGridData(show: false), borderData: FlBorderData(show: false), titlesData: const FlTitlesData(show: false), lineBarsData: [LineChartBarData(spots: last.asMap().entries.map((e) {
      double v = 2; final m = e.value['mood']; if (m == 'excellent') v = 4; else if (m == 'balanced') v = 3; else if (m == 'stressed') v = 2; else if (m == 'fatigued') v = 1;
      return FlSpot(e.key.toDouble(), v);
    }).toList(), isCurved: true, color: cPlum, barWidth: 3, dotData: const FlDotData(show: true))])));
  }

  Widget _buildBarChart() {
    final counts = <String, int>{};
    for (var e in _allEntries) { for (var t in _parseTags(e['content'] ?? '')) counts[t] = (counts[t] ?? 0) + 1; }
    if (counts.isEmpty) return const SizedBox();
    final tops = (counts.entries.toList()..sort((a,b) => b.value.compareTo(a.value))).take(4).toList();
    return SizedBox(height: 100, child: BarChart(BarChartData(gridData: const FlGridData(show: false), borderData: FlBorderData(show: false), titlesData: const FlTitlesData(show: false), barGroups: tops.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.value.toDouble(), color: cPlum, width: 15)])).toList())));
  }

  Widget _buildPagination() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_totalPages, (i) => GestureDetector(onTap: () => setState(() => _currentPage = i) , child: Container(margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10), width: 10, height: 10, decoration: BoxDecoration(color: i == _currentPage ? cPlum : cDusty, shape: BoxShape.circle)))));
  }

  String _moodEmoji(String mood) => _moods.firstWhere((m) => m['key'] == mood, orElse: () => _moods[1])['emoji'] as String;

  String _monthName(int m) => DateFormat('MMMM').format(DateTime(2026, m));
}
