import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// REMOVED: import 'package:flutter_tts/flutter_tts.dart'; (Handled by AudioService)
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart'; 

// Internal Architecture Imports
import 'atmospheric_background.dart';
import 'db_service.dart';
import 'services/word_repository.dart';
import 'wordmodel.dart';
import 'theme_provider.dart'; 
import 'audio_service.dart'; // REQUIRED IMPORT

class WordDetailPage extends StatefulWidget {
  final String word;
  final WordData? preloadedData;

  const WordDetailPage({super.key, required this.word, this.preloadedData});

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  final WordRepository _repository = WordRepository();
  // REMOVED: final FlutterTts _flutterTts = FlutterTts();
  final DBService _dbService = DBService();

  WordData? _data;
  bool _isLoading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    if (widget.preloadedData != null) {
      _data = widget.preloadedData;
      _isLoading = false;
      _checkFavoriteStatus();
    } else {
      _fetchData();
    }
  }

  // FIXED: Removed dispose logic for TTS as it is now global
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchData() async {
    final result = await _repository.fetchWordDetails(widget.word);
    if (mounted) {
      setState(() {
        _data = result;
        _isLoading = false;
      });
      _checkFavoriteStatus();
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (_data == null) return;
    final favorites = await _dbService.getFavorites();
    final exists = favorites.any((element) => element['word'] == _data!.word);
    if (mounted) {
      setState(() => _isFavorite = exists);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_data == null) return;
    HapticFeedback.mediumImpact();

    setState(() => _isFavorite = !_isFavorite);

    if (_isFavorite) {
      await _dbService.saveFavorite({
        'word': _data!.word,
        'meaning': _data!.meaning,
        'example': _data!.example,
        'pronunciation': _data!.phonetic,
      });
    } else {
      await _dbService.deleteFavorite(_data!.word);
    }
  }

  void _shareWord() {
    if (_data == null) return;
    Share.share(
      "Verbum App:\n${_data!.word.toUpperCase()} - ${_data!.meaning}",
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final env = themeProvider.currentEnv;
    final bool isBrightTheme = (env == AppEnv.ethereal || env == AppEnv.aurora);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white70,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AtmosphericBackground(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _data == null
            ? const Center(
                child: Text(
                  "Word details not found",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 100, 20, 120),
                    physics: const BouncingScrollPhysics(),
                    child: _buildGlassContainer(context, isBrightTheme),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 40,
                    right: 40,
                    child: _buildFloatingActionBar(isBrightTheme),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGlassContainer(BuildContext context, bool isBrightTheme) {
    final textShadows = [
      Shadow(
        offset: const Offset(0, 2),
        blurRadius: 6.0,
        color: Colors.black.withValues(alpha: 0.7),
      ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isBrightTheme
                ? Colors.black.withValues(alpha: 0.55)
                : Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'word_${_data!.word}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    _data!.word.toUpperCase(),
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      height: 1.0,
                      shadows: textShadows,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_data!.phonetic != null)
                Text(
                  _data!.phonetic!,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.w500,
                    shadows: textShadows,
                  ),
                ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Divider(color: Colors.white10),
              ),

              _buildSectionLabel("MEANING", textShadows),
              const SizedBox(height: 8),
              Text(
                _data!.meaning,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  height: 1.6,
                  color: Colors.white.withValues(alpha: 0.95),
                  shadows: textShadows,
                ),
              ),

              if (_data!.example != null) ...[
                const SizedBox(height: 32),
                _buildSectionLabel("EXAMPLE", textShadows),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Text(
                    "\"${_data!.example}\"",
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                      height: 1.4,
                      shadows: textShadows,
                    ),
                  ),
                ),
              ],

              if (_data!.synonyms.isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildSectionLabel("SYNONYMS", textShadows),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _data!.synonyms
                      .take(5)
                      .map((s) => _buildChip(s))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionBar(bool isBrightTheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: isBrightTheme
                ? Colors.black.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.volume_up_rounded,
                label: "Speak",
                onTap: () {
                  HapticFeedback.lightImpact();
                  // FIXED: Uses centralized AudioService for high-quality voice
                  AudioService.speak(_data!.word); 
                },
              ),
              Container(width: 1, height: 24, color: Colors.white24),
              _buildActionButton(
                icon: _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: "Save",
                color: _isFavorite ? Colors.redAccent : Colors.white,
                onTap: _toggleFavorite,
              ),
              Container(width: 1, height: 24, color: Colors.white24),
              _buildActionButton(
                icon: Icons.share_rounded,
                label: "Share",
                onTap: () {
                  HapticFeedback.lightImpact();
                  _shareWord();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
// ... (Rest of your helper widgets _buildActionButton, _buildSectionLabel, _buildChip remain exactly the same)
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, List<Shadow> shadows) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
        color: Colors.white70, 
        shadows: shadows,
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
      ),
    );
  }
}