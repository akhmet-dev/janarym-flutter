import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/app_theme.dart';
import '../l10n/app_text.dart';
import '../providers/onboarding_provider.dart';

class PermissionsScreen extends StatefulWidget {
  final VoidCallback onAllGranted;

  const PermissionsScreen({super.key, required this.onAllGranted});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _cameraGranted = false;
  bool _micGranted = false;
  bool _speechGranted = false;
  bool _locationGranted = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    _cameraGranted = await Permission.camera.isGranted;
    _micGranted = await Permission.microphone.isGranted;
    _speechGranted = await Permission.speech.isGranted;
    _locationGranted = await Permission.location.isGranted;
    _isChecking = false;
    setState(() {});
    _checkAllGranted();
  }

  void _checkAllGranted() {
    if (_cameraGranted && _micGranted && _speechGranted) {
      widget.onAllGranted();
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isGranted || status.isLimited) {
      switch (permission) {
        case Permission.camera:
          _cameraGranted = true;
          break;
        case Permission.microphone:
          _micGranted = true;
          break;
        case Permission.speech:
          _speechGranted = true;
          break;
        case Permission.location:
          _locationGranted = true;
          break;
        default:
          break;
      }
      setState(() {});
      _checkAllGranted();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = OnboardingProvider.shared.currentLanguage;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: _isChecking
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withOpacity(0.1),
                        ),
                        child: const Icon(Icons.security, color: AppTheme.primary, size: 32),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppText.pick('Рұқсаттар', 'Разрешения', language: lang),
                        style: AppTheme.heading2,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppText.pick(
                          'Жанарым жұмыс істеу үшін келесі рұқсаттар қажет',
                          'Жанарым нужны следующие разрешения для работы',
                          language: lang,
                        ),
                        style: AppTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      _buildPermissionRow(
                        icon: Icons.camera_alt,
                        title: AppText.pick('Камера', 'Камера', language: lang),
                        subtitle: AppText.pick('Қоршаған ортаны көру', 'Видеть окружение', language: lang),
                        granted: _cameraGranted,
                        onTap: () => _requestPermission(Permission.camera),
                      ),
                      const SizedBox(height: 12),
                      _buildPermissionRow(
                        icon: Icons.mic,
                        title: AppText.pick('Микрофон', 'Микрофон', language: lang),
                        subtitle: AppText.pick('Дауыс командалары', 'Голосовые команды', language: lang),
                        granted: _micGranted,
                        onTap: () => _requestPermission(Permission.microphone),
                      ),
                      const SizedBox(height: 12),
                      _buildPermissionRow(
                        icon: Icons.record_voice_over,
                        title: AppText.pick('Сөйлеуді тану', 'Распознавание речи', language: lang),
                        subtitle: AppText.pick('Сұрақтарды тыңдау', 'Слушать вопросы', language: lang),
                        granted: _speechGranted,
                        onTap: () => _requestPermission(Permission.speech),
                      ),
                      const SizedBox(height: 12),
                      _buildPermissionRow(
                        icon: Icons.location_on,
                        title: AppText.pick('Орналасу', 'Геолокация', language: lang),
                        subtitle: AppText.pick('Навигация мен қауіпсіздік', 'Навигация и безопасность', language: lang),
                        granted: _locationGranted,
                        onTap: () => _requestPermission(Permission.location),
                      ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: (_cameraGranted && _micGranted && _speechGranted)
                              ? widget.onAllGranted
                              : null,
                          child: Text(
                            AppText.pick('Жалғастыру', 'Продолжить', language: lang),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPermissionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool granted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: granted ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          color: granted ? AppTheme.primary.withOpacity(0.08) : AppTheme.overlayLight,
          border: Border.all(
            color: granted ? AppTheme.primary.withOpacity(0.3) : AppTheme.divider,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (granted ? AppTheme.primary : AppTheme.textTertiary).withOpacity(0.15),
              ),
              child: Icon(icon, color: granted ? AppTheme.primary : AppTheme.textTertiary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.body.copyWith(fontSize: 15)),
                  Text(subtitle, style: AppTheme.caption),
                ],
              ),
            ),
            Icon(
              granted ? Icons.check_circle : Icons.circle_outlined,
              color: granted ? AppTheme.primary : AppTheme.textDisabled,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
