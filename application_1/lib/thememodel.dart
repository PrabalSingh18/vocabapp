import 'package:flutter/material.dart';

enum AppEnv { snow, rain, fog, cloudy, sunny }

class EnvConfig {
  final String name;
  final Color bgColor;
  final Color accentColor;
  final IconData icon;

  EnvConfig({
    required this.name,
    required this.bgColor,
    required this.accentColor,
    required this.icon,
  });
}

final Map<AppEnv, EnvConfig> environments = {
  AppEnv.snow: EnvConfig(name: "Winter", bgColor: const Color(0xFF0A0E21), accentColor: Colors.cyanAccent, icon: Icons.ac_unit),
  AppEnv.rain: EnvConfig(name: "Rainy", bgColor: const Color(0xFF050A19), accentColor: Colors.blueAccent, icon: Icons.umbrella),
  AppEnv.fog: EnvConfig(name: "Mist", bgColor: const Color(0xFF1A1A1A), accentColor: Colors.purpleAccent, icon: Icons.cloud_queue),
  AppEnv.cloudy: EnvConfig(name: "Cloudy", bgColor: const Color(0xFF121520), accentColor: Colors.grey, icon: Icons.cloud),
  AppEnv.sunny: EnvConfig(name: "Sunny", bgColor: const Color(0xFF0A1E21), accentColor: Colors.orangeAccent, icon: Icons.wb_sunny),
};