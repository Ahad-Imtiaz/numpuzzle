import 'dart:math';

import 'package:flutter/material.dart';

import 'package:numpuzzle/utils/platform_util.dart';

class FloatingNumbersBackground extends StatefulWidget {
  const FloatingNumbersBackground({super.key});

  @override
  State<FloatingNumbersBackground> createState() => _FloatingNumbersBackgroundState();
}

class _FloatingNumbersBackgroundState extends State<FloatingNumbersBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Random _random = Random();
  final List<_FloatingNumber> _numbers = [];

  @override
  void initState() {
    super.initState();

    int totalNumbers = 25;
    for (int i = 0; i < totalNumbers; i++) {
      int value = i + 1;
      _numbers.add(_FloatingNumber(
        value: value,
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speedX: (_random.nextDouble() - 0.5) * 0.001,
        speedY: (_random.nextDouble() - 0.5) * 0.001,
        rotation: _random.nextDouble() * pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.001,
        opacity: 0.15 + _random.nextDouble() * 0.45,
        fontSize: 7 + _random.nextDouble() * 25,
      ));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1), // effectively infinite
    )..addListener(_updateNumbers);

    _controller.repeat();
  }

  void _updateNumbers() {
    const deltaTime = 1 / 60;

    for (var n in _numbers) {
      // Smoothly interpolate speed back to target
      if (n.velocityDecayTime > 0) {
        final t = deltaTime / n.velocityDecayTime;
        n.speedX += (n.targetSpeedX - n.speedX) * t;
        n.speedY += (n.targetSpeedY - n.speedY) * t;
        n.velocityDecayTime -= deltaTime;
      }

      n.x += n.speedX;
      n.y += n.speedY;
      n.rotation += n.rotationSpeed;

      // Wrap around edges
      if (n.x < -0.1) n.x = 1.1;
      if (n.x > 1.1) n.x = -0.1;
      if (n.y < -0.1) n.y = 1.1;
      if (n.y > 1.1) n.y = -0.1;

      // Slowly grow and shrink font size
      final time = DateTime.now().millisecondsSinceEpoch / 1000;
      n.fontSize = n.baseFontSize * (0.9 + 0.2 * sin(time * n.sizeSpeed + n.sizePhase));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(Offset position, BuildContext context) {
    final tapX = position.dx / MediaQuery.of(context).size.width;
    final tapY = position.dy / MediaQuery.of(context).size.height;

    for (var n in _numbers) {
      final dx = n.x - tapX;
      final dy = n.y - tapY;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < 0.15) {
        // Push away
        n.speedX += dx / dist * 0.02;
        n.speedY += dy / dist * 0.02;

        // Smoothly return to original over 2 seconds
        n.targetSpeedX = n.originalSpeedX;
        n.targetSpeedY = n.originalSpeedY;
        n.velocityDecayTime = 2.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final enableTouch = !PlatformUtil.isMobileWeb;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Listener(
            onPointerDown: enableTouch ? (event) => _handleTap(event.localPosition, context) : null,
            onPointerMove: enableTouch ? (event) => _handleTap(event.localPosition, context) : null,
            child: CustomPaint(
              painter: _FloatingNumberPainter(_numbers),
              size: Size.infinite,
            ),
          );
        },
      ),
    );
  }
}

class _FloatingNumber {
  double x;
  double y;
  double speedX;
  double speedY;
  final double originalSpeedX;
  final double originalSpeedY;

  double targetSpeedX;
  double targetSpeedY;
  double velocityDecayTime = 0;

  double rotation;
  double rotationSpeed;
  final int value;
  final double opacity;
  final double baseFontSize;

  final double sizePhase;
  final double sizeSpeed;
  double fontSize;

  _FloatingNumber({
    required this.value,
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.rotation,
    required this.rotationSpeed,
    required this.opacity,
    required double fontSize,
  })  : originalSpeedX = speedX,
        originalSpeedY = speedY,
        targetSpeedX = speedX,
        targetSpeedY = speedY,
        baseFontSize = fontSize,
        fontSize = fontSize,
        sizePhase = Random().nextDouble() * 2 * pi,
        sizeSpeed = 0.2 + Random().nextDouble() * 0.3;
}

class _FloatingNumberPainter extends CustomPainter {
  final List<_FloatingNumber> numbers;
  _FloatingNumberPainter(this.numbers);

  @override
  void paint(Canvas canvas, Size size) {
    for (var n in numbers) {
      final textSpan = TextSpan(
        text: n.value.toString(),
        style: TextStyle(
          fontSize: n.fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent.withOpacity(n.opacity),
          shadows: [
            Shadow(
              blurRadius: 6.0,
              color: Colors.blueAccent.withOpacity(n.opacity),
              offset: const Offset(0, 0),
            ),
            Shadow(
              blurRadius: 3.0,
              color: Colors.blueAccent.withOpacity(n.opacity),
              offset: const Offset(0, 0),
            ),
          ],
        ),
      );

      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();

      canvas.save();
      canvas.translate(n.x * size.width, n.y * size.height);
      canvas.rotate(n.rotation);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingNumberPainter oldDelegate) => true;
}
