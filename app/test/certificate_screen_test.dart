import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parali_setu/l10n/app_strings.dart';
import 'package:parali_setu/models/certificate_result.dart';
import 'package:parali_setu/repositories/farmer_repository.dart';
import 'package:parali_setu/screens/certificate_screen.dart';

void main() {
  group('Certificate Model Tests', () {
    test('CertificateResult parses JSON correctly', () {
      final json = {
        'certificate_id': 'CERT-PSETU-889900',
        'booking_id': 'bk-test-1234',
        'farmer_name': 'Gurpreet Singh',
        'village': 'Kot Buddha',
        'district': 'Tarn Taran',
        'state': 'Punjab',
        'stubble_tonnes': 8.0,
        'satellite_source': 'Copernicus Sentinel-2',
        'image_date': '2026-10-26',
        'cloud_cover_pct': 4.2,
        'delta_nbr': 0.038,
        'result_state': 'verified_no_burn',
        'burn_detected': false,
        'burn_severity': 'NONE',
        'co2_avoided_tonnes': 12.0,
        'pm25_avoided_kg': 144.0,
        'equivalent_trees': 551,
        'issued_at': '2026-10-26T15:00:00Z',
        'is_valid': true,
        'authority': 'Punjab Clean Air Initiative',
        'verification_notes': 'Clean harvest verified without burn scars.',
      };

      final cert = CertificateResult.fromJson(json);
      expect(cert.certificateId, 'CERT-PSETU-889900');
      expect(cert.farmerName, 'Gurpreet Singh');
      expect(cert.stubbleTonnes, 8.0);
      expect(cert.co2AvoidedTonnes, 12.0);
      expect(cert.pm25AvoidedKg, 144.0);
      expect(cert.equivalentTrees, 551);
      expect(cert.isValid, true);
    });
  });

  group('CertificateScreen Widget Tests', () {
    testWidgets('renders official certificate diploma, seal, and shares with KVK', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = MockFarmerRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: CertificateScreen(
            bookingId: 'bk-test-889900',
            repository: repo,
            language: AppLanguage.english,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify Header & Certificate Title
      expect(find.text('No-Burn Certificate'), findsOneWidget);
      expect(find.text('NO-BURN GREEN HARVEST CERTIFICATE'), findsOneWidget);

      // 2. Verify Farmer Details
      expect(find.text('Gurpreet Singh'), findsOneWidget);
      expect(find.textContaining('Kot Buddha, Tarn Taran, Punjab'), findsOneWidget);

      // 3. Verify Sentinel-2 Satellite Badge
      expect(find.textContaining('Sentinel-2 SWIR Verified'), findsOneWidget);

      // 4. Verify Impact Cards
      expect(find.text('12.0 t'), findsOneWidget);
      expect(find.text('144 kg'), findsOneWidget);
      expect(find.text('551'), findsOneWidget);

      // 5. Tap Share Certificate Button
      final shareBtn = find.text('Share Certificate');
      expect(shareBtn, findsOneWidget);
      await tester.tap(shareBtn);
      await tester.pumpAndSettle();

      // 6. Verify Share SnackBar appears
      expect(find.textContaining('ready to share with KVK'), findsOneWidget);
    });
  });
}
