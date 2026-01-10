import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

// A dedicated page just for selecting themes
class ThemeSelectionPage extends StatelessWidget {
  const ThemeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      // Transparent background so the main app background shows through
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Select Theme",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.1),
            child: const SafeArea(
              // Load the grid widget here
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: ThemeSelectionGrid(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =================================================================
// THE GRID WIDGETS (Moved from settingscreen.dart)
// =================================================================
class ThemeSelectionGrid extends StatelessWidget {
  const ThemeSelectionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    final List<Map<String, dynamic>> themeData = [
      {'env': AppEnv.noir, 'icon': Icons.water_drop_outlined},
      {'env': AppEnv.deepSpace, 'icon': Icons.nights_stay_outlined},
      {'env': AppEnv.stormy, 'icon': Icons.cloud_outlined},
      {'env': AppEnv.aurora, 'icon': Icons.wb_sunny_outlined},
      {'env': AppEnv.ethereal, 'icon': Icons.ac_unit_outlined},
      {'env': AppEnv.tranquil, 'icon': Icons.landscape_outlined},
    ];

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: themeData.length,
      itemBuilder: (context, index) {
        final data = themeData[index];
        final AppEnv env = data['env'];
        final IconData icon = data['icon'];
        final bool isSelected = themeProvider.currentEnv == env;
        final String name = themeProvider.getThemeName(env);

        return _ThemeOptionCard(
          name: name,
          icon: icon,
          isSelected: isSelected,
          textColor: textColor,
          onTap: () {
            themeProvider.updateTheme(env);
          },
        );
      },
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final Color textColor;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color cardBgColor;
    if (isSelected) {
      cardBgColor = primaryColor.withValues(alpha: 0.15);
    } else {
      cardBgColor = isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade200;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.6)
                : textColor.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: -2,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? primaryColor
                      : textColor.withValues(alpha: 0.5),
                  size: 30,
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? primaryColor : textColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}