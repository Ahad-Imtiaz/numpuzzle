import 'dart:math';

import 'package:numpuzzle/enums/game_mode.dart';
import 'package:numpuzzle/models/cell.dart';

class GridManager {
  final int gridSize;
  final GameMode mode;
  final bool isReversedMode;
  final Random random = Random();

  late List<List<Cell>> grid;
  int nextNumber = 1;

  GridManager({
    required this.gridSize,
    required this.mode,
    required this.isReversedMode,
  }) {
    generateGrid();
  }

  void generateGrid() {
    List<int> numbers = List.generate(gridSize * gridSize, (i) => i + 1)..shuffle();
    grid = List.generate(
      gridSize,
      (i) => List.generate(
        gridSize,
        (j) => Cell(number: numbers[i * gridSize + j], visited: isReversedMode),
      ),
    );

    if (mode != GameMode.simple) generateRedFields();
    _setInitialNextNumber();
  }

  void _setInitialNextNumber() {
    nextNumber = !isReversedMode ? 1 : grid.expand((r) => r).map((c) => c.number).reduce(max);
  }

  void generateRedFields() {
    final selectableCells = grid.expand((r) => r).where((c) {
      if (isReversedMode) return c.visited && c.number != nextNumber;
      return !c.visited && c.number != nextNumber;
    }).toList();

    int lockedCellCount = 0;
    switch (mode) {
      case GameMode.easy:
        lockedCellCount = min(4 + random.nextInt(10), selectableCells.length);
        break;
      case GameMode.intermediate:
      case GameMode.hard:
        lockedCellCount = min(3 + random.nextInt(4), selectableCells.length);
        break;
      case GameMode.simple:
        lockedCellCount = 0;
        break;
    }

    for (var row in grid) {
      for (var cell in row) {
        if ((isReversedMode && cell.visited) || (!isReversedMode && !cell.visited)) {
          if (cell.number != nextNumber) cell.isLocked = false;
        }
      }
    }

    selectableCells.shuffle();
    for (int i = 0; i < lockedCellCount; i++) {
      selectableCells[i].isLocked = true;
    }
  }

  void clearRedFields() {
    for (var row in grid) {
      for (var cell in row) {
        cell.isLocked = false;
      }
    }
  }

  void shuffleGrid() {
    if (random.nextBool()) {
      int row1 = random.nextInt(gridSize);
      int row2 = random.nextInt(gridSize);
      while (row1 == row2) {
        row2 = random.nextInt(gridSize);
      }
      final temp = grid[row1];
      grid[row1] = grid[row2];
      grid[row2] = temp;
    } else {
      int col1 = random.nextInt(gridSize);
      int col2 = random.nextInt(gridSize);
      while (col1 == col2) {
        col2 = random.nextInt(gridSize);
      }
      for (int i = 0; i < gridSize; i++) {
        final temp = grid[i][col1];
        grid[i][col1] = grid[i][col2];
        grid[i][col2] = temp;
      }
    }
  }

  void recalculateNextNumber() {
    final selectable = grid.expand((r) => r).where((c) {
      if (isReversedMode) return c.visited && !c.isLocked;
      return !c.visited && !c.isLocked;
    }).toList();

    if (selectable.isEmpty) {
      nextNumber = -1; // signal for win
      return;
    }

    nextNumber =
        isReversedMode ? selectable.map((c) => c.number).reduce(max) : selectable.map((c) => c.number).reduce(min);
  }
}
