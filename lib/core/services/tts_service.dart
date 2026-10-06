import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setSpeechRate(0.45); // slightly slower for language learners
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _isPlaying = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
      });

      _flutterTts.setErrorHandler((msg) {
        _isPlaying = false;
        debugPrint('TTS Error: $msg');
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS initialization warning: $e');
    }
  }

  Future<bool> speak(String text, {String languageCode = 'es-ES'}) async {
    try {
      if (!_isInitialized) {
        await init();
      }

      await _flutterTts.stop();
      await _flutterTts.setLanguage(languageCode);
      final result = await _flutterTts.speak(text);
      return result == 1;
    } catch (e) {
      debugPrint('TTS speak failed: $e');
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}

