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

  // 35 AUTHENTIC PRODUCT PLACEHOLDERS (ENSURING HIGH DENSITY)
  final List<Map<String, String>> allProducts = List.generate(35, (i) {
    String type = ["Sunscreen", "Moisturizer", "Serum", "Cleanser", "Ampoule", "Clay mask"][i % 6];
    // FORCE AT LEAST 50% TO BE TOP-TIER 100/100 FOR RECOMMENDED TAB
    String score = (i % 2 == 0) ? "100/100" : (95 + (i % 3)).toString() + "/100";
    return {
      "n": "$type Layer ${i + 1}",
      "t": type,
      "s": score,
      "d": "Daily $type routine verified."
    };
  });

  List<Map<String, String>> get filteredProducts {
    return allProducts.where((p) {
      // 1. FILTER BY TOGGLE (SHOW PERFECT & HIGH SCORES IN RECOMMENDED)
      if (!isSearchMode && !p['s']!.contains("100/100")) return false;
      
      // 2. FILTER BY CATEGORY
      if (selectedCategory != "All Items" && p['t'] != selectedCategory) return false;

      // 3. FILTER BY SEARCH QUERY
      if (searchQuery.isNotEmpty && !p['n']!.toLowerCase().contains(searchQuery.toLowerCase())) return false;

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const sageGreen = Color(0xFF71A877);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Products', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontFamily: 'Serif')),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          // ── FUNCTIONAL TOGGLE ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 55,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  _toggleBtn("Search", isSearchMode, () => setState(() => isSearchMode = true)),
                  _toggleBtn("Recommended", !isSearchMode, () => setState(() => isSearchMode = false)),
                ],
              ),
            ),
          ),

          // ── FUNCTIONAL SEARCH BAR ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.black.withOpacity(0.05))),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: const InputDecoration(hintText: "Search product...", border: InputBorder.none, icon: Icon(Icons.search, color: Colors.grey)),
              ),
            ),
          ),

          // ── FUNCTIONAL CATEGORY FILTER ──
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: ["All Items", "Sunscreen", "Moisturizer", "Serum", "Cleanser", "Ampoule", "Clay mask"].map((c) => _catChip(c)).toList(),
            ),
          ),

          // ── DYNAMIC GRID ──
          Expanded(
            child: filteredProducts.isEmpty 
              ? const Center(child: Text("No compatible products found.", style: TextStyle(color: Colors.grey)))
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20, childAspectRatio: 0.75),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) => _productCard(filteredProducts[index]),
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
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: isActive ? const Color(0xFF71A877) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _catChip(String label) {
    bool isSel = selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(left: 10, bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(color: isSel ? const Color(0xFFF5F5F5) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withOpacity(0.08))),
        child: Center(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87))),
      ),
    );
  }

  Widget _productCard(Map<String, String> p) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(12), child: Icon(Icons.favorite_border_rounded, size: 18, color: Colors.black.withOpacity(0.3))),
          // PLACEHOLDER IMAGE
          Expanded(
            child: Center(
              child: Container(
                width: 60, height: 80,
                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black.withOpacity(0.05))),
                child: const Icon(Icons.image_outlined, color: Colors.grey, size: 25),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF71A877).withOpacity(0.7), borderRadius: BorderRadius.circular(6)), child: Text("Safety: ${p['s']}", style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                Text(p['d']!, style: const TextStyle(fontSize: 8, color: Colors.grey)),
                Text(p["n"]!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black87)),
                const Text("Verified Match", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF71A877))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
