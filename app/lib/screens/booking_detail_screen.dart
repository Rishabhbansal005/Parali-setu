import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/booking_result.dart';
import '../models/matched_bundle.dart';
import '../repositories/farmer_repository.dart';
import '../theme.dart';

class BookingDetailScreen extends StatefulWidget {
  final BookingResult initialBooking;
  final MatchedBundle bundle;
  final FarmerRepository repository;
  final AppLanguage language;

  const BookingDetailScreen({
    super.key,
    required this.initialBooking,
    required this.bundle,
    required this.repository,
    this.language = AppLanguage.english,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late BookingResult _booking;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _booking = widget.initialBooking;
  }

  Future<void> _refreshBooking() async {
    setState(() => _isLoading = true);
    try {
      final updated = await widget.repository.getBooking(bookingId: _booking.id);
      setState(() {
        _booking = updated;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _simulateWeighbridge() async {
    // Show a modal to submit certified Dharamkanta slip
    final grossController = TextEditingController(text: '14.2');
    final tareController = TextEditingController(text: '6.2');
    final ticketController = TextEditingController(text: 'DK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dharamkanta Slip Entry',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(false),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Enter Gross & Tare weights to simulate weighbridge verification and release escrow funds.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ticketController,
                decoration: const InputDecoration(
                  labelText: 'Dharamkanta Ticket #',
                  prefixIcon: Icon(Icons.confirmation_number_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: grossController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Gross (Tonnes)',
                        prefixIcon: Icon(Icons.local_shipping_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: tareController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Tare (Tonnes)',
                        prefixIcon: Icon(Icons.scale_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text(
                    'Verify & Release Escrow',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (submitted == true) {
      final gross = double.tryParse(grossController.text) ?? 14.2;
      final tare = double.tryParse(tareController.text) ?? 6.2;
      final ticket = ticketController.text.trim();

      setState(() => _isLoading = true);
      try {
        final updated = await widget.repository.submitWeighbridgeTicket(
          bookingId: _booking.id,
          grossWeightTonnes: gross,
          tareWeightTonnes: tare,
          ticketNumber: ticket.isNotEmpty ? ticket : null,
        );
        setState(() {
          _booking = updated;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF2E7D32),
              content: Text('✓ Weighbridge certified! Escrow released to farmer account.'),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.language);
    final isPaid = _booking.status == 'paid';
    final hasWeighbridge = _booking.weighbridgeRecord != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: AppBar(
        title: Text(
          strings.bookingStatusTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshBooking,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshBooking,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                    ],

                    // Top Hero Escrow Card
                    _buildEscrowHeroCard(strings, isPaid),
                    const SizedBox(height: 20),

                    // 4-Stage Lifecycle Stepper
                    _buildLifecycleStepper(strings),
                    const SizedBox(height: 20),

                    // Certified Dharamkanta Card
                    _buildWeighbridgeCard(strings, hasWeighbridge),
                    const SizedBox(height: 20),

                    // Logistics & Partner Details
                    _buildLogisticsCard(strings),
                    const SizedBox(height: 20),

                    // Environmental Impact Badge
                    _buildEnvironmentalCard(strings),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEscrowHeroCard(AppStrings strings, bool isPaid) {
    final amount = isPaid
        ? (_booking.finalPayoutInr ?? widget.bundle.netIncomeInr)
        : (_booking.escrowAmountInr ?? widget.bundle.netIncomeInr);

    final bgGradient = isPaid
        ? const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF1C6B32), Color(0xFF24532B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPaid ? Icons.check_circle : Icons.lock,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isPaid ? strings.escrowReleasedBadge : strings.escrowLockedBadge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'ID: ${_booking.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isPaid ? strings.finalPayoutLabel : strings.netEarningsLabel,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPaid
                ? 'Directly credited upon certified weighbridge slip.'
                : 'Guaranteed funds deposited in escrow by ${widget.bundle.buyerName}.',
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildLifecycleStepper(AppStrings strings) {
    final status = _booking.status;
    final isConfirmed = true;
    final isPickedUp = status == 'picked_up' || status == 'paid';
    final isWeighed = _booking.weighbridgeRecord != null || status == 'paid';
    final isPaid = status == 'paid';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pickup & Escrow Lifecycle',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _stepperRow(strings.stepConfirmed, isConfirmed, isConfirmed, 'Factory fund locked in escrow'),
            _stepperLine(isPickedUp),
            _stepperRow(strings.stepPickedUp, isPickedUp, isPickedUp, 'Baler & truck dispatched to field'),
            _stepperLine(isWeighed),
            _stepperRow(strings.stepWeighed, isWeighed, isWeighed, 'Dharamkanta gross & tare certified'),
            _stepperLine(isPaid),
            _stepperRow(strings.stepPaid, isPaid, isPaid, 'Immediate escrow release to farmer'),
          ],
        ),
      ),
    );
  }

  Widget _stepperRow(String title, bool isDone, bool isActive, String subtitle) {
    final color = isDone ? AppColors.primary : Colors.grey.shade400;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone ? AppColors.primary : Colors.grey.shade200,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(
            isDone ? Icons.check : Icons.circle,
            size: 16,
            color: isDone ? Colors.white : Colors.grey.shade400,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDone ? AppColors.textDark : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepperLine(bool isDone) {
    return Container(
      margin: const EdgeInsets.only(left: 13, top: 4, bottom: 4),
      width: 2,
      height: 20,
      color: isDone ? AppColors.primary : Colors.grey.shade300,
    );
  }

  Widget _buildWeighbridgeCard(AppStrings strings, bool hasWeighbridge) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Certified Dharamkanta Ticket',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasWeighbridge ? Colors.green.shade50 : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasWeighbridge ? Colors.green.shade200 : Colors.amber.shade300,
                    ),
                  ),
                  child: Text(
                    hasWeighbridge ? 'VERIFIED' : 'PENDING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: hasWeighbridge ? Colors.green.shade800 : Colors.amber.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (hasWeighbridge) ...[
              _detailRow(strings.ticketNoLabel, _booking.weighbridgeRecord!.ticketNumber ?? 'DK-778899'),
              const Divider(height: 16),
              _detailRow(strings.netWeightLabel, '${_booking.weighbridgeRecord!.weightTonnes.toStringAsFixed(2)} Tonnes (${_booking.weighbridgeRecord!.weightKg.toStringAsFixed(0)} kg)'),
              const Divider(height: 16),
              _detailRow('Status', 'Certified & Payout Released'),
            ] else ...[
              Text(
                'Truck is scheduled for pickup. Upon delivery at Dharamkanta, verified net weight will release funds.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.scale, size: 18),
                  label: Text(
                    strings.simulateWeighbridgeSlip,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: _simulateWeighbridge,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogisticsCard(AppStrings strings) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip & Partner Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            _detailRow(strings.pickupDateLabel, widget.bundle.proposedPickupDate.toIso8601String().substring(0, 10)),
            const Divider(height: 16),
            _detailRow(strings.machineCostLabel, widget.bundle.machineName),
            const Divider(height: 16),
            _detailRow(strings.transportCostLabel, widget.bundle.truckName),
            const Divider(height: 16),
            _detailRow(strings.buyerLabel, widget.bundle.buyerName),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalCard(AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco, color: Color(0xFF2E7D32), size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No-Burn Certified Harvest',
                  style: TextStyle(
                    color: Color(0xFF1B5E20),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Prevents ${widget.bundle.co2SavedTonnes.toStringAsFixed(1)}t CO₂ & ${widget.bundle.pm25AvoidedKg.toStringAsFixed(0)}kg PM₂.₅ air pollution.',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
