import 'package:flutter/material.dart';

import 'package:numpuzzle/screens/number_puzzle_game_screen.dart';
import 'package:numpuzzle/utils/game_helper.dart';
import 'package:numpuzzle/widgets/floating_numbers_background.dart';

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
        builder: (_) => NumberPuzzleGameScreen(mode: mode, isReversedMode: reversedMode),
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
      body: Stack(
        children: [
          const FloatingNumbersBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CheckboxListTile(
                  title: const Text("Reversed Mode"),
                  value: reversedMode,
                  onChanged: (val) => setState(() => reversedMode = val ?? false),
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
        ],
      ),
    );
  }
}
