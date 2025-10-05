
import 'package:eyeplay/models/ishihara_level.dart';
import 'package:flutter/material.dart';

class IshiharaResultScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalPlates;
  final IshiharaLevel? failedLevel;
  final int? failedLevelIndex;

  const IshiharaResultScreen({
    super.key,
    required this.correctAnswers,
    required this.totalPlates,
    this.failedLevel,
    this.failedLevelIndex,
  });

  @override
  Widget build(BuildContext context) {
    String rating;
    String message;

    if (failedLevel != null) {
      rating = 'Deficiency Found';
      message =
          'You may have a color vision deficiency. You failed on level $failedLevelIndex.';
    } else if (correctAnswers == totalPlates) {
      rating = 'Normal Vision';
      message = 'You have normal color vision.';
    } else {
      // This case should ideally not be reached if we end on first failure,
      // but as a fallback.
      rating = 'Possible Deficiency';
      message =
          'You may have a mild color vision deficiency. Please see an eye doctor.';
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              'You answered $correctAnswers out of $totalPlates plates correctly.',
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFF546E7A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (failedLevel != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed colors:', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Container(
                      width: 24,
                      height: 24,
                      color: failedLevel!.shapeColor,
                    ),
                    const SizedBox(width: 5),
                    const Text('on', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 5),
                    Container(
                      width: 24,
                      height: 24,
                      color: failedLevel!.backgroundColor,
                    ),
                  ],
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
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
