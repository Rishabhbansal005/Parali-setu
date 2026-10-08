import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/matched_bundle.dart';
import '../repositories/farmer_repository.dart';
import '../theme.dart';

class OptionsScreen extends StatefulWidget {
  final double acres;
  final String variety;
  final DateTime harvestDate;
  final double stubbleTonnes;
  final String? estimateId;
  final AppLanguage language;
  final FarmerRepository repository;

  const OptionsScreen({
    super.key,
    required this.acres,
    required this.variety,
    required this.harvestDate,
    required this.stubbleTonnes,
    this.estimateId,
    required this.language,
    required this.repository,
  });

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  late Future<List<MatchedBundle>> _bundlesFuture;

  @override
  void initState() {
    super.initState();
    _loadBundles();
  }

  void _loadBundles() {
    _bundlesFuture = widget.repository.getMatchedBundles(
      estimateId: widget.estimateId,
      acres: widget.acres,
      variety: widget.variety,
      harvestDate: widget.harvestDate,
      stubbleTonnes: widget.stubbleTonnes,
    );
  }

  void _showBookingConfirmation(MatchedBundle bundle, AppStrings strings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                strings.bookingConfirmedTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock, color: Colors.amber, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        strings.escrowHoldNotice.replaceAll(
                          '{amount}',
                          bundle.netIncomeInr.toStringAsFixed(0),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _infoRow(
                      strings.pickupDateLabel,
                      bundle.proposedPickupDate.toIso8601String().substring(0, 10),
                    ),
                    const Divider(height: 16),
                    _infoRow(strings.machineCostLabel, bundle.machineName),
                    const Divider(height: 16),
                    _infoRow(strings.buyerLabel, bundle.buyerName),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop(); // Back to home
                  },
                  child: Text(
                    strings.viewBookingDetails,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'BEST_VALUE':
        return const Color(0xFF2E7D32); // Deep Green
      case 'FASTEST':
        return const Color(0xFFE65100); // Deep Orange
      case 'LOCAL_GREEN':
        return const Color(0xFF00695C); // Deep Teal
      default:
        return const Color(0xFF1565C0); // Deep Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.language);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(strings.selectBundleTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<MatchedBundle>>(
        future: _bundlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    strings.bundlesSubtitle,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(_loadBundles),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final bundles = snapshot.data ?? [];
          if (bundles.isEmpty) {
            return const Center(child: Text('No bundles available'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Header banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.acres.toStringAsFixed(1)} Killa • ${widget.variety}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.stubbleTonnes.toStringAsFixed(1)} Tonnes',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.bundlesSubtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bundle Cards
              ...bundles.map((bundle) {
                final tagColor = _getTagColor(bundle.tag);
                final tagLabel = bundle.getLocalizedTag(widget.language.code);

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: bundle.rank == 1
                        ? BorderSide(color: AppColors.primary, width: 2)
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tag Badge and Rank
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: tagColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: tagColor.withAlpha(100)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.stars, size: 16, color: tagColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    tagLabel,
                                    style: TextStyle(
                                      color: tagColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Option #${bundle.rank}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Net In-Hand Income
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹${bundle.netIncomeInr.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              strings.netEarningsLabel,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Partner Details Box
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              _partnerRow(
                                Icons.agriculture,
                                strings.machineCostLabel,
                                bundle.machineName,
                                '-₹${bundle.machineCostInr.toStringAsFixed(0)}',
                              ),
                              const Divider(height: 16),
                              _partnerRow(
                                Icons.local_shipping,
                                strings.transportCostLabel,
                                bundle.truckName,
                                '-₹${bundle.transportCostInr.toStringAsFixed(0)}',
                              ),
                              const Divider(height: 16),
                              _partnerRow(
                                Icons.factory,
                                strings.buyerLabel,
                                '${bundle.buyerName} (${bundle.buyerDistanceKm} km)',
                                '+₹${bundle.grossIncomeInr.toStringAsFixed(0)}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Environmental Impact Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Text('🌱', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Avoids ${bundle.co2SavedTonnes.toStringAsFixed(1)}t CO₂ • ${bundle.pm25AvoidedKg.toStringAsFixed(0)} kg PM₂.₅',
                                  style: const TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Action Button (56dp)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bundle.rank == 1 ? AppColors.primary : Colors.white,
                              foregroundColor: bundle.rank == 1 ? Colors.white : AppColors.primary,
                              elevation: bundle.rank == 1 ? 2 : 0,
                              side: BorderSide(
                                color: AppColors.primary,
                                width: bundle.rank == 1 ? 0 : 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => _showBookingConfirmation(bundle, strings),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  strings.bookPickupBtn,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _partnerRow(IconData icon, String role, String name, String amount) {
    final isExpense = amount.startsWith('-');
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isExpense ? Colors.red.shade700 : AppColors.primary,
          ),
        ),
      ],
    );
  }
}
