import 'package:flutter/material.dart';

class GameResultScreen extends StatelessWidget {
  final int score;
  final int stage;

  const GameResultScreen({super.key, required this.score, required this.stage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Your Score: $score',
              style: const TextStyle(
                fontSize: 32,
                color: Color(0xFF546E7A),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You reached stage: $stage',
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFF546E7A),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Play Again',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
