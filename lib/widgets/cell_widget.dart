import 'package:flutter/material.dart';

import 'package:numpuzzle/models/cell.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final bool isReversedMode;
  final VoidCallback onTap;

  const CellWidget({super.key, required this.cell, required this.isReversedMode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final baseColor = isReversedMode
        ? (cell.isRed ? Colors.red : (cell.visited ? Colors.blue : Colors.grey[300]!))
        : (cell.visited ? Colors.blue : (cell.isRed ? Colors.red : Colors.grey[300]!));
    final displayColor = cell.animateWrong ? Colors.orange : baseColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
              cell.isHidden ? '' : cell.number.toString(),
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
  }
}
