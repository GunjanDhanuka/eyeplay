import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final double score;

  const ResultScreen({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    String rating;
    int stars;
    String message;

    if (score < 1.0) {
      stars = 3;
      rating = 'Excellent!';
      message = 'Your eyes are super sharp!';
    } else if (score < 2.0) {
      stars = 2;
      rating = 'Good!';
      message = 'You\'re doing great!';
    } else {
      stars = 1;
      rating = 'Needs Improvement!';
      message = 'Let\'s play again soon!';
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  index < stars ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 64,
                );
              }),
            ),
            const SizedBox(height: 32),
            Text(
              'Your score: ${score.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFF546E7A),
              ),
            ),
            const SizedBox(height: 16),
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
