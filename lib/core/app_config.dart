/// Application configuration — API keys, model names, subscription tiers, etc.
class AppConfig {
  AppConfig._();

  // MARK: - API Keys (loaded from environment or config)
  static String openAIProxyURL = const String.fromEnvironment(
    'OPENAI_PROXY_URL',
    defaultValue: '',
  );

  static String openAIAPIKey = const String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  static String yandexMapKitAPIKey = const String.fromEnvironment(
    'YANDEX_MAPKIT_API_KEY',
    defaultValue: '',
  );

  // MARK: - OpenAI Models
  static const String openAITranscriptionModel = 'gpt-4o-transcribe';
  static const String openAIVisionModel = 'gpt-4.1-mini';
  static const String openAITTSModel = 'gpt-4o-mini-tts';
  static const bool preferServerSTTForKazakhRussian = true;
  static const double assistantAudioSampleRate = 24000;
  static const int assistantAudioBitRate = 32000;

  // MARK: - System Prompt
  static const String systemPrompt = '''
You are Janarym, a voice assistant for visually impaired users. \
Always answer in the same language the user speaks (Kazakh or Russian). \
Answer ONLY what was asked — no extra advice, no unsolicited context, no follow-up suggestions. \
Never start with filler words like "Sure!", "Of course!", "Hello!", or "Great question!". Start with the answer immediately. \
Never narrate your actions ("I am analyzing...", "Let me check..." — DO NOT say this). \
When describing camera surroundings: name 2–4 main obstacles or objects, estimate distance in steps (1 step ≈ 0.7 m). \
Say "ahead at about 2 steps" not "there is a table". Use calm, spatial language — left, right, ahead, at your feet. \
Never list objects like a shopping list. Always say WHERE the object is relative to the user. \
If the frame is unclear, say so in one short sentence instead of guessing. \
Keep answers to 1–2 short sentences. Expand only when explicitly asked. \
Never use markdown, bullet points, or asterisks — output is read aloud by TTS.
''';

  static const double maxRecordingDuration = 20;
  static const bool presenceMonitoringEnabled = true;

  // MARK: - Subscription
  static const String premiumProductID = 'kz.janarym.premium.monthly';
  static const String vipProductID = 'kz.janarym.vip.monthly';
  static const int freeRequestsPerDay = 5;

  // MARK: - Theme
  static const String backgroundColor = '#020617';

  /// Whether to use proxy mode (OPENAI_PROXY_URL set)
  static bool get useProxy => openAIProxyURL.isNotEmpty;

  /// Whether direct OpenAI API is available
  static bool get canUseDirectOpenAI => openAIAPIKey.isNotEmpty;
}
