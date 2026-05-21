import 'package:flutter_tts/flutter_tts.dart';
import '../models/user_profile.dart';

/// Text-to-Speech service wrapping flutter_tts.
class TTSService {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  void Function()? onFinished;

  bool get isSpeaking => _isSpeaking;

  TTSService() {
    _init();
  }

  void _init() {
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      onFinished?.call();
    });
    _tts.setCancelHandler(() {
      _isSpeaking = false;
    });
    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
    });
  }

  Future<void> speak(String text, {required DetectedLanguage language, double rate = 0.5}) async {
    if (text.trim().isEmpty) return;
    await stop();

    String locale;
    switch (language) {
      case DetectedLanguage.kazakh: locale = 'kk-KZ'; break;
      case DetectedLanguage.russian: locale = 'ru-RU'; break;
      case DetectedLanguage.english: locale = 'en-US'; break;
    }

    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(rate);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _isSpeaking = true;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
    }
  }

  Future<void> dispose() async {
    await stop();
  }
}
