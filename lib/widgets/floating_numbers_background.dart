import 'dart:math';
import 'package:flutter/material.dart';

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
    // Initialize floating numbers
    for (int i = 0; i < 30; i++) {
      _numbers.add(_FloatingNumber(
        value: _random.nextInt(25) + 1,
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speedX: (_random.nextDouble() - 0.5) * 0.001, // random horizontal drift
        speedY: (_random.nextDouble() - 0.5) * 0.001, // random vertical drift
        rotation: _random.nextDouble() * pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.001,
        opacity: 0.25 + _random.nextDouble() * 0.5, // max 0.75
        fontSize: 20 + _random.nextDouble() * 25,
      ));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1), // effectively infinite
    )
      ..addListener(_updateNumbers)
      ..repeat();
  }

  void _updateNumbers() {
    for (var n in _numbers) {
      n.x += n.speedX;
      n.y += n.speedY;
      n.rotation += n.rotationSpeed;

      // Wrap around edges for infinite movement
      if (n.x < -0.1) n.x = 1.1;
      if (n.x > 1.1) n.x = -0.1;
      if (n.y < -0.1) n.y = 1.1;
      if (n.y > 1.1) n.y = -0.1;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FloatingNumberPainter(_numbers),
      size: Size.infinite,
    );
  }
}

class _FloatingNumber {
  double x;
  double y;
  double speedX;
  double speedY;
  double rotation;
  double rotationSpeed;
  final int value;
  final double opacity;
  final double fontSize;

  _FloatingNumber({
    required this.value,
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.rotation,
    required this.rotationSpeed,
    required this.opacity,
    required this.fontSize,
  });
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
              color: Colors.blueAccent.withOpacity(n.opacity / 2),
              offset: const Offset(0, 0),
            ),
          ],
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      canvas.save();
      canvas.translate(n.x * size.width, n.y * size.height);
      canvas.rotate(n.rotation);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingNumberPainter oldDelegate) => true;
}
