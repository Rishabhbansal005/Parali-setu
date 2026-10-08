import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../repositories/farmer_repository.dart';
import '../theme.dart';
import 'field_details_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  final AppLanguage language;

  const PhoneLoginScreen({super.key, required this.language});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _repository = RepositoryProvider.getRepository();

  bool _isOtpSent = false;
  bool _isLoading = false;
  String _statusMessage = '';
  String? _errorMessage;

  static const bool _isDemoLoginEnabled = bool.fromEnvironment('DEMO_LOGIN', defaultValue: false);

  @override
  void dispose() {
    _phoneController.dispose() ;
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    final phoneInput = _phoneController.text.trim();
    if (phoneInput.length < 10) {
      setState(() {
        _errorMessage = AppStrings(widget.language).invalidPhone;
      });
      return;
    }

    final formattedPhone = phoneInput.startsWith('+91')
        ? phoneInput
        : '+91${phoneInput.replaceAll(RegExp(r'[^0-9]'), '')}';

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _statusMessage = '';
    });

    try {
      await _repository.sendOtp(
        formattedPhone,
        onStatusUpdate: (msg) {
          if (mounted) setState(() => _statusMessage = msg);
        },
      );
      if (mounted) {
        setState(() {
          _isOtpSent = true;
          _isLoading = false;
          _statusMessage = '';
        });
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

  void _verifyOtp() async {
    final otpInput = _otpController.text.trim();
    if (otpInput.length != 6) {
      setState(() {
        _errorMessage = AppStrings(widget.language).invalidOtp;
      });
      return;
    }

    final phoneInput = _phoneController.text.trim();
    final formattedPhone = phoneInput.startsWith('+91')
        ? phoneInput
        : '+91${phoneInput.replaceAll(RegExp(r'[^0-9]'), '')}';

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _statusMessage = '';
    });

    try {
      final tokens = await _repository.verifyOtp(
        formattedPhone,
        otpInput,
        onStatusUpdate: (msg) {
          if (mounted) setState(() => _statusMessage = msg);
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => FieldDetailsScreen(
              language: widget.language,
              farmerId: tokens.farmerId,
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

  void _quickDemoLogin() {
    // Quick demo login pre-fills seeded farmer Gurpreet Singh's phone number
    setState(() {
      _phoneController.text = '9810000001';
      _otpController.text = '123456';
    });
    _verifyOtp();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.language);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.loginTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                strings.loginSubtitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              // Phone Field
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !_isOtpSent && !_isLoading,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: strings.phoneLabel,
                  prefixText: '+91 ',
                  prefixStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  prefixIcon: const Icon(Icons.phone_android, color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(height: 16),

              // OTP Field (visible once OTP is requested)
              if (_isOtpSent) ...[
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  enabled: !_isLoading,
                  maxLength: 6,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: strings.enterOtp,
                    counterText: '',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryGreen),
                  ),
                ),
                const SizedBox(height: 8),

                // Demo hint strictly in debug builds per instructions
                if (kDebugMode)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.paraliGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: AppTheme.paraliGold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            strings.demoHint,
                            style: const TextStyle(fontSize: 13, color: AppTheme.paraliGold, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
              ],

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

              // Action Button (Send OTP or Verify OTP)
              ElevatedButton(
                onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _sendOtp),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(_isOtpSent ? strings.verifyOtp : strings.sendOtp),
              ),
              const SizedBox(height: 16),

              // Optional Demo Login Button (--dart-define=DEMO_LOGIN=true)
              if (_isDemoLoginEnabled) ...[
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _quickDemoLogin,
                  icon: const Icon(Icons.bolt, color: AppTheme.paraliGold),
                  label: Text(
                    strings.demoLoginBtn,
                    style: const TextStyle(color: AppTheme.paraliGold),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
