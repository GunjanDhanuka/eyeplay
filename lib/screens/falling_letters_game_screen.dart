import 'dart:async';
import 'dart:math';
import 'package:eyeplay/screens/game_result_screen.dart';
import 'package:flutter/material.dart';

enum EDirection { up, down, left, right }

class FallingLettersGameScreen extends StatefulWidget {
  const FallingLettersGameScreen({super.key});

  @override
  State<FallingLettersGameScreen> createState() =>
      _FallingLettersGameScreenState();
}

class _FallingLettersGameScreenState extends State<FallingLettersGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<FallingE> _letters = [];
  List<PoppedBubble> _poppedBubbles = [];
  double _gameHeight = 0;
  double _gameWidth = 0;
  final Random _random = Random();
  int _score = 0;
  int _lives = 3;
  int _stage = 1;
  double _letterSpeed = 2.0;
  double _letterSize = 48.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        _updateGame();
      });
    WidgetsBinding.instance.addPostFrameCallback((_) => _showInstructions());
  }

  void _showInstructions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How to Play'),
          content: const Text(
              'A letter \'E\' will fall from the top. Swipe in the direction the \'E\' is pointing (up, down, left, or right).'),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it!'),
              onPressed: () {
                Navigator.of(context).pop();
                _controller.repeat();
              },
            ),
          ],
        );
      },
    );
  }

  void _spawnNewLetter() {
    final direction = EDirection.values[_random.nextInt(EDirection.values.length)];
    _letters.add(
      FallingE(
        position: Offset(_random.nextDouble() * (_gameWidth - _letterSize), 0),
        size: _letterSize,
        direction: direction,
      ),
    );
  }

  void _updateGame() {
    if (_poppedBubbles.isNotEmpty) {
      for (var bubble in _poppedBubbles) {
        bubble.animationProgress += 0.05;
      }
      _poppedBubbles.removeWhere((bubble) => bubble.animationProgress >= 1.0);
    }

    if (_letters.isEmpty && _controller.isAnimating) {
      _spawnNewLetter();
    }

    final List<FallingE> lettersToRemove = [];
    for (var letter in _letters) {
      letter.position = letter.position.translate(0, _letterSpeed);
      if (letter.position.dy > _gameHeight) {
        lettersToRemove.add(letter);
        _lives--;
        _poppedBubbles.add(PoppedBubble(position: letter.position, initialSize: letter.size));
      }
    }

    _letters.removeWhere((l) => lettersToRemove.contains(l));

    if (_lives <= 0) {
      _gameOver();
    }

    setState(() {});
  }

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    if (velocity.distance == 0 || _letters.isEmpty) {
      return;
    }

    final EDirection swipeDirection;
    if (velocity.dx.abs() > velocity.dy.abs()) {
      swipeDirection = velocity.dx > 0 ? EDirection.right : EDirection.left;
    } else {
      swipeDirection = velocity.dy > 0 ? EDirection.down : EDirection.up;
    }

    if (_letters.first.direction == swipeDirection) {
      _handleCorrectSwipe();
    } else {
      _handleIncorrectSwipe();
    }
  }

  void _handleCorrectSwipe() {
    setState(() {
      _score++;
      final poppedE = _letters.removeAt(0);
      _poppedBubbles.add(PoppedBubble(position: poppedE.position, initialSize: poppedE.size));
      if (_score % 5 == 0) {
        _stage++;
        _letterSpeed += 0.5;
        _letterSize = max(20, _letterSize - 4);
      }
    });
  }

  void _handleIncorrectSwipe() {
    setState(() {
      _lives--;
      if (_lives <= 0) {
        _gameOver();
      } else {
        if (_letters.isNotEmpty) {
          final poppedE = _letters.removeAt(0);
          _poppedBubbles.add(PoppedBubble(position: poppedE.position, initialSize: poppedE.size));
        }
      }
    });
  }

  void _gameOver() {
    _controller.stop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameResultScreen(score: _score, stage: _stage),
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
        title: const Text('Tumbling E'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _gameHeight = constraints.maxHeight;
          _gameWidth = constraints.maxWidth;
          return GestureDetector(
            onPanEnd: _handleSwipe,
            child: Stack(
              children: [
                CustomPaint(
                  painter: GamePainter(letters: _letters, poppedBubbles: _poppedBubbles),
                  child: Container(),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Text(
                    'Lives: $_lives',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Text(
                    'Score: $_score | Stage: $_stage',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.cyan.shade400,
    );
  }
}

class FallingE {
  Offset position;
  double size;
  EDirection direction;

  FallingE({
    required this.position,
    required this.size,
    required this.direction,
  });
}

class PoppedBubble {
  final Offset position;
  final double initialSize;
  double animationProgress;

  PoppedBubble({
    required this.position,
    required this.initialSize,
    this.animationProgress = 0.0,
  });
}

class GamePainter extends CustomPainter {
  final List<FallingE> letters;
  final List<PoppedBubble> poppedBubbles;

  GamePainter({required this.letters, required this.poppedBubbles});

  @override
  void paint(Canvas canvas, Size size) {
    final bubblePaint = Paint()..color = Colors.lightBlue.withOpacity(0.4);
    final bubbleBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var letter in letters) {
      final center = Offset(letter.position.dx + letter.size / 2, letter.position.dy + letter.size / 2);
      final bubbleRadius = letter.size * 0.75;

      canvas.drawCircle(center, bubbleRadius, bubblePaint);
      canvas.drawCircle(center, bubbleRadius, bubbleBorderPaint);

      canvas.save();
      canvas.translate(center.dx, center.dy);

      double angle = 0;
      switch (letter.direction) {
        case EDirection.up:
          angle = -pi / 2;
          break;
        case EDirection.down:
          angle = pi / 2;
          break;
        case EDirection.left:
          angle = pi;
          break;
        case EDirection.right:
          angle = 0;
          break;
      }
      canvas.rotate(angle);

      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: letter.size,
        fontWeight: FontWeight.bold,
      );
      final textSpan = TextSpan(
        text: 'E',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-letter.size / 2, -letter.size / 2));

      canvas.restore();
    }

    for (var bubble in poppedBubbles) {
      final progress = bubble.animationProgress;
      final opacity = 1.0 - progress;
      final radius = bubble.initialSize * (0.75 + progress * 0.5);

      final popPaint = Paint()..color = Colors.lightBlueAccent.withOpacity(opacity * 0.5);
      final popBorderPaint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final center = Offset(bubble.position.dx + bubble.initialSize / 2, bubble.position.dy + bubble.initialSize / 2);

      canvas.drawCircle(center, radius, popPaint);
      canvas.drawCircle(center, radius, popBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    return true;
  }
}
