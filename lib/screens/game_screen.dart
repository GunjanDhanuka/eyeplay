import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find the Hidden Shape'),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Which shape is different?',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 48),
            // Add game widgets here
          ],
        ),
      ),
    );
  }
}
