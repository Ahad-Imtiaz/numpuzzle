import 'package:flutter/material.dart';

import 'package:numpuzzle/models/cell.dart';
import 'package:numpuzzle/widgets/cell_widget.dart';

class GameBoard extends StatelessWidget {
  final List<List<Cell>> grid;
  final bool isReversedMode;
  final Function(int row, int col) onCellTapped;

  const GameBoard({super.key, required this.grid, required this.isReversedMode, required this.onCellTapped});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(grid.length, (row) {
        return Expanded(
          child: Row(
            children: List.generate(grid[row].length, (col) {
              return CellWidget(
                cell: grid[row][col],
                isReversedMode: isReversedMode,
                onTap: () => onCellTapped(row, col),
              );
            }),
          ),
        );
      }),
    );
  }
}
