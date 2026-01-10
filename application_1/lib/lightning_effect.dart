import 'dart:math';
import 'package:flutter/material.dart';

class LightningEffect extends StatefulWidget {
  const LightningEffect({super.key});

  @override
  State<LightningEffect> createState() => _LightningEffectState();
}

class _LightningEffectState extends State<LightningEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _startRandomLightning();
  }

  // Logic for "Real Life" frequency: Strikes every 10-25 seconds
  void _startRandomLightning() async {
    while (mounted) {
      await Future.delayed(Duration(seconds: 10 + _random.nextInt(15)));
      if (mounted) {
        // Double flash effect for realism
        await _controller.forward();
        await _controller.reverse();
        await Future.delayed(const Duration(milliseconds: 100));
        await _controller.forward();
        await _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(CurveTween(curve: Curves.easeInOut)),
      child: Container(
        color: Colors.white.withValues(alpha: 0.15), // Subtle flash, not blinding
      ),
    );
  }
}