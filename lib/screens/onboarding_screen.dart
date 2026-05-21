import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../models/user_profile.dart';
import '../providers/onboarding_provider.dart';
import '../l10n/app_text.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();
    final lang = onboarding.currentLanguage;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Row(
                  children: List.generate(4, (i) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i <= _currentPage ? AppTheme.primary : AppTheme.divider,
                      ),
                    ),
                  )),
                ),
              ),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    _buildLanguagePage(onboarding, lang),
                    _buildVoicePage(onboarding, lang),
                    _buildSpeechRatePage(onboarding, lang),
                    _buildFinishPage(onboarding, lang),
                  ],
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: _goBack,
                        child: Text(
                          AppText.pick('Артқа', 'Назад', language: lang),
                          style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                        ),
                      ),
                    const Spacer(),
                    SizedBox(
                      width: 120,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _currentPage < 3 ? _goNext : () => _finish(onboarding),
                        child: Text(
                          _currentPage < 3
                              ? AppText.pick('Келесі', 'Далее', language: lang)
                              : AppText.pick('Бастау', 'Начать', language: lang),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Page 1: Language selection
  Widget _buildLanguagePage(OnboardingProvider onboarding, AppLanguage lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withOpacity(0.1),
            ),
            child: const Icon(Icons.language, color: AppTheme.primary, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            AppText.pick('Тілді таңдаңыз', 'Выберите язык', language: lang),
            style: AppTheme.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppText.pick(
              'Жанарым осы тілде сөйлейді',
              'Жанарым будет говорить на этом языке',
              language: lang,
            ),
            style: AppTheme.bodySmall,
          ),
          const SizedBox(height: 32),
          ...AppLanguage.values.map((l) => _buildOptionCard(
            label: l.displayName,
            isSelected: onboarding.currentLanguage == l,
            onTap: () => onboarding.updateLanguage(l),
          )),
        ],
      ),
    );
  }

  // Page 2: Voice selection
  Widget _buildVoicePage(OnboardingProvider onboarding, AppLanguage lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accent.withOpacity(0.1),
            ),
            child: const Icon(Icons.record_voice_over, color: AppTheme.accent, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            AppText.pick('Дауысты таңдаңыз', 'Выберите голос', language: lang),
            style: AppTheme.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...GPTVoice.values.map((v) => _buildOptionCard(
            label: v == GPTVoice.ember
                ? AppText.pick('Ер дауыс', 'Мужской голос', language: lang)
                : AppText.pick('Әйел дауыс', 'Женский голос', language: lang),
            isSelected: onboarding.profile.gptVoice == v,
            onTap: () => onboarding.updateProfile(onboarding.profile.copyWith(gptVoice: v)),
            icon: v == GPTVoice.ember ? Icons.male : Icons.female,
          )),
        ],
      ),
    );
  }

  // Page 3: Speech rate
  Widget _buildSpeechRatePage(OnboardingProvider onboarding, AppLanguage lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.speaking.withOpacity(0.1),
            ),
            child: const Icon(Icons.speed, color: AppTheme.speaking, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            AppText.pick('Сөйлеу жылдамдығы', 'Скорость речи', language: lang),
            style: AppTheme.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...SpeechRate.values.map((r) => _buildOptionCard(
            label: r.display(lang),
            isSelected: onboarding.profile.speechRate == r,
            onTap: () => onboarding.updateProfile(onboarding.profile.copyWith(speechRate: r)),
          )),
        ],
      ),
    );
  }

  // Page 4: Finish
  Widget _buildFinishPage(OnboardingProvider onboarding, AppLanguage lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withOpacity(0.15),
            ),
            child: const Icon(Icons.check, color: AppTheme.primary, size: 44),
          ),
          const SizedBox(height: 24),
          Text(
            AppText.pick('Барлығы дайын!', 'Всё готово!', language: lang),
            style: AppTheme.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            AppText.pick(
              'Жанарым сізге көмектесуге дайын.\nЭкранды басып, сұрағыңызды айтыңыз.',
              'Жанарым готов помогать.\nНажмите на экран и задайте вопрос.',
              language: lang,
            ),
            style: AppTheme.body.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          color: isSelected ? AppTheme.primary.withOpacity(0.1) : AppTheme.overlayLight,
          border: Border.all(
            color: isSelected ? AppTheme.primary.withOpacity(0.5) : AppTheme.divider,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.textTertiary, size: 24),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Text(
                label,
                style: AppTheme.body.copyWith(
                  color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppTheme.primary : AppTheme.textDisabled,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void _goNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _finish(OnboardingProvider onboarding) {
    onboarding.completeOnboarding();
  }
}
