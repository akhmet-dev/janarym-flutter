import '../models/user_profile.dart';

/// Voice personality — bilingual phrases for Janarym.
class JanarymVoice {
  JanarymVoice._();
  static final JanarymVoice shared = JanarymVoice._();

  String greeting({required DetectedLanguage language}) {
    switch (language) {
      case DetectedLanguage.kazakh: return 'Сәлем! Мен Жанарым, сенің көмекшіңмін.';
      case DetectedLanguage.russian: return 'Привет! Я Жанарым, твой помощник.';
      case DetectedLanguage.english: return 'Hi! I am Janarym, your assistant.';
    }
  }

  String error({required DetectedLanguage language}) {
    switch (language) {
      case DetectedLanguage.kazakh: return 'Кешіріңіз, қате болды.';
      case DetectedLanguage.russian: return 'Извините, произошла ошибка.';
      case DetectedLanguage.english: return 'Sorry, an error occurred.';
    }
  }

  String torchOn({required DetectedLanguage language}) {
    switch (language) {
      case DetectedLanguage.kazakh: return 'Фонарик қосылды';
      case DetectedLanguage.russian: return 'Фонарик включён';
      case DetectedLanguage.english: return 'Flashlight is on';
    }
  }

  String torchOff({required DetectedLanguage language}) {
    switch (language) {
      case DetectedLanguage.kazakh: return 'Фонарик өшірілді';
      case DetectedLanguage.russian: return 'Фонарик выключен';
      case DetectedLanguage.english: return 'Flashlight is off';
    }
  }

  String videoStarted({required DetectedLanguage language}) {
    switch (language) {
      case DetectedLanguage.kazakh: return 'Видео түсіріп жатырмын';
      case DetectedLanguage.russian: return 'Идёт запись видео';
      case DetectedLanguage.english: return 'Video recording';
    }
  }

  String videoSaved({required DetectedLanguage language}) {
    switch (language) {
      case DetectedLanguage.kazakh: return 'Видео сақталды';
      case DetectedLanguage.russian: return 'Видео сохранено';
      case DetectedLanguage.english: return 'Video saved';
    }
  }

  String sosSent({required DetectedLanguage language}) {
    switch (language) {
      case DetectedLanguage.kazakh: return 'Апаңа хабар жібердім, жол келе жатыр!';
      case DetectedLanguage.russian: return 'SOS отправлен. Близкие уже получили сообщение.';
      case DetectedLanguage.english: return 'SOS sent. Your trusted contact has been notified.';
    }
  }

  String settingsOpened({required DetectedLanguage language}) {
    switch (language) {
      case DetectedLanguage.kazakh: return 'Баптаулар';
      case DetectedLanguage.russian: return 'Настройки';
      case DetectedLanguage.english: return 'Settings';
    }
  }

  String medCardOpened({required DetectedLanguage language}) {
    switch (language) {
      case DetectedLanguage.kazakh: return 'Медициналық карта';
      case DetectedLanguage.russian: return 'Медицинская карта';
      case DetectedLanguage.english: return 'Medical card';
    }
  }

  String screenWelcome({required DetectedLanguage language}) {
    switch (language) {
      case DetectedLanguage.kazakh: return 'Экранды басып, сұрағыңызды айтыңыз';
      case DetectedLanguage.russian: return 'Нажмите на экран и задайте вопрос';
      case DetectedLanguage.english: return 'Tap the screen and ask your question';
    }
  }

  String timeInWords(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final min = date.minute;

    const hourWords = {
      1: 'бір', 2: 'екі', 3: 'үш', 4: 'төрт', 5: 'бес',
      6: 'алты', 7: 'жеті', 8: 'сегіз', 9: 'тоғыз',
      10: 'он', 11: 'он бір', 12: 'он екі',
    };

    final hWord = hourWords[hour] ?? '$hour';
    if (min == 0) return hWord;
    return '$hWord $min';
  }
}
