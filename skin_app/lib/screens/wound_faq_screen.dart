import 'package:flutter/material.dart';
import '../data/faq_data.dart';
import '../data/wound_faq_data.dart';
import 'wound_faq_detail_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PREMIUM CLINICAL WOUND FAQ — Modern, Professional, Trusted
// ═══════════════════════════════════════════════════════════════════════════

class WoundFaqScreen extends StatefulWidget {
  const WoundFaqScreen({super.key});

  @override
  State<WoundFaqScreen> createState() => _WoundFaqScreenState();
}

class _WoundFaqScreenState extends State<WoundFaqScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  String _searchQuery = '';
  int _selectedCategoryIndex = -1;

  // Modern Human-Centered Colors
  static const Color primary  = Color(0xFF8A7650); // Tuscan Brown
  static const Color sage     = Color(0xFF8E977D); // Sage
  static const Color navy     = Color(0xFF0F172A); // Deep Slate
  static const Color bg       = Color(0xFFF3E4C9); // Papaya Whip
  static const Color slate    = Color(0xFF64748B); // A neutral grey for text/borders
  static const Color surface  = Color(0xFFECE7D1); // Bone

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  List<FaqCategory> get _filtered {
    List<FaqCategory> list = _selectedCategoryIndex == -1
        ? woundFaqData
        : [woundFaqData[_selectedCategoryIndex]];

    if (_searchQuery.isNotEmpty) {
      list = list.map((cat) {
        final items = cat.items.where((i) =>
            i.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            i.answer.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
        return FaqCategory(title: cat.title, icon: cat.icon, gradient: cat.gradient, items: items);
      }).where((cat) => cat.items.isNotEmpty).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildPremiumHeader(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildSearchBar(),
                    _buildCategoryRow(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: _filtered.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _buildExpandableCategoryCard(_filtered[i], i),
                          childCount: _filtered.length,
                        ),
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          _buildFloatingSummary(),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      elevation: 0,
      backgroundColor: primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [navy, Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(right: -40, top: -40, child: Icon(Icons.masks_rounded, size: 200, color: Colors.white.withOpacity(0.05))),
            Positioned(left: 24, bottom: 40, right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(8)),
                    child: const Text("CLINICAL ARCHIVE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ),
                  const SizedBox(height: 12),
                  const Text("Wound Care FAQs", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                  const SizedBox(height: 6),
                  Text("Trusted medical guidance for advanced healing.", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: navy.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: "Search clinical topics...",
          hintStyle: TextStyle(color: slate, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: primary, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _searchQuery = '')) : null,
        ),
      ),
    );
  }

  Widget _buildCategoryRow() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: woundFaqData.length + 1,
        itemBuilder: (ctx, i) {
          final isAll = i == 0;
          final isSelected = _selectedCategoryIndex == i - 1;
          final label = isAll ? "All Topics" : woundFaqData[i - 1].title;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategoryIndex = val ? i - 1 : -1),
              backgroundColor: surface,
              selectedColor: primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : navy,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                fontSize: 12,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? Colors.transparent : slate.withOpacity(0.1))),
              showCheckmark: false,
              elevation: 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandableCategoryCard(FaqCategory cat, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: slate.withOpacity(0.08)),
        boxShadow: [BoxShadow(color: navy.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WoundFaqDetailScreen(category: cat))),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: cat.gradient),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(cat.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat.title, style: const TextStyle(color: navy, fontSize: 16, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text("${cat.items.length} Medical Insights", style: TextStyle(color: slate, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: slate, size: 14),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: cat.items.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.circle, color: primary.withOpacity(0.3), size: 6),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item.question, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: slate, fontSize: 13, fontWeight: FontWeight.w500))),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: primary.withOpacity(0.2)),
          const SizedBox(height: 20),
          const Text("No clinical data found", style: TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text("Try searching with different medical terms.", textAlign: TextAlign.center, style: TextStyle(color: slate, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFloatingSummary() {
    return Positioned(
      bottom: 24, left: 24, right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: navy,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: navy.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Knowledge base contains ${woundFaqData.fold(0, (s, c) => s + c.items.length)} medical answers",
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
            const Text("AI READY", style: TextStyle(color: primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}
