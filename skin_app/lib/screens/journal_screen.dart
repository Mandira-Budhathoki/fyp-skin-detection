import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> with TickerProviderStateMixin {
  static const Color navy    = Color(0xFF1B263B);
  static const Color teal    = Color(0xFF2A9D8F);
  static const Color orange  = Color(0xFFE76F51);
  static const Color purple  = Color(0xFF7C5CBF);
  static const Color blue    = Color(0xFF3A86FF);
  static const Color bg      = Color(0xFFF8FAFB);

  late TabController _tabController;

  // ── Journal state ─────────────────────────────
  String? _userId;
  List<Map<String, dynamic>> _allEntries = [];
  bool _loadingEntries = false;
  String? _editingEntryId;
  final TextEditingController _journalCtrl = TextEditingController();
  String _selectedMood = 'happy';
  bool _isBold = false;

  // Formatting tags applied to entry text
  bool _isItalic = false;
  List<String> _selectedTags = [];

  // ── Calendar ──────────────────────────────────
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<Map<String, dynamic>>> _dayMap = {};

  // ── Pagination ────────────────────────────────
  int _currentPage = 0;
  static const int _pageSize = 5;

  // ── To-Do ─────────────────────────────────────
  List<Map<String, dynamic>> _todos = [];
  final TextEditingController _todoCtrl = TextEditingController();

  // ── Moods ─────────────────────────────────────
  static const List<Map<String, dynamic>> _moods = [
    {'key': 'happy',     'emoji': '😊', 'label': 'Happy',     'color': Color(0xFFFFB700)},
    {'key': 'calm',      'emoji': '😌', 'label': 'Calm',      'color': Color(0xFF2A9D8F)},
    {'key': 'anxious',   'emoji': '😰', 'label': 'Anxious',   'color': Color(0xFFE76F51)},
    {'key': 'sad',       'emoji': '😢', 'label': 'Sad',       'color': Color(0xFF3A86FF)},
    {'key': 'angry',     'emoji': '😤', 'label': 'Angry',     'color': Color(0xFFE63946)},
    {'key': 'grateful',  'emoji': '🙏', 'label': 'Grateful',  'color': Color(0xFF7C5CBF)},
    {'key': 'excited',   'emoji': '🤩', 'label': 'Excited',   'color': Color(0xFFFF6B6B)},
    {'key': 'tired',     'emoji': '😴', 'label': 'Tired',     'color': Color(0xFF8D99AE)},
  ];

  static const List<String> _tagOptions = ['Skin', 'Sleep', 'Diet', 'Exercise', 'Stress', 'Mood', 'Medication', 'Pain', 'Progress'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0 && !_tabController.indexIsChanging) {
        _loadJournal();
      }
    });
    _loadUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _journalCtrl.dispose();
    _todoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userId = prefs.getString('userId'));
    await _loadJournal();
  }

  Future<void> _loadJournal() async {
    if (_userId == null) return;
    setState(() => _loadingEntries = true);
    try {
      final entries = await ApiService.getJournalHistory(_userId!);
      final mapped = List<Map<String, dynamic>>.from(entries.map((e) {
        final raw = Map<String, dynamic>.from(e);
        // parse tags from content if stored as "TAGS:[...]\n..."
        return raw;
      }));
      final dayMap = <String, List<Map<String, dynamic>>>{};
      for (final e in mapped) {
        final ts = e['timestamp']?.toString() ?? '';
        final dayKey = ts.split('T').first;
        dayMap.putIfAbsent(dayKey, () => []).add(e);
      }
      if (mounted) setState(() { _allEntries = mapped; _dayMap = dayMap; _loadingEntries = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingEntries = false);
    }
  }

  Future<void> _saveEntry() async {
    if (_userId == null) {
      _snack('Please log in first.', Colors.red);
      return;
    }
    final raw = _journalCtrl.text.trim();
    if (raw.isEmpty) return;

    // Prefix bold/italic markers
    String content = raw;
    if (_isBold) content = '**$content**';
    if (_isItalic) content = '_${content}_';
    if (_selectedTags.isNotEmpty) content += '\n[${_selectedTags.join(', ')}]';

    try {
      if (_editingEntryId != null) {
        await ApiService.updateJournalEntry(_editingEntryId!, content, _selectedMood);
      } else {
        await ApiService.addJournalEntry(_userId!, content, _selectedMood);
      }
      _journalCtrl.clear();
      setState(() {
        _editingEntryId = null;
        _isBold = false;
        _isItalic = false;
        _selectedTags = [];
      });
      await _loadJournal();
      _snack(_editingEntryId == null ? 'Entry saved!' : 'Entry updated!', teal);
    } catch (e) {
      _snack('Failed to save. Check connection.', Colors.red);
    }
  }

  Future<void> _deleteEntry(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Entry?', style: TextStyle(color: navy, fontWeight: FontWeight.bold)),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiService.deleteJournalEntry(id);
      await _loadJournal();
      _snack('Entry deleted.', orange);
    } catch (_) {
      _snack('Failed to delete.', Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // Returns entries for selected day or all
  List<Map<String, dynamic>> get _filteredEntries {
    if (_selectedDay != null) {
      final key = _selectedDay!.toIso8601String().split('T').first;
      return _dayMap[key] ?? [];
    }
    return _allEntries;
  }

  // Paged subset
  List<Map<String, dynamic>> get _pagedEntries {
    final src = _filteredEntries;
    final start = _currentPage * _pageSize;
    if (start >= src.length) return [];
    return src.sublist(start, (start + _pageSize).clamp(0, src.length));
  }

  int get _totalPages => ((_filteredEntries.length) / _pageSize).ceil().clamp(1, 999);

  // Parse raw content back to display string (strip markers)
  String _displayContent(String raw) {
    return raw.replaceAll(RegExp(r'\*\*|\*|_'), '').replaceAll(RegExp(r'\n\[.*?\]'), '');
  }

  List<String> _parseTags(String raw) {
    final match = RegExp(r'\[([^\]]+)\]').firstMatch(raw);
    if (match == null) return [];
    return match.group(1)!.split(', ').map((t) => t.trim()).toList();
  }

  bool _isBoldEntry(String raw) => raw.startsWith('**') && raw.contains('**', 2);
  bool _isItalicEntry(String raw) => raw.startsWith('_');

  Color _moodColor(String mood) {
    final m = _moods.firstWhere((m) => m['key'] == mood, orElse: () => {'color': Colors.grey});
    return m['color'] as Color;
  }

  String _moodEmoji(String mood) {
    final m = _moods.firstWhere((m) => m['key'] == mood, orElse: () => {'emoji': '😐'});
    return m['emoji'] as String;
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
        title: const Text('Health Journal', style: TextStyle(color: navy, fontWeight: FontWeight.w900, fontSize: 20)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: navy.withOpacity(0.07), borderRadius: BorderRadius.circular(20)),
              child: Text('${_allEntries.length} entries', style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: navy,
          unselectedLabelColor: Colors.grey,
          indicatorColor: teal,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.edit_note_rounded), text: 'Write'),
            Tab(icon: Icon(Icons.calendar_month_rounded), text: 'Calendar'),
            Tab(icon: Icon(Icons.checklist_rounded), text: 'To-Do'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildWriteTab(),
          _buildCalendarTab(),
          _buildTodoTab(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  WRITE TAB
  // ══════════════════════════════════════════════
  Widget _buildWriteTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mood selector
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_emotions_outlined, color: navy, size: 20),
                    const SizedBox(width: 8),
                    const Text('How are you feeling?', style: TextStyle(fontWeight: FontWeight.bold, color: navy, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _moods.map((m) {
                    final active = m['key'] == _selectedMood;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMood = m['key']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: active ? (m['color'] as Color) : (m['color'] as Color).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: active ? (m['color'] as Color) : Colors.transparent),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(m['emoji'], style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 5),
                            Text(m['label'], style: TextStyle(
                              color: active ? Colors.white : Colors.grey[700],
                              fontWeight: active ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            )),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Tags
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.label_outline_rounded, color: navy, size: 20),
                    const SizedBox(width: 8),
                    const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold, color: navy, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _tagOptions.map((tag) {
                    final active = _selectedTags.contains(tag);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (active) _selectedTags.remove(tag);
                        else _selectedTags.add(tag);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? navy : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: active ? navy : Colors.grey.shade300),
                        ),
                        child: Text(tag, style: TextStyle(
                          color: active ? Colors.white : Colors.grey[600],
                          fontWeight: active ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        )),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Editor
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)],
            ),
            child: Column(
              children: [
                // Formatting toolbar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      _fmtBtn(label: 'B', active: _isBold, onTap: () => setState(() => _isBold = !_isBold),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                      const SizedBox(width: 6),
                      _fmtBtn(label: 'I', active: _isItalic, onTap: () => setState(() => _isItalic = !_isItalic),
                          style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15)),
                      const Spacer(),
                      if (_editingEntryId != null)
                        TextButton.icon(
                          onPressed: () => setState(() { _editingEntryId = null; _journalCtrl.clear(); _isBold = false; _isItalic = false; _selectedTags = []; }),
                          icon: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                          label: const Text('Cancel Edit', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _journalCtrl,
                    maxLines: 6,
                    style: TextStyle(
                      fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                      fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                      fontSize: 15,
                      height: 1.6,
                    ),
                    decoration: InputDecoration(
                      hintText: "What's on your mind today?\n\nRecord how your skin feels, your energy levels, any symptoms...",
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.6),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: GestureDetector(
                    onTap: _saveEntry,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _editingEntryId != null
                              ? [orange, orange.withOpacity(0.7)]
                              : [navy, navy.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(
                          color: (_editingEntryId != null ? orange : navy).withOpacity(0.3),
                          blurRadius: 12, offset: const Offset(0, 4),
                        )],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_editingEntryId != null ? Icons.update_rounded : Icons.save_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(_editingEntryId != null ? 'UPDATE ENTRY' : 'SAVE ENTRY',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Entries list with pagination
          if (_loadingEntries)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: teal)))
          else if (_allEntries.isEmpty)
            _buildEmptyState()
          else ...[
            // Stats header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDay != null
                      ? 'Entries on ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}'
                      : 'All Entries (${_allEntries.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: navy, fontSize: 15),
                ),
                if (_selectedDay != null)
                  TextButton(
                    onPressed: () => setState(() { _selectedDay = null; _currentPage = 0; }),
                    child: const Text('Clear filter', style: TextStyle(color: teal, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ..._pagedEntries.map((entry) => _buildEntryCard(entry)),
            const SizedBox(height: 8),
            _buildPagination(),
          ],
        ],
      ),
    );
  }

  Widget _fmtBtn({required String label, required bool active, required VoidCallback onTap, TextStyle? style}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: active ? navy : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? navy : Colors.grey.shade200),
        ),
        child: Center(
          child: Text(label, style: (style ?? const TextStyle()).copyWith(color: active ? Colors.white : Colors.grey[700])),
        ),
      ),
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> entry) {
    final rawContent = entry['content']?.toString() ?? '';
    final mood = entry['mood']?.toString() ?? 'happy';
    final moodColor = _moodColor(mood);
    final tags = _parseTags(rawContent);
    final displayText = _displayContent(rawContent);
    final bold = _isBoldEntry(rawContent);
    final italic = _isItalicEntry(rawContent);
    final ts = entry['timestamp']?.toString() ?? '';
    final dateStr = ts.isNotEmpty ? ts.split('T').first : '';
    final timeStr = ts.contains('T') ? ts.split('T')[1].substring(0, 5) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: moodColor, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(_moodEmoji(mood), style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: moodColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(mood[0].toUpperCase() + mood.substring(1),
                    style: TextStyle(color: moodColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const Spacer(),
              Text('$dateStr  $timeStr', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _editingEntryId = entry['id'];
                    _journalCtrl.text = displayText;
                    _selectedMood = mood;
                    _selectedTags = tags;
                    _isBold = bold;
                    _isItalic = italic;
                  });
                  _tabController.animateTo(0);
                },
                child: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _deleteEntry(entry['id']),
                child: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: tags.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: teal.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('#$t', style: const TextStyle(fontSize: 11, color: teal, fontWeight: FontWeight.w600)),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPagination() {
    if (_totalPages <= 1) return const SizedBox();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
          icon: const Icon(Icons.chevron_left_rounded),
          color: _currentPage > 0 ? navy : Colors.grey,
        ),
        ...List.generate(_totalPages, (i) => GestureDetector(
          onTap: () => setState(() => _currentPage = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: i == _currentPage ? navy : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: i == _currentPage ? navy : Colors.grey.shade300),
            ),
            child: Center(child: Text('${i + 1}', style: TextStyle(color: i == _currentPage ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13))),
          ),
        )),
        IconButton(
          onPressed: _currentPage < _totalPages - 1 ? () => setState(() => _currentPage++) : null,
          icon: const Icon(Icons.chevron_right_rounded),
          color: _currentPage < _totalPages - 1 ? navy : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: teal.withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(Icons.edit_note_rounded, size: 56, color: teal),
          ),
          const SizedBox(height: 16),
          const Text('No entries yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 8),
          Text('Start tracking your daily wellness journey', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  CALENDAR TAB
  // ══════════════════════════════════════════════
  Widget _buildCalendarTab() {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final startOffset = (firstDay.weekday % 7); // Sun=0

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)],
            ),
            child: Column(
              children: [
                // Month navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1)),
                      icon: const Icon(Icons.chevron_left_rounded, color: navy, size: 28),
                    ),
                    Text(
                      '${_monthName(_focusedDay.month)} ${_focusedDay.year}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: navy),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1)),
                      icon: const Icon(Icons.chevron_right_rounded, color: navy, size: 28),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Day headers
                GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                      .map((d) => Center(child: Text(d, style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 12))))
                      .toList(),
                ),

                const SizedBox(height: 4),

                // Calendar grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
                  itemCount: startOffset + daysInMonth,
                  itemBuilder: (_, i) {
                    if (i < startOffset) return const SizedBox();
                    final day = i - startOffset + 1;
                    final date = DateTime(_focusedDay.year, _focusedDay.month, day);
                    final dayKey = date.toIso8601String().split('T').first;
                    final hasEntry = _dayMap.containsKey(dayKey);
                    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                    final isSelected = _selectedDay != null &&
                        date.year == _selectedDay!.year &&
                        date.month == _selectedDay!.month &&
                        date.day == _selectedDay!.day;

                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedDay = isSelected ? null : date;
                        _currentPage = 0;
                        if (!isSelected) _tabController.animateTo(0);
                      }),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected ? navy : isToday ? teal.withOpacity(0.1) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                color: isSelected ? Colors.white : isToday ? teal : Colors.grey[700],
                                fontWeight: (isToday || isSelected) ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                            if (hasEntry)
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : teal,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Mood stats
          _buildMoodStats(),
        ],
      ),
    );
  }

  Widget _buildMoodStats() {
    // Aggregate mood counts
    final moodCounts = <String, int>{};
    for (final e in _allEntries) {
      final m = e['mood']?.toString() ?? 'happy';
      moodCounts[m] = (moodCounts[m] ?? 0) + 1;
    }
    if (moodCounts.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mood Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: navy)),
          const SizedBox(height: 14),
          ...moodCounts.entries.map((entry) {
            final pct = entry.value / _allEntries.length;
            final mData = _moods.firstWhere((m) => m['key'] == entry.key, orElse: () => {'emoji': '😐', 'label': entry.key, 'color': Colors.grey});
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(mData['emoji'], style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  SizedBox(width: 60, child: Text(mData['label'] as String, style: const TextStyle(fontSize: 13, color: navy))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 7,
                        backgroundColor: (mData['color'] as Color).withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(mData['color'] as Color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${entry.value}', style: TextStyle(color: (mData['color'] as Color), fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = ['', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'];
    return names[m];
  }

  // ══════════════════════════════════════════════
  //  TO-DO TAB
  // ══════════════════════════════════════════════
  Widget _buildTodoTab() {
    final pending = _todos.where((t) => !(t['done'] as bool)).toList();
    final done = _todos.where((t) => t['done'] as bool).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [teal.withOpacity(0.15), teal.withOpacity(0.05)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Today\'s Tasks', style: TextStyle(fontWeight: FontWeight.w900, color: navy, fontSize: 17)),
                    Text('${done.length}/${_todos.length} done',
                        style: const TextStyle(color: teal, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _todos.isEmpty ? 0 : done.length / _todos.length,
                    minHeight: 8,
                    backgroundColor: teal.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation(teal),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Add task
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoCtrl,
                    onSubmitted: (_) => _addTodo(),
                    decoration: const InputDecoration(
                      hintText: 'Add a wellness task...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _addTodo,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: navy, shape: BoxShape.circle),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick add suggestions
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'Drink 3L water', 'Take meds', '30-min walk', 'Apply sunscreen', '8h sleep',
                'No junk food', 'Journaling', 'Skincare routine',
              ].map((s) => GestureDetector(
                onTap: () {
                  _todoCtrl.text = s;
                  _addTodo();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: teal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: teal.withOpacity(0.2)),
                  ),
                  child: Text('+ $s', style: const TextStyle(color: teal, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              )).toList(),
            ),
          ),

          const SizedBox(height: 20),

          if (pending.isNotEmpty) ...[
            const Text('Pending', style: TextStyle(fontWeight: FontWeight.bold, color: navy, fontSize: 15)),
            const SizedBox(height: 10),
            ...pending.map((t) => _buildTodoItem(t)),
          ],

          if (done.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Completed ✅', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 15)),
            const SizedBox(height: 10),
            ...done.map((t) => _buildTodoItem(t)),
          ],

          if (_todos.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.checklist_rounded, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('No tasks yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: navy)),
                    Text('Add wellness tasks above or use quick suggestions', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _addTodo() {
    final text = _todoCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _todos.add({'text': text, 'done': false, 'id': DateTime.now().toIso8601String()});
      _todoCtrl.clear();
    });
  }

  Widget _buildTodoItem(Map<String, dynamic> todo) {
    final done = todo['done'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: done ? Colors.grey.shade300 : teal, width: 3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => todo['done'] = !done),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: done ? teal : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: done ? teal : Colors.grey.shade400, width: 2),
              ),
              child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              todo['text'],
              style: TextStyle(
                color: done ? Colors.grey : navy,
                decoration: done ? TextDecoration.lineThrough : null,
                fontSize: 14,
                fontWeight: done ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _todos.remove(todo)),
            child: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
