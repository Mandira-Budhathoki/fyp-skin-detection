import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({Key? key}) : super(key: key);

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> with SingleTickerProviderStateMixin {
  static const Color navy = Color(0xFF1B263B);
  static const Color teal = Color(0xFF2A9D8F);
  static const Color orange = Color(0xFFE76F51);
  static const Color purple = Color(0xFF7C5CBF);
  static const Color bg = Color(0xFFF8FAFB);

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  String _error = '';
  List<Map<String, dynamic>> _articles = [];
  String _activeCategory = 'Skin';
  String _searchQuery = '';

  static const List<Map<String, dynamic>> _categories = [
    {'label': 'Skin', 'query': 'skin health dermatology', 'icon': Icons.face_retouching_natural_rounded, 'color': Color(0xFF2A9D8F)},
    {'label': 'Wound', 'query': 'wound healing treatment', 'icon': Icons.healing_rounded, 'color': Color(0xFFE76F51)},
    {'label': 'Melanoma', 'query': 'melanoma skin cancer detection', 'icon': Icons.biotech_rounded, 'color': Color(0xFF7C5CBF)},
    {'label': 'Nutrition', 'query': 'nutrition skin health diet', 'icon': Icons.restaurant_rounded, 'color': Color(0xFFFFB700)},
    {'label': 'UV & Sun', 'query': 'UV protection sunscreen skin', 'icon': Icons.wb_sunny_rounded, 'color': Color(0xFFFF6B6B)},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final cat = _categories[_tabController.index];
        setState(() => _activeCategory = cat['label']);
        _fetchArticles(cat['query']);
      }
    });
    _fetchArticles(_categories[0]['query']);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchArticles(String query) async {
    setState(() { _isLoading = true; _error = ''; _articles = []; });

    try {
      // Use PubMed eSearch + eSummary (free, no API key needed)
      final searchUrl = Uri.parse(
        'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi'
        '?db=pubmed&term=${Uri.encodeComponent(query)}&retmax=10&retmode=json&sort=relevance',
      );

      final searchRes = await http.get(searchUrl, headers: {'User-Agent': 'SkinCareApp/1.0'})
          .timeout(const Duration(seconds: 15));

      if (searchRes.statusCode != 200) throw Exception('Search failed');

      final searchData = jsonDecode(searchRes.body);
      final List<dynamic> ids = searchData['esearchresult']['idlist'] ?? [];

      if (ids.isEmpty) {
        setState(() { _articles = []; _isLoading = false; });
        return;
      }

      final idStr = ids.take(10).join(',');
      final summaryUrl = Uri.parse(
        'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi'
        '?db=pubmed&id=$idStr&retmode=json',
      );

      final summaryRes = await http.get(summaryUrl, headers: {'User-Agent': 'SkinCareApp/1.0'})
          .timeout(const Duration(seconds: 15));

      if (summaryRes.statusCode != 200) throw Exception('Summary failed');

      final summaryData = jsonDecode(summaryRes.body);
      final result = summaryData['result'] as Map<String, dynamic>;
      final uids = result['uids'] as List<dynamic>;

      final articles = uids.map((uid) {
        final item = result[uid.toString()];
        final authors = (item['authors'] as List<dynamic>?)
            ?.take(2)
            .map((a) => a['name'])
            .join(', ') ?? 'Unknown Author';
        final source = item['source'] ?? 'PubMed';
        final pubDate = item['pubdate'] ?? '';
        return {
          'id': uid.toString(),
          'title': item['title'] ?? 'Untitled',
          'authors': authors,
          'source': source,
          'date': pubDate,
          'url': 'https://pubmed.ncbi.nlm.nih.gov/$uid/',
          'abstract': null, // loaded on demand
        };
      }).where((a) => (a['title'] as String).isNotEmpty).toList();

      setState(() { _articles = articles; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Could not fetch articles. Check your connection.'; _isLoading = false; });
    }
  }

  Future<void> _fetchAbstract(String pmid) async {
    try {
      final url = Uri.parse(
        'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi'
        '?db=pubmed&id=$pmid&retmode=text&rettype=abstract',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final text = res.body;
        final idx = _articles.indexWhere((a) => a['id'] == pmid);
        if (idx >= 0 && mounted) {
          setState(() => _articles[idx]['abstract'] = text.length > 600 ? text.substring(0, 600) + '...' : text);
        }
      }
    } catch (_) {}
  }

  void _search() {
    final q = _searchController.text.trim();
    if (q.isEmpty) return;
    setState(() => _searchQuery = q);
    _fetchArticles(q);
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
        title: const Text('Health Articles', style: TextStyle(color: navy, fontWeight: FontWeight.w900, fontSize: 20)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.search_rounded, color: Colors.grey, size: 22),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (_) => _search(),
                          decoration: const InputDecoration(
                            hintText: 'Search any medical topic...',
                            hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _search,
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(12)),
                          child: const Text('Search', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Category tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: navy,
                unselectedLabelColor: Colors.grey,
                indicatorColor: teal,
                indicatorWeight: 3,
                tabs: _categories.map((c) => Tab(
                  child: Row(
                    children: [
                      Icon(c['icon'] as IconData, size: 16),
                      const SizedBox(width: 6),
                      Text(c['label'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: teal, strokeWidth: 3),
            const SizedBox(height: 16),
            Text('Fetching articles from PubMed...', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final cat = _categories.firstWhere((c) => c['label'] == _activeCategory);
                _fetchArticles(cat['query']);
              },
              style: ElevatedButton.styleFrom(backgroundColor: teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_articles.isEmpty) {
      return const Center(child: Text('No articles found.', style: TextStyle(color: Colors.grey)));
    }

    final catColor = (_categories.firstWhere(
      (c) => c['label'] == _activeCategory,
      orElse: () => {'color': teal},
    )['color'] as Color);

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _articles.length,
      itemBuilder: (_, i) {
        final article = _articles[i];
        return _buildArticleCard(article, catColor, i);
      },
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article, Color catColor, int index) {
    final hasAbstract = article['abstract'] != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (expanded) {
            if (expanded && article['abstract'] == null) {
              _fetchAbstract(article['id']);
            }
          },
          tilePadding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: catColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: catColor)),
            ),
          ),
          title: Text(
            article['title'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: navy, height: 1.3),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(Icons.article_outlined, size: 13, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${article['source']} • ${article['date']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          children: [
            if (article['authors'] != null && article['authors'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(child: Text(article['authors'], style: const TextStyle(fontSize: 12, color: Colors.grey))),
                  ],
                ),
              ),
            hasAbstract
                ? Text(article['abstract'], style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5))
                : const Row(
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: teal)),
                      SizedBox(width: 10),
                      Text('Loading abstract...', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
            const SizedBox(height: 14),
            // Open in browser
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Visit: ${article['url']}'),
                  backgroundColor: catColor,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: catColor.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_new_rounded, size: 16, color: catColor),
                    const SizedBox(width: 8),
                    Text('Read on PubMed', style: TextStyle(color: catColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
