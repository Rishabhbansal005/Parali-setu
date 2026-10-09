import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parali_setu/l10n/app_strings.dart';
import 'package:parali_setu/repositories/farmer_repository.dart';
import 'package:parali_setu/screens/field_details_screen.dart';

void main() {
  group('Voice Intake Unit & Mock Repository Tests', () {
    late MockFarmerRepository repository;

    setUp(() {
      repository = MockFarmerRepository();
    });

    test('parseVoiceInput extracts killa, PR-126, and date in Hindi', () async {
      final res = await repository.parseVoiceInput(
        transcript: '4 killa PR-126, 25 October',
        language: 'hi',
      );

      expect(res.acres, 4.0);
      expect(res.variety, 'PR-126');
      expect(res.harvestDate, '2026-10-25');
      expect(res.confidence, greaterThanOrEqualTo(0.90));
      expect(res.confirmationPrompt, contains('4 किल्ला PR-126'));
      expect(res.confirmationPrompt, contains('सही है?'));
    });

    test('parseVoiceInput extracts bigha conversion to acres (10 bigha = 2.0 acres)', () async {
      final res = await repository.parseVoiceInput(
        transcript: '10 bigha Basmati, kal',
        language: 'hi',
      );

      expect(res.acres, 2.0); // 10 * 0.20 = 2.0 acres
      expect(res.variety, 'Basmati');
      expect(res.harvestDate, '2026-10-21');
      expect(res.confirmationPrompt, contains('2 किल्ला Basmati'));
    });

    test('parseVoiceInput supports Punjabi Gurmukhi phrasing', () async {
      final res = await repository.parseVoiceInput(
        transcript: '6 ਕਿੱਲੇ Pusa-44, 28 ਅਕਤੂਬਰ',
        language: 'pa',
      );

      expect(res.acres, 6.0);
      expect(res.variety, 'Pusa-44');
      expect(res.harvestDate, '2026-10-28');
      expect(res.confirmationPrompt, contains('6 ਕਿੱਲਾ Pusa-44'));
      expect(res.confirmationPrompt, contains('ਕੀ ਇਹ ਸਹੀ ਹੈ?'));
    });
  });

  group('FieldDetailsScreen Voice Intake UI Flow', () {
    late MockFarmerRepository repository;

    setUp(() {
      repository = MockFarmerRepository();
    });

    Widget createTestWidget({AppLanguage language = AppLanguage.hindi}) {
      return MaterialApp(
        home: FieldDetailsScreen(
          language: language,
          repository: repository,
        ),
      );
    }

    testWidgets('Tapping mic opens bottom sheet with vernacular sample chips', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final micBtn = find.byKey(const Key('voice_intake_mic_button'));
      expect(micBtn, findsOneWidget);

      await tester.tap(micBtn);
      await tester.pumpAndSettle();

      // Verify bottom sheet opened
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('4 killa PR-126, 25 October'), findsOneWidget);
      expect(find.text('6 ਕਿੱਲੇ Pusa-44, 28 ਅਕਤੂਬਰ'), findsOneWidget);
    });

    testWidgets('Full Voice Intake Flow: Tap sample -> Confirmation Card -> Apply -> Auto-Fill', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(language: AppLanguage.hindi));
      await tester.pumpAndSettle();

      // 1. Open voice bottom sheet
      await tester.tap(find.byKey(const Key('voice_intake_mic_button')));
      await tester.pumpAndSettle();

      // 2. Tap sample chip: "4 killa PR-126, 25 October"
      final sampleChip = find.text('4 killa PR-126, 25 October');
      expect(sampleChip, findsOneWidget);
      await tester.tap(sampleChip);
      await tester.pump(); // Start async call
      await tester.pump(const Duration(milliseconds: 400)); // Advance delayed timer
      await tester.pumpAndSettle();

      // 3. Verify AI Directive 1 Confirmation Card is visible
      expect(find.text('जानकारी की पुष्टि करें'), findsOneWidget);
      expect(find.byKey(const Key('voice_confirm_yes_button')), findsOneWidget);
      expect(find.byKey(const Key('voice_retry_button')), findsOneWidget);

      // 4. Confirm by tapping "हाँ, सही है"
      await tester.tap(find.byKey(const Key('voice_confirm_yes_button')));
      await tester.pumpAndSettle();

      // 5. Verify bottom sheet dismissed and auto-filled badge appears
      expect(find.text('आवाज से भरा गया'), findsOneWidget);
      expect(find.text('4.0 एकड़'), findsOneWidget);
    });
  });
}
