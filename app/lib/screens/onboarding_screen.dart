import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants.dart';
import '../l10n/app_strings.dart';
import '../repositories/farmer_repository.dart';
import '../theme.dart';
import '../widgets/illustrations.dart';
import 'phone_login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final FarmerRepository repository;
  final Function(AppLanguage) onLanguageChanged;
  final AppLanguage currentLanguage;

  const OnboardingScreen({
    super.key,
    required this.repository,
    required this.onLanguageChanged,
    required this.currentLanguage,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    _storage.write(key: AppConstants.keyHasSeenOnboarding, value: 'true').catchError((_) {});
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

  void _onLanguageSelected(AppLanguage lang) async {
    widget.onLanguageChanged(lang);
    try {
      await _storage.write(key: AppConstants.keyLanguage, value: lang.code);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.currentLanguage);

    final slides = [
      _SlideData(
        title: strings.onboardingSlide1Title,
        description: strings.onboardingSlide1Desc,
        illustration: const OnboardingIllustration1(),
      ),
      _SlideData(
        title: strings.onboardingSlide2Title,
        description: strings.onboardingSlide2Desc,
        illustration: const OnboardingIllustration2(),
      ),
      _SlideData(
        title: strings.onboardingSlide3Title,
        description: strings.onboardingSlide3Desc,
        illustration: const OnboardingIllustration3(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.warmBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            key: const Key('onboarding_skip_btn'),
            onPressed: _completeOnboarding,
            child: Text(
              strings.skip,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLanguageChip('English', AppLanguage.english),
                  const SizedBox(width: 8),
                  _buildLanguageChip('हिंदी', AppLanguage.hindi),
                  const SizedBox(width: 8),
                  _buildLanguageChip('ਪੰਜਾਬੀ', AppLanguage.punjabi),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, idx) {
                  final slide = slides[idx];
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          slide.illustration,
                          const SizedBox(height: 24),
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 8,
                  width: _currentPage == i ? 26 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? AppTheme.primaryGreen : const Color(0xFFD0DDD0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('onboarding_primary_btn'),
                  onPressed: () {
                    if (_currentPage < slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  child: Text(
                    _currentPage == slides.length - 1 ? strings.getStarted : strings.next,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageChip(String label, AppLanguage lang) {
    final isSelected = widget.currentLanguage == lang;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppTheme.textDark,
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryGreen,
      backgroundColor: Colors.white,
      side: BorderSide(color: isSelected ? AppTheme.primaryGreen : const Color(0xFFD0DDD0)),
      onSelected: (_) => _onLanguageSelected(lang),
    );
  }
}

class _SlideData {
  final String title;
  final String description;
  final Widget illustration;

  _SlideData({
    required this.title,
    required this.description,
    required this.illustration,
  });
}
