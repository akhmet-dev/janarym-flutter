import '../models/user_profile.dart';

/// Bilingual text helper
class AppText {
  AppText._();

  static String pick(String kk, String ru, {String? en, AppLanguage? language}) {
    final lang = language ?? AppLanguage.kazakh;
    switch (lang) {
      case AppLanguage.kazakh: return kk;
      case AppLanguage.russian: return ru;
      case AppLanguage.english: return en ?? kk;
    }
  }
}
