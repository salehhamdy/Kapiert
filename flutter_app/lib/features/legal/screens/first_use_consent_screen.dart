import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_colors.dart';
import '../providers/terms_consent_provider.dart';
import 'legal_document_screen.dart';

class FirstUseConsentScreen extends ConsumerStatefulWidget {
  const FirstUseConsentScreen({super.key});

  @override
  ConsumerState<FirstUseConsentScreen> createState() =>
      _FirstUseConsentScreenState();
}

class _FirstUseConsentScreenState extends ConsumerState<FirstUseConsentScreen> {
  bool _acceptedTerms = false;
  bool _showError = false;

  void _openLegalDoc(LegalDocType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(initialType: type),
      ),
    );
  }

  void _handleAgree() {
    if (!_acceptedTerms) {
      setState(() => _showError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please check the box to accept the Terms of Use and Privacy Policy.',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.dieRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    ref.read(termsConsentProvider.notifier).acceptTerms();
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Brand Header ─────────────────────────────────────────
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.derBlue,
                              Color(0xFF2563EB),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.derBlue.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        'Welcome to Kapiert',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    Center(
                      child: Text(
                        'German Article & Vocabulary Trainer',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.derBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        'Before your first practice session, please review our terms and privacy policy. We believe in complete transparency and respecting your data.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          height: 1.5,
                          color: textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Key Commitments ──────────────────────────────────────
                    _CommitmentItem(
                      icon: Icons.shield_outlined,
                      iconColor: AppColors.correctGreen,
                      title: 'Privacy-First & Zero Ads',
                      description:
                          'We do not display ads, never sell personal information, and do not track you across other apps.',
                      surface: surface,
                      divider: divider,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 12),

                    _CommitmentItem(
                      icon: Icons.phone_android_rounded,
                      iconColor: AppColors.derBlue,
                      title: 'Local-First Storage',
                      description:
                          'In Guest Mode, all lookup history and quiz stats remain securely stored on your local device.',
                      surface: surface,
                      divider: divider,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 12),

                    _CommitmentItem(
                      icon: Icons.school_outlined,
                      iconColor: AppColors.streakOrange,
                      title: 'Educational Learning Companion',
                      description:
                          'Designed to help you master der, die, and das through continuous recall and daily habit building.',
                      surface: surface,
                      divider: divider,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 24),

                    // ── Document Links ───────────────────────────────────────
                    Text(
                      'READ FULL DOCUMENTS',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _LegalDocTile(
                      key: const Key('consent_open_terms_button'),
                      title: 'Terms of Use',
                      subtitle: 'User license, acceptable use, and disclaimers',
                      icon: Icons.description_outlined,
                      isDark: isDark,
                      surface: surface,
                      divider: divider,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => _openLegalDoc(LegalDocType.terms),
                    ),
                    const SizedBox(height: 8),

                    _LegalDocTile(
                      key: const Key('consent_open_privacy_button'),
                      title: 'Privacy Policy',
                      subtitle: 'How we collect, store, and protect your data',
                      icon: Icons.privacy_tip_outlined,
                      isDark: isDark,
                      surface: surface,
                      divider: divider,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => _openLegalDoc(LegalDocType.privacy),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Sticky Bottom Consent Action Bar ────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              decoration: BoxDecoration(
                color: surface,
                border: Border(top: BorderSide(color: divider)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Consent Checkbox Row
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _acceptedTerms = !_acceptedTerms;
                        if (_acceptedTerms) _showError = false;
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            key: const Key('consent_terms_checkbox'),
                            value: _acceptedTerms,
                            onChanged: (val) {
                              setState(() {
                                _acceptedTerms = val ?? false;
                                if (_acceptedTerms) _showError = false;
                              });
                            },
                            activeColor: AppColors.derBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            side: BorderSide(
                              color: _showError
                                  ? AppColors.dieRed
                                  : divider,
                              width: _showError ? 2 : 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'I have read and agree to the Terms of Use and Privacy Policy.',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _showError
                                  ? AppColors.dieRed
                                  : textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Agreement Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      key: const Key('consent_agree_button'),
                      onPressed: _handleAgree,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _acceptedTerms
                            ? AppColors.derBlue
                            : AppColors.derBlue.withValues(alpha: 0.6),
                        foregroundColor: Colors.white,
                        elevation: _acceptedTerms ? 3 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Agree & Get Started',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Commitment Item ──────────────────────────────────────────────────────────

class _CommitmentItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final Color surface;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;

  const _CommitmentItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.surface,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    height: 1.4,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Legal Document Tile ──────────────────────────────────────────────────────

class _LegalDocTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDark;
  final Color surface;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  const _LegalDocTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDark,
    required this.surface,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: divider),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.derBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: textSecondary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
