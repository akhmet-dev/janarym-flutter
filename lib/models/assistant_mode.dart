import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'user_profile.dart';

/// Assistant processing state
enum AssistantMode {
  idle, recording, processing, speaking, error;

  String get localizedTitle {
    switch (this) {
      case AssistantMode.idle: return 'Дайын';
      case AssistantMode.recording: return 'Тыңдап жатырмын...';
      case AssistantMode.processing: return 'Ойланып жатырмын...';
      case AssistantMode.speaking: return 'Айтып жатырмын...';
      case AssistantMode.error: return 'Қате';
    }
  }

  Color get color {
    switch (this) {
      case AssistantMode.idle: return AppTheme.primary;
      case AssistantMode.recording: return AppTheme.recording;
      case AssistantMode.processing: return AppTheme.processing;
      case AssistantMode.speaking: return AppTheme.speaking;
      case AssistantMode.error: return AppTheme.error;
    }
  }
}

/// App feature mode
enum AppMode {
  general, navigation, security, shopping, reading, arGlasses;

  IconData get icon {
    switch (this) {
      case AppMode.general: return Icons.mic;
      case AppMode.navigation: return Icons.map;
      case AppMode.security: return Icons.shield;
      case AppMode.shopping: return Icons.shopping_cart;
      case AppMode.reading: return Icons.description;
      case AppMode.arGlasses: return Icons.visibility;
    }
  }

  String localizedName(AppLanguage lang) {
    final kk = lang == AppLanguage.kazakh;
    switch (this) {
      case AppMode.general: return kk ? 'Жалпы' : 'Общий';
      case AppMode.navigation: return 'Навигация';
      case AppMode.security: return kk ? 'Қауіпсіздік' : 'Безопасность';
      case AppMode.shopping: return kk ? 'Сауда' : 'Покупки';
      case AppMode.reading: return kk ? 'Мәтін оқу' : 'Чтение';
      case AppMode.arGlasses: return kk ? 'AR Көзілдірік' : 'AR Очки';
    }
  }

  String get modeKey {
    switch (this) {
      case AppMode.general: return 'general';
      case AppMode.navigation: return 'navigation';
      case AppMode.security: return 'antiscam';
      case AppMode.shopping: return 'shopping';
      case AppMode.reading: return 'reading';
      case AppMode.arGlasses: return 'arglasses';
    }
  }
}
