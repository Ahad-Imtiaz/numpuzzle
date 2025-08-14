import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

enum GameMode { simple, easy, intermediate }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ModeSelectionScreen());
  }
}

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  bool reversedMode = false;

  void _startGame(BuildContext context, GameMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ZipGame(mode: mode, isReversedMode: reversedMode),
      ),
    );
  }

  void _showRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Game Rules"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Simple: Tap numbers in order from 1 to 25. No red cells."),
              SizedBox(height: 8),
              Text("Intermediate: Tap numbers in order from 1 to 25. Some red cells are traps."),
              SizedBox(height: 8),
              Text("Hard: Tap numbers in order from 1 to 25. Red cells appear and change dynamically."),
              SizedBox(height: 8),
              Text("Reversed Mode: Start with all cells selected and unselect them in order."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(_).pop,
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Game Mode")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CheckboxListTile(
              title: const Text("Reversed Mode"),
              value: reversedMode,
              onChanged: (val) {
                setState(() {
                  reversedMode = val ?? false;
                });
              },
            ),
            const SizedBox(height: 10),
            ...GameMode.values.map(
              (mode) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: () => _startGame(context, mode),
                  child: Text(mode.name),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showRules(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
              ),
              child: const Text("Rules"),
            ),
          ],
        ),
      ),
    );
  }
}

class Cell {
  final int number;
  bool visited;
  bool isRed;
  bool animateWrong = false;

  Cell({required this.number, this.visited = false, this.isRed = false});
}

class ZipGame extends StatefulWidget {
  final GameMode mode;
  final bool isReversedMode;

  const ZipGame({super.key, required this.mode, required this.isReversedMode});

  @override
  ZipGameState createState() => ZipGameState();
}

class ZipGameState extends State<ZipGame> {
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
      if (widget.isReversedMode) {
        return c.visited && c.number != nextNumber;
      }
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
      default:
        break;
    }

    // Clear old reds
    for (var row in grid) {
      for (var cell in row) {
        if ((widget.isReversedMode && cell.visited) || (!widget.isReversedMode && !cell.visited)) {
          if (cell.number != nextNumber) cell.isRed = false;
        }
      }
    }

    selectableCells.shuffle();
    for (int i = 0; i < redCount; i++) {
      selectableCells[i].isRed = true;
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
        cell.isRed = false;
      }
    }
  }

  void _recalculateNextNumber() {
    final selectable = grid.expand((r) => r).where((c) {
      if (widget.isReversedMode) {
        return c.visited && !c.isRed;
      }
      return !c.visited && !c.isRed;
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

  void _animateWrongTap(Cell cell) {
    setState(() {
      cell.animateWrong = true;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        cell.animateWrong = false;
      });
    });
  }

  void _onCellTapped(int row, int col) {
    Cell cell = grid[row][col];

    if (widget.isReversedMode) {
      if (!cell.visited) return;
      if (cell.number == nextNumber && !cell.isRed) {
        setState(() {
          cell.visited = false;
          if (widget.mode == GameMode.intermediate) {
            _clearRedFields();
            _generateRedFields();
          }
          _recalculateNextNumber();
        });
      } else {
        _animateWrongTap(cell);
        setState(() => wrongTaps++);
      }
    } else {
      if (cell.visited) return;
      if (cell.number == nextNumber && !cell.isRed) {
        setState(() {
          cell.visited = true;
          if (widget.mode == GameMode.intermediate) {
            _clearRedFields();
            _generateRedFields();
          }
          _recalculateNextNumber();
        });
      } else {
        _animateWrongTap(cell);
        setState(() => wrongTaps++);
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
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
    var startGame = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Ready to start?", style: TextStyle(fontSize: 24)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _startGame,
          child: const Text("Start Game"),
        ),
      ],
    );

    var startedGame = Column(children: [
      const SizedBox(height: 16),
      Text(
        "Time: ${elapsedTime}s",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      Text(
        "Wrong taps: $wrongTaps",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
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
                        ? (cell.isRed ? Colors.red : (cell.visited ? Colors.blue : Colors.grey[300]!))
                        : (cell.visited ? Colors.blue : (cell.isRed ? Colors.red : Colors.grey[300]!));

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
          ),
        ),
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Number Puzzle - ${widget.mode.name} ${widget.isReversedMode ? '(Reversed)' : ''}",
        ),
      ),
      body: Center(
        child: !gameStarted ? startGame : startedGame,
      ),
    );
  }
}
