import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants.dart';
import '../models/farm.dart';
import '../models/estimate_result.dart';
import '../models/user_profile.dart';
import '../models/matched_bundle.dart';

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String farmerId;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
    required this.farmerId,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json, {String farmerId = ''}) {
    return AuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
      farmerId: farmerId,
    );
  }
}

abstract class FarmerRepository {
  Future<bool> sendOtp(String phoneE164, {Function(String)? onStatusUpdate});
  Future<AuthTokens> verifyOtp(String phoneE164, String otp, {Function(String)? onStatusUpdate});
  Future<UserProfile> getProfile({Function(String)? onStatusUpdate});
  Future<UserProfile> updateProfile({
    String? name,
    String? language,
    String? village,
    String? district,
    Function(String)? onStatusUpdate,
  });
  Future<bool> refreshToken({Function(String)? onStatusUpdate});
  Future<void> clearSession();
  Future<UserProfile?> getCachedProfile();

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
    double pricePerTonne = AppConstants.assumedPricePerTonneInr,
    Function(String)? onStatusUpdate,
  });
  Future<List<MatchedBundle>> getMatchedBundles({
    String? estimateId,
    double acres = 4.0,
    String variety = 'PR-126',
    DateTime? harvestDate,
    double? stubbleTonnes,
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
      return await action().timeout(AppConstants.networkTimeout);
    } on TimeoutException {
      onStatusUpdate?.call('Server is waking up, please wait... (retrying)');
      return await action().timeout(AppConstants.networkTimeout);
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } catch (e) {
      if (e.toString().contains('Failed host lookup') || e.toString().contains('Connection refused')) {
        onStatusUpdate?.call('Connecting to server, please wait...');
        await Future.delayed(const Duration(seconds: 3));
        return await action().timeout(AppConstants.networkTimeout);
      }
      rethrow;
    }
  }

  String _extractSubFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
        );
        return payload['sub'] as String? ?? '';
      }
    } catch (_) {}
    return '';
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
          throw Exception(errorData['detail'] ?? 'Failed to send OTP');
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
          final refreshToken = data['refresh_token'] as String;
          final farmerId = _extractSubFromJwt(accessToken);

          _cachedAccessToken = accessToken;
          _cachedFarmerId = farmerId;

          await _storage.write(key: AppConstants.keyAccessToken, value: accessToken);
          await _storage.write(key: AppConstants.keyRefreshToken, value: refreshToken);
          await _storage.write(key: AppConstants.keyFarmerId, value: farmerId);

          // Eagerly fetch and cache profile
          try {
            await getProfile();
          } catch (_) {}

          return AuthTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            farmerId: farmerId,
          );
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['detail'] ?? 'OTP verification failed');
        }
      },
    );
  }

  @override
  Future<bool> refreshToken({Function(String)? onStatusUpdate}) async {
    try {
      final storedRefresh = await _storage.read(key: AppConstants.keyRefreshToken);
      if (storedRefresh == null || storedRefresh.isEmpty) {
        return false;
      }

      final uri = Uri.parse('$baseUrl/auth/token/refresh');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': storedRefresh}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccess = data['access_token'] as String;
        final newRefresh = data['refresh_token'] as String? ?? storedRefresh;
        final farmerId = _extractSubFromJwt(newAccess);

        _cachedAccessToken = newAccess;
        _cachedFarmerId = farmerId;

        await _storage.write(key: AppConstants.keyAccessToken, value: newAccess);
        await _storage.write(key: AppConstants.keyRefreshToken, value: newRefresh);
        if (farmerId.isNotEmpty) {
          await _storage.write(key: AppConstants.keyFarmerId, value: farmerId);
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<UserProfile> getProfile({Function(String)? onStatusUpdate}) async {
    return _executeWithRetry(
      onStatusUpdate: onStatusUpdate,
      action: () async {
        var token = _cachedAccessToken ?? await _storage.read(key: AppConstants.keyAccessToken);
        final uri = Uri.parse('$baseUrl/auth/me');

        var response = await _client.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );

        // Silent single 401 refresh attempt
        if (response.statusCode == 401) {
          final refreshed = await refreshToken();
          if (refreshed) {
            token = _cachedAccessToken;
            response = await _client.get(
              uri,
              headers: {
                'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
              },
            );
          }
        }

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final profile = UserProfile.fromJson(data);
          await _storage.write(key: AppConstants.keyCachedProfile, value: jsonEncode(profile.toJson()));
          return profile;
        } else {
          final cached = await getCachedProfile();
          if (cached != null) return cached;
          throw Exception('Failed to load profile');
        }
      },
    );
  }

  @override
  Future<UserProfile> updateProfile({
    String? name,
    String? language,
    String? village,
    String? district,
    Function(String)? onStatusUpdate,
  }) async {
    return _executeWithRetry(
      onStatusUpdate: onStatusUpdate,
      action: () async {
        var token = _cachedAccessToken ?? await _storage.read(key: AppConstants.keyAccessToken);
        final uri = Uri.parse('$baseUrl/auth/me');

        final body = <String, dynamic>{};
        if (name != null) body['name'] = name;
        if (language != null) body['language'] = language;
        if (village != null) body['village'] = village;
        if (district != null) body['district'] = district;

        var response = await _client.patch(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 401) {
          final refreshed = await refreshToken();
          if (refreshed) {
            token = _cachedAccessToken;
            response = await _client.patch(
              uri,
              headers: {
                'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
              },
              body: jsonEncode(body),
            );
          }
        }

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final profile = UserProfile.fromJson(data);
          await _storage.write(key: AppConstants.keyCachedProfile, value: jsonEncode(profile.toJson()));
          return profile;
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['detail'] ?? 'Failed to update profile');
        }
      },
    );
  }

  @override
  Future<UserProfile?> getCachedProfile() async {
    try {
      final jsonStr = await _storage.read(key: AppConstants.keyCachedProfile);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        return UserProfile.fromJson(jsonDecode(jsonStr));
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> clearSession() async {
    _cachedAccessToken = null;
    _cachedFarmerId = null;
    await _storage.delete(key: AppConstants.keyAccessToken);
    await _storage.delete(key: AppConstants.keyRefreshToken);
    await _storage.delete(key: AppConstants.keyFarmerId);
    await _storage.delete(key: AppConstants.keyCachedProfile);
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
        final farmerId = _cachedFarmerId ?? await _storage.read(key: AppConstants.keyFarmerId) ?? '';
        final token = _cachedAccessToken ?? await _storage.read(key: AppConstants.keyAccessToken) ?? '';

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
          throw Exception(errorData['detail'] ?? 'Failed to create farm');
        }
      },
    );
  }

  @override
  Future<EstimateResult> createEstimate({
    required String farmId,
    required String harvestDate,
    double pricePerTonne = AppConstants.assumedPricePerTonneInr,
    Function(String)? onStatusUpdate,
  }) async {
    return _executeWithRetry(
      onStatusUpdate: onStatusUpdate,
      action: () async {
        final token = _cachedAccessToken ?? await _storage.read(key: AppConstants.keyAccessToken) ?? '';
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
          throw Exception(errorData['detail'] ?? 'Failed to create estimate');
        }
      },
    );
  }

  @override
  Future<List<MatchedBundle>> getMatchedBundles({
    String? estimateId,
    double acres = 4.0,
    String variety = 'PR-126',
    DateTime? harvestDate,
    double? stubbleTonnes,
    Function(String)? onStatusUpdate,
  }) async {
    return _executeWithRetry(
      onStatusUpdate: onStatusUpdate,
      action: () async {
        final token = _cachedAccessToken ?? await _storage.read(key: AppConstants.keyAccessToken) ?? '';
        final uri = Uri.parse('$baseUrl/matching/find-bundles');
        final response = await _client.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'estimate_id': estimateId,
            'acres': acres,
            'paddy_variety': variety,
            'harvest_date': (harvestDate ?? DateTime.now().add(const Duration(days: 2))).toIso8601String().substring(0, 10),
            'stubble_tonnes': stubbleTonnes ?? (acres * 2.0),
            'latitude': 30.25,
            'longitude': 75.85,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final rawList = data['bundles'] as List<dynamic>? ?? [];
          return rawList.map((e) => MatchedBundle.fromJson(e as Map<String, dynamic>)).toList();
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['detail'] ?? 'Failed to match bundles');
        }
      },
    );
  }
}

