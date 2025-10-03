import 'package:eyeplay/screens/snellen_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SnellenChartScreen extends StatefulWidget {
  const SnellenChartScreen({super.key});

  @override
  State<SnellenChartScreen> createState() => _SnellenChartScreenState();
}

class _SnellenChartScreenState extends State<SnellenChartScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      _handleAnswer(_text);
    }
  }

  int _currentLine = 0;
  final List<Map<String, dynamic>> _snellenChart = [
    {'line': 'E', 'size': 80.0, 'score': 200},
    {'line': 'F P', 'size': 60.0, 'score': 100},
    {'line': 'T O Z', 'size': 40.0, 'score': 80},
    {'line': 'L P E D', 'size': 30.0, 'score': 60},
    {'line': 'P E C F D', 'size': 20.0, 'score': 40},
    {'line': 'E D F C Z P', 'size': 15.0, 'score': 20},
  ];

  void _handleAnswer(String recognizedText) {
    String expectedText = _snellenChart[_currentLine]['line'].replaceAll(' ', '');
    String formattedRecognizedText = recognizedText.replaceAll(' ', '').toUpperCase();

    if (formattedRecognizedText == expectedText) {
      if (_currentLine < _snellenChart.length - 1) {
        setState(() {
          _currentLine++;
          _text = '';
        });
      } else {
        _showResult();
      }
    } else {
      _showResult();
    }
  }

  void _showResult() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SnellenResultScreen(
          score: _snellenChart[_currentLine]['score'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snellen Chart Test'),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _snellenChart[_currentLine]['line'],
              style: TextStyle(
                fontSize: _snellenChart[_currentLine]['size'],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 64),
            Text(
              'Recognized: $_text',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            FloatingActionButton(
              onPressed: _listen,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            ),
          ],
        ),
      ),
    );
  }
}
