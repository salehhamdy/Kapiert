import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import 'welcome_screen.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  static const int _otpLength = 8;
  static const int _timerSeconds = 9 * 60 + 47; // 09:47 matching mockup
  static const int _resendCooldownSeconds = 45;

  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _remainingSeconds = _timerSeconds;
  int _resendCooldown = 0;
  Timer? _countdownTimer;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _initFields();
    _startTimer();
  }

  void _initFields() {
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    _setupFocusListeners();
  }

  void _setupFocusListeners() {
    for (int i = 0; i < _otpLength; i++) {
      final index = i;
      // Auto-select text on focus so typing immediately replaces it
      _focusNodes[index].addListener(() {
        if (_focusNodes[index].hasFocus && mounted) {
          _controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[index].text.length,
          );
        }
      });

      // Handle backspace when field is empty to jump back to previous box
      _focusNodes[index].onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace) {
          if (_controllers[index].text.isEmpty && index > 0) {
            _controllers[index - 1].clear();
            _focusNodes[index - 1].requestFocus();
            if (mounted) setState(() {});
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      };
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() => _remainingSeconds = _timerSeconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _remainingSeconds--);
      }
    });
  }

  void _onDigitInput(int index, String value) {
    if (value.isEmpty) {
      if (mounted) setState(() {});
      return;
    }

    // Keep only numbers
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      _controllers[index].clear();
      if (mounted) setState(() {});
      return;
    }

    // Case 1: Full 8-digit OTP pasted
    if (digits.length == _otpLength) {
      for (int k = 0; k < _otpLength; k++) {
        _controllers[k].text = digits[k];
      }
      _focusNodes.last.unfocus();
      if (mounted) setState(() {});
      if (_otpComplete) _verify();
      return;
    }

    // Case 2: Multi-digit partial paste
    if (digits.length > 2) {
      for (int k = 0; k < digits.length && (index + k) < _otpLength; k++) {
        _controllers[index + k].text = digits[k];
      }
      final nextIndex = (index + digits.length).clamp(0, _otpLength - 1);
      if (index + digits.length >= _otpLength) {
        _focusNodes.last.unfocus();
        if (mounted) setState(() {});
        if (_otpComplete) _verify();
      } else {
        _focusNodes[nextIndex].requestFocus();
        if (mounted) setState(() {});
      }
      return;
    }

    // Case 3: Typed into a field that already had a digit (e.g. value length 2)
    if (digits.length == 2 && _controllers[index].text.isNotEmpty) {
      final old = _controllers[index].text;
      final newChar = digits[0] == old ? digits[1] : digits[0];
      _controllers[index].text = newChar;
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_otpComplete) _verify();
      }
      if (mounted) setState(() {});
      return;
    }

    // Case 4: Single digit entered
    _controllers[index].text = digits;
    _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    if (index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
      if (mounted) setState(() {});
      if (_otpComplete) _verify();
      return;
    }
    if (mounted) setState(() {});
  }

  String get _otp => _controllers.map((c) => c.text).join();

  bool get _otpComplete => _otp.length == _otpLength;

  String get _timerLabel {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _verify() async {
    if (!_otpComplete || _isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).verifyOTP(
        email: widget.email,
        token: _otp,
      );
      final authError = ref.read(authProvider).error;
      if (authError != null && authError.isNotEmpty) {
        throw Exception(authError);
      }
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = _friendlyError(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0 || _isResending) return;
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Requesting resendOTP for ${widget.email}');
      await ref.read(authProvider.notifier).resendOTP(email: widget.email);
      _startResendCooldown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A new verification code was sent to ${widget.email}'),
            backgroundColor: AppColors.derBlue,
          ),
        );
      }
    } catch (e) {
      debugPrint('Resend OTP failed: $e');
      final errorStr = e.toString().toLowerCase();
      String message = 'Failed to resend. Please try again later.';
      if (errorStr.contains('rate limit') ||
          errorStr.contains('over_email_send_rate_limit') ||
          errorStr.contains('too many requests') ||
          errorStr.contains('429')) {
        message = 'Too many requests. Please wait a few minutes before resending.';
      } else if (errorStr.contains('smtp') || errorStr.contains('error sending')) {
        message = 'Email service is currently busy. Please try again later.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.dieRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendCooldown = _resendCooldownSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCooldown <= 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _resendCooldown--);
      }
    });
  }

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('expired')) {
      return 'Code expired. Please request a new one.';
    }
    if (lower.contains('invalid') || lower.contains('bad')) {
      return 'Incorrect code. Check your email and try again.';
    }
    if (lower.contains('not configured') || lower.contains('stateerror')) {
      return 'Auth is not configured yet.';
    }
    return 'Verification failed. Please check the code and try again.';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.user != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Envelope icon ────────────────────────────────────────────
              _EnvelopeIcon()
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
              const SizedBox(height: 28),

              // ── Heading ───────────────────────────────────────────────────
              Text(
                'Check your email',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ).animate().fadeIn(delay: 80.ms, duration: 350.ms),
              const SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'We sent an 8-digit code to\n',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                  children: [
                    TextSpan(
                      text: widget.email,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 120.ms, duration: 350.ms),
              const SizedBox(height: 36),

              // ── OTP boxes ─────────────────────────────────────────────────
              if (_errorMessage != null) ...[
                _InlineError(message: _errorMessage!),
                const SizedBox(height: 12),
              ],
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_otpLength, (i) {
                    return Padding(
                      padding: EdgeInsets.only(
                          right: i < _otpLength - 1 ? 6 : 0),
                      child: _OtpBox(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        autofocus: i == 0,
                        width: 36,
                        onChanged: (val) => _onDigitInput(i, val),
                      ),
                    );
                  }),
                ),
              ).animate().fadeIn(delay: 160.ms, duration: 400.ms),
              const SizedBox(height: 28),

              // ── Verify button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_otpComplete && !_isLoading) ? _verify : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimaryLight,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.textPrimaryLight.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Verify email',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ).animate().fadeIn(delay: 220.ms, duration: 350.ms),
              const SizedBox(height: 20),

              // ── Resend ────────────────────────────────────────────────────
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't get it? ",
                        style:
                            GoogleFonts.nunito(fontSize: 13, color: textSecondary),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _resendCooldown == 0 && !_isResending
                            ? _resend
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 8,
                          ),
                          child: Text(
                            _isResending
                                ? 'Sending...'
                                : (_resendCooldown > 0
                                    ? 'Resend code (${_resendCooldown}s)'
                                    : 'Resend code'),
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _resendCooldown == 0 && !_isResending
                                  ? AppColors.derBlue
                                  : textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _remainingSeconds > 0
                        ? 'Expires in $_timerLabel'
                        : 'Code expired',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: _remainingSeconds <= 30 && _remainingSeconds > 0
                          ? AppColors.dieRed
                          : textSecondary,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 260.ms, duration: 350.ms),
              const SizedBox(height: 24),

              // ── Back to Sign In ──────────────────────────────────────────
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(
                  'Back to Sign In',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Envelope icon ───────────────────────────────────────────────────────────

class _EnvelopeIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.derBlue.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.email_outlined,
        size: 38,
        color: AppColors.derBlue,
      ),
    );
  }
}

// ── Single OTP box ──────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final double width;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    this.autofocus = false,
    this.width = 44,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return AnimatedBuilder(
      animation: Listenable.merge([controller, focusNode]),
      builder: (context, _) {
        final isFilled = controller.text.isNotEmpty;
        final isActive = focusNode.hasFocus;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: 52,
          decoration: BoxDecoration(
            color: isFilled
                ? AppColors.dasGreen.withValues(alpha: 0.08)
                : surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFilled
                  ? AppColors.dasGreen
                  : isActive
                      ? AppColors.derBlue
                      : AppColors.dividerLight.withValues(alpha: 0.8),
              width: isActive || isFilled ? 2 : 1.2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.derBlue.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            showCursor: isActive,
            onChanged: onChanged,
            style: GoogleFonts.nunito(
              fontSize: width <= 36 ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: isFilled ? AppColors.dasGreen : textPrimary,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        );
      },
    );
  }
}

// ── Inline error ────────────────────────────────────────────────────────────

class _InlineError extends StatelessWidget {
  final String message;
  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.dieRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.dieRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.dieRed, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: AppColors.dieRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
