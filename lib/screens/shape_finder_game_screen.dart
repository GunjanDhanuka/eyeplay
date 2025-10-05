import 'dart:math';
import 'package:eyeplay/models/ishihara_level.dart';
import 'package:eyeplay/screens/ishihara_result_screen.dart';
import 'package:eyeplay/widgets/custom_feedback_dialog.dart';
import 'package:flutter/material.dart';

class ShapeFinderGameScreen extends StatefulWidget {
  @override
  _ShapeFinderGameScreenState createState() => _ShapeFinderGameScreenState();
}

class _ShapeFinderGameScreenState extends State<ShapeFinderGameScreen> {
  late List<IshiharaLevel> _levels;
  int _currentLevelIndex = 0;
  List<Offset> _points = <Offset>[];
  Path? _shapePath;
  int _score = 0;
  int _lives = 3;
  late IshiharaLevel _currentLevel;

  @override
  void initState() {
    super.initState();
    _levels = [
      // Red-Green plates
      IshiharaLevel(shapeColor: const Color(0xFF4CAF50), backgroundColor: const Color(0xFFF44336)),
      IshiharaLevel(shapeColor: const Color(0xFFF08080), backgroundColor: const Color(0xFF98FB98)),
      IshiharaLevel(shapeColor: const Color(0xFFD2B48C), backgroundColor: const Color(0xFF8FBC8F)),
      // Blue-Yellow plates
      IshiharaLevel(shapeColor: const Color(0xFF2196F3), backgroundColor: const Color(0xFFFFEB3B)),
      IshiharaLevel(shapeColor: const Color(0xFF9370DB), backgroundColor: const Color(0xFFF0E68C)),
      // Another plate
      IshiharaLevel(shapeColor: const Color(0xFFFF4500), backgroundColor: const Color(0xFFADFF2F)),
    ];
    _currentLevel = _levels[_currentLevelIndex];
    WidgetsBinding.instance.addPostFrameCallback((_) => _showInstructions());
  }

  void _showInstructions() {
    final size = MediaQuery.of(context).size;
    setState(() {
      _shapePath = _getRandomShapePath(size);
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('How to Play'),
          content: Text('Find the hidden circle and draw a line around it.'),
          actions: <Widget>[
            TextButton(
              child: Text('Got it!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Path _getRandomShapePath(Size size) {
    final random = Random();
    final path = Path();
    final safePadding = 120.0;
    final double centerX =
        random.nextDouble() * (size.width - 2 * safePadding) + safePadding;
    final double centerY =
        random.nextDouble() * (size.height - 2 * safePadding) + safePadding;
    final center = Offset(centerX, centerY);

    path.addOval(Rect.fromCircle(center: center, radius: 100));
    return path;
  }

  void _checkShape() {
    int correctPoints = 0;
    for (final point in _points) {
      if (point != Offset.zero && _shapePath!.contains(point)) {
        correctPoints++;
      }
    }

    if (_points.isNotEmpty && correctPoints > 5) {
      setState(() {
        _score++;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomFeedbackDialog(
            title: 'You found it!',
            message: 'You are a master of shapes!',
            buttonText: 'Next',
            onPressed: () {
              Navigator.of(context).pop();
              _nextLevel();
            },
          );
        },
      );
    } else {
      setState(() {
        _lives--;
      });

      if (_lives > 0) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomFeedbackDialog(
              title: 'Oops!',
              message: 'That was not quite right. You have $_lives lives left.',
              buttonText: 'Try Again',
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _points.clear();
                });
              },
            );
          },
        );
      } else {
        _endGameWithFailure();
      }
    }
  }

  void _endGameWithFailure() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => IshiharaResultScreen(
          correctAnswers: _score,
          totalPlates: _levels.length,
          failedLevel: _currentLevel,
          failedLevelIndex: _currentLevelIndex + 1,
        ),
      ),
    );
  }

  void _nextLevel() {
    if (_currentLevelIndex < _levels.length - 1) {
      setState(() {
        _currentLevelIndex++;
        _currentLevel = _levels[_currentLevelIndex];
        _points.clear();
        final size = MediaQuery.of(context).size;
        _shapePath = _getRandomShapePath(size);
      });
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => IshiharaResultScreen(
            correctAnswers: _score,
            totalPlates: _levels.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_shapePath == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Ishihara Test - Level ${_currentLevelIndex + 1}'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Ishihara Test - Level ${_currentLevelIndex + 1}'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (DragUpdateDetails details) {
          setState(() {
            _points.add(details.localPosition);
          });
        },
        onPanEnd: (DragEndDetails details) {
          setState(() {
            _points.add(Offset.zero);
          });
          _checkShape();
        },
        child: Stack(
          children: <Widget>[
            RepaintBoundary(
              child: CustomPaint(
                painter: ShapePainter(
                  shapePath: _shapePath!,
                  shapeColor: _currentLevel.shapeColor,
                  backgroundColor: _currentLevel.backgroundColor,
                ),
                child: ConstrainedBox(constraints: const BoxConstraints.expand()),
              ),
            ),
            CustomPaint(
              painter: DrawingPainter(points: _points),
              child: ConstrainedBox(constraints: const BoxConstraints.expand()),
            ),
          ],
        ),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final Path shapePath;
  final Color shapeColor;
  final Color backgroundColor;

  ShapePainter({
    required this.shapePath,
    required this.shapeColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();

    for (int i = 0; i < 2000; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double radius = random.nextDouble() * 5 + 2;
      canvas.drawCircle(Offset(x, y), radius, Paint()..color = backgroundColor);
    }

    for (int i = 0; i < 500; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      if (shapePath.contains(Offset(x, y))) {
        double radius = random.nextDouble() * 5 + 2;
        canvas.drawCircle(Offset(x, y), radius, Paint()..color = shapeColor);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ShapePainter oldDelegate) {
    return oldDelegate.shapePath != shapePath ||
        oldDelegate.shapeColor != shapeColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class DrawingPainter extends CustomPainter {
  List<Offset> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
