import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme.dart';
import 'phone_login_screen.dart';

class LanguageChoiceScreen extends StatefulWidget {
  const LanguageChoiceScreen({super.key});

  @override
  State<LanguageChoiceScreen> createState() => _LanguageChoiceScreenState();
}

class _LanguageChoiceScreenState extends State<LanguageChoiceScreen> {
  AppLanguage _selectedLanguage = AppLanguage.hindi;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(_selectedLanguage);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // App Branding
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.agriculture,
                    size: 64,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                strings.appTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.tagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),

              // Language Choice Heading
              Text(
                strings.chooseLanguage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              // Hindi Option
              _buildLanguageCard(
                title: 'हिंदी',
                subtitle: 'Hindi',
                isSelected: _selectedLanguage == AppLanguage.hindi,
                onTap: () {
                  setState(() {
                    _selectedLanguage = AppLanguage.hindi;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Punjabi Option (Marked NEEDS NATIVE REVIEW)
              _buildLanguageCard(
                title: 'ਪੰਜਾਬੀ',
                subtitle: 'Punjabi /* NEEDS NATIVE REVIEW */',
                isSelected: _selectedLanguage == AppLanguage.punjabi,
                onTap: () {
                  setState(() {
                    _selectedLanguage = AppLanguage.punjabi;
                  });
                },
              ),
              const Spacer(),

              // Continue Button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PhoneLoginScreen(
                        language: _selectedLanguage,
                      ),
                    ),
                  );
                },
                child: Text(strings.continueBtn),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : const Color(0xFFD0DDD0),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxStyle.shadow,
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primaryGreen : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BoxStyle {
  static final BoxShadow shadow = BoxShadow(
    color: AppTheme.primaryGreen.withValues(alpha: 0.12),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );
}

