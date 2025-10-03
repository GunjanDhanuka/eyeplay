import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:eyeplay/screens/result_screen.dart';

class LoadingScreen extends StatefulWidget {
  final XFile image;

  const LoadingScreen({super.key, required this.image});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _computeAndNavigate();
  }

  Future<void> _computeAndNavigate() async {
    final score = await _computeRefractiveScore();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResultScreen(score: score),
        ),
      );
    }
  }

  Future<double> _computeRefractiveScore() async {
    await Future.delayed(const Duration(seconds: 3));
    return 1.25;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'Analyzing your awesome eyes...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
