import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class AtmosphericBackground extends StatefulWidget {
  final Widget child;
  const AtmosphericBackground({super.key, required this.child});

  @override
  State<AtmosphericBackground> createState() => _AtmosphericBackgroundState();
}

class _AtmosphericBackgroundState extends State<AtmosphericBackground>
    with TickerProviderStateMixin {
  // Updated to TickerProvider for multiple controllers
  late AnimationController _controller;
  late AnimationController
  _lightningController; // NEW: Controller for lightning flash
  final List<WeatherParticle> particles = [];
  final Random _random = Random();
  ui.Image? _backgroundImage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Initialize Lightning Controller
    _lightningController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _loadAssets();
    _initParticles();
    _startLightningCycle(); // Start the random lightning timer
  }

  // Logic for "Real Life" lightning: Strikes every 10-25 seconds
  void _startLightningCycle() async {
  while (mounted) {
    // Wait for the random delay
    await Future.delayed(Duration(seconds: 10 + _random.nextInt(15)));

    // Check if we are still on the screen and active before doing work
    if (!mounted) break; 

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (themeProvider.currentEnv == AppEnv.stormy) {
      // Logic for flash
      await _lightningController.forward();
      await _lightningController.reverse();
      }
    }
  }

  Future<void> _loadAssets() async {
    try {
      final ByteData data = await rootBundle.load(
        'assets/images/cozy_field_bg.jpg',
      );
      final Completer<ui.Image> completer = Completer();
      ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
        return completer.complete(img);
      });
      final loadedImage = await completer.future;
      if (mounted) setState(() => _backgroundImage = loadedImage);
    } catch (e) {
      debugPrint("Error loading background image: $e");
    }
  }

  void _initParticles() {
    particles.clear();
    for (int i = 0; i < 200; i++) {
      particles.add(WeatherParticle(random: _random));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _lightningController.dispose(); // Dispose lightning controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: AnimatedBuilder(
            // Sync both controllers to the painter
            animation: Listenable.merge([_controller, _lightningController]),
            builder: (context, child) {
              return CustomPaint(
                painter: CinematicWeatherPainter(
                  env: themeProvider.currentEnv,
                  particles: particles,
                  animValue: _controller.value,
                  lightningValue:
                      _lightningController.value, // Pass lightning value
                  backgroundImage: _backgroundImage,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.3,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class CinematicWeatherPainter extends CustomPainter {
  final AppEnv env;
  final List<WeatherParticle> particles;
  final double animValue;
  final double lightningValue; // Added
  final ui.Image? backgroundImage;

  CinematicWeatherPainter({
    required this.env,
    required this.particles,
    required this.animValue,
    required this.lightningValue,
    this.backgroundImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    if (env == AppEnv.tranquil) {
      if (backgroundImage != null) {
        _drawImageBackground(canvas, size);
      } else {
        _drawTranquilFallbackGradient(canvas, rect);
      }
    } else {
      _drawCinematicSky(canvas, rect);
    }

    // NEW: DRAW LIGHTNING FLASH (Only for Stormy theme)
    if (env == AppEnv.stormy && lightningValue > 0) {
      final lightningPaint = Paint()
        ..color = Colors.white.withValues(
          alpha: lightningValue * 0.12,
        ); // Subtle atmospheric flash
      canvas.drawRect(rect, lightningPaint);
    }

    switch (env) {
      case AppEnv.noir:
        _drawNoirRain(canvas, size);
        break;
      case AppEnv.ethereal:
        _drawEtherealSnow(canvas, size);
        break;
      case AppEnv.aurora:
        _drawAuroraBorealis(canvas, size);
        break;
      case AppEnv.deepSpace:
        _drawDeepSpace(canvas, size);
        break;
      case AppEnv.stormy:
        _drawStormyClouds(canvas, size);
        break;
      case AppEnv.tranquil:
        _drawTranquilAtmosphere(canvas, size);
        break;
    }
  }

  // --- ALL OTHER METHODS REMAIN UNCHANGED ---

  void _drawImageBackground(Canvas canvas, Size size) {
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.width, size.height),
      image: backgroundImage!,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = Colors.blueGrey.withValues(alpha: 0.2)
        ..blendMode = BlendMode.overlay,
    );
  }

  void _drawTranquilFallbackGradient(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0D1B2A),
          const Color(0xFF1B263B),
          const Color(0xFF000000),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawTranquilAtmosphere(Canvas canvas, Size size) {
    for (var p in particles.take(150)) {
      p.updatePosition(speedMultiplier: 2.5);
      double length = 25.0 * p.depth;
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3 * p.depth)
        ..strokeWidth = 0.8 * p.depth
        ..strokeCap = StrokeCap.round;
      double dx = -3.0 * p.depth;
      canvas.drawLine(
        Offset(p.x * size.width, p.y * size.height),
        Offset((p.x * size.width) + dx, (p.y * size.height) + length),
        paint,
      );
    }
    for (var p in particles.skip(150)) {
      double twinkle = pow(
        sin((animValue * p.twinkleSpeed) + p.randomOffset),
        4,
      ).toDouble();
      double alpha = 0.2 + (0.6 * twinkle);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        (1.2 * p.depth) + (twinkle * 0.5),
        Paint()..color = Colors.white.withValues(alpha: alpha * p.depth),
      );
    }
  }

  void _drawCinematicSky(Canvas canvas, Rect rect) {
    List<Color> colors;
    List<double> stops;
    switch (env) {
      case AppEnv.noir:
        colors = [
          const Color(0xFF0F172A),
          const Color(0xFF1E293B),
          const Color(0xFF000000),
        ];
        stops = [0.0, 0.5, 1.0];
        break;
      case AppEnv.aurora:
        colors = [
          const Color(0xFF000000),
          const Color(0xFF0F2027),
          const Color(0xFF203A43),
        ];
        stops = [0.0, 0.6, 1.0];
        break;
      case AppEnv.ethereal:
        colors = [
          const Color(0xFF2C3E50),
          const Color(0xFF4CA1AF),
          const Color(0xFFDEE4E4),
        ];
        stops = [0.0, 0.5, 1.0];
        break;
      case AppEnv.deepSpace:
        colors = [
          const Color(0xFF0B0014),
          const Color(0xFF180c2e),
          const Color(0xFF000000),
        ];
        stops = [0.0, 0.4, 1.0];
        break;
      case AppEnv.stormy:
        colors = [const Color(0xFF232526), const Color(0xFF414345)];
        stops = [0.0, 1.0];
        break;
      default:
        colors = [Colors.black, Colors.black];
        stops = [0.0, 1.0];
    }
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: stops,
        ).createShader(rect),
    );
  }

  void _drawAuroraBorealis(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      double speed = 0.1 + (i * 0.05);
      double shift = (animValue * speed) % 1.0;
      Color auroraColor = i == 0
          ? const Color(0xFF00FF87).withValues(alpha: 0.15)
          : i == 1
          ? const Color(0xFF60EFFF).withValues(alpha: 0.12)
          : const Color(0xFF9900FF).withValues(alpha: 0.1);
      final paint = Paint()
        ..color = auroraColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
      Path path = Path();
      double startY = size.height * (0.2 + (i * 0.1));
      path.moveTo(0, startY);
      for (double x = 0; x <= size.width; x += 20) {
        double y =
            startY +
            sin((x / 100) + (shift * 2 * pi)) * 50 +
            cos((x / 50) + (animValue * 2 * pi)) * 30;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
      path.close();
      canvas.drawPath(path, paint);
    }
    for (var p in particles.take(60)) {
      p.updatePosition(speedMultiplier: 0.5, isRising: true);
      double pulse = 0.5 + 0.5 * sin((animValue * 10) + p.randomOffset);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        1.5 * p.depth,
        Paint()
          ..color = const Color(
            0xFFCCFF00,
          ).withValues(alpha: 0.4 * p.depth * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }
  }

  void _drawDeepSpace(Canvas canvas, Size size) {
    final nebulaPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    for (int i = 0; i < 3; i++) {
      double shift = (animValue * 0.1) + (i * 2.0);
      double x = size.width * (0.5 + 0.3 * sin(shift));
      double y = size.height * (0.5 + 0.3 * cos(shift * 0.7));
      nebulaPaint.color = i.isEven
          ? Colors.purpleAccent.withValues(alpha: 0.15)
          : Colors.cyanAccent.withValues(alpha: 0.12);
      canvas.drawCircle(Offset(x, y), size.width * 0.6, nebulaPaint);
    }
    for (var p in particles) {
      double twinkle = sin((animValue * 10 * pi) + (p.randomOffset * 10));
      double alpha = 0.6 + (0.4 * twinkle);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        1.5 * p.depth,
        Paint()..color = Colors.white.withValues(alpha: alpha * p.depth),
      );
    }
  }

  void _drawNoirRain(Canvas canvas, Size size) {
    for (var p in particles) {
      p.updatePosition(speedMultiplier: 2.5);
      double length = 15.0 * p.depth;
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4 * p.depth)
        ..strokeWidth = 1.5 * p.depth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(p.x * size.width, p.y * size.height),
        Offset(p.x * size.width - 3, p.y * size.height + length),
        paint,
      );
    }
  }

  void _drawEtherealSnow(Canvas canvas, Size size) {
    for (var p in particles) {
      p.updatePosition(speedMultiplier: 0.3);
      double wobble =
          sin((animValue * 2 * pi) + p.randomOffset) * (15 * p.depth);
      canvas.drawCircle(
        Offset((p.x * size.width) + wobble, p.y * size.height),
        (p.randomOffset % 4 + 2) * p.depth,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7 * p.depth)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, (1.0 - p.depth) * 2),
      );
    }
  }

  void _drawStormyClouds(Canvas canvas, Size size) {
    for (int i = 0; i < 6; i++) {
      double speed = 0.1 + (i * 0.05);
      double shift = (animValue * speed) % 1.0;
      final cloudPaint = Paint()
        ..color = const Color(0xFFB0BEC5).withValues(alpha: 0.15 + (i * 0.02))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);
      double x = (shift * size.width * 1.5) - (size.width * 0.5);
      double y = size.height * (0.0 - (i * 0.05)) + (sin(animValue * pi) * 10);
      double r = 100.0 + (i * 30);
      canvas.drawCircle(Offset(x, y), r, cloudPaint);
      canvas.drawCircle(Offset(x + r, y + 20), r * 0.8, cloudPaint);
      canvas.drawCircle(Offset(x - r * 0.8, y + 30), r * 0.6, cloudPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CinematicWeatherPainter oldDelegate) => true;
}

class WeatherParticle {
  double x, y, depth, size, speed, randomOffset, twinkleSpeed;
  WeatherParticle({required Random random})
    : x = random.nextDouble(),
      y = random.nextDouble(),
      depth = random.nextDouble(),
      size = random.nextDouble(),
      speed = random.nextDouble(),
      randomOffset = random.nextDouble() * 20,
      twinkleSpeed = 5 + random.nextDouble() * 15;
  void updatePosition({
    required double speedMultiplier,
    bool isRising = false,
  }) {
    double moveSpeed = 0.002 * speedMultiplier * (0.5 + depth);
    if (isRising) {
      y -= moveSpeed;
      if (y < -0.1) {
        y = 1.1;
        x = Random().nextDouble();
      }
    } else {
      y += moveSpeed;
      if (y > 1.1) {
        y = -0.1;
        x = Random().nextDouble();
      }
    }
  }
}
