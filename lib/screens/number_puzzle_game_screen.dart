import 'dart:math';

import 'package:flutter/material.dart';
import 'package:numpuzzle/enums/game_mode.dart';
import '../utils/game_helper.dart';
import '../utils/game_timer.dart';
import '../utils/red_cell_manager.dart';
import '../widgets/game_board.dart';
import '../widgets/start_game_widget.dart';
import '../models/cell.dart';

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
  int wrongTaps = 0;
  bool gameStarted = false;

  late GameTimer gameTimer;
  late RedCellManager redCellManager;

  @override
  void initState() {
    super.initState();
    redCellManager = RedCellManager();
    gameTimer = GameTimer(onTick: (time) => setState(() {}));
    _generateGrid();
  }

  void _generateGrid() {
    grid = GameHelper.generateGrid(
      gridSize: gridSize,
      isReversedMode: widget.isReversedMode,
      mode: widget.mode,
      random: Random(),
      nextNumberCallback: (value) => nextNumber = value,
    );

    if (widget.mode != GameMode.simple) {
      redCellManager.generateRedCells(grid, widget.isReversedMode, widget.mode);
    }
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
      wrongTaps = 0;
      _generateGrid();
    });
    gameTimer.reset();
    gameTimer.start();
  }

  void _onCellTapped(int row, int col) {
    GameHelper.handleCellTap(
      grid: grid,
      row: row,
      col: col,
      isReversedMode: widget.isReversedMode,
      mode: widget.mode,
      isPunishWrongTapsActive: widget.isPunishWrongTapsActive,
      wrongTapsIncrement: () => setState(() => wrongTaps++),
      nextNumberCallback: (value) => setState(() => nextNumber = value),
      refreshGrid: () => setState(() {}),
      showWinDialog: _showWinDialog,
    );
  }

  void _showWinDialog() {
    gameTimer.stop();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("You Won! 🎉"),
        content: Text("Time: ${gameTimer.elapsedTime}s\nWrong taps: $wrongTaps"),
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
    gameTimer.dispose();
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
      body: Center(
        child: !gameStarted
            ? StartGameWidget(onStart: _startGame)
            : GameBoard(
                grid: grid,
                onCellTapped: _onCellTapped,
                isReversedMode: widget.isReversedMode,
              ),
      ),
    );
  }
}
