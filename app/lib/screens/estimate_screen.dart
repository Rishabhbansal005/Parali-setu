import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../l10n/app_strings.dart';
import '../models/estimate_result.dart';
import '../theme.dart';

class EstimateScreen extends StatelessWidget {
  final AppLanguage language;
  final EstimateResult estimate;
  final double acres;
  final String variety;
  final String harvestMethod;

  const EstimateScreen({
    super.key,
    required this.language,
    required this.estimate,
    required this.acres,
    required this.variety,
    required this.harvestMethod,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(language);
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.warmBackground,
      appBar: AppBar(
        title: Text(strings.estimateTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Big Stubble Quantity & Range Bar Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.eco, color: AppTheme.primaryGreen, size: 26),
                          const SizedBox(width: 8),
                          Text(
                            strings.stubbleQtyLabel,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Big range number
                      Text(
                        '${estimate.stubbleTonnesLow.toStringAsFixed(1)} - ${estimate.stubbleTonnesHigh.toStringAsFixed(1)} ${strings.tonnesUnit}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        '${strings.midEstimate}: ~${estimate.stubbleTonnesMid.toStringAsFixed(1)} ${strings.tonnesUnit}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Visual Range Bar
                      _buildRangeBar(
                        low: estimate.stubbleTonnesLow,
                        mid: estimate.stubbleTonnesMid,
                        high: estimate.stubbleTonnesHigh,
                        unit: strings.tonnesUnit,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 2. Expected Income Card
              Card(
                elevation: 2,
                color: const Color(0xFFFFF9E6), // Warm golden tint
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: const BorderSide(color: Color(0xFFFFE082), width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.currency_rupee, color: Color(0xFFB78103), size: 26),
                          const SizedBox(width: 6),
                          Text(
                            strings.expectedEarningsLabel,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${currencyFormatter.format(estimate.incomeLowInr)} - ${currencyFormatter.format(estimate.incomeHighInr)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB78103),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECB3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          strings.assumedPriceNote(AppConstants.assumedPricePerTonneInr),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A5500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 3. Certified Weighbridge Disclaimer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0EAE0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.scale_outlined, color: AppTheme.primaryGreen, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        strings.disclaimer,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4. Advisory Next Steps
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.verified_user_outlined, color: AppTheme.secondaryGreen, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        strings.nextStepAdvice,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 5. Recalculate button (56dp min height)
              SizedBox(
                height: 56,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(strings.recalculateBtn),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangeBar({
    required double low,
    required double mid,
    required double high,
    required String unit,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Background bar
            Container(
              height: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFA5D6A7),
                    AppTheme.primaryGreen,
                    Color(0xFF81C784),
                  ],
                ),
              ),
            ),
            // Center indicator pip
            Container(
              width: 10,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.primaryGreen, width: 2.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${low.toStringAsFixed(1)} $unit',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
            ),
            Text(
              '~${mid.toStringAsFixed(1)} $unit',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
            ),
            Text(
              '${high.toStringAsFixed(1)} $unit',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}
