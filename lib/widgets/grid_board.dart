import 'package:flutter/material.dart';
import 'package:numpuzzle/models/grid_manager.dart';
import 'package:numpuzzle/widgets/cell_widget.dart';

class GridBoard extends StatelessWidget {
  final GridManager gridManager;
  final int gridSize;
  final bool isReversedMode;
  final void Function(int row, int col) onCellTapped;

  const GridBoard({
    super.key,
    required this.gridManager,
    required this.gridSize,
    required this.isReversedMode,
    required this.onCellTapped,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Take the smaller of width or height so it always fits
        final boardSize = constraints.biggest.shortestSide;

        // Account for spacing between cells
        final cellSize = (boardSize - (gridSize - 1) * 8) / gridSize;

        return SizedBox(
          width: boardSize,
          height: boardSize,
          child: Stack(children: [
            for (int row = 0; row < gridSize; row++)
              for (int col = 0; col < gridSize; col++)
                AnimatedPositioned(
                  key: ValueKey(gridManager.grid[row][col].number),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  left: col * (cellSize + 4),
                  top: row * (cellSize + 4),
                  width: cellSize,
                  height: cellSize,
                  child: CellWidget(
                    cell: gridManager.grid[row][col],
                    isReversedMode: isReversedMode,
                    onTap: () => onCellTapped(row, col),
                  ),
                ),
          ]),
        );
      },
    );
  }
}
