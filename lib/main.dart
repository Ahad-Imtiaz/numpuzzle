import 'package:flutter/material.dart';

import 'package:numpuzzle/screens/mode_selection_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    print('----- Toggling them');
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.grey[200],
      cardColor: Colors.white,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black87),
      ),
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blueGrey,
      scaffoldBackgroundColor: Colors.black,
      cardColor: Colors.grey[900],
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white70),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NumPuzzle',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: ModeSelectionScreen(
        onToggleTheme: toggleTheme,
      ),
    );
  }
}
