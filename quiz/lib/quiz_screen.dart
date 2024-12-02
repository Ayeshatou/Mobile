import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// ignore: unused_import
import 'package:hive/hive.dart';

class QuizScreen extends StatefulWidget {
  final int numQuestions;
  final String category;
  final String difficulty;
  final String type;

  const QuizScreen({
    super.key,
    required this.numQuestions,
    required this.category,
    required this.difficulty,
    required this.type,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<dynamic> questions;
  late int currentQuestionIndex;
  late int score;
  late Timer timer;
  late int remainingTime;
  late bool isAnswerSelected;
  late List<bool> answerCorrect;

  @override
  void initState() {
    super.initState();
    currentQuestionIndex = 0;
    score = 0;
    remainingTime = 10;  // Set a 10-second timer for each question
    isAnswerSelected = false;
    answerCorrect = [];
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final url =
        'https://opentdb.com/api.php?amount=${widget.numQuestions}&category=${widget.category}&difficulty=${widget.difficulty}&type=${widget.type}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        questions = json.decode(response.body)['results'];
      });
      startTimer();
    } else {
      // Handle API failure
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load questions")),
      );
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime == 0) {
        // Time's up, mark the question as incorrect
        setState(() {
          answerCorrect.add(false);
        });
        nextQuestion();
      } else {
        setState(() {
          remainingTime--;
        });
      }
    });
  }

  void selectAnswer(int index) {
    if (!isAnswerSelected) {
      setState(() {
        isAnswerSelected = true;
        answerCorrect.add(
          questions[currentQuestionIndex]['correct_answer'] ==
              questions[currentQuestionIndex]['incorrect_answers'][index]
              ? true
              : false,
        );
        if (answerCorrect.last) {
          score++;
        }
      });
      timer.cancel(); // Stop timer after an answer is selected
      Future.delayed(const Duration(seconds: 1), () {
        nextQuestion();
      });
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex + 1 < questions.length) {
      setState(() {
        currentQuestionIndex++;
        remainingTime = 10; // Reset timer
        isAnswerSelected = false;
      });
      startTimer();
    } else {
      // End of quiz, show summary
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SummaryScreen(score: score)),
      );
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentQuestion = questions[currentQuestionIndex];
    final questionText = currentQuestion['question'];
    final correctAnswer = currentQuestion['correct_answer'];
    final incorrectAnswers = List<String>.from(currentQuestion['incorrect_answers']);
    final answers = [...incorrectAnswers, correctAnswer]..shuffle();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Time'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / widget.numQuestions,
            ),
            const SizedBox(height: 16),
            Text(
              'Question ${currentQuestionIndex + 1} of ${widget.numQuestions}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              questionText,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Display answers
            ...List.generate(answers.length, (index) {
              return ElevatedButton(
                onPressed: isAnswerSelected ? null : () => selectAnswer(index),
                child: Text(answers[index]),
              );
            }),
            const SizedBox(height: 16),
            // Timer Display
            Text(
              'Time remaining: $remainingTime',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryScreen extends StatelessWidget {
  final int score;
  const SummaryScreen({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Total Score: $score',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: const Text('Back to Setup'),
            ),
          ],
        ),
      ),
    );
  }
}
