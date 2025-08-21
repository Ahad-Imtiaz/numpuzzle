import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:numpuzzle/models/cell.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final bool isReversedMode;
  final VoidCallback onTap;

  const CellWidget({
    super.key,
    required this.cell,
    required this.isReversedMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: cell.animateWrong
              ? Colors.orange
              : isReversedMode
                  ? (cell.isLocked ? Colors.red : (cell.visited ? Colors.blue : Colors.grey[300]!))
                  : (cell.visited ? Colors.blue : (cell.isLocked ? Colors.red : Colors.grey[300]!)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            cell.isHidden ? '' : cell.number.toString(),
            style: TextStyle(
              fontSize: kIsWeb ? 28 : 20,
              fontWeight: FontWeight.bold,
              color: (cell.visited || cell.isLocked) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
