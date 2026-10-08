import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parali_setu/l10n/app_strings.dart';
import 'package:parali_setu/models/booking_result.dart';
import 'package:parali_setu/models/matched_bundle.dart';
import 'package:parali_setu/repositories/farmer_repository.dart';
import 'package:parali_setu/screens/booking_detail_screen.dart';

void main() {
  group('Booking Models Unit Tests', () {
    test('BookingResult parses JSON correctly', () {
      final json = {
        'id': 'bk-test-1234',
        'offer_id': 'off-test-5678',
        'farmer_id': 'farmer-uuid-1',
        'status': 'confirmed',
        'escrow_amount_inr': 5460.0,
        'final_payout_inr': null,
        'confirmed_at': '2026-10-25T10:00:00Z',
        'payment': {
          'id': 'pm-123',
          'booking_id': 'bk-test-1234',
          'provider': 'simulated_escrow',
          'escrow_amount_inr': 5460.0,
          'status': 'held',
          'held_at': '2026-10-25T10:00:00Z',
        },
      };

      final booking = BookingResult.fromJson(json);
      expect(booking.id, 'bk-test-1234');
      expect(booking.status, 'confirmed');
      expect(booking.escrowAmountInr, 5460.0);
      expect(booking.payment?.status, 'held');
    });

    test('WeighbridgeSummary parses JSON and calculates net tonnes', () {
      final json = {
        'id': 'wb-123',
        'booking_id': 'bk-test-1234',
        'weight_kg': 8000.0,
        'weight_tonnes': 8.0,
        'ticket_number': 'DK-889900',
        'disputed': false,
        'measured_at': '2026-10-26T14:30:00Z',
      };

      final wb = WeighbridgeSummary.fromJson(json);
      expect(wb.ticketNumber, 'DK-889900');
      expect(wb.weightTonnes, 8.0);
      expect(wb.weightKg, 8000.0);
      expect(wb.disputed, false);
    });
  });

  group('BookingDetailScreen Widget Tests', () {
    testWidgets('renders escrow hero, stepper, and simulates Dharamkanta ticket release', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = MockFarmerRepository();
      final bundle = MatchedBundle(
        offerId: 'off-test-123',
        rank: 1,
        tag: 'BEST_VALUE',
        tagLabelEn: 'Best Net Payout',
        tagLabelHi: 'सबसे ज्यादा मुनाफा',
        tagLabelPa: 'ਸਭ ਤੋਂ ਵੱਧ ਮੁਨਾਫਾ',
        proposedPickupDate: DateTime(2026, 10, 26),
        daysAfterHarvest: 2,
        machineName: 'Gurdeep Singh Agro Balers',
        machineType: 'Claas Square Baler',
        machineCostInr: 4800.0,
        truckName: 'Sharma Transport Logistics',
        truckCapacityTonnes: 12.0,
        transportCostInr: 540.0,
        buyerName: 'Verbio India Bio-CNG Plant',
        buyerType: 'Bio-CNG Refinery',
        buyerDistanceKm: 18.5,
        buyerPricePerTonneInr: 1350.0,
        stubbleTonnes: 8.0,
        grossIncomeInr: 10800.0,
        netIncomeInr: 5460.0,
        co2SavedTonnes: 12.0,
        pm25AvoidedKg: 144.0,
      );

      final initialBooking = BookingResult(
        id: 'bk-test-9999',
        offerId: bundle.offerId,
        farmerId: 'farmer-1',
        status: 'confirmed',
        escrowAmountInr: 5460.0,
        confirmedAt: DateTime.now(),
        payment: PaymentSummary(
          id: 'pm-1',
          bookingId: 'bk-test-9999',
          provider: 'simulated_escrow',
          escrowAmountInr: 5460.0,
          status: 'held',
          heldAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookingDetailScreen(
            initialBooking: initialBooking,
            bundle: bundle,
            repository: repo,
            language: AppLanguage.english,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify Escrow locked banner & amount
      expect(find.text('Live Pickup & Escrow'), findsOneWidget);
      expect(find.text('Factory Escrow Locked'), findsOneWidget);
      expect(find.text('₹5460'), findsOneWidget);

      // 2. Verify Stepper steps
      expect(find.text('Booking Confirmed'), findsOneWidget);
      expect(find.text('Baler Picked Up'), findsOneWidget);
      expect(find.text('Weighbridge Weighed'), findsOneWidget);
      expect(find.text('Escrow Released'), findsOneWidget);

      // 3. Verify Environmental Card
      expect(find.text('No-Burn Certified Harvest'), findsOneWidget);

      // 4. Tap "Simulate Weighbridge Receipt" button
      final simulateBtn = find.text('Simulate Weighbridge Receipt');
      expect(simulateBtn, findsOneWidget);
      await tester.tap(simulateBtn);
      await tester.pumpAndSettle();

      // 5. Verify modal opened
      expect(find.text('Dharamkanta Slip Entry'), findsOneWidget);
      expect(find.text('Verify & Release Escrow'), findsOneWidget);

      // 6. Submit modal
      await tester.tap(find.text('Verify & Release Escrow'));
      await tester.pumpAndSettle();

      // 7. Verify status changed to VERIFIED and released
      expect(find.text('VERIFIED'), findsOneWidget);
      expect(find.text('Transferred to Bank'), findsOneWidget);
    });
  });
}
