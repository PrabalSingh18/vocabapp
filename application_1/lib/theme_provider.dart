import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. CINEMATIC THEME NAMES
enum AppEnv {
  noir,      // Dark theme
  ethereal,  // Light theme
  deepSpace, // Dark theme
  stormy,    // Dark theme
  aurora,    // Dark theme
  tranquil   // Dark theme
}

// 2. Settings Color Scheme Class
class SettingsThemeColors {
  final Color background;
  final Color text;
  final Color icon;
  final Color accent;

  SettingsThemeColors({
    required this.background,
    required this.text,
    required this.icon,
    required this.accent,
  });
}

class ThemeProvider extends ChangeNotifier {
  // Theme State
  AppEnv _currentEnv = AppEnv.noir;
  AppEnv get currentEnv => _currentEnv;

  // NEW: Vocabulary & Premium State
  String _vocabMode = 'Default'; // Options: 'Default', 'LexisPro'
  bool _isPremium = false;

  String get vocabMode => _vocabMode;
  bool get isPremium => _isPremium;

  // Constructor: Load all saved preferences on startup
  ThemeProvider() {
    _loadPreferences();
  }

  ThemeMode get themeMode {
    switch (_currentEnv) {
      case AppEnv.noir:
      case AppEnv.deepSpace:
      case AppEnv.stormy:
      case AppEnv.aurora:   
      case AppEnv.tranquil: 
        return ThemeMode.dark;
      case AppEnv.ethereal: 
        return ThemeMode.light;
    }
  }

  // --- Theme Logic ---
  Future<void> updateTheme(AppEnv newEnv) async {
    if (_currentEnv == newEnv) return;
    _currentEnv = newEnv;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme_env', newEnv.name);
  }

  // --- NEW: Vocabulary Mode Logic ---
  Future<void> updateVocabMode(String newMode) async {
    if (_vocabMode == newMode) return;
    _vocabMode = newMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vocab_mode', newMode);
  }

  // --- NEW: Premium Status Logic ---
  Future<void> setPremiumStatus(bool status) async {
    _isPremium = status;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', status);
  }

  // UPDATED: Loads all preferences from storage
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Theme
    final String? savedEnvName = prefs.getString('selected_theme_env');
    if (savedEnvName != null) {
      try {
        _currentEnv = AppEnv.values.firstWhere((e) => e.name == savedEnvName);
      } catch (e) {
        debugPrint("Error loading theme: $e");
      }
    }

    // Load Vocabulary Mode
    _vocabMode = prefs.getString('vocab_mode') ?? 'Default';

    // Load Premium Status
    _isPremium = prefs.getBool('is_premium') ?? false;

    notifyListeners();
  }

  // 3. Settings Page Color Palette
  SettingsThemeColors get settingsColors {
    switch (_currentEnv) {
      case AppEnv.noir:
        return SettingsThemeColors(
          background: const Color(0xFF121212), 
          text: const Color(0xFFE0E0E0),       
          icon: const Color(0xFF90CAF9),       
          accent: Colors.blueAccent,
        );
      case AppEnv.deepSpace:
        return SettingsThemeColors(
          background: const Color(0xFF0F0F1A), 
          text: const Color(0xFFD1C4E9),       
          icon: const Color(0xFFB39DDB),       
          accent: Colors.deepPurpleAccent,
        );
      case AppEnv.stormy:
        return SettingsThemeColors(
          background: const Color(0xFF263238), 
          text: const Color(0xFFCFD8DC),       
          icon: const Color(0xFF90A4AE),       
          accent: Colors.blueGrey,
        );
      case AppEnv.aurora:
        return SettingsThemeColors(
          background: const Color(0xFF00252A), 
          text: const Color(0xFF80DEEA),       
          icon: const Color(0xFF26C6DA),       
          accent: Colors.tealAccent,           
        );
      case AppEnv.tranquil:
        return SettingsThemeColors(
          background: const Color(0xFF122216), 
          text: const Color(0xFFA5D6A7),       
          icon: const Color(0xFF66BB6A),       
          accent: Colors.lightGreenAccent,     
        );
      case AppEnv.ethereal:
        return SettingsThemeColors(
          background: Colors.white,            
          text: Colors.black,                  
          icon: Colors.black87,                
          accent: Colors.black,                
        );
    }
  }

  String getThemeName(AppEnv env) {
    switch (env) {
      case AppEnv.noir: return "Noir";
      case AppEnv.ethereal: return "Ethereal";
      case AppEnv.deepSpace: return "Deep Space";
      case AppEnv.stormy: return "Stormy";
      case AppEnv.aurora: return "Aurora";
      case AppEnv.tranquil: return "Tranquil";
    }
  }
}