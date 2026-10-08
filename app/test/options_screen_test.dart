import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parali_setu/l10n/app_strings.dart';
import 'package:parali_setu/models/matched_bundle.dart';
import 'package:parali_setu/repositories/farmer_repository.dart';
import 'package:parali_setu/screens/options_screen.dart';


void main() {
  group('MatchedBundle Model Tests', () {
    test('parses JSON correctly with localized tags', () {
      final json = {
        'offer_id': 'test-offer-123',
        'rank': 1,
        'tag': 'BEST_VALUE',
        'tag_label_en': 'Best Value',
        'tag_label_hi': 'सबसे ज्यादा मुनाफा',
        'tag_label_pa': 'ਸਭ ਤੋਂ ਵੱਧ ਮੁਨਾਫਾ',
        'proposed_pickup_date': '2026-10-25',
        'days_after_harvest': 2,
        'machine_name': 'Gurdeep Baler',
        'machine_type': 'Square Baler',
        'machine_cost_inr': 4800.0,
        'truck_name': 'Sharma Roadways',
        'truck_capacity_tonnes': 12.0,
        'transport_cost_inr': 540.0,
        'buyer_name': 'Verbio Bio-CNG',
        'buyer_type': 'Bio-CNG',
        'buyer_distance_km': 18.5,
        'buyer_price_per_tonne_inr': 1350.0,
        'stubble_tonnes': 8.0,
        'gross_income_inr': 10800.0,
        'net_income_inr': 5460.0,
        'co2_saved_tonnes': 12.0,
        'pm25_avoided_kg': 144.0,
      };

      final bundle = MatchedBundle.fromJson(json);
      expect(bundle.offerId, 'test-offer-123');
      expect(bundle.rank, 1);
      expect(bundle.netIncomeInr, 5460.0);
      expect(bundle.co2SavedTonnes, 12.0);
      expect(bundle.getLocalizedTag('hi'), 'सबसे ज्यादा मुनाफा');
      expect(bundle.getLocalizedTag('pa'), 'ਸਭ ਤੋਂ ਵੱਧ ਮੁਨਾਫਾ');
      expect(bundle.getLocalizedTag('en'), 'Best Value');
    });
  });

  group('OptionsScreen Widget Flow Tests', () {
    testWidgets('renders matched bundle cards and opens escrow confirmation modal', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = MockFarmerRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: OptionsScreen(
            acres: 4.0,
            variety: 'PR-126',
            harvestDate: DateTime(2026, 10, 25),
            stubbleTonnes: 8.0,
            language: AppLanguage.english,
            repository: repo,
          ),
        ),
      );


      // Wait for future to complete
      await tester.pumpAndSettle();

      // Verify header summary
      expect(find.text('4.0 Killa • PR-126'), findsOneWidget);
      expect(find.text('8.0 Tonnes'), findsOneWidget);

      // Verify bundles are rendered (Rank 1, 2, 3)
      expect(find.text('Option #1'), findsOneWidget);
      expect(find.text('Option #2'), findsOneWidget);
      expect(find.text('Option #3'), findsOneWidget);

      // Verify partners are displayed
      expect(find.text('Gurdeep Singh Agro Balers'), findsOneWidget);
      expect(find.text('Sharma Transport Logistics'), findsOneWidget);

      // Tap "Book This Pickup" on Option #1
      final bookButtons = find.text('Book This Pickup');
      expect(bookButtons, findsAtLeastNWidgets(1));
      await tester.tap(bookButtons.first);
      await tester.pumpAndSettle();

      // Verify booking modal opens
      expect(find.text('Booking Confirmed!'), findsOneWidget);
      expect(find.textContaining('Simulated Escrow'), findsOneWidget);
    });
  });
}
