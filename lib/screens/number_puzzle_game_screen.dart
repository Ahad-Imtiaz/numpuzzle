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
  Timer? shuffleTimer;
  int shuffleCountdown = 2;
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

    int lockedCellCount = 0;
    switch (widget.mode) {
      case GameMode.easy:
        lockedCellCount = min(4 + random.nextInt(10), selectableCells.length);
        break;
      case GameMode.intermediate:
      case GameMode.hard:
        lockedCellCount = min(3 + random.nextInt(4), selectableCells.length);
        break;
      case GameMode.simple:
        lockedCellCount = 0;
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
    for (int i = 0; i < lockedCellCount; i++) {
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
      if (!mounted) return;

      setState(() => elapsedTime++);
    });

    if (widget.mode == GameMode.hard) {
      shuffleCountdown = 2;

      shuffleTimer?.cancel();
      shuffleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          shuffleCountdown--;

          if (shuffleCountdown <= 0) {
            _shuffleGrid();
            // Reset countdown
            shuffleCountdown = 2;
          }
        });
      });
    }
  }

  void _clearRedFields() {
    for (var row in grid) {
      for (var cell in row) {
        cell.isLocked = false;
      }
    }
  }

  void _shuffleGrid() {
    setState(() {
      if (random.nextBool()) {
        // shuffle row
        int rowIndex1 = random.nextInt(gridSize);
        int rowIndex2 = random.nextInt(gridSize);
        while (rowIndex1 == rowIndex2) {
          rowIndex2 = random.nextInt(gridSize);
        }
        final temp = grid[rowIndex1];
        grid[rowIndex1] = grid[rowIndex2];
        grid[rowIndex2] = temp;
      } else {
        // shuffle column
        int colIndex1 = random.nextInt(gridSize);
        int colIndex2 = random.nextInt(gridSize);
        while (colIndex1 == colIndex2) {
          colIndex2 = random.nextInt(gridSize);
        }
        for (int i = 0; i < gridSize; i++) {
          final temp = grid[i][colIndex1];
          grid[i][colIndex1] = grid[i][colIndex2];
          grid[i][colIndex2] = temp;
        }
      }
    });
  }

  void _recalculateNextNumber() {
    final selectable = grid.expand((r) => r).where((c) {
      if (widget.isReversedMode) return c.visited && !c.isLocked;
      return !c.visited && !c.isLocked;
    }).toList();

    if (selectable.isEmpty) {
      timer?.cancel();
      shuffleTimer?.cancel();
      if (!mounted) return;
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
      if (widget.mode == GameMode.intermediate || widget.mode == GameMode.hard) {
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
    shuffleTimer?.cancel();
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

    final gameBoardWidget = Column(children: [
      const SizedBox(height: 16),
      Text("Time: ${elapsedTime}s", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text("Wrong taps: $wrongTaps", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      if (widget.mode == GameMode.hard)
        Text("Time until shift: $shuffleCountdown", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 32),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellSize = (constraints.maxWidth - (gridSize - 1) * 8) / gridSize;

              return Stack(children: [
                for (int row = 0; row < gridSize; row++)
                  for (int col = 0; col < gridSize; col++)
                    AnimatedPositioned(
                      key: ValueKey(grid[row][col].number),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      left: col * (cellSize + 8),
                      top: row * (cellSize + 8),
                      width: cellSize,
                      height: cellSize,
                      child: GestureDetector(
                        onTap: () => _onCellTapped(row, col),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: grid[row][col].animateWrong
                                ? Colors.orange
                                : widget.isReversedMode
                                    ? (grid[row][col].isLocked
                                        ? Colors.red
                                        : (grid[row][col].visited ? Colors.blue : Colors.grey[300]!))
                                    : (grid[row][col].visited
                                        ? Colors.blue
                                        : (grid[row][col].isLocked ? Colors.red : Colors.grey[300]!)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              grid[row][col].isHidden ? '' : grid[row][col].number.toString(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    (grid[row][col].visited || grid[row][col].isLocked) ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
              ]);
            },
          ),
        ),
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text("Number Puzzle - ${widget.mode.name} ${widget.isReversedMode ? '(Reversed)' : ''}"),
      ),
      body: Center(child: !gameStarted ? startGameWidget : gameBoardWidget),
    );
  }
}
