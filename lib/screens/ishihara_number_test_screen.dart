import 'dart:math';
import 'dart:ui' as ui;
import 'package:eyeplay/models/ishihara_level.dart';
import 'package:eyeplay/screens/ishihara_result_screen.dart';
import 'package:flutter/material.dart';

class IshiharaNumberTestScreen extends StatefulWidget {
  const IshiharaNumberTestScreen({super.key});

  @override
  State<IshiharaNumberTestScreen> createState() =>
      _IshiharaNumberTestScreenState();
}

class _IshiharaNumberTestScreenState extends State<IshiharaNumberTestScreen> {
  late final List<IshiharaPlate> _plates;
  int _currentPlateIndex = 0;
  int _correctAnswers = 0;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _plates = [
      IshiharaPlate(number: '12', level: IshiharaLevel(shapeColor: const Color.fromRGBO(80, 160, 70, 1), backgroundColor: const Color.fromRGBO(205, 95, 95, 1))),
      IshiharaPlate(number: '8', level: IshiharaLevel(shapeColor: const Color.fromRGBO(70, 150, 80, 1), backgroundColor: const Color.fromRGBO(195, 105, 105, 1))),
      IshiharaPlate(number: '29', level: IshiharaLevel(shapeColor: const Color.fromRGBO(90, 170, 60, 1), backgroundColor: const Color.fromRGBO(215, 85, 85, 1))),
      IshiharaPlate(number: '5', level: IshiharaLevel(shapeColor: const Color.fromRGBO(60, 90, 170, 1), backgroundColor: const Color.fromRGBO(215, 200, 85, 1))),
      IshiharaPlate(number: '3', level: IshiharaLevel(shapeColor: const Color.fromRGBO(85, 60, 170, 1), backgroundColor: const Color.fromRGBO(215, 215, 85, 1))),
      IshiharaPlate(number: '74', level: IshiharaLevel(shapeColor: const Color.fromRGBO(170, 85, 60, 1), backgroundColor: const Color.fromRGBO(85, 170, 215, 1))),
    ];
  }

  void _checkAnswer() {
    if (_textController.text == _plates[_currentPlateIndex].number) {
      _correctAnswers++;
    }

    if (_currentPlateIndex < _plates.length - 1) {
      setState(() {
        _currentPlateIndex++;
        _textController.clear();
      });
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => IshiharaResultScreen(
            correctAnswers: _correctAnswers,
            totalPlates: _plates.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ishihara Test - Plate ${_currentPlateIndex + 1} of ${_plates.length}'),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'What number do you see?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            RepaintBoundary(
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: IshiharaPlatePainter(
                    plate: _plates[_currentPlateIndex],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: '##',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1A237E), width: 2.0),
                ),
              ),
              onChanged: (_) => setState(() {}), // Necessary to rebuild parts of the UI if needed but RepaintBoundary protects the plate
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class IshiharaPlate {
  final String number;
  final IshiharaLevel level;

  IshiharaPlate({required this.number, required this.level});
}

class IshiharaPlatePainter extends CustomPainter {
  final IshiharaPlate plate;

  IshiharaPlatePainter({required this.plate});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final plateRadius = size.width / 2;
    final _random = Random(plate.number.hashCode);

    final textPainter = TextPainter(
      text: TextSpan(
        text: plate.number,
        style: TextStyle(fontSize: plateRadius * 1.5, color: Colors.transparent, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);

    final textOffset = center - Offset(textPainter.width / 2, textPainter.height / 2);

    final List<ui.TextBox> glyphRects = textPainter.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: plate.number.length),
    );

    for (int i = 0; i < 2000; i++) {
      final dotRadius = _random.nextDouble() * (plateRadius * 0.05) + (plateRadius * 0.02);
      final r = plateRadius * sqrt(_random.nextDouble());
      final theta = _random.nextDouble() * 2 * pi;
      final pos = center + Offset(r * cos(theta), r * sin(theta));

      bool isInFigure = false;
      for (final box in glyphRects) {
        if (box.toRect().shift(textOffset).contains(pos)) {
          isInFigure = true;
          break;
        }
      }

      final baseColor = isInFigure ? plate.level.shapeColor : plate.level.backgroundColor;
      final color = _jitterColor(baseColor, _random);

      canvas.drawCircle(pos, dotRadius, Paint()..color = color);
    }
  }

  Color _jitterColor(Color baseColor, Random random) {
    const jitter = 15;
    int r = (baseColor.red + random.nextInt(jitter * 2) - jitter).clamp(0, 255);
    int g = (baseColor.green + random.nextInt(jitter * 2) - jitter).clamp(0, 255);
    int b = (baseColor.blue + random.nextInt(jitter * 2) - jitter).clamp(0, 255);
    return Color.fromRGBO(r, g, b, 1.0);
  }

  @override
  bool shouldRepaint(covariant IshiharaPlatePainter oldDelegate) {
    return oldDelegate.plate != plate;
  }
}
