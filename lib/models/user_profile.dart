import 'package:flutter/foundation.dart';

/// Supported app languages
enum AppLanguage {
  kazakh,
  russian,
  english;

  String get shortLabel {
    switch (this) {
      case AppLanguage.kazakh: return 'ҚАЗ';
      case AppLanguage.russian: return 'РУС';
      case AppLanguage.english: return 'ENG';
    }
  }

  String get displayName {
    switch (this) {
      case AppLanguage.kazakh: return 'Қазақша';
      case AppLanguage.russian: return 'Русский';
      case AppLanguage.english: return 'English';
    }
  }

  String get openAILanguageCode {
    switch (this) {
      case AppLanguage.kazakh: return 'kk';
      case AppLanguage.russian: return 'ru';
      case AppLanguage.english: return 'en';
    }
  }

  String get assistantLanguageName {
    switch (this) {
      case AppLanguage.kazakh: return 'kazakh';
      case AppLanguage.russian: return 'russian';
      case AppLanguage.english: return 'english';
    }
  }

  DetectedLanguage get detectedLanguage {
    switch (this) {
      case AppLanguage.kazakh: return DetectedLanguage.kazakh;
      case AppLanguage.russian: return DetectedLanguage.russian;
      case AppLanguage.english: return DetectedLanguage.english;
    }
  }
}

enum DetectedLanguage { kazakh, russian, english }

enum SpeechRate {
  slow, normal, fast;

  double get avRate {
    switch (this) {
      case SpeechRate.slow: return 0.8;
      case SpeechRate.normal: return 1.0;
      case SpeechRate.fast: return 1.3;
    }
  }

  String display(AppLanguage lang) {
    switch (this) {
      case SpeechRate.slow: return lang == AppLanguage.kazakh ? 'Баяу' : 'Медленная';
      case SpeechRate.normal: return lang == AppLanguage.kazakh ? 'Қалыпты' : 'Нормальная';
      case SpeechRate.fast: return lang == AppLanguage.kazakh ? 'Жылдам' : 'Быстрая';
    }
  }
}

enum ResponseLength {
  short, medium, long;

  String display(AppLanguage lang) {
    switch (this) {
      case ResponseLength.short: return lang == AppLanguage.kazakh ? 'Қысқа' : 'Короткий';
      case ResponseLength.medium: return lang == AppLanguage.kazakh ? 'Орташа' : 'Средний';
      case ResponseLength.long: return lang == AppLanguage.kazakh ? 'Толық' : 'Подробный';
    }
  }
}

enum GPTVoice {
  ash, ballad, coral, sage, verse, ember, jupiter;

  String get openAIVoiceID => name;

  String displayName(AppLanguage lang) {
    final kk = lang == AppLanguage.kazakh;
    switch (this) {
      case GPTVoice.ash: return kk ? 'Ash (ер)' : 'Ash (муж.)';
      case GPTVoice.ballad: return kk ? 'Ballad (ер)' : 'Ballad (муж.)';
      case GPTVoice.coral: return kk ? 'Coral (әйел)' : 'Coral (жен.)';
      case GPTVoice.sage: return kk ? 'Sage (әйел)' : 'Sage (жен.)';
      case GPTVoice.verse: return kk ? 'Verse (әйел)' : 'Verse (жен.)';
      case GPTVoice.ember: return kk ? 'Ember (ер)' : 'Ember (муж.)';
      case GPTVoice.jupiter: return kk ? 'Jupiter (ер)' : 'Jupiter (муж.)';
    }
  }

  String announcement(AppLanguage lang) {
    return '${displayName(lang)} ${lang == AppLanguage.kazakh ? 'таңдалды' : 'выбран'}';
  }
}

enum Formality {
  formal, informal;

  String display(AppLanguage lang) {
    switch (this) {
      case Formality.formal: return lang == AppLanguage.kazakh ? 'Сіз' : 'Вы';
      case Formality.informal: return lang == AppLanguage.kazakh ? 'Сен' : 'Ты';
    }
  }
}

enum FocusMode {
  all, people, text, objects;

  String announcementText(AppLanguage lang) {
    final kk = lang == AppLanguage.kazakh;
    switch (this) {
      case FocusMode.all: return kk ? 'Жалпы фокус режимі' : 'Общий режим фокуса';
      case FocusMode.people: return kk ? 'Адамдарға фокус' : 'Фокус на людях';
      case FocusMode.text: return kk ? 'Мәтінге фокус' : 'Фокус на тексте';
      case FocusMode.objects: return kk ? 'Заттарға фокус' : 'Фокус на объектах';
    }
  }

  String promptInstruction({required AppLanguage language}) {
    final kk = language == AppLanguage.kazakh;
    switch (this) {
      case FocusMode.all: return '';
      case FocusMode.people: return kk ? ' Тек адамдарға назар аудар.' : ' Фокусируйся только на людях.';
      case FocusMode.text: return kk ? ' Тек мәтінді оқу.' : ' Читай только текст.';
      case FocusMode.objects: return kk ? ' Тек заттарға назар аудар.' : ' Описывай только объекты.';
    }
  }
}

class UserProfile {
  AppLanguage language;
  SpeechRate speechRate;
  ResponseLength responseLength;
  GPTVoice gptVoice;
  Formality formality;
  FocusMode focusMode;
  String name;
  int age;

  UserProfile({
    this.language = AppLanguage.kazakh,
    this.speechRate = SpeechRate.normal,
    this.responseLength = ResponseLength.short,
    this.gptVoice = GPTVoice.jupiter,
    this.formality = Formality.formal,
    this.focusMode = FocusMode.all,
    this.name = '',
    this.age = 0,
  });

  UserProfile copyWith({
    AppLanguage? language, SpeechRate? speechRate,
    ResponseLength? responseLength, GPTVoice? gptVoice,
    Formality? formality, FocusMode? focusMode,
    String? name, int? age,
  }) {
    return UserProfile(
      language: language ?? this.language,
      speechRate: speechRate ?? this.speechRate,
      responseLength: responseLength ?? this.responseLength,
      gptVoice: gptVoice ?? this.gptVoice,
      formality: formality ?? this.formality,
      focusMode: focusMode ?? this.focusMode,
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }

  Map<String, dynamic> toJson() => {
    'language': language.name, 'speechRate': speechRate.name,
    'responseLength': responseLength.name, 'gptVoice': gptVoice.name,
    'formality': formality.name, 'focusMode': focusMode.name,
    'name': name, 'age': age,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      language: AppLanguage.values.firstWhere((e) => e.name == json['language'], orElse: () => AppLanguage.kazakh),
      speechRate: SpeechRate.values.firstWhere((e) => e.name == json['speechRate'], orElse: () => SpeechRate.normal),
      responseLength: ResponseLength.values.firstWhere((e) => e.name == json['responseLength'], orElse: () => ResponseLength.short),
      gptVoice: GPTVoice.values.firstWhere((e) => e.name == json['gptVoice'], orElse: () => GPTVoice.jupiter),
      formality: Formality.values.firstWhere((e) => e.name == json['formality'], orElse: () => Formality.formal),
      focusMode: FocusMode.values.firstWhere((e) => e.name == json['focusMode'], orElse: () => FocusMode.all),
      name: json['name'] ?? '', age: json['age'] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserProfile &&
          language == other.language && speechRate == other.speechRate &&
          responseLength == other.responseLength && gptVoice == other.gptVoice &&
          formality == other.formality && focusMode == other.focusMode &&
          name == other.name && age == other.age;

  @override
  int get hashCode => Object.hash(language, speechRate, responseLength, gptVoice, formality, focusMode, name, age);
}
