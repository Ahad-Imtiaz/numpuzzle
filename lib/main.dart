import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

enum GameMode { simple, intermediate, hard }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ModeSelectionScreen());
  }
}

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  void _startGame(BuildContext context, GameMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ZipGame(mode: mode)),
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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

  Cell({required this.number, this.visited = false, this.isRed = false});
}

class ZipGame extends StatefulWidget {
  final GameMode mode;
  const ZipGame({super.key, required this.mode});

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
        (j) => Cell(number: numbers[i * gridSize + j]),
      ),
    );

    if (widget.mode != GameMode.simple) _generateRedFields();
  }

  void _generateRedFields() {
    final selectableCells = grid.expand((r) => r).where((c) => !c.visited && c.number != nextNumber).toList();

    int redCount = 0;
    switch (widget.mode) {
      case GameMode.intermediate:
        redCount = min(4 + random.nextInt(10), selectableCells.length);
        break;
      case GameMode.hard:
        redCount = min(3 + random.nextInt(4), selectableCells.length);
        break;
      case GameMode.simple:
        redCount = 0;
        break;
    }

    // Clear previous red cells
    for (var row in grid) {
      for (var cell in row) {
        if (!cell.visited && cell.number != nextNumber) cell.isRed = false;
      }
    }

    // Randomly pick redCount cells
    selectableCells.shuffle();
    for (int i = 0; i < redCount; i++) {
      selectableCells[i].isRed = true;
    }
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
      nextNumber = 1;
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
    final selectable = grid.expand((r) => r).where((c) => !c.visited && !c.isRed).toList();
    if (selectable.isEmpty) {
      timer?.cancel();
      _showWinDialog();
      return;
    }
    nextNumber = selectable.map((c) => c.number).reduce(min);
  }

  void _onCellTapped(int row, int col) {
    Cell cell = grid[row][col];

    if (cell.visited) return;

    if (cell.number == nextNumber && !cell.isRed) {
      setState(() {
        cell.visited = true;
        if (widget.mode == GameMode.hard) {
          _clearRedFields();
          _generateRedFields();
        }
        _recalculateNextNumber();
      });
    } else {
      setState(() => wrongTaps++);
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
    return Scaffold(
      appBar: AppBar(title: Text("Number Puzzle - ${widget.mode.name}")),
      body: Center(
        child: !gameStarted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Ready to start?", style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _startGame,
                    child: const Text("Start Game"),
                  ),
                ],
              )
            : Column(
                children: [
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
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => _onCellTapped(row, col),
                                    child: Container(
                                      margin: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: cell.visited
                                            ? Colors.blue
                                            : cell.isRed
                                                ? Colors.red
                                                : Colors.grey[300],
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
                ],
              ),
      ),
    );
  }
}
