import 'package:flutter/material.dart';
import 'package:camera/camera.dart' hide FocusMode;
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../models/assistant_mode.dart';
import '../models/user_profile.dart';
import '../providers/assistant_provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_text.dart';
import '../widgets/status_pill.dart';
import '../widgets/pulsing_dot.dart';
import '../widgets/modes_menu.dart';
import '../widgets/glass_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  bool _isModesOpen = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Init camera
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssistantProvider>().initCamera();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assistant = context.watch<AssistantProvider>();
    final onboarding = context.watch<OnboardingProvider>();
    final auth = context.watch<AuthProvider>();
    final lang = onboarding.currentLanguage;
    final kk = lang == AppLanguage.kazakh;

    return Scaffold(
      body: Stack(
        children: [
          // ─── Camera Preview (full screen background) ───
          if (assistant.cameraController != null &&
              assistant.cameraController!.value.isInitialized)
            Positioned.fill(
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: assistant.cameraController!.value.previewSize?.height ?? 1,
                    height: assistant.cameraController!.value.previewSize?.width ?? 1,
                    child: CameraPreview(assistant.cameraController!),
                  ),
                ),
              ),
            )
          else
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppTheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        AppText.pick('Камера іске қосылып жатыр...', 'Запуск камеры...', language: lang),
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ─── Dim overlay when menu is open ───
          if (_isModesOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _isModesOpen = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  color: Colors.black.withOpacity(0.15),
                ),
              ),
            ),

          // ─── Full screen PTT tap zone ───
          if (!_isModesOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => assistant.toggleVoiceCapture(),
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),

          // ─── Top bar ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    StatusPill(
                      assistantMode: assistant.mode,
                      appMode: assistant.activeMode,
                      language: lang,
                    ),

                    // Offline indicator
                    if (assistant.isOfflineMode) ...[
                      const SizedBox(width: 8),
                      _buildOfflineBadge(kk),
                    ],

                    const Spacer(),

                    // User menu
                    PopupMenuButton<String>(
                      icon: Icon(Icons.account_circle, color: AppTheme.textTertiary, size: 28),
                      color: AppTheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onSelected: (value) {
                        if (value == 'logout') {
                          _showLogoutDialog(context, auth, lang);
                        }
                      },
                      itemBuilder: (_) => [
                        if (auth.currentUser != null)
                          PopupMenuItem(
                            enabled: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(auth.currentUser!.name, style: AppTheme.body),
                                Text(auth.currentUser!.role.label, style: AppTheme.caption),
                              ],
                            ),
                          ),
                        const PopupMenuDivider(),
                        ...AppLanguage.values.map(
                          (l) => PopupMenuItem(
                            onTap: () => onboarding.updateLanguage(l),
                            child: Row(
                              children: [
                                Icon(
                                  onboarding.currentLanguage == l
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: onboarding.currentLanguage == l
                                      ? AppTheme.primary
                                      : AppTheme.textTertiary,
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Text(l.displayName, style: AppTheme.bodySmall),
                              ],
                            ),
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              const Icon(Icons.logout, color: AppTheme.error, size: 18),
                              const SizedBox(width: 12),
                              Text(
                                AppText.pick('Шығу', 'Выйти', language: lang),
                                style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Live transcription overlay ───
          if (assistant.liveTranscript.isNotEmpty || assistant.liveResponseText.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              left: 16,
              right: 16,
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (assistant.liveTranscript.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.person, color: AppTheme.textTertiary, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              assistant.liveTranscript,
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimary),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (assistant.liveResponseText.isNotEmpty) ...[
                      if (assistant.liveTranscript.isNotEmpty) const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.auto_awesome, color: AppTheme.primary.withOpacity(0.8), size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              assistant.liveResponseText,
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // ─── Bottom controls ───
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Left buttons: settings, medcard
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCircleButton(
                          icon: Icons.settings,
                          color: AppTheme.textSecondary,
                          onTap: () => _showSettingsSheet(context, onboarding, lang),
                        ),
                        const SizedBox(height: 10),
                        _buildCircleButton(
                          icon: Icons.local_hospital,
                          color: AppTheme.error,
                          onTap: () => _showMedCardSheet(context, onboarding, lang),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Right: modes menu + button
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_isModesOpen)
                          ModesMenu(
                            activeMode: assistant.activeMode,
                            language: lang,
                            onModeTap: (mode) {
                              assistant.setActiveMode(mode);
                              setState(() => _isModesOpen = false);
                            },
                          ),
                        const SizedBox(height: 8),
                        _buildModesButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Center PTT indicator (subtle dot only) ───
          if (assistant.mode == AssistantMode.recording)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 100,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) {
                      final scale = 1.0 + _pulseController.value * 0.15;
                      return Container(
                        width: 12 * scale,
                        height: 12 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.recording.withOpacity(0.8),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.recording.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          // ─── Processing indicator ───
          if (assistant.mode == AssistantMode.processing)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.processing.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.processing,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppText.pick('Ойланып жатырмын...', 'Думаю...', language: lang),
                          style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOfflineBadge(bool kk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, color: Colors.orange, size: 12),
          const SizedBox(width: 4),
          Text(kk ? 'Офлайн' : 'Офлайн',
              style: AppTheme.caption.copyWith(color: Colors.orange, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildModesButton() {
    return GestureDetector(
      onTap: () => setState(() => _isModesOpen = !_isModesOpen),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.65),
          border: Border.all(
            color: Colors.white.withOpacity(_isModesOpen ? 0.5 : 0.22),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.24), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: AnimatedRotation(
          turns: _isModesOpen ? 0.25 : 0,
          duration: const Duration(milliseconds: 180),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _gridDot(),
                  const SizedBox(width: 5),
                  _gridDot(),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _gridDot(),
                  const SizedBox(width: 5),
                  _gridDot(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridDot() {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, OnboardingProvider onboarding, AppLanguage lang) {
    final kk = lang == AppLanguage.kazakh;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final profile = onboarding.profile;
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: AppTheme.divider),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.textDisabled, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  Text(kk ? 'Баптаулар' : 'Настройки', style: AppTheme.heading3),
                  const SizedBox(height: 20),

                  // Speech Rate
                  _settingsSection(
                    title: kk ? 'Сөйлеу жылдамдығы' : 'Скорость речи',
                    child: Row(
                      children: SpeechRate.values.map((r) {
                        final selected = profile.speechRate == r;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              onboarding.updateProfile(profile.copyWith(speechRate: r));
                              setSheetState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: selected ? AppTheme.primary.withOpacity(0.15) : AppTheme.overlayLight,
                                border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
                              ),
                              child: Center(
                                child: Text(r.display(lang), style: AppTheme.bodySmall.copyWith(
                                  color: selected ? AppTheme.primary : AppTheme.textSecondary,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                )),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Response Length
                  _settingsSection(
                    title: kk ? 'Жауап ұзындығы' : 'Длина ответа',
                    child: Row(
                      children: ResponseLength.values.map((r) {
                        final selected = profile.responseLength == r;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              onboarding.updateProfile(profile.copyWith(responseLength: r));
                              setSheetState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: selected ? AppTheme.primary.withOpacity(0.15) : AppTheme.overlayLight,
                                border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
                              ),
                              child: Center(
                                child: Text(r.display(lang), style: AppTheme.bodySmall.copyWith(
                                  color: selected ? AppTheme.primary : AppTheme.textSecondary,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                )),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Voice
                  _settingsSection(
                    title: kk ? 'Дауыс' : 'Голос',
                    child: Row(
                      children: GPTVoice.values.map((v) {
                        final selected = profile.gptVoice == v;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              onboarding.updateProfile(profile.copyWith(gptVoice: v));
                              setSheetState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: selected ? AppTheme.primary.withOpacity(0.15) : AppTheme.overlayLight,
                                border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
                              ),
                              child: Center(
                                child: Text(
                                  v == GPTVoice.ember ? (kk ? 'Ер' : 'Муж.') : (kk ? 'Әйел' : 'Жен.'),
                                  style: AppTheme.bodySmall.copyWith(
                                    color: selected ? AppTheme.primary : AppTheme.textSecondary,
                                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Formality
                  _settingsSection(
                    title: kk ? 'Қатынасу формасы' : 'Обращение',
                    child: Row(
                      children: Formality.values.map((f) {
                        final selected = profile.formality == f;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              onboarding.updateProfile(profile.copyWith(formality: f));
                              setSheetState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: selected ? AppTheme.primary.withOpacity(0.15) : AppTheme.overlayLight,
                                border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
                              ),
                              child: Center(
                                child: Text(f.display(lang), style: AppTheme.bodySmall.copyWith(
                                  color: selected ? AppTheme.primary : AppTheme.textSecondary,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                )),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Focus Mode
                  _settingsSection(
                    title: kk ? 'Фокус режимі' : 'Режим фокуса',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: FocusMode.values.map((fm) {
                        final selected = profile.focusMode == fm;
                        return GestureDetector(
                          onTap: () {
                            onboarding.updateProfile(profile.copyWith(focusMode: fm));
                            setSheetState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: selected ? AppTheme.primary.withOpacity(0.15) : AppTheme.overlayLight,
                              border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
                            ),
                            child: Text(fm.announcementText(lang), style: AppTheme.caption.copyWith(
                              color: selected ? AppTheme.primary : AppTheme.textSecondary,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                            )),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _settingsSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  void _showMedCardSheet(BuildContext context, OnboardingProvider onboarding, AppLanguage lang) {
    final kk = lang == AppLanguage.kazakh;
    final profile = onboarding.profile;
    final nameController = TextEditingController(text: profile.name);
    final ageController = TextEditingController(text: profile.age > 0 ? profile.age.toString() : '');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppTheme.divider),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.textDisabled, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.local_hospital, color: AppTheme.error, size: 20),
                  const SizedBox(width: 8),
                  Text(kk ? 'Мед карта' : 'Мед. карта', style: AppTheme.heading3),
                ],
              ),
              const SizedBox(height: 20),

              // Name field
              TextField(
                controller: nameController,
                style: AppTheme.body,
                decoration: InputDecoration(
                  labelText: kk ? 'Аты-жөні' : 'ФИО',
                  labelStyle: AppTheme.caption,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primary),
                  ),
                  filled: true,
                  fillColor: AppTheme.overlayLight,
                ),
              ),
              const SizedBox(height: 12),

              // Age field
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                style: AppTheme.body,
                decoration: InputDecoration(
                  labelText: kk ? 'Жасы' : 'Возраст',
                  labelStyle: AppTheme.caption,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primary),
                  ),
                  filled: true,
                  fillColor: AppTheme.overlayLight,
                ),
              ),
              const SizedBox(height: 20),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    onboarding.updateProfile(profile.copyWith(
                      name: nameController.text.trim(),
                      age: int.tryParse(ageController.text.trim()) ?? 0,
                    ));
                    Navigator.of(context).pop();
                  },
                  child: Text(kk ? 'Сақтау' : 'Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth, AppLanguage lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(AppText.pick('Шығу', 'Выйти', language: lang), style: AppTheme.heading3),
        content: Text(
          AppText.pick('Аккаунттан шығасыз ба?', 'Выйти из аккаунта?', language: lang),
          style: AppTheme.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppText.pick('Жоқ', 'Нет', language: lang)),
          ),
          TextButton(
            onPressed: () {
              auth.signOut();
              Navigator.of(ctx).pop();
            },
            child: Text(
              AppText.pick('Иә, шығу', 'Да, выйти', language: lang),
              style: const TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
