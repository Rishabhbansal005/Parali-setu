class MatchedBundle {
  final String offerId;
  final int rank;
  final String tag;
  final String tagLabelEn;
  final String tagLabelHi;
  final String tagLabelPa;
  final DateTime proposedPickupDate;
  final int daysAfterHarvest;

  // Machine
  final String machineName;
  final String machineType;
  final double machineCostInr;

  // Truck
  final String truckName;
  final double truckCapacityTonnes;
  final double transportCostInr;

  // Buyer
  final String buyerName;
  final String buyerType;
  final double buyerDistanceKm;
  final double buyerPricePerTonneInr;

  // Financials
  final double stubbleTonnes;
  final double grossIncomeInr;
  final double netIncomeInr;

  // Eco
  final double co2SavedTonnes;
  final double pm25AvoidedKg;

  const MatchedBundle({
    required this.offerId,
    required this.rank,
    required this.tag,
    required this.tagLabelEn,
    required this.tagLabelHi,
    required this.tagLabelPa,
    required this.proposedPickupDate,
    required this.daysAfterHarvest,
    required this.machineName,
    required this.machineType,
    required this.machineCostInr,
    required this.truckName,
    required this.truckCapacityTonnes,
    required this.transportCostInr,
    required this.buyerName,
    required this.buyerType,
    required this.buyerDistanceKm,
    required this.buyerPricePerTonneInr,
    required this.stubbleTonnes,
    required this.grossIncomeInr,
    required this.netIncomeInr,
    required this.co2SavedTonnes,
    required this.pm25AvoidedKg,
  });

  String getLocalizedTag(String langCode) {
    if (langCode == 'hi') return tagLabelHi;
    if (langCode == 'pa') return tagLabelPa;
    return tagLabelEn;
  }

  factory MatchedBundle.fromJson(Map<String, dynamic> json) {
    return MatchedBundle(
      offerId: json['offer_id'] as String? ?? '',
      rank: (json['rank'] as num?)?.toInt() ?? 1,
      tag: json['tag'] as String? ?? 'BEST_VALUE',
      tagLabelEn: json['tag_label_en'] as String? ?? 'Best Value',
      tagLabelHi: json['tag_label_hi'] as String? ?? 'सबसे अच्छा विकल्प',
      tagLabelPa: json['tag_label_pa'] as String? ?? 'ਸਭ ਤੋਂ ਵਧੀਆ ਵਿਕਲਪ',
      proposedPickupDate: json['proposed_pickup_date'] != null
          ? DateTime.tryParse(json['proposed_pickup_date'] as String) ?? DateTime.now().add(const Duration(days: 2))
          : DateTime.now().add(const Duration(days: 2)),
      daysAfterHarvest: (json['days_after_harvest'] as num?)?.toInt() ?? 1,
      machineName: json['machine_name'] as String? ?? 'Gurdeep Agro Baler',
      machineType: json['machine_type'] as String? ?? 'Square Baler',
      machineCostInr: (json['machine_cost_inr'] as num?)?.toDouble() ?? 4800.0,
      truckName: json['truck_name'] as String? ?? 'Sharma Roadways',
      truckCapacityTonnes: (json['truck_capacity_tonnes'] as num?)?.toDouble() ?? 12.0,
      transportCostInr: (json['transport_cost_inr'] as num?)?.toDouble() ?? 600.0,
      buyerName: json['buyer_name'] as String? ?? 'Verbio Bio-CNG Plant',
      buyerType: json['buyer_type'] as String? ?? 'Bio-CNG',
      buyerDistanceKm: (json['buyer_distance_km'] as num?)?.toDouble() ?? 18.0,
      buyerPricePerTonneInr: (json['buyer_price_per_tonne_inr'] as num?)?.toDouble() ?? 1350.0,
      stubbleTonnes: (json['stubble_tonnes'] as num?)?.toDouble() ?? 8.0,
      grossIncomeInr: (json['gross_income_inr'] as num?)?.toDouble() ?? 10800.0,
      netIncomeInr: (json['net_income_inr'] as num?)?.toDouble() ?? 5400.0,
      co2SavedTonnes: (json['co2_saved_tonnes'] as num?)?.toDouble() ?? 12.0,
      pm25AvoidedKg: (json['pm25_avoided_kg'] as num?)?.toDouble() ?? 144.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offer_id': offerId,
      'rank': rank,
      'tag': tag,
      'tag_label_en': tagLabelEn,
      'tag_label_hi': tagLabelHi,
      'tag_label_pa': tagLabelPa,
      'proposed_pickup_date': proposedPickupDate.toIso8601String().substring(0, 10),
      'days_after_harvest': daysAfterHarvest,
      'machine_name': machineName,
      'machine_type': machineType,
      'machine_cost_inr': machineCostInr,
      'truck_name': truckName,
      'truck_capacity_tonnes': truckCapacityTonnes,
      'transport_cost_inr': transportCostInr,
      'buyer_name': buyerName,
      'buyer_type': buyerType,
      'buyer_distance_km': buyerDistanceKm,
      'buyer_price_per_tonne_inr': buyerPricePerTonneInr,
      'stubble_tonnes': stubbleTonnes,
      'gross_income_inr': grossIncomeInr,
      'net_income_inr': netIncomeInr,
      'co2_saved_tonnes': co2SavedTonnes,
      'pm25_avoided_kg': pm25AvoidedKg,
    };
  }
}
