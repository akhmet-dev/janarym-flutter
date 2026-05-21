import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/assistant_mode.dart';
import '../models/user_profile.dart';

/// Popup modes menu with glass-morphism styling.
class ModesMenu extends StatelessWidget {
  final AppMode activeMode;
  final AppLanguage language;
  final void Function(AppMode) onModeTap;

  const ModesMenu({
    super.key,
    required this.activeMode,
    required this.language,
    required this.onModeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: AppMode.values.map((mode) {
          final isActive = mode == activeMode;
          return GestureDetector(
            onTap: () => onModeTap(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 180,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primary.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? AppTheme.primary.withOpacity(0.4) : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    mode.icon,
                    color: isActive ? AppTheme.primary : AppTheme.textTertiary,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      mode.localizedName(language),
                      style: AppTheme.bodySmall.copyWith(
                        color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isActive)
                    const Icon(Icons.check, color: AppTheme.primary, size: 16),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
