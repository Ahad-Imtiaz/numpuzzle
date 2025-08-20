import 'dart:async';
import 'package:flutter/material.dart';
import 'package:numpuzzle/enums/game_mode.dart';
import 'package:numpuzzle/models/grid_manager.dart';
import 'package:numpuzzle/widgets/game_info_panel.dart';
import 'package:numpuzzle/widgets/grid_board.dart';

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
  int shuffleCountdown = 2;
  bool gameStarted = false;

  Timer? timer;
  Timer? shuffleTimer;

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
    _resetGame();
    gridManager.generateGrid();
    _startTimers();
  }

  void _resetGame() {
    setState(() {
      gameStarted = true;
      elapsedTime = 0;
      wrongTaps = 0;
      shuffleCountdown = 2;
    });

    timer?.cancel();
    shuffleTimer?.cancel();
  }

  void _startTimers() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => elapsedTime++);
    });

    if (widget.mode == GameMode.hard) {
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

  void _onCellTapped(int row, int col) {
    final cell = gridManager.grid[row][col];

    if ((widget.isReversedMode && !cell.visited) || (!widget.isReversedMode && cell.visited)) return;

    if (cell.number == gridManager.nextNumber && !cell.isLocked) {
      _handleCorrectTap(cell);
    } else {
      _handleWrongTap(cell);
    }
  }

  void _handleCorrectTap(cell) {
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

  void _handleWrongTap(cell) {
    wrongTaps++;
    _animateWrongCell(cell, hide: widget.isPunishWrongTapsActive);
  }

  void _animateWrongCell(cell, {required bool hide}) {
    setState(() {
      cell.animateWrong = true;
      if (hide) cell.isHidden = true;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        cell.animateWrong = false;
      });
    });

    if (hide) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          cell.isHidden = false;
        });
      });
    }
  }

  void _stopTimers() {
    timer?.cancel();
    shuffleTimer?.cancel();
    timer = null;
    shuffleTimer = null;
  }

  void _showWinDialog() {
    _stopTimers();

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Number Puzzle - ${widget.mode.name} ${widget.isReversedMode ? '(Reversed)' : ''}",
        ),
      ),
      body: gameStarted ? _buildGameUI() : _buildStartUI(),
    );
  }

  Widget _buildStartUI() => Center(
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
      );

  Widget _buildGameUI() => Column(
        children: [
          const SizedBox(height: 16),
          GameInfoPanel(
            elapsedTime: elapsedTime,
            wrongTaps: wrongTaps,
            shuffleCountdown: widget.mode == GameMode.hard ? shuffleCountdown : null,
            mode: widget.mode,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridBoard(
                gridManager: gridManager,
                gridSize: gridSize,
                isReversedMode: widget.isReversedMode,
                onCellTapped: _onCellTapped,
              ),
            ),
          ),
        ],
      );
}
