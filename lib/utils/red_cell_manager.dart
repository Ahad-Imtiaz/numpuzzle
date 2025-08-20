import 'dart:math';

import 'package:numpuzzle/enums/game_mode.dart';
import 'package:numpuzzle/models/cell.dart';

class RedCellManager {
  final Random random = Random();

  void generateRedCells(List<List<Cell>> grid, bool isReversedMode, GameMode mode) {
    // Clear existing reds
    for (var row in grid) {
      for (var cell in row) {
        cell.isRed = false;
      }
    }

    final selectableCells = grid.expand((r) => r).where((c) {
      if (isReversedMode) return c.visited;
      return !c.visited;
    }).toList();

    int redCount = _getRedCount(mode, selectableCells.length);

    selectableCells.shuffle(random);
    for (int i = 0; i < redCount; i++) {
      selectableCells[i].isRed = true;
    }
  }

  int _getRedCount(GameMode mode, int maxCount) {
    switch (mode) {
      case GameMode.easy:
        return max(0, min(4 + random.nextInt(10), maxCount));
      case GameMode.intermediate:
        return max(0, min(3 + random.nextInt(4), maxCount));
      case GameMode.simple:
        return 0;
    }
  }
}
