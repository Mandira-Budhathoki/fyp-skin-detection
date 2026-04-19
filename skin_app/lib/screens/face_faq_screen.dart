import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/faq_data.dart';
import '../data/face_faq_data.dart';
import 'face_faq_detail_screen.dart';

class FaceFaqScreen extends StatefulWidget {
  const FaceFaqScreen({super.key});

  @override
  State<FaceFaqScreen> createState() => _FaceFaqScreenState();
}

class _FaceFaqScreenState extends State<FaceFaqScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  String _searchQuery = '';
  int _selectedCategoryIndex = -1;

  // Premium 'Au' Gold & Earth Palette
  static const Color navy     = Color(0xFF8B7355); // Rich Earth
  static const Color azure    = Color(0xFFC5A059); // Au Gold
  static const Color slate    = Color(0xFF9E8E77); // Muted Gold
  static const Color bg       = Color(0xFFFBF9F4); // Cream Paper
  static const Color surface  = Colors.white;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
    _mainController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  List<FaqCategory> get _filtered {
    List<FaqCategory> list = _selectedCategoryIndex == -1
        ? faceFaqData
        : [faceFaqData[_selectedCategoryIndex]];

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
          // Dynamic Pulsating Background (Twists & Turns)
          Positioned.fill(child: _buildDynamicBackground()),
          
          Positioned.fill(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildModernSliverHeader(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildNeoSearchBar(),
                      _buildScrollableCategories(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: _filtered.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => _buildTwistedFaceCard(_filtered[i], i),
                            childCount: _filtered.length,
                          ),
                        ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicBackground() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, _) {
        return Stack(
          children: [
            Positioned(
              top: -100 + (_mainController.value * 50),
              right: -50 + (_mainController.value * 30),
              child: _blurCircle(azure.withOpacity(0.12), 350),
            ),
            Positioned(
              bottom: 100 - (_mainController.value * 40),
              left: -80 + (_mainController.value * 20),
              child: _blurCircle(navy.withOpacity(0.08), 400),
            ),
          ],
        );
      },
    );
  }

  Widget _blurCircle(Color c, double s) => Container(width: s, height: s, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  Widget _buildModernSliverHeader() {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      elevation: 0,
      backgroundColor: navy,
      leading: Padding(
        padding: const EdgeInsets.all(12),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [navy, Color(0xFF5D4D37)], 
                  begin: Alignment.bottomRight, 
                  end: Alignment.topLeft
                )
              )
            ),
            Positioned(
              right: -40, top: -20,
              child: Transform.rotate(
                angle: -0.2,
                child: Container(width: 200, height: 350, decoration: BoxDecoration(color: azure.withOpacity(0.05), borderRadius: BorderRadius.circular(80))),
              ),
            ),
            Positioned(left: 24, bottom: 40, right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: azure.withOpacity(0.3), borderRadius: BorderRadius.circular(30), border: Border.all(color: azure.withOpacity(0.5))),
                    child: const Text("GOLD CLINICAL", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ),
                  const SizedBox(height: 16),
                  const Flexible(
                    child: Text(
                      "Premium Facial\nArchive", 
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -1.2)
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Trusted wisdom for natural beauty.", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeoSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: azure.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: navy.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: "Search premium health reports...",
          hintStyle: TextStyle(color: slate.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w600),
          prefixIcon: const Icon(Icons.search_rounded, color: azure, size: 24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildScrollableCategories() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: faceFaqData.length + 1,
        itemBuilder: (ctx, i) {
          final isSelected = _selectedCategoryIndex == i - 1;
          final label = i == 0 ? "General Care" : faceFaqData[i - 1].title;

          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = i - 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? navy : Colors.white70,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? Colors.transparent : slate.withOpacity(0.3)),
                ),
                child: Text(label, style: TextStyle(color: isSelected ? Colors.white : navy, fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTwistedFaceCard(FaqCategory cat, int index) {
    final bool isLeft = index % 2 == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isLeft ? 40 : 16),
          topRight: Radius.circular(isLeft ? 16 : 40),
          bottomLeft: Radius.circular(isLeft ? 16 : 40),
          bottomRight: Radius.circular(isLeft ? 40 : 16),
        ),
        boxShadow: [BoxShadow(color: navy.withOpacity(0.08), blurRadius: 25, offset: const Offset(0, 10))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FaceFaqDetailScreen(category: cat))),
          borderRadius: BorderRadius.circular(40),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: cat.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(cat.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cat.title, style: const TextStyle(color: Color(0xFF5D4037), fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -1)),
                      const SizedBox(height: 6),
                      Text("${cat.items.length} Knowledge Cells", style: const TextStyle(color: azure, fontSize: 12, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: navy.withOpacity(0.3), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(60),
      child: Column(
        children: [
          Icon(Icons.face_retouching_off_rounded, size: 90, color: azure.withOpacity(0.2)),
          const SizedBox(height: 24),
          const Text("Lost in Thought", textAlign: TextAlign.center, style: TextStyle(color: navy, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 10),
          const Text("No matches found in our clinical facial repository.", textAlign: TextAlign.center, style: TextStyle(color: slate, fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
