import 'package:flutter/material.dart';
import '../data/faq_data.dart';
import '../data/wound_faq_data.dart';
import 'wound_faq_detail_screen.dart';

class WoundFaqScreen extends StatefulWidget {
  const WoundFaqScreen({super.key});

  @override
  State<WoundFaqScreen> createState() => _WoundFaqScreenState();
}

class _WoundFaqScreenState extends State<WoundFaqScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _searchQuery = "";
  int _selectedCategoryIndex = -1; // -1 for "All"

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
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
    List<FaqCategory> filtered = woundFaqData;
    
    if (_selectedCategoryIndex != -1) {
      filtered = [woundFaqData[_selectedCategoryIndex]];
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.map((cat) {
        final filteredItems = cat.items.where((item) {
          return item.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 item.answer.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
        
        return FaqCategory(
          title: cat.title,
          icon: cat.icon,
          gradient: cat.gradient,
          items: filteredItems,
        );
      }).where((cat) => cat.items.isNotEmpty).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Clinical Guide',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildTopSearchPanel(),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "TOPICS",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCategoryFilter(),
                      ],
                    ),
                  ),
                ),
                _buildFaqList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSearchPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          cursorColor: const Color(0xFF475569),
          style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B)),
          decoration: const InputDecoration(
            hintText: "Search medical conditions...",
            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
            prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: woundFaqData.length + 1,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index - 1;
          final title = index == 0 ? "All" : woundFaqData[index - 1].title;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index - 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFaqList() {
    final categories = filteredCategories;
    
    if (categories.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: Color(0xFFE2E8F0)),
              SizedBox(height: 16),
              Text(
                "No clinical records found",
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = categories[index];
            return _buildCategoryItem(category, index);
          },
          childCount: categories.length,
        ),
      ),
    );
  }

  Widget _buildCategoryItem(FaqCategory category, int index) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: Interval((index / 15).clamp(0, 1), 1.0, curve: Curves.easeOut),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WoundFaqDetailScreen(category: category),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: category.gradient.first.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(category.icon, color: category.gradient.first, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${category.items.length} clinical items",
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
