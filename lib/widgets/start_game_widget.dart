import 'package:flutter/material.dart';

class StartGameWidget extends StatelessWidget {
  final VoidCallback onStart;
  const StartGameWidget({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Ready to start?", style: TextStyle(fontSize: 24)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onStart,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
          ),
          child: const Text("Start Game"),
        ),
      ],
    );
  }
}
