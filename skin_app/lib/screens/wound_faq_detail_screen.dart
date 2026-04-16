import 'package:flutter/material.dart';
import '../data/faq_data.dart';

class WoundFaqDetailScreen extends StatelessWidget {
  final FaqCategory category;

  const WoundFaqDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F8),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 170.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF2C687B),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                category.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  letterSpacing: -0.3,
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF8CC7C4), Color(0xFF2C687B)],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      category.icon,
                      size: 140,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 60,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${category.items.length} Questions',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = category.items[index];
                  return _buildFaqItemCard(context, item, index);
                },
                childCount: category.items.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItemCard(BuildContext context, FaqItem item, int index) {
    // Alternating accent colors for visual interest
    final accents = [
      const Color(0xFF8CC7C4),
      const Color(0xFF2C687B),
      const Color(0xFFE07B54),
      const Color(0xFF5B8DB8),
    ];
    final accent = accents[index % accents.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          leading: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: accent, size: 22),
          ),
          title: Text(
            item.question,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
              color: Color(0xFF1E293B),
              letterSpacing: -0.2,
            ),
          ),
          iconColor: accent,
          collapsedIconColor: const Color(0xFF94A3B8),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(0.06), accent.withOpacity(0.02)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withOpacity(0.1)),
                ),
                child: Text(
                  item.answer,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF475569),
                    height: 1.65,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
