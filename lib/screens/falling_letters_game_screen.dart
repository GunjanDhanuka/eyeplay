import 'dart:async';
import 'package:eyeplay/screens/game_result_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FallingLettersGameScreen extends StatefulWidget {
  const FallingLettersGameScreen({super.key});

  @override
  State<FallingLettersGameScreen> createState() => _FallingLettersGameScreenState();
}

class _FallingLettersGameScreenState extends State<FallingLettersGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<FallingLetter> _letters = [];
  List<FallingLetter> _poppedLetters = [];
  double _gameHeight = 0;
  double _gameWidth = 0;
  final Random _random = Random();
  final List<String> _allowedLetters = ['A', 'B', 'D', 'E', 'F', 'M', 'N', 'O', 'V'];
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  String _speechStatus = '';
  int _score = 0;
  int _stage = 1;
  int _stageScore = 0;
  int _nextStageScore = 10;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _logLocales(); // Log available locales
    _listen(); // Start listening automatically
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        _updateGame();
      });
    _controller.repeat();
  }

  void _logLocales() async {
    var locales = await _speech.locales();
    for (var locale in locales) {
      print('Locale: ${locale.localeId}, Name: ${locale.name}');
    }
  }

  void _updateGame() {
    // Spawn new letters
    if (_letters.length < 2) { // Limit the number of letters to 2
      _letters.add(
        FallingLetter(
          letter: _allowedLetters[_random.nextInt(_allowedLetters.length)],
          position: Offset(_random.nextDouble() * _gameWidth, 0),
          size: 48 - (_stage * 4).clamp(0, 40).toDouble(),
          color: Colors.black,
        ),
      );
    }

    // Update letter positions
    for (var letter in _letters) {
      letter.position = letter.position.translate(0, 1 + (_stage / 2));
    }

    // Update popped letters animation
    for (var letter in _poppedLetters) {
      letter.animationProgress += 0.05;
    }
    _poppedLetters.removeWhere((letter) => letter.animationProgress >= 1);

    // Remove off-screen letters and check for game over
    _letters.removeWhere((letter) {
      if (letter.position.dy > _gameHeight) {
        // _gameOver(); // Game over disabled for testing
        return true;
      }
      return false;
    });

    setState(() {});
  }

  void _listen() async {
    print('--- _listen called ---');
    if (!_isListening) {
      print('--- Initializing speech recognition ---');
      setState(() => _speechStatus = 'Initializing...');
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('--- onStatus: $val ---');
          setState(() => _speechStatus = 'Status: $val');
          if (val == 'notListening') {
            Future.delayed(const Duration(seconds: 1), () => _listen());
          }
        },
        onError: (val) {
          print('--- onError: $val ---');
          setState(() => _speechStatus = 'Error: $val');
        },
        debugLogging: true,
      );
      if (available) {
        print('--- Speech recognition available ---');
        setState(() {
          _isListening = true;
          _speechStatus = 'Listening...';
        });
        _speech.listen(
          onResult: (val) {
            print('--- onResult: ${val.recognizedWords} ---');
            setState(() {
              _text = val.recognizedWords;
              _handleSpeechInput(_text);
            });
          },
        );
      } else {
        print('--- Speech recognition not available ---');
        setState(() => _speechStatus = 'Not available');
      }
    }
  }

  void _handleSpeechInput(String input) {
    if (kDebugMode) {
      print("=======");
      print(_text);
      print("=======");
    }
    String spokenLetter = input.toUpperCase().trim();
    if (spokenLetter.length == 1) {
      setState(() {
        List<FallingLetter> lettersToRemove = [];
        for (var letter in _letters) {
          if (letter.letter == spokenLetter) {
            letter.isPopped = true;
            _poppedLetters.add(letter);
            lettersToRemove.add(letter);
            _score++;
            _stageScore++;
          }
        }
        _letters.removeWhere((letter) => lettersToRemove.contains(letter));

        if (_stageScore >= _nextStageScore) {
          _stage++;
          _stageScore = 0;
          _nextStageScore += 5;
        }
      });
    }
  }

  void _gameOver() {
    _controller.stop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameResultScreen(score: _score),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Falling Letters'),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _gameHeight = constraints.maxHeight;
          _gameWidth = constraints.maxWidth;
          return Stack(
            children: [
              CustomPaint(
                painter: GamePainter(letters: _letters, poppedLetters: _poppedLetters),
                child: Container(),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Quit'),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Text(
                  'Score: $_score | Stage: $_stage',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Text(
                  'Recognized: $_text',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Text(
                  'Status: $_speechStatus',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class FallingLetter {
  String letter;
  Offset position;
  double size;
  Color color;
  double radius;
  bool isPopped = false;
  double animationProgress = 0;

  FallingLetter({
    required this.letter,
    required this.position,
    required this.size,
    required this.color,
  }) : radius = size * 0.8;
}

class GamePainter extends CustomPainter {
  final List<FallingLetter> letters;
  final List<FallingLetter> poppedLetters;

  GamePainter({required this.letters, required this.poppedLetters});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw falling letters
    for (var letter in letters) {
      // Draw bubble
      final bubblePaint = Paint()
        ..color = Colors.blue.withOpacity(0.3);
      canvas.drawCircle(letter.position.translate(letter.size / 2, letter.size / 2), letter.radius, bubblePaint);

      // Draw letter
      final textStyle = TextStyle(
        color: letter.color,
        fontSize: letter.size,
      );
      final textSpan = TextSpan(
        text: letter.letter,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, letter.position);
    }

    // Draw popped letters animation
    for (var letter in poppedLetters) {
      final bubblePaint = Paint()
        ..color = Colors.blue.withOpacity(0.3 * (1 - letter.animationProgress));
      canvas.drawCircle(
        letter.position.translate(letter.size / 2, letter.size / 2),
        letter.radius * (1 + letter.animationProgress),
        bubblePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
