import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // REQUIRED: For SystemChrome
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'audio_service.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // === FIX: HIDE SYSTEM BARS ===
  // This prevents the phone's default bar from overlapping your app.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  await AudioService.initAudio();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final activeColor = _getThemeColor(themeProvider.currentEnv);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Verbum App',

      // === DEFINE THE LIGHT THEME ===
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: activeColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), 
        useMaterial3: true,
      ),

      // === DEFINE THE DARK THEME ===
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: activeColor,
          brightness: Brightness.dark,
          surfaceTint: activeColor,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0E21), 
        useMaterial3: true,
      ),

      themeMode: themeProvider.themeMode,
      home: const LoginPage(),
    );
  }

  Color _getThemeColor(AppEnv env) {
    switch (env) {
      case AppEnv.noir:      return Colors.blueAccent;
      case AppEnv.aurora:    return Colors.tealAccent;
      case AppEnv.deepSpace: return Colors.purpleAccent;
      case AppEnv.stormy:    return Colors.blueGrey;
      case AppEnv.ethereal:  return Colors.cyanAccent;
      case AppEnv.tranquil:  return Colors.lightGreenAccent;
    }
  }
}