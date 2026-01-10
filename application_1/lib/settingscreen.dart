import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_provider.dart';
import 'audio_service.dart';
import 'services/word_repository.dart';
import 'word_detail_page.dart';
import 'wordmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsColors = themeProvider.settingsColors;
    final WordRepository repository = WordRepository();

    return Scaffold(
      backgroundColor: settingsColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: settingsColors.icon),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            color: settingsColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildProfileHeader(settingsColors, themeProvider.isPremium),

          // --- SENIOR DEV: Word of the Day Section ---
          FutureBuilder<WordData?>(
            future: repository.fetchWordOfTheDay(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return _buildDailyWordCard(snapshot.data!, settingsColors, context);
              }
              // Return a small spacer while loading to prevent UI jump
              return const SizedBox(height: 10);
            },
          ),

          const SizedBox(height: 10),

          // 1. Vocabulary Goals Mode Selection
          _buildVocabularySettings(context, themeProvider),

          const SizedBox(height: 20),

          // 2. Music Control Tile
          const _MusicSettingsTile(),

          _buildDivider(settingsColors),

          // 3. Expandable Theme Tile
          const _ThemeSettingsTile(),

          _buildDivider(settingsColors),

          // 4. About Us Tile
          _buildAboutTile(context, settingsColors),
          
          const SizedBox(height: 40),
          
          // 5. Upgrade Button (Only shows if NOT premium)
          if (!themeProvider.isPremium) _buildUpgradeButton(context, settingsColors),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // NEW: Professional Glassmorphic Daily Word Card
  Widget _buildDailyWordCard(WordData word, SettingsThemeColors colors, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        // Senior Dev Tip: Use very low opacity text color for subtle backgrounds
        color: colors.text.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.text.withValues(alpha: 0.08)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => WordDetailPage(word: word.word))
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.amber, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        "DAILY DISCOVERY",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: colors.text.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, size: 12, color: colors.text.withValues(alpha: 0.2)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                word.word,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                word.meaning,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.text.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(SettingsThemeColors colors, bool isPremium) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colors.icon.withValues(alpha: 0.2),
                child: Icon(Icons.person, size: 36, color: colors.icon),
              ),
              if (isPremium)
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.amber,
                    child: Icon(Icons.star, size: 12, color: Colors.black),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPremium ? "Lexis Pro Member" : "Guest User",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isPremium ? "Unlimited learning unlocked" : "15 Searches remaining",
                style: TextStyle(
                  fontSize: 14,
                  color: colors.text.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularySettings(BuildContext context, ThemeProvider provider) {
    final colors = provider.settingsColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            "VOCABULARY GOALS",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: colors.text.withValues(alpha: 0.6),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.text.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              _buildModeTile(
                title: "Default Mode",
                subtitle: "Random discovery & daily words",
                isSelected: provider.vocabMode == 'Default',
                onTap: () => provider.updateVocabMode('Default'),
                colors: colors,
                icon: Icons.explore_outlined,
              ),
              _buildModeTile(
                title: "Lexis Pro",
                subtitle: "Exam-level words (20 daily limit)",
                isSelected: provider.vocabMode == 'LexisPro',
                onTap: () => provider.updateVocabMode('LexisPro'),
                colors: colors,
                icon: Icons.auto_awesome,
                isPro: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeTile({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required SettingsThemeColors colors,
    required IconData icon,
    bool isPro = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isSelected ? colors.accent : colors.icon.withValues(alpha: 0.5)),
      title: Text(title, style: TextStyle(color: colors.text, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      subtitle: Text(subtitle, style: TextStyle(color: colors.text.withValues(alpha: 0.5), fontSize: 11)),
      trailing: isSelected 
        ? Icon(Icons.check_circle_rounded, color: colors.accent) 
        : Icon(Icons.circle_outlined, color: colors.text.withValues(alpha: 0.1)),
    );
  }

  Widget _buildUpgradeButton(BuildContext context, SettingsThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.background,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () => _showPaywall(context),
        child: const Text("UPGRADE TO PRO", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber, size: 48),
            const SizedBox(height: 16),
            const Text("Unlock Lexis Pro", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              "• Unlimited Dictionary Searches\n• Unlimited Lexis Pro Advanced Words\n• Exclusive Cinematic Themes",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  provider.setPremiumStatus(true);
                  Navigator.pop(context);
                },
                child: const Text("GET LIFETIME ACCESS - \$4.99"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(SettingsThemeColors colors) {
    return Divider(height: 1, indent: 16, endIndent: 16, color: colors.text.withValues(alpha: 0.2));
  }

  Widget _buildAboutTile(BuildContext context, SettingsThemeColors colors) {
    return ListTile(
      leading: Icon(Icons.info_outline, color: colors.icon),
      title: Text("About Us", style: TextStyle(color: colors.text)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colors.icon),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: "Verbum",
          applicationVersion: "1.0.0",
          applicationIcon: const Icon(Icons.book, size: 40),
          children: [const Text("A beautiful app to enhance your vocabulary with cinematic atmospheres made by Prabal Kuntal.")],
        );
      },
    );
  }
}

class _MusicSettingsTile extends StatefulWidget {
  const _MusicSettingsTile();
  @override
  State<_MusicSettingsTile> createState() => _MusicSettingsTileState();
}

class _MusicSettingsTileState extends State<_MusicSettingsTile> {
  bool _isMusicEnabled = AudioService.isEnabled;
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsColors = themeProvider.settingsColors;
    return ListTile(
      leading: Icon(Icons.music_note, color: settingsColors.icon),
      title: Text("Background Music", style: TextStyle(color: settingsColors.text)),
      subtitle: Text(_isMusicEnabled ? "Tap to change track" : "Disabled", style: TextStyle(color: settingsColors.text.withValues(alpha: 0.7), fontSize: 12)),
      trailing: Switch(
        value: _isMusicEnabled,
        activeThumbColor: settingsColors.accent,
        activeTrackColor: settingsColors.accent.withValues(alpha: 0.5),
        onChanged: (bool value) {
          setState(() => _isMusicEnabled = value);
          AudioService.toggleMusic(value);
        },
      ),
      onTap: _isMusicEnabled ? () => _showTrackSelectionDialog(context) : null,
    );
  }

  void _showTrackSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Atmosphere'),
          children: List.generate(AudioService.trackNames.length, (index) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                AudioService.selectTrack(index);
              },
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(AudioService.trackNames[index])),
            );
          }),
        );
      },
    );
  }
}

