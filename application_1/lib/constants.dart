import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = "VERBUM";
  static const String randomWordApi = 'https://random-word-api.herokuapp.com/word?number=15';
  static const String dictionaryApi = 'https://api.dictionaryapi.dev/api/v2/entries/en/';
}

// ADD THIS CLASS
class AppStrings {
  static const String errorNetwork = "Could not connect to the network.";
}

class AppColors {
  static const Color bgDark = Color(0xFF0A0E21);
  static const Color accentCyan = Colors.cyanAccent;
  static Color glassBorder = Colors.white.withValues(alpha: 0.12);
}