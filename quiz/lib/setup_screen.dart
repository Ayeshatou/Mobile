import 'dart:convert';
import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'package:http/http.dart' as http;

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int numQuestions = 5;
  String category = '';
  String difficulty = 'easy';
  String type = 'multiple';
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body)['trivia_categories'];
        category = categories.isNotEmpty ? categories.first['id'].toString() : '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Quiz')),
      body: categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: numQuestions,
                    items: [5, 10, 15]
                        .map((e) => DropdownMenuItem(value: e, child: Text('$e Questions')))
                        .toList(),
                    onChanged: (value) => setState(() => numQuestions = value ?? 5),
                    decoration: const InputDecoration(labelText: 'Number of Questions'),
                  ),
                  DropdownButtonFormField<String>(
                    value: category,
                    items: categories
                        .map((cat) => DropdownMenuItem(
                              value: cat['id'].toString(),
                              child: Text(cat['name']),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => category = value ?? ''),
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  DropdownButtonFormField<String>(
                    value: difficulty,
                    items: ['easy', 'medium', 'hard']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e.capitalize())))
                        .toList(),
                    onChanged: (value) => setState(() => difficulty = value ?? 'easy'),
                    decoration: const InputDecoration(labelText: 'Difficulty'),
                  ),
                  DropdownButtonFormField<String>(
                    value: type,
                    items: ['multiple', 'boolean']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e.capitalize())))
                        .toList(),
                    onChanged: (value) => setState(() => type = value ?? 'multiple'),
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            numQuestions: numQuestions,
                            category: category,
                            difficulty: difficulty,
                            type: type,
                          ),
                        ),
                      );
                    },
                    child: const Text('Start Quiz'),
                  ),
                ],
              ),
            ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
