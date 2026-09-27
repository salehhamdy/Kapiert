import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_colors.dart';

/// Warm goodbye screen shown immediately after the user signs out.
///
/// Displays the user's name, their saved streak, the der/die/das article
/// pills as a brand reminder, and a primary "Sign in again" CTA.
class SignedOutScreen extends StatelessWidget {
  /// The user's display name (from Supabase metadata or email prefix).
  final String displayName;

  /// The streak count at the moment of sign-out.
  final int streak;

  const SignedOutScreen({
    super.key,
    required this.displayName,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ── Icon bubble ───────────────────────────────────────────
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.dieRed.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.dieRed,
                  size: 32,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 28),

              // ── Title ─────────────────────────────────────────────────
              Text(
                'Logged out',
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
              const SizedBox(height: 12),

              // ── Farewell message ──────────────────────────────────────
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.textSecondaryLight,
                  ),
                  children: [
                    TextSpan(text: 'See you soon, '),
                    TextSpan(
                      text: displayName,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    TextSpan(text: '!\nYour '),
                    const WidgetSpan(
                      child: Text('🔥', style: TextStyle(fontSize: 15)),
                    ),
                    TextSpan(
                      text: ' $streak-day streak',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        color: AppColors.streakOrange,
                      ),
                    ),
                    TextSpan(text: ' is saved.'),
                  ],
                ),
              ).animate().fadeIn(delay: 180.ms, duration: 350.ms),
              const SizedBox(height: 32),

              // ── Article pills ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ArticlePill(article: 'der', color: AppColors.derBlue),
                  const SizedBox(width: 10),
                  _ArticlePill(article: 'die', color: AppColors.dieRed),
                  const SizedBox(width: 10),
                  _ArticlePill(article: 'das', color: AppColors.dasGreen),
                ],
              ).animate().fadeIn(delay: 260.ms, duration: 350.ms),
              const SizedBox(height: 48),

              // ── Sign in again ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/signin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Sign in again',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 320.ms, duration: 350.ms),
              const SizedBox(height: 14),

              // ── Create new account ────────────────────────────────────
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/signup'),
                child: Text(
                  'Create new account',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.derBlue,
                  ),
                ),
              ).animate().fadeIn(delay: 380.ms, duration: 350.ms),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Article pill helper ──────────────────────────────────────────────────────

class _ArticlePill extends StatelessWidget {
  final String article;
  final Color color;

  const _ArticlePill({required this.article, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        article,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

