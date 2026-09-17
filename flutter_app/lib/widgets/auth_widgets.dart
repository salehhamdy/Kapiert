import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

// ── Field label (all-caps, muted) ───────────────────────────────────────────

class AuthFieldLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const AuthFieldLabel({super.key, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }
}

// ── Styled text input ────────────────────────────────────────────────────────

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final Color surface;
  final Color divider;
  final Color textPrimary;
  final String? Function(String?)? validator;
  final bool hasError;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.surface,
    required this.divider,
    required this.textPrimary,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.validator,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError ? AppColors.dieRed : divider;
    final focusBorderColor = hasError ? AppColors.dieRed : AppColors.derBlue;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.nunito(fontSize: 15, color: textPrimary),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
          fontSize: 15,
          color: AppColors.textSecondaryLight.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: surface,
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: focusBorderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dieRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dieRed, width: 2),
        ),
        errorStyle: GoogleFonts.nunito(
          fontSize: 12,
          color: AppColors.dieRed,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Dark pill CTA button ─────────────────────────────────────────────────────

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimaryLight,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              AppColors.textPrimaryLight.withValues(alpha: 0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

// ── — or — divider row ────────────────────────────────────────────────────────

class AuthOrDivider extends StatelessWidget {
  final Color divider;
  final Color textSecondary;
  const AuthOrDivider(
      {super.key, required this.divider, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: GoogleFonts.nunito(fontSize: 13, color: textSecondary),
          ),
        ),
        Expanded(child: Divider(color: divider)),
      ],
    );
  }
}

// ── Google sign-in button ─────────────────────────────────────────────────────

class AuthGoogleButton extends StatelessWidget {
  final Color surface;
  final Color divider;
  final VoidCallback? onPressed;
  final bool isLoading;
  const AuthGoogleButton({
    super.key,
    required this.surface,
    required this.divider,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: surface,
          side: BorderSide(color: divider),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation(AppColors.textPrimaryLight),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CustomPaint(painter: _GoogleLogoPainter()),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Continue with Google',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1.4),
      3.14 / 2, 3.14, false, paint,
    );

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1.4),
      -3.14 / 2, 3.14 / 2, false, paint,
    );

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1.4),
      0, 3.14 / 2, false, paint,
    );

    paint
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF34A853);
    canvas.drawRect(
      Rect.fromLTWH(center.dx - 0.5, center.dy - 1.5, radius, 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Red error banner ─────────────────────────────────────────────────────────

class AuthErrorBanner extends StatelessWidget {
  final String message;
  const AuthErrorBanner({super.key, required this.message});

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

// ── "Already have an account? Sign in" footer link ───────────────────────────

class AuthFooterLink extends StatelessWidget {
  final String prefix;
  final String linkLabel;
  final Color textSecondary;
  final VoidCallback onTap;

  const AuthFooterLink({
    super.key,
    required this.prefix,
    required this.linkLabel,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: prefix,
          style: GoogleFonts.nunito(fontSize: 14, color: textSecondary),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: onTap,
                child: Text(
                  linkLabel,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.derBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
