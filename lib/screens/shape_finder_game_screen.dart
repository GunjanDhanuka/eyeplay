
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
          content: Text('Find the hidden shape and draw a line around it.'),
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
    final shapeType = random.nextInt(3);
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);

    switch (shapeType) {
      case 0: // Circle
        path.addOval(Rect.fromCircle(center: center, radius: 100));
        break;
      case 1: // Square
        path.addRect(Rect.fromCenter(center: center, width: 200, height: 200));
        break;
      case 2: // Star
        final radius = 100.0;
        final innerRadius = radius / 2;
        final angle = (pi * 2) / 10;
        for (int i = 0; i < 10; i++) {
          final r = i.isEven ? radius : innerRadius;
          final x = center.dx + cos(i * angle) * r;
          final y = center.dy + sin(i * angle) * r;
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        break;
    }
    return path;
  }

  void _checkShape() {
    int correctPoints = 0;
    for (final point in _points) {
      if (point != Offset.zero && _shapePath.contains(point)) {
        correctPoints++;
      }
    }

    if (_points.isNotEmpty && (correctPoints / _points.length) > 0.7) {
      setState(() {
        _isShapeFound = true;
      });
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
        title: Text('Find the Shape'),
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
              if (_isShapeFound)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'You found it!',
                        style: TextStyle(fontSize: 24, color: Colors.green),
                      ),
                      ElevatedButton(
                        onPressed: _nextLevel,
                        child: Text('Next'),
                      ),
                    ],
                  ),
                )
              else
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _points.clear();
                        });
                      },
                      child: Text('Try Again'),
                    ),
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
