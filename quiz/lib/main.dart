import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'setup_screen.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('leaderboard'); // Open leaderboard box
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customizable Quiz App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SetupScreen(),
    );
  }
}
