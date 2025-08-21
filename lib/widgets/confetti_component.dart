import 'package:flutter/material.dart';

import 'package:confetti/confetti.dart';

class ConfettiComponent extends StatelessWidget {
  const ConfettiComponent({
    super.key,
    required ConfettiController confettiController,
  }) : _confettiController = confettiController;

  final ConfettiController _confettiController;

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: _confettiController,
      blastDirectionality: BlastDirectionality.explosive,
      minBlastForce: 10.0,
      maxBlastForce: 50.0,
      shouldLoop: false,
      numberOfParticles: 30,
      emissionFrequency: 0.05,
      gravity: 0.1,
      colors: const [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.yellow,
        Colors.pink,
        Colors.purple,
      ],
    );
  }
}
