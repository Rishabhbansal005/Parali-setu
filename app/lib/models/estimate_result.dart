class EstimateResult {
  final String id;
  final String farmId;
  final String harvestDate;
  final String? wheatSowDate;
  final double stubbleTonnesLow;
  final double stubbleTonnesMid;
  final double stubbleTonnesHigh;
  final double incomeLowInr;
  final double incomeHighInr;

  EstimateResult({
    required this.id,
    required this.farmId,
    required this.harvestDate,
    this.wheatSowDate,
    required this.stubbleTonnesLow,
    required this.stubbleTonnesMid,
    required this.stubbleTonnesHigh,
    required this.incomeLowInr,
    required this.incomeHighInr,
  });

  factory EstimateResult.fromJson(Map<String, dynamic> json) {
    return EstimateResult(
      id: json['id'] as String? ?? '',
      farmId: json['farm_id'] as String? ?? '',
      harvestDate: json['harvest_date'] as String? ?? '',
      wheatSowDate: json['wheat_sow_date'] as String?,
      stubbleTonnesLow: (json['stubble_tonnes_low'] as num?)?.toDouble() ?? 0.0,
      stubbleTonnesMid: (json['stubble_tonnes_mid'] as num?)?.toDouble() ?? 0.0,
      stubbleTonnesHigh: (json['stubble_tonnes_high'] as num?)?.toDouble() ?? 0.0,
      incomeLowInr: (json['income_low_inr'] as num?)?.toDouble() ?? 0.0,
      incomeHighInr: (json['income_high_inr'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farm_id': farmId,
      'harvest_date': harvestDate,
      'wheat_sow_date': wheatSowDate,
      'stubble_tonnes_low': stubbleTonnesLow,
      'stubble_tonnes_mid': stubbleTonnesMid,
      'stubble_tonnes_high': stubbleTonnesHigh,
      'income_low_inr': incomeLowInr,
      'income_high_inr': incomeHighInr,
    };
  }
}
