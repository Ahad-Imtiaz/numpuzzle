import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:numpuzzle/utils/platform_util.dart';

class FloatingNumbersBackground extends StatefulWidget {
  const FloatingNumbersBackground({super.key});

  @override
  State<FloatingNumbersBackground> createState() => _FloatingNumbersBackgroundState();
}

class _FloatingNumbersBackgroundState extends State<FloatingNumbersBackground> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Random _random = Random();
  final List<_FloatingNumber> _numbers = [];

  Duration _lastTick = Duration.zero;
  bool get _isWebMobile => PlatformUtil.isMobileWeb;

  @override
  void initState() {
    super.initState();

    const totalNumbers = 25;
    for (int i = 0; i < totalNumbers; i++) {
      final value = i + 1;
      final opacity = _isWebMobile ? 0.75 : (0.15 + _random.nextDouble() * 0.45);

      final sx = (_random.nextDouble() - 0.5) * 0.001;
      final sy = (_random.nextDouble() - 0.5) * 0.001;

      _numbers.add(
        _FloatingNumber(
          value: value,
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          speedX: sx,
          speedY: sy,
          rotation: _random.nextDouble() * pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.001,
          opacity: opacity,
          fontSize: _isWebMobile ? (10 + _random.nextDouble() * 15) : (7 + _random.nextDouble() * 25),
          useShadows: !_isWebMobile,
        ),
      );
    }

    _ticker = createTicker((elapsed) {
      // Throttle to ~30fps on mobile web for perf.
      if (_isWebMobile && (elapsed - _lastTick) < const Duration(milliseconds: 33)) return;
      _lastTick = elapsed;

      _updateNumbers();
      setState(() {});
    })
      ..start();
  }

  void _updateNumbers() {
    const deltaTime = 1 / 60; // integrate at ~60Hz

    for (var n in _numbers) {
      // Smoothly interpolate speed back to the original target over time.
      if (n.decayRemaining > 0) {
        // proportion of remaining decay to apply this frame; clamp to [0, 1]
        final t = (deltaTime / n.decayRemaining).clamp(0.0, 1.0);
        n.speedX += (n.targetSpeedX - n.speedX) * t;
        n.speedY += (n.targetSpeedY - n.speedY) * t;
        n.decayRemaining -= deltaTime;
        if (n.decayRemaining < 0) n.decayRemaining = 0;
      }

      n.x += n.speedX;
      n.y += n.speedY;
      n.rotation += n.rotationSpeed;

      // Wrap around edges
      if (n.x < -0.1) n.x = 1.1;
      if (n.x > 1.1) n.x = -0.1;
      if (n.y < -0.1) n.y = 1.1;
      if (n.y > 1.1) n.y = -0.1;

      // Animate font size (mobile web excluded)
      if (!_isWebMobile) {
        final time = DateTime.now().millisecondsSinceEpoch / 1000;
        n.fontSize = n.baseFontSize * (0.9 + 0.2 * sin(time * n.sizeSpeed + n.sizePhase));
        n.maybeUpdatePainter(); // lazy relayout only when size changed enough
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _handleTap(Offset position, BuildContext context) {
    if (_isWebMobile) return; // interactivity off on mobile web for performance

    final size = MediaQuery.of(context).size;
    final tapX = position.dx / size.width;
    final tapY = position.dy / size.height;

    for (var n in _numbers) {
      final dx = n.x - tapX;
      final dy = n.y - tapY;
      final distSq = dx * dx + dy * dy;
      const radius = 0.15;
      if (distSq < radius * radius) {
        final dist = sqrt(distSq).clamp(0.0001, 10.0); // avoid div-by-zero

        // Push away from the tap
        n.speedX += dx / dist * 0.02;
        n.speedY += dy / dist * 0.02;

        // Then smoothly return to original speed over 2 seconds
        n.targetSpeedX = n.originalSpeedX;
        n.targetSpeedY = n.originalSpeedY;
        n.decayRemaining = 2.0; // seconds back to baseline
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Listener(
        onPointerDown: !_isWebMobile ? (e) => _handleTap(e.localPosition, context) : null,
        onPointerMove: !_isWebMobile ? (e) => _handleTap(e.localPosition, context) : null,
        child: CustomPaint(
          painter: _FloatingNumberPainter(_numbers),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _FloatingNumber {
  double x;
  double y;

  // Current speed
  double speedX;
  double speedY;

  // Baseline/original speed (what we return to)
  final double originalSpeedX;
  final double originalSpeedY;

  // Target speed for decay back to baseline
  double targetSpeedX;
  double targetSpeedY;

  // Time remaining to decay back (seconds)
  double decayRemaining = 0;

  double rotation;
  double rotationSpeed;
  final int value;
  final double opacity;
  final double baseFontSize;
  final bool useShadows;

  final double sizePhase;
  final double sizeSpeed;
  double fontSize;

  final TextPainter painter;
  double _lastLaidOutFontSize;

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
    required this.useShadows,
  })  : baseFontSize = fontSize,
        fontSize = fontSize,
        originalSpeedX = speedX,
        originalSpeedY = speedY,
        targetSpeedX = speedX,
        targetSpeedY = speedY,
        sizePhase = Random().nextDouble() * 2 * pi,
        sizeSpeed = 0.2 + Random().nextDouble() * 0.3,
        painter = TextPainter(
          text: TextSpan(
            text: value.toString(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent.withOpacity(opacity),
              shadows: useShadows
                  ? [
                      Shadow(
                        blurRadius: 6.0,
                        color: Colors.blueAccent.withOpacity(opacity),
                        offset: Offset.zero,
                      ),
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.blueAccent.withOpacity(opacity),
                        offset: Offset.zero,
                      ),
                    ]
                  : null,
            ),
          ),
          textDirection: TextDirection.ltr,
        ),
        _lastLaidOutFontSize = fontSize {
    painter.layout();
  }

  /// Only relayout when the font size changes meaningfully to reduce cost.
  void maybeUpdatePainter() {
    if ((fontSize - _lastLaidOutFontSize).abs() >= 0.5) {
      painter.text = TextSpan(
        text: value.toString(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent.withOpacity(opacity),
          shadows: useShadows
              ? [
                  Shadow(
                    blurRadius: 6.0,
                    color: Colors.blueAccent.withOpacity(opacity),
                    offset: Offset.zero,
                  ),
                  Shadow(
                    blurRadius: 3.0,
                    color: Colors.blueAccent.withOpacity(opacity),
                    offset: Offset.zero,
                  ),
                ]
              : null,
        ),
      );
      painter.layout();
      _lastLaidOutFontSize = fontSize;
    }
  }
}

class _FloatingNumberPainter extends CustomPainter {
  final List<_FloatingNumber> numbers;
  _FloatingNumberPainter(this.numbers);

  @override
  void paint(Canvas canvas, Size size) {
    for (var n in numbers) {
      canvas.save();
      canvas.translate(n.x * size.width, n.y * size.height);
      canvas.rotate(n.rotation);
      n.painter.paint(canvas, Offset(-n.painter.width / 2, -n.painter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingNumberPainter oldDelegate) => true;
}
