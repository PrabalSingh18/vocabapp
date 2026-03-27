import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'db_service.dart';
import 'word_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final DBService _dbService = DBService();
  
  List<Map<String, dynamic>> _allSavedWords = []; 
  List<Map<String, dynamic>> _filteredWords = []; 
  
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); 
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final data = await _dbService.getFavorites();
      
      if (mounted) {
        setState(() {
          _allSavedWords = List.from(data);
          _filteredWords = _allSavedWords;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading favorites: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _runFilter(String query) {
    List<Map<String, dynamic>> results = [];
    if (query.isEmpty) {
      results = _allSavedWords;
    } else {
      results = _allSavedWords
          .where((item) =>
              item['word'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredWords = results;
    });
  }

  Future<void> _deleteWord(String word, int index) async {
    await _dbService.deleteFavorite(word);
    if (!mounted) return; 
    
    _loadFavorites();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$word removed'), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('SAVED WORDS', 
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          if (_allSavedWords.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              onPressed: () => _showClearAllDialog(),
            )
        ],
      ),
      body: Column(
        children: [
          if (_allSavedWords.isNotEmpty) _buildSearchField(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
                : _filteredWords.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredWords.length,
                        itemBuilder: (context, index) {
                          final item = _filteredWords[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildDismissibleTile(item, index),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _runFilter(value),
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: "Search saved words...",
          prefixIcon: const Icon(Icons.search, color: Colors.black38),
          suffixIcon: _searchController.text.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear), 
                onPressed: () {
                  _searchController.clear();
                  _runFilter('');
                }) 
            : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDismissibleTile(Map<String, dynamic> item, int index) {
    return Dismissible(
      key: Key(item['word']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) => _deleteWord(item['word'], index),
      child: _buildFavoriteTile(item, index),
    );
  }

  Widget _buildFavoriteTile(Map<String, dynamic> item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        title: Text(item['word'].toString().toUpperCase(),
          style: GoogleFonts.sourceSerif4(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(item['meaning'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WordDetailPage(word: item['word']))),
      ),
    );
  }


  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text("Clear All?"),
        content: const Text("This will remove all saved words."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(innerContext), child: const Text("CANCEL")),
          TextButton(onPressed: () async {
            await _dbService.clearAllFavorites();
            if (!innerContext.mounted) return;
            Navigator.pop(innerContext);
            _loadFavorites();
          }, child: const Text("CLEAR ALL")),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(_searchController.text.isEmpty ? "Your list is empty" : "No matches found", 
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
