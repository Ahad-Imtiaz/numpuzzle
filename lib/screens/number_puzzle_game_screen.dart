import 'dart:async';

import 'package:flutter/material.dart';

import 'package:numpuzzle/enums/game_mode.dart';
import 'package:numpuzzle/models/cell.dart';
import 'package:numpuzzle/models/grid_manager.dart';
import 'package:numpuzzle/widgets/cell_widget.dart';

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
  late GridManager gridManager;
  int elapsedTime = 0;
  int wrongTaps = 0;
  Timer? timer;
  Timer? shuffleTimer;
  int shuffleCountdown = 2;
  bool gameStarted = false;

  @override
  void initState() {
    super.initState();
    gridManager = GridManager(
      gridSize: gridSize,
      mode: widget.mode,
      isReversedMode: widget.isReversedMode,
    );
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
      elapsedTime = 0;
      wrongTaps = 0;
      gridManager.generateGrid();
    });

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => elapsedTime++);
    });

    if (widget.mode == GameMode.hard) {
      shuffleCountdown = 2;
      shuffleTimer?.cancel();
      shuffleTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          shuffleCountdown--;
          if (shuffleCountdown <= 0) {
            gridManager.shuffleGrid();
            shuffleCountdown = 2;
          }
        });
      });
    }
  }

  void _handleCorrectTap(Cell cell) {
    setState(() {
      cell.visited = !cell.visited;
      if (widget.mode == GameMode.intermediate || widget.mode == GameMode.hard) {
        gridManager.clearRedFields();
        gridManager.generateRedFields();
      }
      gridManager.recalculateNextNumber();
      if (gridManager.nextNumber == -1) _showWinDialog();
    });
  }

  void _handleWrongTap(Cell cell) {
    setState(() {
      cell.animateWrong = true;
      if (widget.isPunishWrongTapsActive) cell.isHidden = true;
      wrongTaps++;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => cell.animateWrong = false);
    });

    if (widget.isPunishWrongTapsActive) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => cell.isHidden = false);
      });
    }
  }

  void _onCellTapped(int row, int col) {
    final cell = gridManager.grid[row][col];
    if ((widget.isReversedMode && !cell.visited) || (!widget.isReversedMode && cell.visited)) return;

    (cell.number == gridManager.nextNumber && !cell.isLocked) ? _handleCorrectTap(cell) : _handleWrongTap(cell);
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
    shuffleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!gameStarted) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Number Puzzle - ${widget.mode.name} ${widget.isReversedMode ? '(Reversed)' : ''}"),
        ),
        body: Center(
          child: Column(
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
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Number Puzzle - ${widget.mode.name} ${widget.isReversedMode ? '(Reversed)' : ''}"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text("Time: ${elapsedTime}s", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("Wrong taps: $wrongTaps", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (widget.mode == GameMode.hard)
            Text("Time until shift: $shuffleCountdown",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cellSize = (constraints.maxWidth - (gridSize - 1) * 8) / gridSize;

                  return Stack(
                    children: [
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
                              isReversedMode: widget.isReversedMode,
                              onTap: () => _onCellTapped(row, col),
                            ),
                          ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
