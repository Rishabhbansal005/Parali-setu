class Farm {
  final String id;
  final String farmerId;
  final String name;
  final double areaAcres;
  final String paddyVariety;
  final String harvestMethod;

  Farm({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.areaAcres,
    required this.paddyVariety,
    required this.harvestMethod,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'] as String? ?? '',
      farmerId: json['farmer_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Farm',
      areaAcres: (json['area_acres'] as num?)?.toDouble() ?? 0.0,
      paddyVariety: json['paddy_variety'] as String? ?? 'PR-126',
      harvestMethod: json['harvest_method'] as String? ?? 'combine',
    );
  }
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String farmerId;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.farmerId,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json, {String farmerId = ''}) {
    return AuthTokens(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      farmerId: farmerId,
    );
  }
}
