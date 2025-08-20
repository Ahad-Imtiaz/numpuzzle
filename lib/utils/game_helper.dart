import 'dart:math';

import 'package:flutter/material.dart';

import 'package:numpuzzle/enums/game_mode.dart';
import 'package:numpuzzle/models/cell.dart';

class GameHelper {
  static List<List<Cell>> generateGrid({
    required int gridSize,
    required bool isReversedMode,
    required GameMode mode,
    required Random random,
    required Function(int) nextNumberCallback,
  }) {
    List<int> numbers = List.generate(gridSize * gridSize, (i) => i + 1)..shuffle();
    List<List<Cell>> grid = List.generate(
      gridSize,
      (i) => List.generate(
        gridSize,
        (j) => Cell(number: numbers[i * gridSize + j], visited: isReversedMode),
      ),
    );

    if (mode != GameMode.simple) _generateRedFields(grid, isReversedMode, mode, random);

    int nextNumber = isReversedMode ? grid.expand((r) => r).map((c) => c.number).reduce(max) : 1;
    nextNumberCallback(nextNumber);

    return grid;
  }

  static void _generateRedFields(List<List<Cell>> grid, bool isReversedMode, GameMode mode, Random random) {
    final selectableCells = grid.expand((r) => r).where((c) {
      if (isReversedMode) return c.visited;
      return !c.visited;
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

    selectableCells.shuffle();
    for (int i = 0; i < redCount; i++) {
      selectableCells[i].isRed = true;
    }
  }

  static void handleCellTap({
    required List<List<Cell>> grid,
    required int row,
    required int col,
    required bool isReversedMode,
    required GameMode mode,
    required bool isPunishWrongTapsActive,
    required VoidCallback wrongTapsIncrement,
    required Function(int) nextNumberCallback,
    required VoidCallback refreshGrid,
    required VoidCallback showWinDialog,
  }) {
    final cell = grid[row][col];
    final isCorrect = (isReversedMode ? cell.visited : !cell.visited) && !cell.isRed;

    if (isCorrect &&
        ((isReversedMode && cell.number == nextNumberCallback.call(0)) ||
            (!isReversedMode && cell.number == nextNumberCallback.call(0)))) {
      cell.visited = !cell.visited;
      if (mode == GameMode.intermediate) {
        for (var row in grid) {
          for (var c in row) {
            c.isRed = false;
          }
        }
        _generateRedFields(grid, isReversedMode, mode, Random());
      }
      // recalc next number
      final selectable =
          grid.expand((r) => r).where((c) => (isReversedMode ? c.visited : !c.visited) && !c.isRed).toList();
      if (selectable.isEmpty) {
        showWinDialog();
        return;
      }
      nextNumberCallback(
          isReversedMode ? selectable.map((c) => c.number).reduce(max) : selectable.map((c) => c.number).reduce(min));
      refreshGrid();
    } else {
      // wrong tap handling
      cell.animateWrong = true;
      if (isPunishWrongTapsActive) cell.isHidden = true;
      wrongTapsIncrement();

      Future.delayed(const Duration(milliseconds: 200), () {
        cell.animateWrong = false;
        refreshGrid();
      });

      if (isPunishWrongTapsActive) {
        Future.delayed(const Duration(seconds: 2), () {
          cell.isHidden = false;
          refreshGrid();
        });
      }
    }
  }
}
