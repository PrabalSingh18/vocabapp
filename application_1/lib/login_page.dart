import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homescreen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _mainFadeController;
  late AnimationController _parallaxController;
  late List<Widget> _cachedParallaxField;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  
  bool _isObscure = true;
  bool _rememberMe = false;

  final List<String> _bgWords = [
    "Eloquent", "Resilient", "Articulate", "Tenacious",
    "Concise", "Prudent", "Lucid", "Stoic", "Adept",
    "Veracity", "Luminous", "Sagacity", "Insight"
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();

    _mainFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _parallaxController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _cachedParallaxField = _generateParallaxField();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? isLoggedIn = prefs.getBool('isLoggedIn');
    if (isLoggedIn == true && mounted) {
      _navigateToHome();
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text == 'test@example.com' && 
        _passController.text == '123456') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', _rememberMe);
      if (mounted) _navigateToHome();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Credentials. Try test@example.com / 123456'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _mainFadeController.dispose();
    _parallaxController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  List<Widget> _generateParallaxField() {
    final Random random = Random();
    return _bgWords.map((word) {
      return _FloatingWord(
        word: word,
        controller: _parallaxController,
        alignment: FractionalOffset(random.nextDouble(), random.nextDouble()),
        speed: 0.4 + (random.nextDouble() * 0.6),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          const _AtmosphericBackground(),
          RepaintBoundary(
            child: Stack(children: _cachedParallaxField),
          ),
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _mainFadeController,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 48),
                      _buildLoginCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.architecture_rounded, size: 52, color: Colors.white70),
        const SizedBox(height: 16),
        Text(
          'VERBUM',
          style: GoogleFonts.inter(
            fontSize: 34,
            fontWeight: FontWeight.w600,
            letterSpacing: 6.0,
            // UPDATED: withValues instead of withOpacity
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Precision in Words. Power in Expression.',
          style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            // UPDATED: withValues instead of withOpacity
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(32),
            // UPDATED: withValues instead of withOpacity
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LOGIN',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 32),
              _CustomInputField(
                controller: _emailController,
                hint: "Email",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              _CustomInputField(
                controller: _passController,
                hint: "Password",
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                isObscure: _isObscure,
                onToggle: () => setState(() => _isObscure = !_isObscure),
              ),
              const SizedBox(height: 20),
              _buildOptionsRow(),
              const SizedBox(height: 32),
              _buildPrimaryButton(),
              const SizedBox(height: 24),
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: Row(
            children: [
              Icon(
                _rememberMe ? Icons.check_box : Icons.check_box_outline_blank,
                color: _rememberMe ? Colors.white : Colors.white54,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Remember me',
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
        Text(
          'Forgot Password?',
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 13, decoration: TextDecoration.underline),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text('SIGN IN', style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return TextButton(
      onPressed: () {},
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
          children: [
            TextSpan(
              text: "Register",
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool isObscure;
  final VoidCallback? onToggle;

  const _CustomInputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.isObscure = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white24, size: 18),
                onPressed: onToggle,
              )
            : null,
        filled: true,
        // UPDATED: withValues instead of withOpacity
        fillColor: Colors.white.withValues(alpha: 0.05),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white, width: 1.5)),
      ),
    );
  }
}

class _FloatingWord extends StatelessWidget {
  final String word;
  final AnimationController controller;
  final FractionalOffset alignment;
  final double speed;

  const _FloatingWord({
    required this.word,
    required this.controller,
    required this.alignment,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double rad = controller.value * 2 * pi * speed;
        return Align(
          alignment: FractionalOffset(
            alignment.dx + (0.03 * sin(rad)),
            alignment.dy + (0.03 * cos(rad)),
          ),
          child: child,
        );
      },
      child: Text(
        word,
        style: GoogleFonts.inter(
          // UPDATED: withValues instead of withOpacity
          color: Colors.white.withValues(alpha: 0.06),
          fontSize: 15 + (speed * 2),
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}

class _AtmosphericBackground extends StatelessWidget {
  const _AtmosphericBackground();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0E21), Color(0xFF1A1F3C), Color(0xFF261D3A)],
        ),
      ),
    );
  }
}