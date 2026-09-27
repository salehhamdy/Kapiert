import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../../../core/errors/failures.dart';
import '../../../shared/widgets/auth_logo_header.dart';
import '../../../shared/widgets/auth_widgets.dart';
import 'sign_up_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() => _errorMessage = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email above first.')),
      );
      return;
    }
    try {
      await ref.read(authProvider.notifier).resetPassword(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reset link sent to $email')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_friendlyError(e.toString()))),
        );
      }
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('Invalid login credentials') ||
        raw.contains('invalid_credentials')) {
      return 'Incorrect email or password.';
    }
    if (raw.contains('network') || raw.contains('SocketException')) {
      return 'No internet connection.';
    }
    if (raw.contains('not configured') || raw.contains('StateError')) {
      return 'Auth is not configured yet.';
    }
    return 'Something went wrong. Please try again.';
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
                // ── Brand strip ────────────────────────────────────────────
                const AuthLogoHeader()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.1, end: 0),
                const SizedBox(height: 20),

                // ── Article legend pills ───────────────────────────────────
                _ArticleStrip(surface: surface)
                    .animate()
                    .fadeIn(delay: 80.ms, duration: 350.ms),
                const SizedBox(height: 36),

                // ── Heading ───────────────────────────────────────────────
                Text(
                  'Welcome back',
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ).animate().fadeIn(delay: 120.ms, duration: 350.ms),
                const SizedBox(height: 6),
                Text(
                  'Sign in to continue learning',
                  style: GoogleFonts.nunito(fontSize: 15, color: textSecondary),
                ).animate().fadeIn(delay: 160.ms, duration: 350.ms),
                const SizedBox(height: 32),

                // ── Error banner ───────────────────────────────────────────
                if (_errorMessage != null) ...[
                  AuthErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 16),
                ],

                // ── Email ─────────────────────────────────────────────────
                AuthFieldLabel(label: 'EMAIL', isDark: isDark),
                const SizedBox(height: 6),
                AuthTextField(
                  controller: _emailController,
                  hint: 'saleh@example.com',
                  keyboardType: TextInputType.emailAddress,
                  surface: surface,
                  divider: divider,
                  textPrimary: textPrimary,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
                const SizedBox(height: 16),

                // ── Password ───────────────────────────────────────────────
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
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Password is required' : null,
                ).animate().fadeIn(delay: 240.ms, duration: 350.ms),
                const SizedBox(height: 8),

                // ── Forgot password ────────────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot password?',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.derBlue,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 260.ms, duration: 350.ms),
                const SizedBox(height: 28),

                // ── Sign in button ─────────────────────────────────────────
                AuthPrimaryButton(
                  label: 'Sign in',
                  isLoading: _isLoading,
                  onPressed: _signIn,
                ).animate().fadeIn(delay: 300.ms, duration: 350.ms),
                const SizedBox(height: 20),

                // ── Divider ────────────────────────────────────────────────
                AuthOrDivider(divider: divider, textSecondary: textSecondary)
                    .animate()
                    .fadeIn(delay: 330.ms, duration: 350.ms),
                const SizedBox(height: 20),

                // ── Google button ──────────────────────────────────────────
                AuthGoogleButton(
                  surface: surface,
                  divider: divider,
                  onPressed: _signInWithGoogle,
                  isLoading: _isGoogleLoading,
                ).animate()
                    .fadeIn(delay: 360.ms, duration: 350.ms),
                const SizedBox(height: 32),

                // ── Footer ─────────────────────────────────────────────────
                AuthFooterLink(
                  prefix: 'No account? ',
                  linkLabel: 'Sign up',
                  textSecondary: textSecondary,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 350.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Article strip (der / die / das legend) ──────────────────────────────────

class _ArticleStrip extends StatelessWidget {
  final Color surface;
  const _ArticleStrip({required this.surface});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ArticleCell(
              article: 'der', label: 'masculine', color: AppColors.derBlue),
          _VerticalDivider(),
          _ArticleCell(
              article: 'die', label: 'feminine', color: AppColors.dieRed),
          _VerticalDivider(),
          _ArticleCell(
              article: 'das', label: 'neuter', color: AppColors.dasGreen),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.dividerLight.withValues(alpha: 0.6),
    );
  }
}

class _ArticleCell extends StatelessWidget {
  final String article;
  final String label;
  final Color color;
  const _ArticleCell(
      {required this.article, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          article,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}