class MockFarmerRepository implements FarmerRepository {
  final Map<String, String> _mockStorage = {};
  UserProfile _mockProfile = UserProfile(
    id: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
    phone: '+919810000001',
    name: 'Gurpreet Singh',
    language: 'en',
    role: 'farmer',
    roles: ['farmer'],
    village: 'Kot Buddha',
    district: 'Tarn Taran',
    state: 'Punjab',
  );

  @override
  Future<bool> sendOtp(String phoneE164, {Function(String)? onStatusUpdate}) async {
    return true;
  }

  @override
  Future<AuthTokens> verifyOtp(String phoneE164, String otp, {Function(String)? onStatusUpdate}) async {
    _mockProfile = _mockProfile.copyWith(phone: phoneE164);
    _mockStorage[AppConstants.keyAccessToken] = 'mock_jwt_access_token';
    _mockStorage[AppConstants.keyRefreshToken] = 'mock_jwt_refresh_token';
    _mockStorage[AppConstants.keyFarmerId] = _mockProfile.id;
    _mockStorage[AppConstants.keyCachedProfile] = jsonEncode(_mockProfile.toJson());

    return AuthTokens(
      accessToken: 'mock_jwt_access_token',
      refreshToken: 'mock_jwt_refresh_token',
      tokenType: 'bearer',
      farmerId: _mockProfile.id,
    );
  }

