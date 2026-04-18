import 'package:flutter/material.dart';
import '../data/faq_data.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PREMIUM CLINICAL DETAIL — Face Intelligence Deep Knowledge
// ═══════════════════════════════════════════════════════════════════════════

class FaceFaqDetailScreen extends StatelessWidget {
  final FaqCategory category;

  const FaceFaqDetailScreen({super.key, required this.category});

  static const Color navy     = Color(0xFF0F172A);
  static const Color azure    = Color(0xFF3B82F6);
  static const Color slate    = Color(0xFF64748B);
  static const Color bg       = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverHeader(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildFaqItemTile(category.items[i], i),
                childCount: category.items.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: navy,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(category.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.2)),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(decoration: BoxDecoration(gradient: LinearGradient(colors: category.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight))),
            Positioned(right: -30, bottom: -30, child: Icon(category.icon, size: 160, color: Colors.white.withOpacity(0.1))),
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(20)),
                child: Text("${category.items.length} Intelligence Points", style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItemTile(FaqItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: slate.withOpacity(0.08)),
        boxShadow: [BoxShadow(color: navy.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: azure.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
          child: Icon(item.icon, color: azure, size: 22),
        ),
        title: Text(item.question, style: const TextStyle(color: navy, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
        iconColor: azure,
        collapsedIconColor: slate,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        expandedAlignment: Alignment.topLeft,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: slate.withOpacity(0.05))),
            child: Text(
              item.answer,
              style: const TextStyle(color: slate, fontSize: 14, height: 1.6, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
