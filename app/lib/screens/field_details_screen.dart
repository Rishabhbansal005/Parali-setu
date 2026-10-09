import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_strings.dart';
import '../models/voice_intake_result.dart';
import '../repositories/farmer_repository.dart';
import '../theme.dart';
import 'estimate_screen.dart';

class FieldDetailsScreen extends StatefulWidget {
  final AppLanguage? language;
  final String? farmerId;
  final FarmerRepository? repository;
  final Function(AppLanguage)? onLanguageChanged;
  final AppLanguage? currentLanguage;

  const FieldDetailsScreen({
    super.key,
    this.language,
    this.farmerId,
    this.repository,
    this.onLanguageChanged,
    this.currentLanguage,
  });

  @override
  State<FieldDetailsScreen> createState() => _FieldDetailsScreenState();
}

class _FieldDetailsScreenState extends State<FieldDetailsScreen> {
  late final FarmerRepository _repository;
  AppLanguage get _lang => widget.currentLanguage ?? widget.language ?? AppLanguage.english;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? RepositoryProvider.getRepository();
  }

  double _acres = 4.0;
  String _selectedVariety = 'PR-126';
  String _selectedHarvestMethod = 'combine';
  DateTime _harvestDate = DateTime(2026, 10, 20);

  bool _voiceAutoFilled = false;
  String? _lastVoiceTranscript;
  bool _isLoading = false;
  String _statusMessage = '';
  String? _errorMessage;

  void _onMicTap() {
    _showVoiceIntakeSheet();
  }

  void _showVoiceIntakeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _VoiceIntakeSheetContent(
        language: _lang,
        repository: _repository,
        onConfirmed: (VoiceIntakeResult result) {
          setState(() {
            _acres = result.acres;
            _selectedVariety = result.variety;
            final parsedDt = DateTime.tryParse(result.harvestDate);
            if (parsedDt != null) {
              _harvestDate = parsedDt;
            }
            _voiceAutoFilled = true;
            _lastVoiceTranscript = result.transcriptRecognized;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppStrings(_lang).voiceRecognizedBadge}: ${result.acres} Acres, ${result.variety}'),
              backgroundColor: AppTheme.primaryGreen,
              duration: const Duration(seconds: 3),
            ),
          );
        },
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
              language: _lang,
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
    final strings = AppStrings(_lang);

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
              // Voice Intake Mic CTA
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      key: const Key('voice_intake_mic_button'),
                      onTap: _onMicTap,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: _voiceAutoFilled ? AppTheme.secondaryGreen : AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withValues(alpha: 0.35),
                              blurRadius: 18,
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
                    if (_voiceAutoFilled) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryGreen),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              strings.voiceRecognizedBadge,
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_lastVoiceTranscript != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '"$_lastVoiceTranscript"',
                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.textMuted),
                          ),
                        ),
                    ],
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

/// Modal Bottom Sheet implementing Vernacular Voice Intake & AI Directive 1 Confirmation
class _VoiceIntakeSheetContent extends StatefulWidget {
  final AppLanguage language;
  final FarmerRepository repository;
  final ValueChanged<VoiceIntakeResult> onConfirmed;

  const _VoiceIntakeSheetContent({
    required this.language,
    required this.repository,
    required this.onConfirmed,
  });

  @override
  State<_VoiceIntakeSheetContent> createState() => _VoiceIntakeSheetContentState();
}

class _VoiceIntakeSheetContentState extends State<_VoiceIntakeSheetContent> {
  final TextEditingController _transcriptController = TextEditingController();
  bool _isAnalyzing = false;
  VoiceIntakeResult? _parsedResult;
  String? _errorMessage;

  AppStrings get _strings => AppStrings(widget.language);

  final List<String> _demoSamples = [
    '4 killa PR-126, 25 October',
    '6 ਕਿੱਲੇ Pusa-44, 28 ਅਕਤੂਬਰ',
    '10 bigha Basmati, kal',
  ];

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _processTranscript(String transcript) async {
    if (transcript.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final langCode = widget.language == AppLanguage.punjabi ? 'pa' : (widget.language == AppLanguage.english ? 'en' : 'hi');
      final result = await widget.repository.parseVoiceInput(
        transcript: transcript,
        language: langCode,
      );

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _parsedResult = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle pill
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // If result is parsed, show AI Directive 1 Confirmation Dialog
          if (_parsedResult != null)
            _buildConfirmationCard(_parsedResult!)
          else
            _buildListeningAndInputSection(),
        ],
      ),
    );
  }

  Widget _buildListeningAndInputSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Pulsing Mic Icon
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.mic, color: AppTheme.primaryGreen, size: 42),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Title & Vernacular hint
        Text(
          _strings.listeningTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _strings.voiceHint,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 18),

        // Text input field with direct analyze button
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('voice_transcript_input'),
                controller: _transcriptController,
                decoration: InputDecoration(
                  hintText: '4 killa PR-126, 25 October...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFC8D6C8)),
                  ),
                ),
                onSubmitted: (val) => _processTranscript(val),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              key: const Key('voice_analyze_button'),
              onPressed: _isAnalyzing ? null : () => _processTranscript(_transcriptController.text),
              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Demo Speech Samples for 1-tap testing
        Text(
          _strings.trySampleVoice,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _demoSamples.map((sample) {
            return ActionChip(
              avatar: const Icon(Icons.record_voice_over, size: 16, color: AppTheme.primaryGreen),
              label: Text(sample, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xFFF0F6F0),
              side: const BorderSide(color: Color(0xFFC8D6C8)),
              onPressed: _isAnalyzing
                  ? null
                  : () {
                      _transcriptController.text = sample;
                      _processTranscript(sample);
                    },
            );
          }).toList(),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// Mandatory Confirmation Card (AI Directive #1):
  /// "Aapne bola: 4 Killa PR-126, 25 October. Sahi hai?"
  Widget _buildConfirmationCard(VoiceIntakeResult result) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified, color: AppTheme.primaryGreen, size: 22),
            const SizedBox(width: 8),
            Text(
              _strings.voiceConfirmTitle,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Spoken prompt bubble (The Golden AI Directive 1 feedback)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFBF7EE), // Parchment / Warm gold tint
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.paraliGold, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.volume_up, color: Color(0xFF8D6E14), size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      result.confirmationPrompt,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8D6E14),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFE8DCC2)),
              const SizedBox(height: 8),

              // 3-Card Summary Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildEntityBadge(Icons.landscape, '${result.acres} Acres'),
                  _buildEntityBadge(Icons.grass, result.variety),
                  _buildEntityBadge(Icons.calendar_today, result.harvestDate),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Action Buttons: [Confirm / Haan Sahi Hai] and [Retry / Dobara Boliye]
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('voice_retry_button'),
                onPressed: () {
                  setState(() {
                    _parsedResult = null;
                    _transcriptController.clear();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: Text(_strings.retryVoiceBtn),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.textMuted),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: ElevatedButton.icon(
                key: const Key('voice_confirm_yes_button'),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onConfirmed(result);
                },
                icon: const Icon(Icons.check_circle),
                label: Text(_strings.confirmYesBtn),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEntityBadge(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryGreen),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
      ],
    );
  }
}
