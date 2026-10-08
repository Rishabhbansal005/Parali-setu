import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../repositories/farmer_repository.dart';
import '../theme.dart';
import 'otp_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  final FarmerRepository repository;
  final Function(AppLanguage) onLanguageChanged;
  final AppLanguage currentLanguage;

  const PhoneLoginScreen({
    super.key,
    required this.repository,
    required this.onLanguageChanged,
    required this.currentLanguage,
  });

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _statusMessage;

  static const bool isDemoLoginEnabled = bool.fromEnvironment('DEMO_LOGIN', defaultValue: false);

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp([String? overridePhone]) async {
    final rawPhone = overridePhone ?? _phoneController.text.trim();
    final strings = AppStrings(widget.currentLanguage);

    if (rawPhone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(rawPhone)) {
      setState(() => _errorMessage = strings.invalidPhone);
      return;
    }

    final phoneE164 = '+91$rawPhone';

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      await widget.repository.sendOtp(
        phoneE164,
        onStatusUpdate: (msg) {
          if (mounted) setState(() => _statusMessage = msg);
        },
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            phoneE164: phoneE164,
            repository: widget.repository,
            onLanguageChanged: widget.onLanguageChanged,
            currentLanguage: widget.currentLanguage,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.currentLanguage);

    return Scaffold(
      backgroundColor: AppTheme.warmBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          strings.appTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.loginTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.loginSubtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 32),

              // Phone number input with fixed +91 prefix
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Text('🇮🇳', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text(
                            '+91',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        key: const Key('phone_number_field'),
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                          letterSpacing: 1.2,
                        ),
                        decoration: InputDecoration(
                          hintText: '98100 00001',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            letterSpacing: 1.2,
                          ),
                          counterText: '',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppTheme.warningRed, fontSize: 14),
                  ),
                ),

              if (_statusMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _statusMessage!,
                    style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 14),
                  ),
                ),

              const SizedBox(height: 28),

              // Get OTP button (56dp min height)
              SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('get_otp_btn'),
                  onPressed: _isLoading ? null : () => _handleSendOtp(),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(strings.getOtpBtn),
                ),
              ),

              const SizedBox(height: 20),

              // DEMO quick login button if --dart-define=DEMO_LOGIN=true
              if (isDemoLoginEnabled)
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: OutlinedButton(
                    key: const Key('demo_quick_login_btn'),
                    onPressed: _isLoading
                        ? null
                        : () {
                            _phoneController.text = '9810000001';
                            _handleSendOtp('9810000001');
                          },
                    child: Text(strings.demoQuickLoginBtn),
                  ),
                ),

              const SizedBox(height: 24),

              // Demo mode notices
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC5E1A5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.secondaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            strings.demoSmsNotice,
                            style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
                          ),
                        ),
                      ],
                    ),
                    if (kDebugMode) ...[
                      const Divider(height: 18, color: Color(0xFFC5E1A5)),
                      Text(
                        strings.demoHint,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
