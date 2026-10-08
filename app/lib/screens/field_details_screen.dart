import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_strings.dart';
import '../repositories/farmer_repository.dart';
import '../theme.dart';
import 'estimate_screen.dart';

class FieldDetailsScreen extends StatefulWidget {
  final AppLanguage language;
  final String farmerId;

  const FieldDetailsScreen({
    super.key,
    required this.language,
    required this.farmerId,
  });

  @override
  State<FieldDetailsScreen> createState() => _FieldDetailsScreenState();
}

class _FieldDetailsScreenState extends State<FieldDetailsScreen> {
  final _repository = RepositoryProvider.getRepository();

  double _acres = 4.0;
  String _selectedVariety = 'PR-126';
  String _selectedHarvestMethod = 'combine';
  DateTime _harvestDate = DateTime(2026, 10, 20);

  bool _isMicPressed = false;
  bool _isLoading = false;
  String _statusMessage = '';
  String? _errorMessage;

  void _onMicTap() {
    setState(() {
      _isMicPressed = true;
    });
    // Friendly voice placeholder notification per SPEC §13
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings(widget.language).micComingSoon),
        backgroundColor: AppTheme.paraliGold,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _submitFieldAndCalculate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _statusMessage = '';
    });

    try {
      // 1. Create farm record via repository
      final farm = await _repository.createFarm(
        name: '$_selectedVariety खेत',
        areaAcres: _acres,
        variety: _selectedVariety,
        harvestMethod: _selectedHarvestMethod,

        onStatusUpdate: (msg) {
          if (mounted) setState(() => _statusMessage = msg);
        },
      );

      // 2. Create estimate via repository
      final formattedHarvestDate = DateFormat('yyyy-MM-dd').format(_harvestDate);
      final estimate = await _repository.createEstimate(
        farmId: farm.id,
        harvestDate: formattedHarvestDate,
        onStatusUpdate: (msg) {
          if (mounted) setState(() => _statusMessage = msg);
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EstimateScreen(
              language: widget.language,
              estimate: estimate,
              acres: _acres,
              variety: _selectedVariety,
              harvestMethod: _selectedHarvestMethod,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.language);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.fieldDetailsTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Voice Intake Mic Placeholder (SPEC §13 requirement)
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _onMicTap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: _isMicPressed ? AppTheme.paraliGold : AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isMicPressed ? AppTheme.paraliGold : AppTheme.primaryGreen).withValues(alpha: 0.3),
                              blurRadius: 16,
                              spreadRadius: 4,
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.mic,
                          size: 46,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.micPrompt,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Divider(),
              const SizedBox(height: 12),

              // Form Heading
              Text(
                strings.manualFormHeading,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              // 1. Acres Stepper (Big easy controls)
              Text(
                strings.acresLabel,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC8D6C8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 36, color: AppTheme.primaryGreen),
                      onPressed: _acres > 0.5 ? () => setState(() => _acres = (_acres - 0.5)) : null,
                    ),
                    Text(
                      '${_acres.toStringAsFixed(1)} एकड़',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 36, color: AppTheme.primaryGreen),
                      onPressed: () => setState(() => _acres = (_acres + 0.5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Paddy Variety Selection
              Text(
                strings.varietyLabel,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChoiceChip(
                    label: strings.varietyPR126,
                    selected: _selectedVariety == 'PR-126',
                    onSelected: (val) => setState(() => _selectedVariety = 'PR-126'),
                  ),
                  _buildChoiceChip(
                    label: strings.varietyPusa44,
                    selected: _selectedVariety == 'Pusa-44',
                    onSelected: (val) => setState(() => _selectedVariety = 'Pusa-44'),
                  ),
                  _buildChoiceChip(
                    label: strings.varietyBasmati,
                    selected: _selectedVariety == 'Basmati',
                    onSelected: (val) => setState(() => _selectedVariety = 'Basmati'),
                  ),
                  _buildChoiceChip(
                    label: strings.varietyOther,
                    selected: _selectedVariety == 'other',
                    onSelected: (val) => setState(() => _selectedVariety = 'other'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Harvest Method Selection
              Text(
                strings.harvestMethodLabel,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildMethodCard(
                      label: strings.methodCombine,
                      icon: Icons.precision_manufacturing,
                      isSelected: _selectedHarvestMethod == 'combine',
                      onTap: () => setState(() => _selectedHarvestMethod = 'combine'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMethodCard(
                      label: strings.methodManual,
                      icon: Icons.pan_tool,
                      isSelected: _selectedHarvestMethod == 'manual',
                      onTap: () => setState(() => _selectedHarvestMethod = 'manual'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. Expected Harvest Date
              Text(
                strings.harvestDateLabel,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _harvestDate,
                    firstDate: DateTime(2026, 9, 1),
                    lastDate: DateTime(2027, 2, 28),
                  );
                  if (picked != null) {
                    setState(() => _harvestDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFC8D6C8)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppTheme.primaryGreen),
                      const SizedBox(width: 14),
                      Text(
                        DateFormat('dd MMMM yyyy').format(_harvestDate),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: AppTheme.textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Status message during cold-start server wake-up
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: const TextStyle(color: AppTheme.secondaryGreen, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              // Error banner
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitFieldAndCalculate,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(strings.calculateBtn),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: selected ? AppTheme.primaryGreen : AppTheme.textDark,
      ),
      side: BorderSide(
        color: selected ? AppTheme.primaryGreen : const Color(0xFFC8D6C8),
        width: selected ? 2 : 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
  }

  Widget _buildMethodCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : const Color(0xFFC8D6C8),
            width: isSelected ? 2 : 1,
          ),
        ),

        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryGreen : AppTheme.textMuted, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primaryGreen : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
