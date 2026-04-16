import 'package:flutter/material.dart';
import '../data/faq_data.dart';
import '../data/wound_faq_data.dart';
import 'wound_faq_detail_screen.dart';

// Palette of card colors for categories (4 alternating colors)
const List<List<Color>> _kCardPalettes = [
  [Color(0xFF8CC7C4), Color(0xFF6AADAA)],   // Teal
  [Color(0xFF2C687B), Color(0xFF1E4F5F)],   // Deep Teal
  [Color(0xFFE07B54), Color(0xFFBF5F3C)],   // Warm Orange
  [Color(0xFF5B8DB8), Color(0xFF3D6E99)],   // Calm Blue
];

// Emoji per category
const List<String> _kCategoryEmojis = ['🩹', '📈', '⚠️', '🧰', '✨', '🥗'];

class WoundFaqScreen extends StatefulWidget {
  const WoundFaqScreen({super.key});

  @override
  State<WoundFaqScreen> createState() => _WoundFaqScreenState();
}

class _WoundFaqScreenState extends State<WoundFaqScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _searchQuery = '';
  int _selectedCategoryIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<FaqCategory> get _filtered {
    List<FaqCategory> list = _selectedCategoryIndex == -1
        ? woundFaqData
        : [woundFaqData[_selectedCategoryIndex]];

    if (_searchQuery.isNotEmpty) {
      list = list
          .map((cat) {
            final items = cat.items
                .where((i) =>
                    i.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    i.answer.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();
            return FaqCategory(
                title: cat.title, icon: cat.icon, gradient: cat.gradient, items: items);
          })
          .where((cat) => cat.items.isNotEmpty)
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroHeader(),
            const SizedBox(height: 12),
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildCategoryChips(),
            const SizedBox(height: 4),
            Expanded(
              child: _filtered.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) {
                        final realIndex = woundFaqData.indexOf(_filtered[i]);
                        return _buildCategoryCard(_filtered[i], realIndex, i);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8CC7C4), Color(0xFF2C687B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Wound FAQs',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '🩺 Your complete wound care knowledge base',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _statPill('${woundFaqData.length}', 'Topics'),
              const SizedBox(width: 8),
              _statPill(
                '${woundFaqData.fold(0, (s, c) => s + c.items.length)}',
                'FAQs',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statPill(String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count $label',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))
          ],
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(fontSize: 14, color: Color(0xFF2D3436)),
          decoration: const InputDecoration(
            hintText: 'Search wound care topics...',
            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
            prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF8CC7C4), size: 22),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: woundFaqData.length + 1,
        itemBuilder: (ctx, i) {
          final selected = _selectedCategoryIndex == i - 1;
          final label = i == 0 ? 'All' : woundFaqData[i - 1].title;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = i - 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: [Color(0xFF8CC7C4), Color(0xFF2C687B)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color: selected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? Colors.transparent : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: const Color(0xFF8CC7C4).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF475569),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(FaqCategory category, int realIndex, int animIndex) {
    final palette = _kCardPalettes[realIndex % _kCardPalettes.length];
    final emoji = _kCategoryEmojis[realIndex % _kCategoryEmojis.length];
    final gradStart = palette[0];
    final gradEnd = palette[1];

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: Interval((animIndex / 10).clamp(0.0, 1.0), 1.0, curve: Curves.easeOut),
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WoundFaqDetailScreen(category: category)),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [gradStart, gradEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradStart.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Big emoji circle
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.items.length} clinical answers',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Preview chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: category.items
                            .take(2)
                            .map((item) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    item.question.length > 22
                                        ? '${item.question.substring(0, 22)}…'
                                        : item.question,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white, size: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search term',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
