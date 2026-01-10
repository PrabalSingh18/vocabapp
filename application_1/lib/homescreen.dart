import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';

// Internal Architecture Imports
import 'services/word_repository.dart';
import 'constants.dart';
import 'wordmodel.dart';
import 'wordcard.dart';
import 'navbar.dart';
import 'atmospheric_background.dart'; 
import 'db_service.dart';
import 'word_detail_page.dart';
import 'audio_service.dart'; 
import 'theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WordRepository _repository = WordRepository();
  final DBService _dbService = DBService();
  
  List<WordData> _words = []; 
  bool _isLoading = true;
  bool _isLoadingMore = false; 
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _pageController.addListener(_scrollListener);
    _fetchDailyWords();
  }

  void _scrollListener() {
    if (_pageController.hasClients && _words.isNotEmpty) {
      final double? currentPage = _pageController.page;
      if (currentPage != null && currentPage >= _words.length - 2) {
        if (!_isLoading && !_isLoadingMore && _errorMessage == null) {
          _loadMoreWords();
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.removeListener(_scrollListener);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchDailyWords() async {
    if (!mounted) return;
    final vocabMode = Provider.of<ThemeProvider>(context, listen: false).vocabMode;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      List<WordData> words = (vocabMode == 'LexisPro') 
          ? await _repository.fetchLexisProWords() 
          : await _repository.fetchDailyWords();
      if (!mounted) return;
      setState(() { _words = words; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _errorMessage = AppStrings.errorNetwork; });
    }
  }

  Future<void> _loadMoreWords() async {
    if (_isLoadingMore) return;
    final vocabMode = Provider.of<ThemeProvider>(context, listen: false).vocabMode;
    setState(() => _isLoadingMore = true);
    try {
      List<WordData> newWords = (vocabMode == 'LexisPro') 
          ? await _repository.fetchLexisProWords() 
          : await _repository.fetchDailyWords();
      if (!mounted) return;
      setState(() { _words.addAll(newWords); _isLoadingMore = false; });
    } catch (e) { if (mounted) setState(() => _isLoadingMore = false); }
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    FocusManager.instance.primaryFocus?.unfocus(); 
    setState(() => _isLoading = true);
    try {
      final wordData = await _repository.fetchWordDetails(query.trim());
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (wordData != null) { _words = [wordData]; _errorMessage = null; } 
        else { _words = []; _errorMessage = "Word not found."; }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _errorMessage = AppStrings.errorNetwork; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 60; 
    
    return Scaffold(
      backgroundColor: Colors.transparent, 
      extendBodyBehindAppBar: true,
      extendBody: true, 
      appBar: _buildAppBar(),
      body: AtmosphericBackground( 
        child: Column(
          children: [
            SizedBox(height: topPadding), 
            _buildSearchBar(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _errorMessage != null 
                    ? _buildErrorState()
                    : _buildPageView(),
            ),
            // Created clear space for the toast to appear without overlapping card bottom
            const SizedBox(height: 130), 
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(AppConstants.appName, 
        style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w200, color: Colors.white.withValues(alpha: 0.9))
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
          onPressed: _fetchDailyWords,
        )
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: _handleSearch,
          style: const TextStyle(color: Colors.white),
          cursorColor: AppColors.accentCyan,
          decoration: InputDecoration(
            hintText: "Search dictionary...",
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.white30, size: 20),
              onPressed: () { _searchController.clear(); _fetchDailyWords(); },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      physics: const BouncingScrollPhysics(),
      controller: _pageController, 
      itemCount: _words.length, 
      itemBuilder: (context, index) {
        final word = _words[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0),
          child: WordCard(
            wordData: word,
            onListen: () => AudioService.speak(word.word),
            onFavorite: () => _saveFavorite(word),
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => WordDetailPage(word: word.word))
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_clock_outlined, size: 60, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            if (!_errorMessage!.contains("load tomorrow")) 
              ElevatedButton(
                onPressed: _fetchDailyWords,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, foregroundColor: Colors.white, shape: const StadiumBorder()),
                child: const Text("Try Again"),
              )
            else 
              TextButton(
                  onPressed: () async {
                    await Provider.of<ThemeProvider>(context, listen: false).updateVocabMode('Default');
                    _fetchDailyWords();
                  },
                  child: const Text("Switch to Default Words", style: TextStyle(color: AppColors.accentCyan))
              )
          ],
        ),
      ),
    );
  }

  // SENIOR DEV SOLUTION: Custom Overlay Toast to fix the positioning fuck-up
  void _saveFavorite(WordData word) async {
    HapticFeedback.mediumImpact();
    await _dbService.saveFavorite({'word': word.word, 'meaning': word.meaning, 'example': word.example, 'pronunciation': word.phonetic});
    
    if (!mounted) return;

    // Trigger the custom toast at the exact bottom coordinate
    _showCustomToast(context, "${word.word.toUpperCase()} added to favorites");
  }

  void _showCustomToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // POSITIONING: Placed exactly above the Navbar (85px up)
        bottom: 95, 
        left: MediaQuery.of(context).size.width * 0.15,
        right: MediaQuery.of(context).size.width * 0.15,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 10)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    // Remove after 2 seconds
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }
}