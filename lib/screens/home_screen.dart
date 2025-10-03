
import 'package:eyeplay/screens/falling_letters_game_screen.dart';
import 'package:eyeplay/screens/ishihara_test_screen.dart';
import 'package:eyeplay/screens/snellen_chart_screen.dart';
import 'package:eyeplay/screens/camera_screen.dart';
import 'package:eyeplay/screens/game_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/fox_logo.png', height: 200),
                const SizedBox(height: 16),
                // const Text(
                //   'EyePlay',
                //   style: TextStyle(
                //     fontSize: 48,
                //     fontWeight: FontWeight.bold,
                //     color: Color(0xFF1A237E),
                //   ),
                // ),
                // const SizedBox(height: 16),
                const Text(
                  'Early vision screening for kids',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF546E7A),
                  ),
                ),
                const SizedBox(height: 48),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => const GameScreen()),
                //     );
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.orange,
                //     padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(30),
                //     ),
                //   ),
                //   child: const Text(
                //     'Play Now',
                //     style: TextStyle(
                //       fontSize: 24,
                //       color: Colors.white,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CameraScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Open Camera',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                // const SizedBox(height: 24),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => const SnellenChartScreen()),
                //     );
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.orange,
                //     padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(30),
                //     ),
                //   ),
                //   child: const Text(
                //     'Snellen Test',
                //     style: TextStyle(
                //       fontSize: 24,
                //       color: Colors.white,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const IshiharaTestScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Ishihara Test',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FallingLettersGameScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Falling Letters Game',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