  @override
  Future<UserProfile> getProfile({Function(String)? onStatusUpdate}) async {
    final cached = await getCachedProfile();
    if (cached != null) {
      _mockProfile = cached;
    }
    return _mockProfile;
  }

  @override
  Future<UserProfile> updateProfile({
    String? name,
    String? language,
    String? village,
    String? district,
    Function(String)? onStatusUpdate,
  }) async {
    _mockProfile = _mockProfile.copyWith(
      name: name ?? _mockProfile.name,
      language: language ?? _mockProfile.language,
      village: village ?? _mockProfile.village,
      district: district ?? _mockProfile.district,
    );
    _mockStorage[AppConstants.keyCachedProfile] = jsonEncode(_mockProfile.toJson());
    if (language != null) {
      _mockStorage[AppConstants.keyLanguage] = language;
    }
    return _mockProfile;
  }

  @override
  Future<bool> refreshToken({Function(String)? onStatusUpdate}) async {
    return true;
  }

  @override
  Future<UserProfile?> getCachedProfile() async {
    final jsonStr = _mockStorage[AppConstants.keyCachedProfile];
    if (jsonStr != null && jsonStr.isNotEmpty) {
      return UserProfile.fromJson(jsonDecode(jsonStr));
    }
    return _mockProfile;
  }

  @override
  Future<void> clearSession() async {
    _mockStorage.remove(AppConstants.keyAccessToken);
    _mockStorage.remove(AppConstants.keyRefreshToken);
    _mockStorage.remove(AppConstants.keyFarmerId);
    _mockStorage.remove(AppConstants.keyCachedProfile);
  }

  @override
  Future<Farm> createFarm({
    required String name,
    required double areaAcres,
    required String variety,
    required String harvestMethod,
    Function(String)? onStatusUpdate,
  }) async {
    return Farm(
      id: 'e4a1a011-37d4-4bb6-b6b8-6e42b26c7104',
      farmerId: _mockProfile.id,
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
    double pricePerTonne = AppConstants.assumedPricePerTonneInr,
    Function(String)? onStatusUpdate,
  }) async {
    // Agronomic calculation per SPEC.md §9:
    // 4.0 acres PR-126 => 8.0t mid (range 6.4 - 9.6t)
    // At assumed price ₹1200/t => ₹7680 - ₹11520
    return EstimateResult(
      id: '89ef6722-1234-4567-8901-23456789abcd',
      farmId: farmId,
      harvestDate: harvestDate,
      wheatSowDate: null,
      stubbleTonnesLow: 6.40,
      stubbleTonnesMid: 8.00,
      stubbleTonnesHigh: 9.60,
      incomeLowInr: 6.40 * pricePerTonne,
      incomeHighInr: 9.60 * pricePerTonne,
    );
  }

