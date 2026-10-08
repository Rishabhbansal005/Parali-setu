import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parali_setu/l10n/app_strings.dart';
import 'package:parali_setu/models/estimate_result.dart';
import 'package:parali_setu/repositories/farmer_repository.dart';
import 'package:parali_setu/screens/estimate_screen.dart';
import 'package:parali_setu/screens/home_screen.dart';
import 'package:parali_setu/screens/onboarding_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parali_setu/screens/phone_login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockFarmerRepository mockRepository;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    mockRepository = MockFarmerRepository();
  });

  group('UX & Widget Flow Tests', () {
    testWidgets('Onboarding shows slides and advances to login', (WidgetTester tester) async {
      AppLanguage currentLang = AppLanguage.english;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            repository: mockRepository,
            onLanguageChanged: (l) => currentLang = l,
            currentLanguage: currentLang,
          ),
        ),
      );

      // Verify Slide 1 English content
      expect(find.text('Do not burn it. Sell it.'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Advance to Slide 2
      await tester.tap(find.byKey(const Key('onboarding_primary_btn')));
      await tester.pumpAndSettle();
      expect(find.text('We find the machine, truck and buyer for you.'), findsOneWidget);

      // Advance to Slide 3
      await tester.tap(find.byKey(const Key('onboarding_primary_btn')));
      await tester.pumpAndSettle();
      expect(find.text('Get paid on the actual weight, safely.'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);

      // Tap Get Started -> transitions to PhoneLoginScreen
      await tester.tap(find.byKey(const Key('onboarding_primary_btn')));
      await tester.pumpAndSettle();
      expect(find.byType(PhoneLoginScreen), findsOneWidget);
      expect(find.text('Farmer Login'), findsOneWidget);
    });

    testWidgets('Language switching updates UI immediately', (WidgetTester tester) async {
      AppLanguage currentLang = AppLanguage.english;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: OnboardingScreen(
                repository: mockRepository,
                onLanguageChanged: (l) {
                  setState(() {
                    currentLang = l;
                  });
                },
                currentLanguage: currentLang,
              ),
            );
          },
        ),
      );

      // Initially English
      expect(find.text('Do not burn it. Sell it.'), findsOneWidget);

      // Switch to Hindi
      await tester.tap(find.text('हिंदी'));
      await tester.pumpAndSettle();
      expect(find.text('इसे जलाएं नहीं। बेचें।'), findsOneWidget);

      // Switch to Punjabi
      await tester.tap(find.text('ਪੰਜਾਬੀ'));
      await tester.pumpAndSettle();
      expect(find.text('ਇਸਨੂੰ ਸਾੜੋ ਨਾ। ਵੇਚੋ। /* NEEDS NATIVE REVIEW */'), findsOneWidget);
    });

    testWidgets('Session restore: HomeScreen displays farmer greeting and tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            repository: mockRepository,
            onLanguageChanged: (_) {},
            currentLanguage: AppLanguage.english,
            isOffline: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Greeting and Primary card
      expect(find.text('Welcome, Gurpreet Singh'), findsOneWidget);
      expect(find.text('Check my stubble value'), findsOneWidget);
      expect(find.text('How It Works'), findsOneWidget);

      // Switch to Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Farmer Profile'), findsOneWidget);
      expect(find.text('Gurpreet Singh'), findsOneWidget);
      expect(find.text('About ParaliSetu'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('EstimateScreen renders big range and assumed price note', (WidgetTester tester) async {
      final estimate = EstimateResult(
        id: 'est-123',
        farmId: 'farm-123',
        harvestDate: '2026-10-25',
        stubbleTonnesLow: 6.40,
        stubbleTonnesMid: 8.00,
        stubbleTonnesHigh: 9.60,
        incomeLowInr: 7680.0,
        incomeHighInr: 11520.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EstimateScreen(
            language: AppLanguage.english,
            estimate: estimate,
            acres: 4.0,
            variety: 'PR-126',
            harvestMethod: 'combine',
          ),
        ),
      );

      expect(find.text('Stubble & Earnings Estimate'), findsOneWidget);
      expect(find.text('6.4 - 9.6 Tonnes'), findsOneWidget);
      expect(find.text('Central Estimate: ~8.0 Tonnes'), findsOneWidget);
      expect(find.text('₹7,680 - ₹11,520'), findsOneWidget);
      expect(find.text('assumed price: ₹1200/tonne'), findsOneWidget);
      expect(find.textContaining('certified weighbridge measurement'), findsOneWidget);
    });
  });
}
