import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';
import '../models/user_profile.dart';
import '../models/assistant_mode.dart';
import '../providers/onboarding_provider.dart';

/// Response DTO from the OpenAI proxy / direct API.
class AssistResponse {
  final String transcript;
  final String responseText;
  final String? audioBase64;

  AssistResponse({
    required this.transcript,
    required this.responseText,
    this.audioBase64,
  });
}

/// Handles all communication with OpenAI (Whisper STT, GPT-4 Vision, TTS)
/// through either direct API or proxy.
class OpenAIService {
  static final OpenAIService shared = OpenAIService._();
  OpenAIService._();

  /// Send text + optional image to proxy and get response + TTS audio.
  Future<AssistResponse> sendViaProxy({
    required String text,
    Uint8List? frameJPEG,
    required AppMode activeMode,
  }) async {
    final url = Uri.parse(AppConfig.openAIProxyURL);
    final onboarding = OnboardingProvider.shared;
    final lang = onboarding.currentLanguage;
    final profile = onboarding.profile;
    final prompt = onboarding.assistantPrompt(activeMode);

    final payload = <String, dynamic>{
      'text': text,
      'prompt': prompt,
      'language': lang.openAILanguageCode,
      'output_language': lang.assistantLanguageName,
      'response_model': AppConfig.openAIVisionModel,
      'voice': profile.gptVoice.openAIVoiceID,
      'tts_model': AppConfig.openAITTSModel,
      'speed': profile.speechRate.avRate,
      'include_audio': true,
    };

    if (frameJPEG != null && frameJPEG.isNotEmpty) {
      payload['image_base64'] = base64Encode(frameJPEG);
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 180));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Proxy error: HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return AssistResponse(
      transcript: (json['transcript'] as String?) ?? text,
      responseText: (json['response_text'] as String?) ?? '',
      audioBase64: json['audio_base64'] as String?,
    );
  }

  /// Direct OpenAI GPT-4 Vision chat.
  Future<String> getChatResponse({
    required String transcript,
    Uint8List? frameJPEG,
    required AppMode activeMode,
  }) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final onboarding = OnboardingProvider.shared;
    final lang = onboarding.currentLanguage;
    final prompt = onboarding.assistantPrompt(activeMode);

    final userContent = <Map<String, dynamic>>[
      {'type': 'text', 'text': _localizedTurnText(transcript, lang)},
    ];
    if (frameJPEG != null && frameJPEG.isNotEmpty) {
      userContent.add({
        'type': 'image_url',
        'image_url': {
          'url': 'data:image/jpeg;base64,${base64Encode(frameJPEG)}',
          'detail': 'low',
        },
      });
    }

    final payload = {
      'model': AppConfig.openAIVisionModel,
      'max_tokens': 220,
      'messages': [
        {'role': 'system', 'content': prompt},
        {'role': 'user', 'content': userContent},
      ],
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${AppConfig.openAIAPIKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 180));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Chat API error: HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List;
    final message = choices.first['message'] as Map<String, dynamic>;
    return message['content'] as String;
  }

  /// Whisper transcription (direct).
  Future<String> transcribeAudio(Uint8List audioData) async {
    final url = Uri.parse('https://api.openai.com/v1/audio/transcriptions');
    final lang = OnboardingProvider.shared.currentLanguage;

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${AppConfig.openAIAPIKey}'
      ..fields['model'] = AppConfig.openAITranscriptionModel
      ..fields['language'] = lang.openAILanguageCode
      ..files.add(http.MultipartFile.fromBytes('file', audioData, filename: 'speech.m4a'));

    final streamedResponse = await request.send().timeout(const Duration(seconds: 180));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Transcription error: HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['text'] as String? ?? '';
  }

  /// TTS synthesis (direct).
  Future<Uint8List> synthesizeSpeech(String text) async {
    final url = Uri.parse('https://api.openai.com/v1/audio/speech');
    final profile = OnboardingProvider.shared.profile;

    final payload = {
      'model': AppConfig.openAITTSModel,
      'input': text,
      'voice': profile.gptVoice.openAIVoiceID,
      'response_format': 'mp3',
      'speed': profile.speechRate.avRate,
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${AppConfig.openAIAPIKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 180));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('TTS error: HTTP ${response.statusCode}');
    }

    return response.bodyBytes;
  }

  String _localizedTurnText(String text, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.kazakh:
        return 'Жауапты тек қазақ тілінде бер.\n$text';
      case AppLanguage.russian:
        return 'Отвечай только на русском языке.\n$text';
      case AppLanguage.english:
        return 'Answer only in English.\n$text';
    }
  }
}
