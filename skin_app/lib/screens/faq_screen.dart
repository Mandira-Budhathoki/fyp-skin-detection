import 'package:flutter/material.dart';
import '../data/faq_data.dart';
import 'faq_detail_screen.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _searchQuery = "";
  int _selectedCategoryIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<FaqCategory> get filteredCategories {
    List<FaqCategory> filtered = skinFaqData;
    if (_selectedCategoryIndex != -1) {
      filtered = [skinFaqData[_selectedCategoryIndex]];
    }
    if (_searchQuery.isNotEmpty) {
      return filtered.where((cat) => 
        cat.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        cat.items.any((item) => 
          item.question.toLowerCase().contains(_searchQuery.toLowerCase())
        )
      ).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildSearchAndFilter()),
          _buildFaqList(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF264653),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
        title: const Text(
          'Skin Health Guide',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF264653), Color(0xFF2A9D8F)],
                ),
              ),
            ),
            Positioned(
              right: -30,
              top: -10,
              child: Icon(Icons.spa_rounded, size: 180, color: Colors.white.withOpacity(0.05)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: "What are you looking for?",
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF2A9D8F), size: 22),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: skinFaqData.length + 1,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index - 1;
                final title = index == 0 ? "All Topics" : skinFaqData[index - 1].title;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategoryIndex = index - 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2A9D8F) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected ? [
                          BoxShadow(color: const Color(0xFF2A9D8F).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                        ] : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqList() {
    final categories = filteredCategories;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = categories[index];
            return _buildCategoryCard(context, category, index);
          },
          childCount: categories.length,
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, FaqCategory category, int index) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: Interval((index / 10).clamp(0, 1), 1, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval((index / 10).clamp(0, 1), 1, curve: Curves.easeOutQuart),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 2), // Ring effect
            boxShadow: [
              BoxShadow(
                color: category.gradient.last.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FaqDetailScreen(category: category)),
                );
              },
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: category.gradient),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(category.icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${category.items.length} Essential Guides",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
