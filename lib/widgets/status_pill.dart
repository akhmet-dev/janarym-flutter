import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/assistant_mode.dart';
import '../models/user_profile.dart';
import '../l10n/app_text.dart';
import 'pulsing_dot.dart';

/// Top-left status pill showing current mode and assistant state.
class StatusPill extends StatelessWidget {
  final AssistantMode assistantMode;
  final AppMode appMode;
  final AppLanguage language;

  const StatusPill({
    super.key,
    required this.assistantMode,
    required this.appMode,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final modeLabel = appMode == AppMode.general
        ? AppText.pick('Жалпы режим', 'Общий режим', language: language)
        : appMode.localizedName(language);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.black.withOpacity(0.55),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(appMode.icon, color: AppTheme.textSecondary, size: 14),
          const SizedBox(width: 8),
          Text(modeLabel, style: AppTheme.label.copyWith(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(width: 8),
          PulsingDot(color: assistantMode.color),
          const SizedBox(width: 6),
          Text(
            assistantMode.localizedTitle,
            style: AppTheme.caption.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
