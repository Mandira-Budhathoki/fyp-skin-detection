import 'package:flutter/material.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool isSearchMode = true;
  String selectedCategory = "All Items";
  String searchQuery = "";

  final List<Map<String, String>> allProducts = [
    {
      "n": "Hydro Boost Water Gel",
      "brand": "Neutrogena",
      "t": "Moisturizer",
      "s": "100/100",
      "d": "Hydrates & plumps skin with Hyaluronic Acid.",
      "img": "assets/products/prod_neutrogena_gel.webp",
    },
    {
      "n": "Moisturizing Cream",
      "brand": "CeraVe",
      "t": "Moisturizer",
      "s": "100/100",
      "d": "With ceramides & hyaluronic acid for dry skin.",
      "img": "assets/products/prod_cerave_cream.jpg",
    },
    {
      "n": "Toleriane Double Repair",
      "brand": "La Roche-Posay",
      "t": "Moisturizer",
      "s": "98/100",
      "d": "Restores skin barrier with ceramides & niacinamide.",
      "img": "assets/products/prod_lrp_toleriane.jpg",
    },
    {
      "n": "Hyaluronic Acid 2% + B5",
      "brand": "The Ordinary",
      "t": "Serum",
      "s": "100/100",
      "d": "Deep hydration serum with 2% hyaluronic acid.",
      "img": "assets/products/prod_ordinary_ha.jpg",
    },
    {
      "n": "Niacinamide 10% + Zinc",
      "brand": "The Ordinary",
      "t": "Serum",
      "s": "100/100",
      "d": "Reduces blemishes and pore appearance.",
      "img": "assets/products/prod_ordinary_niac.jpg",
    },
    {
      "n": "2% BHA Liquid Exfoliant",
      "brand": "Paula's Choice",
      "t": "Serum",
      "s": "97/100",
      "d": "Unclogs pores and smooths skin texture.",
      "img": "assets/products/prod_paulas_choice.jpg",
    },
    {
      "n": "Snail Mucin 96% Essence",
      "brand": "COSRX",
      "t": "Ampoule",
      "s": "100/100",
      "d": "Repairs & hydrates with 96% snail secretion.",
      "img": "assets/products/prod_cosrx_snail.png",
    },
    {
      "n": "Gentle Skin Cleanser",
      "brand": "Cetaphil",
      "t": "Cleanser",
      "s": "100/100",
      "d": "Soap-free, fragrance-free daily face wash.",
      "img": "assets/products/prod_cetaphil_cleanser.png",
    },
    {
      "n": "Sensibio H2O Micellar Water",
      "brand": "Bioderma",
      "t": "Cleanser",
      "s": "98/100",
      "d": "No-rinse micellar cleanser for sensitive skin.",
      "img": "assets/products/prod_bioderma_micellar.jpg",
    },
    {
      "n": "UV Clear SPF 46",
      "brand": "EltaMD",
      "t": "Sunscreen",
      "s": "100/100",
      "d": "Dermatologist-recommended mineral sunscreen.",
      "img": "assets/products/prod_eltamd_spf.jpg",
    },
    {
      "n": "Ultra Sheer SPF 50",
      "brand": "Neutrogena",
      "t": "Sunscreen",
      "s": "97/100",
      "d": "Lightweight, non-greasy daily UV protection.",
      "img": "assets/products/prod_neutrogena_spf.jpg",
    },
    {
      "n": "Jeju Volcanic Clay Mask",
      "brand": "Innisfree",
      "t": "Clay mask",
      "s": "96/100",
      "d": "Deep-cleansing pore clay mask from Jeju island.",
      "img": "assets/products/prod_innisfree_mask.jpg",
    },
  ];

  List<Map<String, String>> get filteredProducts {
    return allProducts.where((p) {
      if (!isSearchMode && !p['s']!.contains("100/100")) return false;
      if (selectedCategory != "All Items" && p['t'] != selectedCategory) return false;
      if (searchQuery.isNotEmpty &&
          !p['n']!.toLowerCase().contains(searchQuery.toLowerCase()) &&
          !p['brand']!.toLowerCase().contains(searchQuery.toLowerCase())) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const sageGreen = Color(0xFF71A877);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Skincare Products',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          // ── TOGGLE ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 50,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F0), borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  _toggleBtn("All Products", isSearchMode, () => setState(() => isSearchMode = true)),
                  _toggleBtn("Top Picks", !isSearchMode, () => setState(() => isSearchMode = false)),
                ],
              ),
            ),
          ),

          // ── SEARCH BAR ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.black.withOpacity(0.07))),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: const InputDecoration(
                    hintText: "Search product or brand...",
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey, size: 20)),
              ),
            ),
          ),

          // ── CATEGORY CHIPS ──
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: ["All Items", "Sunscreen", "Moisturizer", "Serum", "Cleanser", "Ampoule", "Clay mask"]
                  .map((c) => _catChip(c, sageGreen))
                  .toList(),
            ),
          ),

          // ── PRODUCT GRID ──
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
                    child: Text("No products found.",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)))
                : GridView.builder(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.72),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) => _productCard(filteredProducts[index], sageGreen),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool isActive, VoidCallback tap) {
    return Expanded(
      child: GestureDetector(
        onTap: tap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: isActive ? const Color(0xFF71A877) : Colors.transparent,
              borderRadius: BorderRadius.circular(10)),
          child: Text(label,
              style: TextStyle(
                  color: isActive ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ),
      ),
    );
  }

  Widget _catChip(String label, Color accent) {
    bool isSel = selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 10, bottom: 4, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: isSel ? accent : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSel ? accent : Colors.black.withOpacity(0.08))),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSel ? Colors.white : Colors.black87)),
      ),
    );
  }

  Widget _productCard(Map<String, String> p, Color accent) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP ROW ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                      color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(p['t']!,
                      style: TextStyle(color: accent, fontSize: 8, fontWeight: FontWeight.w900)),
                ),
                const Icon(Icons.favorite_border_rounded, size: 16, color: Colors.black26),
              ],
            ),
          ),

          // ── PRODUCT IMAGE ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  p['img']!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFF5F5F5),
                    child: const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 30),
                  ),
                ),
              ),
            ),
          ),

          // ── PRODUCT INFO ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['brand']!,
                    style: const TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w700, color: Colors.grey)),
                Text(p['n']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: accent.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text("✓ ${p['s']}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
