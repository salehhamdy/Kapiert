import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../../../core/errors/failures.dart';
import '../../../shared/widgets/auth_logo_header.dart';
import '../../../shared/widgets/auth_widgets.dart';
import 'verify_email_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _termsAccepted = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;
  bool _emailTouched = false;
  bool _emailHasError = false;
  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _emailController.addListener(_onEmailChanged);
  }

  void _onPasswordChanged() {
    setState(() => _passwordStrength = _calcStrength(_passwordController.text));
  }

  void _onEmailChanged() {
    if (_emailTouched) _validateEmail();
  }

  void _validateEmail() {
    final v = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    setState(() {
      _emailHasError = v.isNotEmpty && !emailRegex.hasMatch(v);
    });
  }

  int _calcStrength(String p) {
    if (p.isEmpty) return 0;
    int score = 0;
    if (p.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(p)) score++;
    if (RegExp(r'[0-9]').hasMatch(p)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(p)) score++;
    return score;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    setState(() {
      _emailTouched = true;
      _validateEmail();
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms to continue.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                VerifyEmailScreen(email: _emailController.text.trim()),
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('already registered') || raw.contains('already exists')) {
      return 'An account with this email already exists.';
    }
    if (raw.contains('Password should be')) {
      return 'Password must be at least 6 characters.';
    }
    if (raw.contains('not configured') || raw.contains('StateError')) {
      return 'Auth is not configured yet.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } on SignInCancelledException {
      // user dismissed the picker — do nothing
    } catch (e) {
      setState(() => _errorMessage = _friendlyGoogleError(e.toString()));
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  String _friendlyGoogleError(String raw) {
    if (raw.contains('network') || raw.contains('SocketException')) {
      return 'No internet connection.';
    }
    if (raw.contains('not configured') || raw.contains('StateError')) {
      return 'Auth is not configured yet.';
    }
    if (raw.contains('ID token')) {
      return 'Google Sign-In failed. Check your OAuth setup.';
    }
    return 'Google Sign-In failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final divider = isDark ? AppColors.dividerDark : AppColors.dividerLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Logo ─────────────────────────────────────────────────
                const AuthLogoHeader()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.1, end: 0),
                const SizedBox(height: 28),

                // ── Heading ───────────────────────────────────────────────
                Text(
                  'Create account',
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ).animate().fadeIn(delay: 80.ms, duration: 350.ms),
                const SizedBox(height: 6),
                Text(
                  'Start mastering der, die & das',
                  style:
                      GoogleFonts.nunito(fontSize: 15, color: textSecondary),
                ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
                const SizedBox(height: 32),

                // ── Error banner ──────────────────────────────────────────
                if (_errorMessage != null) ...[
                  AuthErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 16),
                ],

                // ── Full name ─────────────────────────────────────────────
                AuthFieldLabel(label: 'FULL NAME', isDark: isDark),
                const SizedBox(height: 6),
                AuthTextField(
                  controller: _nameController,
                  hint: 'Saleh',
                  surface: surface,
                  divider: divider,
                  textPrimary: textPrimary,
                  keyboardType: TextInputType.name,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ).animate().fadeIn(delay: 140.ms, duration: 350.ms),
                const SizedBox(height: 16),

                // ── Email ─────────────────────────────────────────────────
                AuthFieldLabel(label: 'EMAIL', isDark: isDark),
                const SizedBox(height: 6),
                Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      setState(() => _emailTouched = true);
                      _validateEmail();
                    }
                  },
                  child: AuthTextField(
                    controller: _emailController,
                    hint: 'saleh@example.com',
                    keyboardType: TextInputType.emailAddress,
                    surface: surface,
                    divider: divider,
                    textPrimary: textPrimary,
                    hasError: _emailHasError,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(v)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ).animate().fadeIn(delay: 180.ms, duration: 350.ms),
                const SizedBox(height: 16),

                // ── Password ──────────────────────────────────────────────
                AuthFieldLabel(label: 'PASSWORD', isDark: isDark),
                const SizedBox(height: 6),
                AuthTextField(
                  controller: _passwordController,
                  hint: '••••••••',
                  obscure: _obscurePassword,
                  surface: surface,
                  divider: divider,
                  textPrimary: textPrimary,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'At least 6 characters';
                    return null;
                  },
                ).animate().fadeIn(delay: 220.ms, duration: 350.ms),

                // ── Strength meter ────────────────────────────────────────
                const SizedBox(height: 8),
                _PasswordStrengthMeter(strength: _passwordStrength)
                    .animate()
                    .fadeIn(delay: 240.ms, duration: 350.ms),
                const SizedBox(height: 20),

                // ── Terms checkbox ────────────────────────────────────────
                _TermsRow(
                  value: _termsAccepted,
                  onChanged: (v) =>
                      setState(() => _termsAccepted = v ?? false),
                  textSecondary: textSecondary,
                ).animate().fadeIn(delay: 280.ms, duration: 350.ms),
                const SizedBox(height: 28),

                // ── Create account button ─────────────────────────────────
                AuthPrimaryButton(
                  label: 'Create account',
                  isLoading: _isLoading,
                  onPressed: _createAccount,
                ).animate().fadeIn(delay: 320.ms, duration: 350.ms),
                const SizedBox(height: 20),

                // ── Divider ───────────────────────────────────────────────
                AuthOrDivider(divider: divider, textSecondary: textSecondary)
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 350.ms),
                const SizedBox(height: 20),

                // ── Google button ──────────────────────────────────────────
                AuthGoogleButton(
                  surface: surface,
                  divider: divider,
                  onPressed: _signInWithGoogle,
                  isLoading: _isGoogleLoading,
                )
                    .animate()
                    .fadeIn(delay: 380.ms, duration: 350.ms),
                const SizedBox(height: 32),

                // ── Footer ────────────────────────────────────────────────
                AuthFooterLink(
                  prefix: 'Have an account? ',
                  linkLabel: 'Sign in',
                  textSecondary: textSecondary,
                  onTap: () => Navigator.of(context).pop(),
                ).animate().fadeIn(delay: 420.ms, duration: 350.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Password strength meter ─────────────────────────────────────────────────

class _PasswordStrengthMeter extends StatelessWidget {
  final int strength; // 0-4

  const _PasswordStrengthMeter({required this.strength});

  Color get _barColor {
    switch (strength) {
      case 1:
        return AppColors.dieRed;
      case 2:
        return const Color(0xFFF59E0B);
      case 3:
        return const Color(0xFFEAB308);
      case 4:
        return AppColors.dasGreen;
      default:
        return AppColors.dividerLight;
    }
  }

  String get _label {
    switch (strength) {
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (strength == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final filled = i < strength;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: filled
                      ? _barColor
                      : AppColors.dividerLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          _label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _barColor,
          ),
        ),
      ],
    );
  }
}

// ── Terms & Privacy checkbox row ─────────────────────────────────────────────

class _TermsRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Color textSecondary;

  const _TermsRow({
    required this.value,
    required this.onChanged,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.textPrimaryLight,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            side: BorderSide(
                color: AppColors.dividerLight.withValues(alpha: 0.8)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'I agree to the ',
              style:
                  GoogleFonts.nunito(fontSize: 13, color: textSecondary),
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Terms',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColors.derBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TextSpan(
                  text: ' and ',
                  style:
                      GoogleFonts.nunito(fontSize: 13, color: textSecondary),
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Privacy Policy',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColors.derBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


