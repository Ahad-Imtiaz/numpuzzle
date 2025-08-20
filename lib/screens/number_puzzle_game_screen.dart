import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:numpuzzle/enums/game_mode.dart';
import 'package:numpuzzle/models/cell.dart';

class NumberPuzzleGameScreen extends StatefulWidget {
  final GameMode mode;
  final bool isReversedMode;
  final bool isPunishWrongTapsActive;

  const NumberPuzzleGameScreen({
    super.key,
    required this.mode,
    required this.isReversedMode,
    required this.isPunishWrongTapsActive,
  });

  @override
  NumberPuzzleGameScreenState createState() => NumberPuzzleGameScreenState();
}

class NumberPuzzleGameScreenState extends State<NumberPuzzleGameScreen> {
  final int gridSize = 5;
  late List<List<Cell>> grid;
  int nextNumber = 1;
  int elapsedTime = 0;
  Timer? timer;
  bool gameStarted = false;
  int wrongTaps = 0;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _generateGrid();
  }

  void _generateGrid() {
    List<int> numbers = List.generate(gridSize * gridSize, (i) => i + 1)..shuffle();
    grid = List.generate(
      gridSize,
      (i) => List.generate(
        gridSize,
        (j) => Cell(
          number: numbers[i * gridSize + j],
          visited: widget.isReversedMode,
        ),
      ),
    );

    if (widget.mode != GameMode.simple) _generateRedFields();
    _setInitialNextNumber();
  }

  void _setInitialNextNumber() {
    nextNumber = !widget.isReversedMode ? 1 : grid.expand((r) => r).map((c) => c.number).reduce(max);
  }

  void _generateRedFields() {
    final selectableCells = grid.expand((r) => r).where((c) {
      if (widget.isReversedMode) return c.visited && c.number != nextNumber;
      return !c.visited && c.number != nextNumber;
    }).toList();

    int redCount = 0;
    switch (widget.mode) {
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
        if ((widget.isReversedMode && cell.visited) || (!widget.isReversedMode && !cell.visited)) {
          if (cell.number != nextNumber) cell.isLocked = false;
        }
      }
    }

    selectableCells.shuffle();
    for (int i = 0; i < redCount; i++) {
      selectableCells[i].isLocked = true;
    }
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
      elapsedTime = 0;
      wrongTaps = 0;
      _generateGrid();
    });

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => elapsedTime++);
    });
  }

  void _clearRedFields() {
    for (var row in grid) {
      for (var cell in row) {
        cell.isLocked = false;
      }
    }
  }

  void _recalculateNextNumber() {
    final selectable = grid.expand((r) => r).where((c) {
      if (widget.isReversedMode) return c.visited && !c.isLocked;
      return !c.visited && !c.isLocked;
    }).toList();

    if (selectable.isEmpty) {
      timer?.cancel();
      _showWinDialog();
      return;
    }

    nextNumber = widget.isReversedMode
        ? selectable.map((c) => c.number).reduce(max)
        : selectable.map((c) => c.number).reduce(min);
  }

  void _handleCorrectTap(Cell cell) {
    setState(() {
      cell.visited = !cell.visited;
      if (widget.mode == GameMode.intermediate) {
        _clearRedFields();
        _generateRedFields();
      }
      _recalculateNextNumber();
    });
  }

  void _handleWrongTap(Cell cell) {
    setState(() {
      cell.animateWrong = true;
      if (widget.isPunishWrongTapsActive) cell.isHidden = true;
      wrongTaps++;
    });

    // Reset animation after 200ms
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => cell.animateWrong = false);
      }
    });

    if (widget.isPunishWrongTapsActive) {
      // Restore number visibility after 2s
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => cell.isHidden = false);
        }
      });
    }
  }

  void _onCellTapped(int row, int col) {
    Cell cell = grid[row][col];

    if ((widget.isReversedMode && !cell.visited) || (!widget.isReversedMode && cell.visited)) {
      return;
    }

    (cell.number == nextNumber && !cell.isLocked) ? _handleCorrectTap(cell) : _handleWrongTap(cell);
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("You Won! 🎉"),
        content: Text("Time: ${elapsedTime}s\nWrong taps: $wrongTaps"),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startGameWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Ready to start?", style: TextStyle(fontSize: 24)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _startGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
          ),
          child: const Text("Start Game"),
        ),
      ],
    );

    final gameBoardWidget = Column(
      children: [
        const SizedBox(height: 16),
        Text("Time: ${elapsedTime}s", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text("Wrong taps: $wrongTaps", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: List.generate(gridSize, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(gridSize, (col) {
                      final cell = grid[row][col];
                      final baseColor = widget.isReversedMode
                          ? (cell.isLocked ? Colors.red : (cell.visited ? Colors.blue : Colors.grey[300]!))
                          : (cell.visited ? Colors.blue : (cell.isLocked ? Colors.red : Colors.grey[300]!));
                      final displayColor = cell.animateWrong ? Colors.orange : baseColor;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onCellTapped(row, col),
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
                                  color: (cell.visited || cell.isLocked) ? Colors.white : Colors.black,
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
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Number Puzzle - ${widget.mode.name} ${widget.isReversedMode ? '(Reversed)' : ''}"),
      ),
      body: Center(child: !gameStarted ? startGameWidget : gameBoardWidget),
    );
  }
}
