import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../services/supabase_service.dart';
import 'welcome_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const int _otpLength = 6;
  static const int _timerSeconds = 9 * 60 + 47; // 09:47 matching mockup

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;
  int _remainingSeconds = _timerSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Listen to each box for auto-advance
    for (int i = 0; i < _otpLength; i++) {
      _controllers[i].addListener(() => _onDigitChanged(i));
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() => _remainingSeconds = _timerSeconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        t.cancel();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _onDigitChanged(int index) {
    final text = _controllers[index].text;
    if (text.length == 1 && index < _otpLength - 1) {
      // Auto-advance to next box
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {}); // update filled/empty visual states
  }

  String get _otp =>
      _controllers.map((c) => c.text).join();

  bool get _otpComplete => _otp.length == _otpLength;

  String get _timerLabel {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _verify() async {
    if (!_otpComplete) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await SupabaseService.verifyOTP(
        email: widget.email,
        token: _otp,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    if (_remainingSeconds > 0) return;
    try {
      await SupabaseService.resendOTP(email: widget.email);
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Code resent to ${widget.email}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to resend. Try again later.')),
        );
      }
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('Token has expired') || raw.contains('otp_expired')) {
      return 'Code expired. Please request a new one.';
    }
    if (raw.contains('Invalid') || raw.contains('invalid')) {
      return 'Incorrect code. Check your email and try again.';
    }
    if (raw.contains('not configured') || raw.contains('StateError')) {
      return 'Auth is not configured yet.';
    }
    return 'Verification failed. Please try again.';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
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
                  text: 'We sent a 6-digit code to\n',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_otpLength, (i) {
                  return Padding(
                    padding: EdgeInsets.only(right: i < _otpLength - 1 ? 10 : 0),
                    child: _OtpBox(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      onBackspace: i > 0
                          ? () {
                              if (_controllers[i].text.isEmpty) {
                                _focusNodes[i - 1].requestFocus();
                                _controllers[i - 1].clear();
                              }
                            }
                          : null,
                    ),
                  );
                }),
              ).animate().fadeIn(delay: 160.ms, duration: 400.ms),
              const SizedBox(height: 36),

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
                  RichText(
                    text: TextSpan(
                      text: "Didn't get it? ",
                      style:
                          GoogleFonts.nunito(fontSize: 13, color: textSecondary),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: _remainingSeconds == 0 ? _resend : null,
                            child: Text(
                              'Resend code',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _remainingSeconds == 0
                                    ? AppColors.derBlue
                                    : textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
  final VoidCallback? onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final isFilled = value.text.isNotEmpty;

        return Focus(
          focusNode: focusNode,
          child: Builder(
            builder: (ctx) {
              final isActive = Focus.of(ctx).hasFocus;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
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
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.backspace &&
                        controller.text.isEmpty) {
                      onBackspace?.call();
                    }
                  },
                  child: TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    showCursor: isActive,
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isFilled ? AppColors.dasGreen : textPrimary,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              );
            },
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