  @override
  Future<List<MatchedBundle>> getMatchedBundles({
    String? estimateId,
    double acres = 4.0,
    String variety = 'PR-126',
    DateTime? harvestDate,
    double? stubbleTonnes,
    Function(String)? onStatusUpdate,
  }) async {
    final effectiveStubble = stubbleTonnes ?? (acres * 2.0);
    final targetHarvest = harvestDate ?? DateTime.now().add(const Duration(days: 2));

    return [
      MatchedBundle(
        offerId: 'off-1111-2222-3333-444455556666',
        rank: 1,
        tag: 'BEST_VALUE',
        tagLabelEn: 'Best Net Payout',
        tagLabelHi: 'सबसे ज्यादा मुनाफा',
        tagLabelPa: 'ਸਭ ਤੋਂ ਵੱਧ ਮੁਨਾਫਾ /* NEEDS NATIVE REVIEW */',
        proposedPickupDate: targetHarvest.add(const Duration(days: 2)),
        daysAfterHarvest: 2,
        machineName: 'Gurdeep Singh Agro Balers',
        machineType: 'Claas Square Baler (CHC Sangrur)',
        machineCostInr: acres * 1200.0,
        truckName: 'Sharma Transport Logistics',
        truckCapacityTonnes: 12.0,
        transportCostInr: 540.0,
        buyerName: 'Verbio India Bio-CNG Plant (Lehra Gaga)',
        buyerType: 'Bio-CNG Refinery',
        buyerDistanceKm: 18.5,
        buyerPricePerTonneInr: 1350.0,
        stubbleTonnes: effectiveStubble,
        grossIncomeInr: effectiveStubble * 1350.0,
        netIncomeInr: (effectiveStubble * 1350.0) - (acres * 1200.0) - 540.0,
        co2SavedTonnes: effectiveStubble * 1.5,
        pm25AvoidedKg: effectiveStubble * 18.0,
      ),
      MatchedBundle(
        offerId: 'off-2222-3333-4444-555566667777',
        rank: 2,
        tag: 'FASTEST',
        tagLabelEn: 'Fastest 24h Pickup',
        tagLabelHi: 'सबसे तेज 24 घंटे में उठान',
        tagLabelPa: 'ਸਭ ਤੋਂ ਤੇਜ਼ 24 ਘੰਟੇ ਚੁਕਾਈ /* NEEDS NATIVE REVIEW */',
        proposedPickupDate: targetHarvest.add(const Duration(days: 1)),
        daysAfterHarvest: 1,
        machineName: 'Kisan Sahayata CHC Nabha',
        machineType: 'New Holland Round Baler',
        machineCostInr: acres * 1350.0,
        truckName: 'Punjab Kisan Express (Tata 1613)',
        truckCapacityTonnes: 16.0,
        transportCostInr: 680.0,
        buyerName: 'Sukhbir Agro Bio-Pellets (Sunam)',
        buyerType: 'Biomass Pellet Mill',
        buyerDistanceKm: 14.2,
        buyerPricePerTonneInr: 1250.0,
        stubbleTonnes: effectiveStubble,
        grossIncomeInr: effectiveStubble * 1250.0,
        netIncomeInr: (effectiveStubble * 1250.0) - (acres * 1350.0) - 680.0,
        co2SavedTonnes: effectiveStubble * 1.5,
        pm25AvoidedKg: effectiveStubble * 18.0,
      ),
      MatchedBundle(
        offerId: 'off-3333-4444-5555-666677778888',
        rank: 3,
        tag: 'LOCAL_GREEN',
        tagLabelEn: 'Local Clean Energy Plant',
        tagLabelHi: 'स्थानीय स्वच्छ ऊर्जा प्लांट',
        tagLabelPa: 'ਸਥਾਨਕ ਸਾਫ਼ ਊਰਜਾ ਪਲਾਂਟ /* NEEDS NATIVE REVIEW */',
        proposedPickupDate: targetHarvest.add(const Duration(days: 3)),
        daysAfterHarvest: 3,
        machineName: 'Malwa Precision Balers',
        machineType: 'Sonalika Stubble Packer',
        machineCostInr: acres * 1100.0,
        truckName: 'Dhillon Heavy Transport',
        truckCapacityTonnes: 10.0,
        transportCostInr: 820.0,
        buyerName: 'Shree Ganesh Paper & Pulp Board',
        buyerType: 'Paper Mill',
        buyerDistanceKm: 26.0,
        buyerPricePerTonneInr: 1180.0,
        stubbleTonnes: effectiveStubble,
        grossIncomeInr: effectiveStubble * 1180.0,
        netIncomeInr: (effectiveStubble * 1180.0) - (acres * 1100.0) - 820.0,
        co2SavedTonnes: effectiveStubble * 1.5,
        pm25AvoidedKg: effectiveStubble * 18.0,
      ),
    ];
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
