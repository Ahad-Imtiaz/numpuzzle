import 'dart:math';

import 'package:numpuzzle/models/cell.dart';

enum GameMode { simple, easy, intermediate }

class GameHelper {
  static List<List<Cell>> generateGrid(int gridSize, GameMode mode, bool isReversedMode) {
    List<int> numbers = List.generate(gridSize * gridSize, (i) => i + 1)..shuffle();

    List<List<Cell>> grid = List.generate(
      gridSize,
      (i) => List.generate(
        gridSize,
        (j) => Cell(
          number: numbers[i * gridSize + j],
          visited: isReversedMode,
        ),
      ),
    );

    if (mode != GameMode.simple) {
      generateRedFields(grid, mode, isReversedMode, nextNumber(grid, isReversedMode));
    }

    return grid;
  }

  static int nextNumber(List<List<Cell>> grid, bool isReversedMode) {
    return !isReversedMode
        ? grid.expand((r) => r).map((c) => c.number).reduce(min)
        : grid.expand((r) => r).map((c) => c.number).reduce(max);
  }

  static void generateRedFields(List<List<Cell>> grid, GameMode mode, bool isReversedMode, int nextNumber) {
    final random = Random();
    final selectableCells = grid.expand((r) => r).where((c) {
      return isReversedMode ? c.visited && c.number != nextNumber : !c.visited && c.number != nextNumber;
    }).toList();

    int redCount = 0;
    switch (mode) {
      case GameMode.easy:
        redCount = min(4 + random.nextInt(10), selectableCells.length);
        break;
      case GameMode.intermediate:
        redCount = min(3 + random.nextInt(4), selectableCells.length);
        break;
      case GameMode.simple:
        redCount = 0;
        break;
    }

    // Clear old reds
    for (var row in grid) {
      for (var cell in row) {
        if ((isReversedMode && cell.visited) || (!isReversedMode && !cell.visited)) {
          if (cell.number != nextNumber) cell.isRed = false;
        }
      }
    }

    selectableCells.shuffle();
    for (int i = 0; i < redCount; i++) {
      selectableCells[i].isRed = true;
    }
  }
}
