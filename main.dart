import 'dart:io' show Platform; // Import for platform detection
import 'package:flutter/foundation.dart' show kIsWeb; // Web detection
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // State management with provider
import 'package:window_size/window_size.dart'; // Import the window_size package for desktop

void main() {
  if (Platform.isWindows) {
    setupWindow(); // Set up the window only for Windows
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => Counter(),
      child: const MyApp(),
    ),
  );
}

// Function to set up the window size for Windows
void setupWindow() {
  WidgetsFlutterBinding.ensureInitialized();
  setWindowTitle('Flutter Counter App'); // Set window title
  setWindowMinSize(const Size(400, 800)); // Set minimum window size
  setWindowMaxSize(const Size(800, 800)); // Set maximum window size
  getCurrentScreen().then((screen) {
    setWindowFrame(Rect.fromCenter(
      center: screen!.frame.center,
      width: 500, // Set initial width of the window
      height: 800, // Set initial height of the window
    ));
  });
}

// Counter class with state management
class Counter with ChangeNotifier {
  int value = 0;

  void increment() {
    value += 1;
    notifyListeners(); // Notify listeners to rebuild widgets
  }

  void decrement() {
    if (value > 0) {
      value -= 1;
      notifyListeners(); // Notify listeners to rebuild widgets
    }
  }
}

// Root of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Counter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Using Material 3 for styling
      ),
      home: const MyHomePage(),
    );
  }
}

// Main page displaying the counter
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Counter App'),
      ),
      body: Consumer<Counter>(
        builder: (context, counter, child) {
          String message;
          Color backgroundColor;

          // Define milestones and corresponding messages and colors
          if (counter.value <= 12) {
            message = "You're a child!";
            backgroundColor = Colors.lightBlue;
          } else if (counter.value <= 19) {
            message = "Teenager time!";
            backgroundColor = Colors.lightGreen;
          } else if (counter.value <= 30) {
            message = "You're a young adult!";
            backgroundColor = Colors.yellow;
          } else if (counter.value <= 50) {
            message = "You're an adult now!";
            backgroundColor = Colors.orange;
          } else {
            message = "Golden years!";
            backgroundColor = Colors.grey;
          }

          return Container(
            color: backgroundColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Your age is:'),
                  Text(
                    '${counter.value}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              var counter = context.read<Counter>();
              counter.decrement();
            },
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              var counter = context.read<Counter>();
              counter.increment();
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
