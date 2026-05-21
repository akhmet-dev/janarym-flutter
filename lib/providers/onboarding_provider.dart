import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/assistant_mode.dart';
import '../core/app_config.dart';

/// Central state provider for the onboarding profile and app language.
class OnboardingProvider extends ChangeNotifier {
  static final OnboardingProvider shared = OnboardingProvider._();

  UserProfile _profile = UserProfile();
  bool _isCompleted = false;

  UserProfile get profile => _profile;
  bool get isCompleted => _isCompleted;
  AppLanguage get currentLanguage => _profile.language;
  bool get isKazakh => _profile.language == AppLanguage.kazakh;

  OnboardingProvider._() {
    _loadFromPrefs();
  }

  void updateLanguage(AppLanguage language) {
    _profile = _profile.copyWith(language: language);
    _saveToPrefs();
    notifyListeners();
  }

  void updateProfile(UserProfile profile) {
    _profile = profile;
    _saveToPrefs();
    notifyListeners();
  }

  void completeOnboarding() {
    _isCompleted = true;
    _saveToPrefs();
    notifyListeners();
  }

  void resetOnboarding() {
    _isCompleted = false;
    _profile = UserProfile();
    _saveToPrefs();
    notifyListeners();
  }

  /// Build the assistant system prompt for a given app mode.
  String assistantPrompt(AppMode mode) {
    final lang = _profile.language;
    final kk = lang == AppLanguage.kazakh;
    String base = AppConfig.systemPrompt;

    // Add response length instruction
    switch (_profile.responseLength) {
      case ResponseLength.short:
        base +=
            kk ? '\nЖауапты 1-2 сөйлем етіп бер.' : '\nОтвечай в 1-2 предложениях.';
        break;
      case ResponseLength.medium:
        base +=
            kk ? '\nЖауапты 2-4 сөйлем етіп бер.' : '\nОтвечай в 2-4 предложениях.';
        break;
      case ResponseLength.long:
        base += kk
            ? '\nТолық жауап бер, бірақ артық мәлімет қоспа.'
            : '\nОтвечай подробно, но без лишней информации.';
        break;
    }

    // Add formality instruction
    switch (_profile.formality) {
      case Formality.formal:
        base +=
            kk ? '\nСіз деп жүгін.' : '\nОбращайся на Вы.';
        break;
      case Formality.informal:
        base +=
            kk ? '\nСен деп жүгін.' : '\nОбращайся на ты.';
        break;
    }

    // Add focus mode instruction
    final focusInstruction = _profile.focusMode.promptInstruction(language: lang);
    if (focusInstruction.isNotEmpty) {
      base += focusInstruction;
    }

    // Mode-specific prompts
    switch (mode) {
      case AppMode.navigation:
        base += kk
            ? '\nНавигация режимі: пайдаланушының орналасуын анықтап, бағыт-бағдар бер.'
            : '\nРежим навигации: помогай с ориентацией и навигацией.';
        break;
      case AppMode.security:
        base += kk
            ? '\nҚауіпсіздік режимі: қоршаған ортадағы қауіпті жағдайларды анықта.'
            : '\nРежим безопасности: определяй потенциальные опасности.';
        break;
      case AppMode.shopping:
        base += kk
            ? '\nСауда режимі: тауарлардың атауын, бағасын, жарамдылық мерзімін оқы.'
            : '\nРежим покупок: называй название, цену и срок годности товаров.';
        break;
      case AppMode.reading:
        base += kk
            ? '\nМәтін оқу режимі: көрген мәтінді толығымен оқы.'
            : '\nРежим чтения: читай весь видимый текст полностью.';
        break;
      case AppMode.arGlasses:
        base += kk
            ? '\nAR көзілдірік режимі: ESP32 камерасынан келген кадрды сипатта.'
            : '\nРежим AR очков: описывай кадр с ESP32 камеры.';
        break;
      default:
        break;
    }

    return base;
  }

  // MARK: - Persistence

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      try {
        _profile = UserProfile.fromJson(jsonDecode(profileJson));
      } catch (_) {}
    }
    _isCompleted = prefs.getBool('onboarding_completed') ?? false;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(_profile.toJson()));
    await prefs.setBool('onboarding_completed', _isCompleted);
  }
}
