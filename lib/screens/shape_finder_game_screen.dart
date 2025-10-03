
import 'package:eyeplay/widgets/custom_feedback_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ShapeFinderGameScreen extends StatefulWidget {
  @override
  _ShapeFinderGameScreenState createState() => _ShapeFinderGameScreenState();
}

class _ShapeFinderGameScreenState extends State<ShapeFinderGameScreen> {
  List<Offset> _points = <Offset>[];
  late Path _shapePath;
  bool _isShapeFound = false;
  int _lives = 3;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showInstructions());
  }

  void _showInstructions() {
    final size = MediaQuery.of(context).size;
    _shapePath = _getRandomShapePath(size);
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
      if (point != Offset.zero && _shapePath.contains(point)) {
        correctPoints++;
      }
    }

    if (_points.isNotEmpty && correctPoints > 2) {
      setState(() {
        _isShapeFound = true;
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
    }
  }

  void _nextLevel() {
    final size = MediaQuery.of(context).size;
    setState(() {
      _points.clear();
      _isShapeFound = false;
      _shapePath = _getRandomShapePath(size);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find the Shape!'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          _shapePath = _getRandomShapePath(Size(constraints.maxWidth, constraints.maxHeight));
          return Stack(
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  painter: ShapePainter(shapePath: _shapePath),
                  size: Size.infinite,
                ),
              ),
              GestureDetector(
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    RenderBox renderBox = context.findRenderObject() as RenderBox;
                    _points.add(renderBox.globalToLocal(details.globalPosition));
                  });
                },
                onPanEnd: (DragEndDetails details) {
                  _points.add(Offset.zero);
                  _checkShape();
                },
                child: CustomPaint(
                  painter: DrawingPainter(points: _points),
                  size: Size.infinite,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final Path shapePath;

  ShapePainter({required this.shapePath});
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    final shapeColor = Colors.red;
    final backgroundColor = Colors.green;

    // Draw background dots
    for (int i = 0; i < 2000; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double radius = random.nextDouble() * 5 + 2;
      canvas.drawCircle(Offset(x, y), radius, Paint()..color = backgroundColor);
    }

    // Draw dots inside the shape
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
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
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
