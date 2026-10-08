import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/farm.dart';
import '../models/estimate_result.dart';

abstract class FarmerRepository {
  Future<bool> sendOtp(String phoneE164, {Function(String)? onStatusUpdate});
  Future<AuthTokens> verifyOtp(String phoneE164, String otp, {Function(String)? onStatusUpdate});
  Future<Farm> createFarm({
    required String name,
    required double areaAcres,
    required String variety,
    required String harvestMethod,
    Function(String)? onStatusUpdate,
  });
  Future<EstimateResult> createEstimate({
    required String farmId,
    required String harvestDate,
    double pricePerTonne = 1200.0,
    Function(String)? onStatusUpdate,
  });
}

class ApiFarmerRepository implements FarmerRepository {
  final String baseUrl;
  final http.Client _client = http.Client();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _cachedAccessToken;
  String? _cachedFarmerId;

  ApiFarmerRepository({required this.baseUrl});

  Future<T> _executeWithRetry<T>({
    required Future<T> Function() action,
    Function(String)? onStatusUpdate,
  }) async {
    try {
      return await action().timeout(const Duration(seconds: 60));
    } on TimeoutException {
      onStatusUpdate?.call('सर्वर चालू हो रहा है, कृपया थोड़ा इंतज़ार करें... (पुनः प्रयास जारी)');
      // One automatic retry
      return await action().timeout(const Duration(seconds: 60));
    } on SocketException {
      throw Exception('इंटरनेट कनेक्शन नहीं है। कृपया अपना नेटवर्क चेक करें।');
    } catch (e) {
      if (e.toString().contains('Failed host lookup') || e.toString().contains('Connection refused')) {
        onStatusUpdate?.call('सर्वर चालू हो रहा है, कृपया थोड़ा इंतज़ार करें...');
        // Retry once after brief pause
        await Future.delayed(const Duration(seconds: 3));
        return await action().timeout(const Duration(seconds: 60));
      }
      rethrow;
    }
  }

  @override
  Future<bool> sendOtp(String phoneE164, {Function(String)? onStatusUpdate}) async {
    return _executeWithRetry(
      onStatusUpdate: onStatusUpdate,
      action: () async {
        final uri = Uri.parse('$baseUrl/auth/otp/send');
        final response = await _client.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone_e164': phoneE164}),
        );
        if (response.statusCode == 200) {
          return true;
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['detail'] ?? 'OTP भेजने में विफल');
        }
      },
    );
  }

  @override
  Future<AuthTokens> verifyOtp(String phoneE164, String otp, {Function(String)? onStatusUpdate}) async {
    return _executeWithRetry(
      onStatusUpdate: onStatusUpdate,
      action: () async {
        final uri = Uri.parse('$baseUrl/auth/otp/verify');
        final response = await _client.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone_e164': phoneE164, 'otp': otp}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final accessToken = data['access_token'] as String;

          // Decode JWT to extract subject (user_id / farmer_id)
          String farmerId = '';
          try {
            final parts = accessToken.split('.');
            if (parts.length == 3) {
              final payload = jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
              );
              farmerId = payload['sub'] as String? ?? '';
            }
          } catch (_) {}

          _cachedAccessToken = accessToken;
          _cachedFarmerId = farmerId;

          // Securely store token
          await _storage.write(key: 'jwt_access_token', value: accessToken);
          await _storage.write(key: 'farmer_id', value: farmerId);

          return AuthTokens.fromJson(data, farmerId: farmerId);
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['detail'] ?? 'ओटीपी सत्यापन विफल');
        }
      },
    );
  }

  @override
  Future<Farm> createFarm({
    required String name,
    required double areaAcres,
    required String variety,
    required String harvestMethod,
    Function(String)? onStatusUpdate,
  }) async {
    return _executeWithRetry(
      onStatusUpdate: onStatusUpdate,
      action: () async {
        final farmerId = _cachedFarmerId ?? await _storage.read(key: 'farmer_id') ?? '';
        final token = _cachedAccessToken ?? await _storage.read(key: 'jwt_access_token') ?? '';

        final uri = Uri.parse('$baseUrl/farmers/$farmerId/farms');
        final response = await _client.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'name': name,
            'area_acres': areaAcres,
            'paddy_variety': variety,
            'harvest_method': harvestMethod,
            'latitude': null,
            'longitude': null,
            'khasra_number': null,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return Farm.fromJson(data);
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['detail'] ?? 'खेत पंजीकृत करने में विफल');
        }
      },
    );
  }

  @override
  Future<EstimateResult> createEstimate({
    required String farmId,
    required String harvestDate,
    double pricePerTonne = 1200.0,
    Function(String)? onStatusUpdate,
  }) async {
    return _executeWithRetry(
      onStatusUpdate: onStatusUpdate,
      action: () async {
        final token = _cachedAccessToken ?? await _storage.read(key: 'jwt_access_token') ?? '';
        final uri = Uri.parse('$baseUrl/estimates');
        final response = await _client.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'farm_id': farmId,
            'harvest_date': harvestDate,
            'wheat_sow_date': null,
            'buyer_price_per_tonne_inr': pricePerTonne,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return EstimateResult.fromJson(data);
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['detail'] ?? 'अनुमान लगाने में विफल');
        }
      },
    );
  }
}

class MockFarmerRepository implements FarmerRepository {
  String? _currentFarmerId;

  @override
  Future<bool> sendOtp(String phoneE164, {Function(String)? onStatusUpdate}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<AuthTokens> verifyOtp(String phoneE164, String otp, {Function(String)? onStatusUpdate}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Simulated demo ID for seeded farmer Gurpreet Singh
    _currentFarmerId = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
    return AuthTokens(
      accessToken: 'mock_jwt_token_for_demo_purposes_only',
      refreshToken: 'mock_refresh_token',
      tokenType: 'bearer',
      farmerId: _currentFarmerId!,
    );
  }

  @override
  Future<Farm> createFarm({
    required String name,
    required double areaAcres,
    required String variety,
    required String harvestMethod,
    Function(String)? onStatusUpdate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Farm(
      id: 'e4a1a011-37d4-4bb6-b6b8-6e42b26c7104',
      farmerId: _currentFarmerId ?? '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      name: name,
      areaAcres: areaAcres,
      paddyVariety: variety,
      harvestMethod: harvestMethod,
    );
  }

  @override
  Future<EstimateResult> createEstimate({
    required String farmId,
    required String harvestDate,
    double pricePerTonne = 1200.0,
    Function(String)? onStatusUpdate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Standard agronomic calculation per SPEC.md Section 9:
    // Yield: 2.0 t/acre for PR-126 (4.0 acres -> 8.0t)
    // Range: 0.80 to 1.20 (6.4t to 9.6t)
    // Income at 1200 INR/t: 7680 to 11520 INR
    return EstimateResult(
      id: '89ef6722-1234-4567-8901-23456789abcd',
      farmId: farmId,
      harvestDate: harvestDate,
      wheatSowDate: null,
      stubbleTonnesLow: 6.40,
      stubbleTonnesMid: 8.00,
      stubbleTonnesHigh: 9.60,
      incomeLowInr: 7680.00,
      incomeHighInr: 11520.00,
    );
  }
}

class RepositoryProvider {
  static const String definedBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static FarmerRepository getRepository() {
    if (definedBaseUrl.isNotEmpty && !definedBaseUrl.contains('example.com')) {
      return ApiFarmerRepository(baseUrl: definedBaseUrl);
    }
    return MockFarmerRepository();
  }
}
