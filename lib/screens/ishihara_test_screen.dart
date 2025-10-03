import 'package:flutter/material.dart';
import 'package:eyeplay/screens/shape_finder_game_screen.dart';
import 'package:flutter/material.dart';

class IshiharaTestScreen extends StatefulWidget {
  const IshiharaTestScreen({super.key});

  @override
  State<IshiharaTestScreen> createState() => _IshiharaTestScreenState();
}

class _IshiharaTestScreenState extends State<IshiharaTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ishihara Test'),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ready to play the Ishihara game?',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ShapeFinderGameScreen(),
                  ),
                );
              },
              child: const Text('Play Game'),
            ),
          ],
        ),
      ),
    );
  }
}
