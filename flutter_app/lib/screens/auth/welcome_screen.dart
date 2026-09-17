import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Success check mark ────────────────────────────────────────
              _SuccessIcon()
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 28),

              // ── Heading ───────────────────────────────────────────────────
              Text(
                "You're in!",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(
                    begin: 0.15,
                    end: 0,
                    delay: 200.ms,
                    duration: 400.ms,
                  ),
              const SizedBox(height: 10),
              Text(
                'Account created successfully.\nTime to master German articles.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: textSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 280.ms, duration: 400.ms),
              const SizedBox(height: 40),

              // ── Article pills (celebratory strip) ─────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _WelcomeArticleCard(
                    article: 'der',
                    label: 'masculine',
                    color: AppColors.derBlue,
                    surface: surface,
                    divider: divider,
                  )
                      .animate()
                      .fadeIn(delay: 380.ms, duration: 350.ms)
                      .slideY(begin: 0.2, end: 0, delay: 380.ms, duration: 350.ms),
                  const SizedBox(width: 10),
                  _WelcomeArticleCard(
                    article: 'die',
                    label: 'feminine',
                    color: AppColors.dieRed,
                    surface: surface,
                    divider: divider,
                  )
                      .animate()
                      .fadeIn(delay: 430.ms, duration: 350.ms)
                      .slideY(begin: 0.2, end: 0, delay: 430.ms, duration: 350.ms),
                  const SizedBox(width: 10),
                  _WelcomeArticleCard(
                    article: 'das',
                    label: 'neuter',
                    color: AppColors.dasGreen,
                    surface: surface,
                    divider: divider,
                  )
                      .animate()
                      .fadeIn(delay: 480.ms, duration: 350.ms)
                      .slideY(begin: 0.2, end: 0, delay: 480.ms, duration: 350.ms),
                ],
              ),

              const Spacer(flex: 2),

              // ── CTA button ────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Start learning →',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 560.ms, duration: 350.ms)
                  .slideY(begin: 0.1, end: 0, delay: 560.ms, duration: 350.ms),

              const SizedBox(height: 24),

              // ── Color dot trio ────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ColorDot(color: AppColors.dasGreen),
                  const SizedBox(width: 6),
                  _ColorDot(color: AppColors.dieRed),
                  const SizedBox(width: 6),
                  _ColorDot(color: AppColors.derBlue),
                ],
              ).animate().fadeIn(delay: 640.ms, duration: 350.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Animated green check circle ─────────────────────────────────────────────

class _SuccessIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.dasGreen.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_rounded,
        size: 42,
        color: AppColors.dasGreen,
      ),
    );
  }
}

// ── Article card (welcome version) ──────────────────────────────────────────

class _WelcomeArticleCard extends StatelessWidget {
  final String article;
  final String label;
  final Color color;
  final Color surface;
  final Color divider;

  const _WelcomeArticleCard({
    required this.article,
    required this.label,
    required this.color,
    required this.surface,
    required this.divider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: divider),
      ),
      child: Column(
        children: [
          Text(
            article,
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom dot indicator ─────────────────────────────────────────────────────

class _ColorDot extends StatelessWidget {
  final Color color;
  const _ColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
