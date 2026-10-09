import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/certificate_result.dart';
import '../repositories/farmer_repository.dart';
import '../theme.dart';

class CertificateScreen extends StatefulWidget {
  final String bookingId;
  final FarmerRepository repository;
  final AppLanguage language;

  const CertificateScreen({
    super.key,
    required this.bookingId,
    required this.repository,
    this.language = AppLanguage.english,
  });

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  late Future<CertificateResult> _certificateFuture;

  @override
  void initState() {
    super.initState();
    _certificateFuture = widget.repository.getCertificate(bookingId: widget.bookingId);
  }

  void _shareCertificate(CertificateResult cert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1B5E20),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Certificate ${cert.certificateId} ready to share with KVK & Panchayat!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.language);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F1),
      appBar: AppBar(
        title: Text(
          strings.certificateTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<CertificateResult>(
        future: _certificateFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                      snapshot.error.toString().replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _certificateFuture = widget.repository.getCertificate(bookingId: widget.bookingId);
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final cert = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Diploma Certificate Card
                _buildCertificateCard(cert, strings),
                const SizedBox(height: 24),

                // Share / Download CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.share, size: 20),
                    label: Text(
                      strings.shareCertificateBtn,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _shareCertificate(cert),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCertificateCard(CertificateResult cert, AppStrings strings) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37), width: 3), // Gold Border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
        child: Column(
          children: [
            // Top Seal Emblem
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFAA771C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withAlpha(80),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.verified,
                color: Colors.white,
                size: 42,
              ),
            ),
            const SizedBox(height: 16),

            // Official Header
            Text(
              cert.authority.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Color(0xFF8D6E18),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'NO-BURN GREEN HARVEST CERTIFICATE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B5E20),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              strings.certificateSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),

            // Divider with Gold Star
            Row(
              children: [
                Expanded(child: Divider(color: Colors.amber.shade300, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.eco, size: 20, color: Colors.green.shade800),
                ),
                Expanded(child: Divider(color: Colors.amber.shade300, thickness: 1)),
              ],
            ),
            const SizedBox(height: 20),

            // Farmer Certification Statement
            const Text(
              'This is proudly presented to',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              cert.farmerName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${cert.village}, ${cert.district}, ${cert.state}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 18),

            Text(
              'for successfully harvesting and diverting ${cert.stubbleTonnes.toStringAsFixed(1)} tonnes of paddy residue from field burning through certified mechanization and biomass supply.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 22),

            // Satellite Spectral Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.satellite_alt, size: 18, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      strings.satelliteVerifiedBadge,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Environmental Impact Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    icon: Icons.cloud_outlined,
                    value: '${cert.co2AvoidedTonnes.toStringAsFixed(1)} t',
                    label: strings.co2AvoidedLabel,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metricCard(
                    icon: Icons.air,
                    value: '${cert.pm25AvoidedKg.toStringAsFixed(0)} kg',
                    label: strings.pm25AvoidedLabel,
                    color: const Color(0xFFE65100),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metricCard(
                    icon: Icons.park,
                    value: '${cert.equivalentTrees}',
                    label: strings.treesPlantedLabel,
                    color: const Color(0xFF00695C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Footer Certificate ID and Timestamp
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CERTIFICATE ID', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    Text(cert.certificateId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('VERIFIED AT', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    Text(cert.issuedAt.substring(0, 10), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
