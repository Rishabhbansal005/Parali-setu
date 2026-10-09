class VoiceIntakeResult {
  final double acres;
  final String variety;
  final String harvestDate;
  final double confidence;
  final String confirmationPrompt;
  final String transcriptRecognized;
  final Map<String, dynamic>? rawEntities;

  const VoiceIntakeResult({
    required this.acres,
    required this.variety,
    required this.harvestDate,
    required this.confidence,
    required this.confirmationPrompt,
    required this.transcriptRecognized,
    this.rawEntities,
  });

  factory VoiceIntakeResult.fromJson(Map<String, dynamic> json) {
    return VoiceIntakeResult(
      acres: (json['acres'] as num).toDouble(),
      variety: json['variety'] as String? ?? 'PR-126',
      harvestDate: json['harvest_date'] as String? ?? '2026-10-25',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.90,
      confirmationPrompt: json['confirmation_prompt'] as String? ?? '',
      transcriptRecognized: json['transcript_recognized'] as String? ?? '',
      rawEntities: json['raw_entities'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'acres': acres,
      'variety': variety,
      'harvest_date': harvestDate,
      'confidence': confidence,
      'confirmation_prompt': confirmationPrompt,
      'transcript_recognized': transcriptRecognized,
      'raw_entities': rawEntities,
    };
  }
}
