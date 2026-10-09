/// Data model for Sentinel-2 verified No-Burn Green Certificate.
class CertificateResult {
  final String certificateId;
  final String bookingId;
  final String farmerName;
  final String village;
  final String district;
  final String state;
  final double stubbleTonnes;
  final String satelliteSource;
  final String imageDate;
  final double cloudCoverPct;
  final double deltaNbr;
  final String resultState;
  final bool? burnDetected;
  final String burnSeverity;
  final double co2AvoidedTonnes;
  final double pm25AvoidedKg;
  final int equivalentTrees;
  final String issuedAt;
  final bool isValid;
  final String authority;
  final String verificationNotes;

  CertificateResult({
    required this.certificateId,
    required this.bookingId,
    required this.farmerName,
    required this.village,
    required this.district,
    required this.state,
    required this.stubbleTonnes,
    required this.satelliteSource,
    required this.imageDate,
    required this.cloudCoverPct,
    required this.deltaNbr,
    required this.resultState,
    this.burnDetected,
    required this.burnSeverity,
    required this.co2AvoidedTonnes,
    required this.pm25AvoidedKg,
    required this.equivalentTrees,
    required this.issuedAt,
    required this.isValid,
    required this.authority,
    required this.verificationNotes,
  });

  factory CertificateResult.fromJson(Map<String, dynamic> json) {
    return CertificateResult(
      certificateId: json['certificate_id'] as String? ?? '',
      bookingId: json['booking_id'] as String? ?? '',
      farmerName: json['farmer_name'] as String? ?? '',
      village: json['village'] as String? ?? 'Kot Buddha',
      district: json['district'] as String? ?? 'Tarn Taran',
      state: json['state'] as String? ?? 'Punjab',
      stubbleTonnes: (json['stubble_tonnes'] as num?)?.toDouble() ?? 0.0,
      satelliteSource: json['satellite_source'] as String? ?? 'Copernicus Sentinel-2',
      imageDate: json['image_date'] as String? ?? '',
      cloudCoverPct: (json['cloud_cover_pct'] as num?)?.toDouble() ?? 0.0,
      deltaNbr: (json['delta_nbr'] as num?)?.toDouble() ?? 0.0,
      resultState: json['result_state'] as String? ?? 'verified_no_burn',
      burnDetected: json['burn_detected'] as bool?,
      burnSeverity: json['burn_severity'] as String? ?? 'NONE',
      co2AvoidedTonnes: (json['co2_avoided_tonnes'] as num?)?.toDouble() ?? 0.0,
      pm25AvoidedKg: (json['pm25_avoided_kg'] as num?)?.toDouble() ?? 0.0,
      equivalentTrees: (json['equivalent_trees'] as num?)?.toInt() ?? 0,
      issuedAt: json['issued_at'] as String? ?? '',
      isValid: json['is_valid'] as bool? ?? true,
      authority: json['authority'] as String? ?? 'Punjab Clean Air Initiative',
      verificationNotes: json['verification_notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'certificate_id': certificateId,
    'booking_id': bookingId,
    'farmer_name': farmerName,
    'village': village,
    'district': district,
    'state': state,
    'stubble_tonnes': stubbleTonnes,
    'satellite_source': satelliteSource,
    'image_date': imageDate,
    'cloud_cover_pct': cloudCoverPct,
    'delta_nbr': deltaNbr,
    'result_state': resultState,
    'burn_detected': burnDetected,
    'burn_severity': burnSeverity,
    'co2_avoided_tonnes': co2AvoidedTonnes,
    'pm25_avoided_kg': pm25AvoidedKg,
    'equivalent_trees': equivalentTrees,
    'issued_at': issuedAt,
    'is_valid': isValid,
    'authority': authority,
    'verification_notes': verificationNotes,
  };
}
