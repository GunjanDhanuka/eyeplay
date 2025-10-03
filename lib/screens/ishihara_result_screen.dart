import 'package:flutter/material.dart';

class IshiharaResultScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalPlates;

  const IshiharaResultScreen({
    super.key,
    required this.correctAnswers,
    required this.totalPlates,
  });

  @override
  Widget build(BuildContext context) {
    String rating;
    String message;

    double percentage = correctAnswers / totalPlates;

    if (percentage == 1.0) {
      rating = 'Normal Vision';
      message = 'You have normal color vision.';
    } else if (percentage >= 0.5) {
      rating = 'Possible Deficiency';
      message = 'You may have a mild color vision deficiency.';
    } else {
      rating = 'Likely Deficiency';
      message = 'It is likely you have a color vision deficiency. Please see an eye doctor.';
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
              'You answered $correctAnswers out of $totalPlates correctly.',
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFF546E7A),
              ),
              textAlign: TextAlign.center,
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
