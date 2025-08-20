import 'package:flutter/material.dart';

import 'package:numpuzzle/enums/game_mode.dart';

class GameInfoPanel extends StatelessWidget {
  final int elapsedTime;
  final int wrongTaps;
  final int? shuffleCountdown;
  final GameMode mode;

  const GameInfoPanel({
    super.key,
    required this.elapsedTime,
    required this.wrongTaps,
    this.shuffleCountdown,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Time: ${elapsedTime}s",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          "Wrong taps: $wrongTaps",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (mode == GameMode.hard && shuffleCountdown != null)
          Text(
            "Time until shift: $shuffleCountdown",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}
