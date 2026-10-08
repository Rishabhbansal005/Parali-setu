import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      appBar: AppBar(
        title: Text(strings.estimateTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Stubble Quantity Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFC8D6C8)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.eco, color: AppTheme.secondaryGreen, size: 28),
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
                    const SizedBox(height: 16),
                    // Central Midpoint
                    Text(
                      '~${estimate.stubbleTonnesMid.toStringAsFixed(1)} ${strings.tonnesUnit}',
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Range Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${strings.approxRange}: ${estimate.stubbleTonnesLow.toStringAsFixed(1)} - ${estimate.stubbleTonnesHigh.toStringAsFixed(1)} ${strings.tonnesUnit}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Expected Income Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1), // Warm Amber Light
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFE082)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.currency_rupee, color: AppTheme.paraliGold, size: 28),
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
                    const SizedBox(height: 12),
                    Text(
                      '${currencyFormatter.format(estimate.incomeLowInr)} - ${currencyFormatter.format(estimate.incomeHighInr)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.paraliGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Field Summary Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('रकबा (Area)', '${acres.toStringAsFixed(1)} एकड़'),
                    const Divider(height: 18),
                    _buildSummaryRow('किस्म (Variety)', variety),
                    const Divider(height: 18),
                    _buildSummaryRow('कटाई तारीख (Harvest Date)', estimate.harvestDate),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. Positive Action Guidance Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
                ),

                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppTheme.primaryGreen, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        strings.nextStepAdvice,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Disclaimer
              Text(
                strings.disclaimer,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 24),

              // Recalculate Button
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.refresh),
                label: Text(strings.recalculateBtn),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: AppTheme.textMuted)),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
      ],
    );
  }
}
