import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import '../models/assistant_mode.dart';
import '../models/user_profile.dart';
import '../providers/onboarding_provider.dart';
import '../services/openai_service.dart';
import '../services/tts_service.dart';
import '../services/network_monitor.dart';
import '../core/app_config.dart';

/// Central coordinator managing the assistant lifecycle:
/// camera → PTT recording → STT → GPT → TTS playback.
class AssistantProvider extends ChangeNotifier {
  // ─── State ───
  AssistantMode _mode = AssistantMode.idle;
  AppMode _activeMode = AppMode.general;
  String _liveTranscript = '';
  String _liveResponseText = '';
  String? _errorMessage;
  bool _isOfflineMode = false;

  AssistantMode get mode => _mode;
  AppMode get activeMode => _activeMode;
  String get liveTranscript => _liveTranscript;
  String get liveResponseText => _liveResponseText;
  String? get errorMessage => _errorMessage;
  bool get isOfflineMode => _isOfflineMode;

  // ─── Services ───
  CameraController? cameraController;
  final TTSService ttsService = TTSService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _speechAvailable = false;

  // ─── Private ───
  Uint8List? _capturedFrameAtPTTStart;

  AssistantProvider() {
    _initNetworkMonitor();
    _initTTSCallbacks();
  }

  void _initNetworkMonitor() {
    NetworkMonitor.shared.addListener(() {
      _isOfflineMode = !NetworkMonitor.shared.isConnected;
      notifyListeners();
    });
  }

  void _initTTSCallbacks() {
    ttsService.onFinished = () {
      if (_mode == AssistantMode.speaking) {
        _mode = AssistantMode.idle;
        notifyListeners();
      }
    };
  }

  // ─── Camera ───

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Prefer back camera
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await cameraController!.initialize();
      notifyListeners();
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<Uint8List?> captureFrame() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return null;
    }
    try {
      final file = await cameraController!.takePicture();
      return await file.readAsBytes();
    } catch (e) {
      debugPrint('Frame capture error: $e');
      return null;
    }
  }

  // ─── Mode Change ───

  void setActiveMode(AppMode mode) {
    _activeMode = mode;
    notifyListeners();
  }

  // ─── PTT (Push-to-Talk) ───

  Future<void> startPTT() async {
    _mode = AssistantMode.recording;
    _liveTranscript = '';
    _liveResponseText = '';
    _errorMessage = null;
    notifyListeners();

    // Capture frame at start
    _capturedFrameAtPTTStart = await captureFrame();

    // Initialize speech if needed
    if (!_speechAvailable) {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            // Speech stopped naturally
          }
        },
        onError: (error) {
          debugPrint('STT error: $error');
        },
      );
    }

    if (!_speechAvailable) {
      // Fallback: skip STT, just capture frame
      _mode = AssistantMode.idle;
      notifyListeners();
      return;
    }

    // Determine locale
    final lang = OnboardingProvider.shared.currentLanguage;
    String localeId;
    switch (lang) {
      case AppLanguage.kazakh: localeId = 'kk-KZ'; break;
      case AppLanguage.russian: localeId = 'ru-RU'; break;
      case AppLanguage.english: localeId = 'en-US'; break;
    }

    await _speech.listen(
      localeId: localeId,
      onResult: (result) {
        _liveTranscript = result.recognizedWords;
        notifyListeners();
      },
      listenFor: Duration(seconds: AppConfig.maxRecordingDuration.toInt()),
      pauseFor: const Duration(seconds: 3),
      listenMode: stt.ListenMode.dictation,
    );
  }

  Future<void> stopPTT() async {
    if (_mode != AssistantMode.recording) {
      _mode = AssistantMode.idle;
      notifyListeners();
      return;
    }

    await _speech.stop();
    _mode = AssistantMode.processing;
    notifyListeners();

    // Capture final frame
    final frameJPEG = await captureFrame() ?? _capturedFrameAtPTTStart;
    _capturedFrameAtPTTStart = null;

    final transcript = _liveTranscript.trim();

    if (transcript.isEmpty && frameJPEG != null) {
      // No speech detected, but we have a frame — describe the scene
      final lang = OnboardingProvider.shared.currentLanguage;
      final defaultPrompt = lang == AppLanguage.kazakh
          ? 'Алдымда не тұр? Қысқа әрі нақты сипаттап бер.'
          : lang == AppLanguage.russian
              ? 'Что передо мной? Опиши коротко и понятно.'
              : 'What is in front of me? Describe it briefly.';
      await _processRequest(defaultPrompt, frameJPEG);
    } else if (transcript.isNotEmpty) {
      await _processRequest(transcript, frameJPEG);
    } else {
      _mode = AssistantMode.idle;
      notifyListeners();
    }
  }

  void toggleVoiceCapture() {
    switch (_mode) {
      case AssistantMode.recording:
        stopPTT();
        break;
      case AssistantMode.idle:
      case AssistantMode.error:
      case AssistantMode.speaking:
        ttsService.stop();
        _audioPlayer.stop();
        startPTT();
        break;
      case AssistantMode.processing:
        break;
    }
  }

  // ─── Processing ───

  Future<void> _processRequest(String text, Uint8List? frameJPEG) async {
    try {
      final String responseText;
      String? audioBase64;

      if (AppConfig.useProxy) {
        final response = await OpenAIService.shared.sendViaProxy(
          text: text,
          frameJPEG: frameJPEG,
          activeMode: _activeMode,
        );
        responseText = response.responseText;
        audioBase64 = response.audioBase64;
        _liveTranscript = response.transcript;
      } else if (AppConfig.canUseDirectOpenAI) {
        responseText = await OpenAIService.shared.getChatResponse(
          transcript: text,
          frameJPEG: frameJPEG,
          activeMode: _activeMode,
        );
      } else {
        throw Exception('No API key configured');
      }

      _liveResponseText = responseText.trim();
      _mode = AssistantMode.speaking;
      notifyListeners();

      // Play TTS
      if (audioBase64 != null && audioBase64.isNotEmpty) {
        await _playAudioBase64(audioBase64);
      } else {
        // Use local TTS
        final lang = OnboardingProvider.shared.profile.language.detectedLanguage;
        await ttsService.speak(_liveResponseText, language: lang);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _mode = AssistantMode.error;
      notifyListeners();

      // Auto-recover after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (_mode == AssistantMode.error) {
          _mode = AssistantMode.idle;
          notifyListeners();
        }
      });
    }
  }

  Future<void> _playAudioBase64(String base64Audio) async {
    try {
      final bytes = base64Decode(base64Audio);
      await _audioPlayer.play(BytesSource(bytes));
      _audioPlayer.onPlayerComplete.listen((_) {
        if (_mode == AssistantMode.speaking) {
          _mode = AssistantMode.idle;
          notifyListeners();
        }
      });
    } catch (e) {
      // Fallback to local TTS
      final lang = OnboardingProvider.shared.profile.language.detectedLanguage;
      await ttsService.speak(_liveResponseText, language: lang);
    }
  }

  // ─── Cleanup ───

  @override
  void dispose() {
    cameraController?.dispose();
    ttsService.dispose();
    _speech.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
