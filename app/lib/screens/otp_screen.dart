import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../repositories/farmer_repository.dart';
import '../theme.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneE164;
  final FarmerRepository repository;
  final Function(AppLanguage) onLanguageChanged;
  final AppLanguage currentLanguage;

  const OtpScreen({
    super.key,
    required this.phoneE164,
    required this.repository,
    required this.onLanguageChanged,
    required this.currentLanguage,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;
  String? _statusMessage;
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _secondsRemaining = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  String _getOtpString() {
    return _controllers.map((c) => c.text.trim()).join();
  }

  Future<void> _handleVerify() async {
    final otp = _getOtpString();
    final strings = AppStrings(widget.currentLanguage);

    if (otp.length != 6) {
      setState(() => _errorMessage = strings.invalidOtp);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      await widget.repository.verifyOtp(
        widget.phoneE164,
        otp,
        onStatusUpdate: (msg) {
          if (mounted) setState(() => _statusMessage = msg);
        },
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            repository: widget.repository,
            onLanguageChanged: widget.onLanguageChanged,
            currentLanguage: widget.currentLanguage,
            isOffline: false,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _handleResend() async {
    if (_secondsRemaining > 0 || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.repository.sendOtp(
        widget.phoneE164,
        onStatusUpdate: (msg) {
          if (mounted) setState(() => _statusMessage = msg);
        },
      );
      _startResendTimer();
      setState(() => _isLoading = false);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.otpTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${strings.otpSubtitle} ${widget.phoneE164}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 32),

              // 6 OTP Digit Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 58,
                    child: TextField(
                      key: Key('otp_box_$index'),
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFC0D2C0), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2.5),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          if (index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            // 6th digit entered -> auto submit!
                            _focusNodes[index].unfocus();
                            _handleVerify();
                          }
                        } else if (val.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

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

              // Verify button (56dp)
              SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('verify_otp_btn'),
                  onPressed: _isLoading ? null : _handleVerify,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(strings.verifyAndLogin),
                ),
              ),

              const SizedBox(height: 24),

              // Resend & Change Number row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _secondsRemaining > 0 ? null : _handleResend,
                    child: Text(
                      _secondsRemaining > 0
                          ? '${strings.resendIn} ${_secondsRemaining}s'
                          : strings.resendOtp,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _secondsRemaining > 0 ? AppTheme.textMuted : AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      strings.changeNumber,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Debug-only hint
              if (kDebugMode)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          strings.demoHint,
                          style: const TextStyle(fontSize: 13, color: Colors.brown),
                        ),
                      ),
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
