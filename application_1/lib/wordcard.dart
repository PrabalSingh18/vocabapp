import 'dart:ui';
import 'package:application_1/wordmodel.dart';
import 'package:application_1/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';

class WordCard extends StatelessWidget {
  final WordData wordData;
  final VoidCallback onListen;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const WordCard({
    super.key,
    required this.wordData,
    required this.onListen,
    required this.onFavorite,
    required this.onTap,
  });

  // Adaptive Glass Tint logic (Preserved)
  Color _getGlassColor(AppEnv env) {
    if (env == AppEnv.ethereal ||
        env == AppEnv.aurora ||
        env == AppEnv.tranquil) {
      return Colors.black.withValues(alpha: 0.40); 
    }
    return Colors.white.withValues(alpha: 0.05);
  }

  // Accent color for icons/highlights (Preserved)
  Color _getAccentColor(AppEnv env) {
    switch (env) {
      case AppEnv.noir:
        return Colors.blueAccent;
      case AppEnv.deepSpace:
        return Colors.tealAccent;
      case AppEnv.stormy:
        return Colors.blueGrey;
      case AppEnv.aurora:
        return Colors.amberAccent;
      case AppEnv.ethereal:
        return Colors.lightBlueAccent;
      case AppEnv.tranquil:
        return Colors.lightGreenAccent;
    }
  }

  void _shareWord() {
    Share.share("Verbum: ${wordData.word.toUpperCase()} - ${wordData.meaning}");
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final glassColor = _getGlassColor(themeProvider.currentEnv);
    final accentColor = _getAccentColor(themeProvider.currentEnv);

    final textShadows = [
      Shadow(
        offset: const Offset(0, 2),
        blurRadius: 4.0,
        color: Colors.black.withValues(alpha: 0.5),
      ),
    ];

    return Center(
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.58,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: glassColor,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: InkWell(
                  splashColor: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(32),
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    onTap();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Hero(
                              tag: 'word_${wordData.word}',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  wordData.word.toUpperCase(),
                                  style: GoogleFonts.sourceSerif4(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                    shadows: textShadows,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _ActionButton(
                            icon: Icons.volume_up_rounded,
                            color: accentColor,
                            onPressed: onListen,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (wordData.phonetic != null)
                        Text(
                          wordData.phonetic!,
                          style: GoogleFonts.inter(
                            color: accentColor.withValues(alpha: 0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            shadows: textShadows,
                          ),
                        ),
                      const Divider(height: 40, color: Colors.white12),
                      _buildLabel("DEFINITION", accentColor),
                      const SizedBox(height: 8),
                      Text(
                        wordData.meaning,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 17,
                          height: 1.4,
                          shadows: textShadows,
                        ),
                      ),
                      if (wordData.example != null) ...[
                        const SizedBox(height: 24),
                        _buildLabel("IN CONTEXT", accentColor),
                        const SizedBox(height: 8),
                        Text(
                          "\"${wordData.example}\"",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                            shadows: textShadows,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (wordData.synonyms.isNotEmpty)
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                children: wordData.synonyms
                                    .take(2)
                                    .map((s) => _buildChip(s, accentColor))
                                    .toList(),
                              ),
                            )
                          else
                            const Spacer(),
                          Row(
                            children: [
                              _ActionButton(
                                icon: Icons.share_rounded,
                                color: Colors.white.withValues(alpha: 0.7),
                                size: 22,
                                onPressed: _shareWord,
                              ),
                              const SizedBox(width: 8),
                              // NEW FEATURE: Integrated Favorite Toggle with Scale Animation
                              _ActionButton(
                                icon: wordData.isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: wordData.isFavorite
                                    ? Colors.redAccent
                                    : Colors.white.withValues(alpha: 0.7),
                                size: 24,
                                onPressed: onFavorite,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color tint) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: tint,
          letterSpacing: 1.5,
          shadows: [
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ],
        ),
      );

  Widget _buildChip(String text, Color tint) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tint.withValues(alpha: 0.3)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.size = 28,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      // NEW: Added AnimatedSwitcher for the 'nice feel' pop animation
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          icon,
          color: color,
          size: size,
          key: ValueKey(icon),
          shadows: [
            Shadow(
              offset: const Offset(0, 2),
              blurRadius: 4,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
      onPressed: () {
        // NEW: Medium haptic impact for tactile feedback
        HapticFeedback.mediumImpact();
        onPressed();
      },
    );
  }
}