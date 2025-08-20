import 'dart:math';

import 'package:numpuzzle/enums/game_mode.dart';
import 'package:numpuzzle/models/cell.dart';

class PuzzleController {
  final int gridSize;
  final GameMode mode;
  final bool isReversedMode;
  final bool isPunishWrongTapsActive;

  late List<List<Cell>> grid;
  int nextNumber = 1;
  int wrongTaps = 0;
  final Random random = Random();

  PuzzleController({
    this.gridSize = 5,
    required this.mode,
    required this.isReversedMode,
    required this.isPunishWrongTapsActive,
  }) {
    generateGrid();
  }

  void generateGrid() {
    List<int> numbers = List.generate(gridSize * gridSize, (i) => i + 1)..shuffle();
    grid = List.generate(
      gridSize,
      (i) => List.generate(
        gridSize,
        (j) => Cell(
          number: numbers[i * gridSize + j],
          visited: isReversedMode,
        ),
      ),
    );
    if (mode != GameMode.simple) generateRedFields();
    setInitialNextNumber();
  }

  void setInitialNextNumber() {
    nextNumber = !isReversedMode ? 1 : grid.expand((r) => r).map((c) => c.number).reduce(max);
  }

  void generateRedFields() {
    final selectableCells = grid.expand((r) => r).where((c) {
      if (isReversedMode) return c.visited && c.number != nextNumber;
      return !c.visited && c.number != nextNumber;
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

  void clearRedFields() {
    for (var row in grid) {
      for (var cell in row) {
        cell.isRed = false;
      }
    }
  }

  void recalculateNextNumber() {
    final selectable = grid.expand((r) => r).where((c) {
      if (isReversedMode) return c.visited && !c.isRed;
      return !c.visited && !c.isRed;
    }).toList();

    if (selectable.isEmpty) {
      nextNumber = -1; // signal game finished
      return;
    }

    nextNumber =
        isReversedMode ? selectable.map((c) => c.number).reduce(max) : selectable.map((c) => c.number).reduce(min);
  }

  void handleCellTap(Cell cell) {
    if (isReversedMode) {
      if (!cell.visited) return;
      if (cell.number == nextNumber && !cell.isRed) {
        cell.visited = false;
        if (mode == GameMode.intermediate) {
          clearRedFields();
          generateRedFields();
        }
        recalculateNextNumber();
      } else {
        wrongTaps++;
      }
    } else {
      if (cell.visited) return;
      if (cell.number == nextNumber && !cell.isRed) {
        cell.visited = true;
        if (mode == GameMode.intermediate) {
          clearRedFields();
          generateRedFields();
        }
        recalculateNextNumber();
      } else {
        wrongTaps++;
      }
    }
  }
}
