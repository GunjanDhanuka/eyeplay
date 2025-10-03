import 'package:flutter/material.dart';

class SnellenResultScreen extends StatelessWidget {
  final int score;

  const SnellenResultScreen({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    String rating;
    String message;

    if (score <= 20) {
      rating = 'Excellent!';
      message = 'You have 20/20 vision!';
    } else if (score <= 40) {
      rating = 'Good!';
      message = 'Your vision is sharp!';
    } else {
      rating = 'Needs Improvement!';
      message = 'It\'s recommended to visit an eye doctor.';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rating,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Your Visual Acuity:',
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFF546E7A),
              ),
            ),
            Text(
              '20 / $score',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF546E7A),
              ),
              textAlign: TextAlign.center,
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
                'Done',
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
