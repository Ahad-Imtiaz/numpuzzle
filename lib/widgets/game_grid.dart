import 'package:flutter/material.dart';

import 'package:numpuzzle/models/cell.dart';

class GameGrid extends StatelessWidget {
  final List<List<Cell>> grid;
  final bool isReversedMode;
  final void Function(int row, int col) onCellTapped;

  const GameGrid({
    super.key,
    required this.grid,
    required this.isReversedMode,
    required this.onCellTapped,
  });

  @override
  Widget build(BuildContext context) {
    final gridSize = grid.length;

    return Column(
      children: List.generate(gridSize, (row) {
        return Expanded(
          child: Row(
            children: List.generate(gridSize, (col) {
              final cell = grid[row][col];
              final baseColor = isReversedMode
                  ? (cell.isRed ? Colors.red : (cell.visited ? Colors.blue : Colors.grey[300]!))
                  : (cell.visited ? Colors.blue : (cell.isRed ? Colors.red : Colors.grey[300]!));
              final displayColor = cell.animateWrong ? Colors.orange : baseColor;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onCellTapped(row, col),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: displayColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${cell.number}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: (cell.visited || cell.isRed) ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
