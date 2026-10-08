import 'package:flutter_test/flutter_test.dart';
import 'package:parali_setu/models/estimate_result.dart';
import 'package:parali_setu/models/farm.dart';

void main() {
  group('EstimateResult Model Parser Tests', () {
    test('parses full backend JSON response correctly', () {
      final backendJson = {
        'id': '89ef6722-1234-4567-8901-23456789abcd',
        'farm_id': 'e4a1a011-37d4-4bb6-b6b8-6e42b26c7104',
        'harvest_date': '2026-10-25',
        'wheat_sow_date': '2026-11-15',
        'stubble_tonnes_low': 6.4,
        'stubble_tonnes_mid': 8.0,
        'stubble_tonnes_high': 9.6,
        'income_low_inr': 7680.0,
        'income_high_inr': 11520.0,
        'config_snapshot': {
          'paddy_variety': 'PR-126',
          'harvest_method': 'combine',
        },
      };

      final result = EstimateResult.fromJson(backendJson);

      expect(result.id, equals('89ef6722-1234-4567-8901-23456789abcd'));
      expect(result.farmId, equals('e4a1a011-37d4-4bb6-b6b8-6e42b26c7104'));
      expect(result.harvestDate, equals('2026-10-25'));
      expect(result.wheatSowDate, equals('2026-11-15'));
      expect(result.stubbleTonnesLow, closeTo(6.4, 0.001));
      expect(result.stubbleTonnesMid, closeTo(8.0, 0.001));
      expect(result.stubbleTonnesHigh, closeTo(9.6, 0.001));
      expect(result.incomeLowInr, closeTo(7680.0, 0.001));
      expect(result.incomeHighInr, closeTo(11520.0, 0.001));
    });

    test('handles integer numbers and null wheat_sow_date gracefully', () {
      final integerJson = {
        'id': 'test-uuid-1',
        'farm_id': 'farm-uuid-1',
        'harvest_date': '2026-10-18',
        'wheat_sow_date': null,
        'stubble_tonnes_low': 6,
        'stubble_tonnes_mid': 8,
        'stubble_tonnes_high': 10,
        'income_low_inr': 7200,
        'income_high_inr': 12000,
      };

      final result = EstimateResult.fromJson(integerJson);

      expect(result.wheatSowDate, isNull);
      expect(result.stubbleTonnesLow, equals(6.0));
      expect(result.stubbleTonnesMid, equals(8.0));
      expect(result.stubbleTonnesHigh, equals(10.0));
      expect(result.incomeLowInr, equals(7200.0));
      expect(result.incomeHighInr, equals(12000.0));
    });

    test('serializes to JSON correctly', () {
      final estimate = EstimateResult(
        id: 'uuid-123',
        farmId: 'farm-456',
        harvestDate: '2026-10-20',
        stubbleTonnesLow: 5.0,
        stubbleTonnesMid: 6.5,
        stubbleTonnesHigh: 8.0,
        incomeLowInr: 6000.0,
        incomeHighInr: 9600.0,
      );

      final json = estimate.toJson();
      expect(json['id'], equals('uuid-123'));
      expect(json['farm_id'], equals('farm-456'));
      expect(json['harvest_date'], equals('2026-10-20'));
      expect(json['stubble_tonnes_mid'], equals(6.5));
    });
  });

  group('Farm Model Parser Tests', () {
    test('parses Farm JSON response correctly', () {
      final farmJson = {
        'id': 'farm-uuid-001',
        'farmer_id': 'farmer-uuid-999',
        'name': 'North Plot 1',
        'area_acres': 4.5,
        'paddy_variety': 'Pusa-44',
        'harvest_method': 'combine',
      };

      final farm = Farm.fromJson(farmJson);
      expect(farm.id, equals('farm-uuid-001'));
      expect(farm.farmerId, equals('farmer-uuid-999'));
      expect(farm.name, equals('North Plot 1'));
      expect(farm.areaAcres, equals(4.5));
      expect(farm.paddyVariety, equals('Pusa-44'));
      expect(farm.harvestMethod, equals('combine'));
    });
  });
}