class _ThemeSettingsTile extends StatelessWidget {
  const _ThemeSettingsTile();
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsColors = themeProvider.settingsColors;
    final List<Map<String, dynamic>> themeData = [
      {'env': AppEnv.noir, 'name': 'Noir', 'color': const Color(0xFF34495E)},
      {'env': AppEnv.deepSpace, 'name': 'Deep Space', 'color': const Color(0xFF2C3E50)},
      {'env': AppEnv.stormy, 'name': 'Stormy', 'color': const Color(0xFF7F8C8D)},
      {'env': AppEnv.aurora, 'name': 'Aurora', 'color': const Color(0xFF1ABC9C)},
      {'env': AppEnv.ethereal, 'name': 'Ethereal', 'color': const Color(0xFF9B59B6)},
      {'env': AppEnv.tranquil, 'name': 'Tranquil', 'color': const Color(0xFF27AE60)},
    ];
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(seedColor: settingsColors.accent, brightness: Theme.of(context).brightness),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.palette, color: settingsColors.icon),
        title: Text("Theme", style: TextStyle(color: settingsColors.text)),
        textColor: settingsColors.accent,
        iconColor: settingsColors.accent,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: themeData.map((data) => _buildThemeOption(context, data, settingsColors)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, Map<String, dynamic> data, SettingsThemeColors settingsColors) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final AppEnv env = data['env'];
    final bool isSelected = themeProvider.currentEnv == env;
    final Color color = data['color'];
    return InkWell(
      onTap: () => themeProvider.updateTheme(env),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? color : settingsColors.text.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(backgroundColor: color, radius: 8),
            const SizedBox(width: 8),
            Text(data['name'], style: TextStyle(color: isSelected ? color : settingsColors.text, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}