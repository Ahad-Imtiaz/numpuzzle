import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FloatingNumbersBackground extends StatefulWidget {
  const FloatingNumbersBackground({super.key});

  @override
  State<FloatingNumbersBackground> createState() => _FloatingNumbersBackgroundState();
}

class _FloatingNumbersBackgroundState extends State<FloatingNumbersBackground> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Random _random = Random();
  final List<_FloatingNumber> _numbers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 30; i++) {
      _numbers.add(_FloatingNumber(
        value: _random.nextInt(25) + 1,
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        dx: (_random.nextDouble() - 0.5) * 0.002,
        dy: (_random.nextDouble() - 0.5) * 0.002,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.01,
        fontSize: 3 + _random.nextDouble() * 30,
        opacity: 0.1 + _random.nextDouble() * 0.35,
      ));
    }

    _ticker = createTicker((_) {
      for (var n in _numbers) {
        n.x += n.dx;
        n.y += n.dy;
        n.rotation += n.rotationSpeed;

        if (n.x < -0.1) n.x = 1.1;
        if (n.x > 1.1) n.x = -0.1;
        if (n.y < -0.1) n.y = 1.1;
        if (n.y > 1.1) n.y = -0.1;
      }
      setState(() {});
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _FloatingNumbersPainter(_numbers),
    );
  }
}

class _FloatingNumbersPainter extends CustomPainter {
  final List<_FloatingNumber> numbers;
  _FloatingNumbersPainter(this.numbers);

  @override
  void paint(Canvas canvas, Size size) {
    for (var n in numbers) {
      canvas.save();
      final dx = n.x * size.width;
      final dy = n.y * size.height;
      canvas.translate(dx, dy);
      canvas.rotate(n.rotation);

      final textSpan = TextSpan(
        text: n.value.toString(),
        style: TextStyle(
          fontSize: n.fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent.withOpacity(n.opacity),
          shadows: [
            Shadow(
              blurRadius: 6.0, // stronger blur
              color: Colors.blueAccent.withOpacity(n.opacity),
              offset: const Offset(0, 0),
            ),
            Shadow(
              blurRadius: 3.0, // layered shadow for depth
              color: Colors.blueAccent.withOpacity(n.opacity / 2),
              offset: const Offset(0, 0),
            ),
          ],
        ),
      );

      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FloatingNumber {
  double x;
  double y;
  double dx;
  double dy;
  double rotation;
  double rotationSpeed;
  double fontSize;
  double opacity;
  final int value;

  _FloatingNumber({
    required this.value,
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.rotation,
    required this.rotationSpeed,
    required this.fontSize,
    required this.opacity,
  });
}
