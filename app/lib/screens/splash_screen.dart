import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants.dart';
import '../l10n/app_strings.dart';
import '../repositories/farmer_repository.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'phone_login_screen.dart';

class SplashScreen extends StatefulWidget {
  final FarmerRepository repository;
  final Function(AppLanguage) onLanguageChanged;
  final AppLanguage currentLanguage;

  const SplashScreen({
    super.key,
    required this.repository,
    required this.onLanguageChanged,
    required this.currentLanguage,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    await Future.delayed(const Duration(milliseconds: 600));

    // 1. Check saved language
    final savedLang = await _storage.read(key: AppConstants.keyLanguage);
    if (savedLang != null) {
      widget.onLanguageChanged(AppLanguage.fromCode(savedLang));
    }

    // 2. Check onboarding status
    final hasSeenOnboarding = await _storage.read(key: AppConstants.keyHasSeenOnboarding);
    if (hasSeenOnboarding != 'true') {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OnboardingScreen(
            repository: widget.repository,
            onLanguageChanged: widget.onLanguageChanged,
            currentLanguage: widget.currentLanguage,
          ),
        ),
      );
      return;
    }

    // 3. Check session tokens
    final token = await _storage.read(key: AppConstants.keyAccessToken);
    if (token != null && token.isNotEmpty) {
      try {
        // Attempt live profile validation
        await widget.repository.getProfile();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              repository: widget.repository,
              onLanguageChanged: widget.onLanguageChanged,
              currentLanguage: widget.currentLanguage,
              isOffline: false,
            ),
          ),
        );
        return;
      } catch (e) {
        // Check if offline with cached profile
        final cachedProfile = await widget.repository.getCachedProfile();
        if (cachedProfile != null) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                repository: widget.repository,
                onLanguageChanged: widget.onLanguageChanged,
                currentLanguage: widget.currentLanguage,
                isOffline: true,
              ),
            ),
          );
          return;
        }
      }
    }

    // Default to login if no valid session
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PhoneLoginScreen(
          repository: widget.repository,
          onLanguageChanged: widget.onLanguageChanged,
          currentLanguage: widget.currentLanguage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.currentLanguage);
    return Scaffold(
      backgroundColor: AppTheme.warmBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco,
                size: 72,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              strings.appTitle,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.tagline,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppTheme.primaryGreen,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
