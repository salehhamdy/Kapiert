import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/validators.dart';
import '../../../shared/widgets/auth_logo_header.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    try {
      await ref.read(authProvider.notifier).resetPassword(email: email);
      if (mounted) {
        setState(() {
          _isSuccess = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _friendlyError(e.toString());
        });
      }
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('network') || raw.contains('SocketException')) {
      return 'No internet connection.';
    }
    if (raw.contains('not configured') || raw.contains('StateError')) {
      return 'Auth is not configured yet.';
    }
    if (raw.contains('rate limit') || raw.contains('over_email_send_rate_limit')) {
      return 'Too many reset requests. Please wait a moment.';
    }
    return 'Unable to send reset link. Please check the email and try again.';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final surface = isDark ? const Color(0xFF1E2230) : Colors.white;
    final divider = isDark ? AppColors.dividerDark : AppColors.dividerLight;
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
          key: const Key('reset_password_back_btn'),
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _isSuccess
                  ? _buildSuccessView(isDark, textPrimary, textSecondary, l10n)
                  : _buildFormView(surface, divider, textPrimary, textSecondary, isDark, l10n),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(
    Color surface,
    Color divider,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: AuthLogoHeader(),
          ),
          const SizedBox(height: 32),

          Text(
            l10n.resetPasswordTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.resetPasswordSubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          if (_errorMessage != null) ...[
            AuthErrorBanner(message: _errorMessage!),
            const SizedBox(height: 16),
          ],

          AuthFieldLabel(label: 'EMAIL ADDRESS', isDark: isDark),
          const SizedBox(height: 6),
          AuthTextField(
            controller: _emailController,
            hint: 'name@example.com',
            surface: surface,
            divider: divider,
            textPrimary: textPrimary,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 24),

          AuthPrimaryButton(
            key: const Key('reset_password_submit_btn'),
            label: l10n.sendResetLink,
            isLoading: _isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.backToSignIn,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.derBlue,
                ),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 250.ms),
    );
  }

  Widget _buildSuccessView(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.correctGreen.withValues(alpha: isDark ? 0.2 : 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: AppColors.correctGreen,
            size: 42,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.resetLinkSent,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'We sent a recovery email to ${_emailController.text.trim()}. Tap the link in your email to reset your credentials.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        AuthPrimaryButton(
          label: l10n.backToSignIn,
          isLoading: false,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() => _isSuccess = false);
              _submit();
            },
            child: Text(
              l10n.sendResetLink,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.derBlue,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }
}
