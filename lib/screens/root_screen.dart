import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'permissions_screen.dart';
import 'main_screen.dart';

/// Root navigation: decides which screen to show based on auth + onboarding state.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  bool _permissionsGranted = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final onboarding = context.watch<OnboardingProvider>();

    // 1. Restoring session
    if (auth.isRestoringSession) {
      return const SplashScreen();
    }

    // 2. Not authenticated → login
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    // 3. Onboarding not completed
    if (!onboarding.isCompleted) {
      return const OnboardingScreen();
    }

    // 4. Permissions not granted
    if (!_permissionsGranted) {
      return PermissionsScreen(
        onAllGranted: () => setState(() => _permissionsGranted = true),
      );
    }

    // 5. Main app
    return const MainScreen();
  }
}
