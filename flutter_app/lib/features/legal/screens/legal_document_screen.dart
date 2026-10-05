import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_colors.dart';

enum LegalDocType { terms, privacy }

class LegalDocumentScreen extends StatefulWidget {
  final LegalDocType initialType;

  const LegalDocumentScreen({
    super.key,
    this.initialType = LegalDocType.terms,
  });

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  late LegalDocType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
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
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Legal & Policies',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // ── Segmented Selector ───────────────────────────────────────────
          Container(
            color: surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: divider),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      title: 'Terms of Use',
                      icon: Icons.description_outlined,
                      isSelected: _selectedType == LegalDocType.terms,
                      onTap: () => setState(() => _selectedType = LegalDocType.terms),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _TabButton(
                      title: 'Privacy Policy',
                      icon: Icons.shield_outlined,
                      isSelected: _selectedType == LegalDocType.privacy,
                      onTap: () => setState(() => _selectedType = LegalDocType.privacy),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content View ────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: _selectedType == LegalDocType.terms
                  ? _TermsContent(
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      surface: surface,
                      divider: divider,
                    )
                  : _PrivacyContent(
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      surface: surface,
                      divider: divider,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Segmented Tab Button ─────────────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _TabButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.derBlue
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.derBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Terms Content ────────────────────────────────────────────────────────────

class _TermsContent extends StatelessWidget {
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color divider;

  const _TermsContent({
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.divider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderBadge(
          title: 'Terms of Use',
          subtitle: 'Effective: October 5, 2026 • Version 1.0',
          icon: Icons.gavel_rounded,
          color: AppColors.derBlue,
          isDark: isDark,
        ),
        const SizedBox(height: 20),

        _SectionCard(
          surface: surface,
          divider: divider,
          children: [
            _Heading('1. Acceptance of Terms', textPrimary),
            _Paragraph(
              'By accessing, downloading, or using Kapiert ("the App"), you agree to be bound by these Terms of Use. If you do not agree to all terms and conditions, do not access or use the application.',
              textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 14),

        _SectionCard(
          surface: surface,
          divider: divider,
          children: [
            _Heading('2. Description of Service', textPrimary),
            _Paragraph(
              'Kapiert provides an educational German article training companion, including instant article lookup for 90,000+ nouns, interactive quizzes, streak tracking, word favoriting, and optional cloud synchronization.',
              textSecondary,
            ),
            _Paragraph(
              'You may use Kapiert in Guest Mode without creating an account. All local features remain fully accessible offline.',
              textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 14),

        _SectionCard(
          surface: surface,
          divider: divider,
          children: [
            _Heading('3. License & Intellectual Property', textPrimary),
            _Paragraph(
              'Kapiert grants you a personal, non-exclusive, revocable license to use the app for personal educational purposes.',
              textSecondary,
            ),
            _Bullet(
              'Software & UI: All branding, design elements, and application code are protected intellectual property.',
              textSecondary,
            ),
            _Bullet(
              'Linguistic Data: German noun database entries are derived from open educational datasets and Wiktionary under Creative Commons (CC BY-SA 3.0).',
              textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 14),

        _SectionCard(
          surface: surface,
          divider: divider,
          children: [
            _Heading('4. Acceptable Use', textPrimary),
            _Paragraph(
              'You agree not to engage in any activity that interferes with or disrupts Kapiert services, including:',
              textSecondary,
            ),
            _Bullet('Attempting to access unauthorized user accounts or databases.', textSecondary),
            _Bullet('Automated crawling or bulk scraping that imposes undue load on backend servers.', textSecondary),
            _Bullet('Reverse engineering or injecting harmful code or payloads.', textSecondary),
          ],
        ),
        const SizedBox(height: 14),

        _SectionCard(
          surface: surface,
          divider: divider,
          children: [
            _Heading('5. Educational Disclaimer & Liability', textPrimary),
            _Paragraph(
              'Kapiert is designed as a learning companion. German article rules have regional nuances and exceptions (e.g. loanwords and dual-gender nouns). Content is provided on an "as-is" basis without warranties of any kind.',
              textSecondary,
            ),
            _Paragraph(
              'Under no circumstances shall Kapiert maintainers be liable for any indirect, incidental, or consequential damages resulting from the use of the app.',
              textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Privacy Content ──────────────────────────────────────────────────────────

class _PrivacyContent extends StatelessWidget {
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color divider;

  const _PrivacyContent({
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.divider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderBadge(
          title: 'Privacy Policy',
          subtitle: 'Effective: October 5, 2026 • Local-First & Zero Ads',
          icon: Icons.shield_rounded,
          color: AppColors.correctGreen,
          isDark: isDark,
        ),
        const SizedBox(height: 20),

        _SectionCard(
          surface: surface,
          divider: divider,
          children: [
            _Heading('1. Privacy-First Commitment', textPrimary),
            _Paragraph(
              'We respect your personal privacy. Kapiert is built around three foundational rules:',
              textSecondary,
            ),
            _Bullet('Zero Ads: No third-party advertisements or ad networks.', textSecondary),
            _Bullet('Zero Data Selling: We never sell or monetize your personal data.', textSecondary),
            _Bullet('Local-First: You can use the entire core app without registering or transmitting data.', textSecondary),
          ],
        ),
        const SizedBox(height: 14),

        _SectionCard(
          surface: surface,
          divider: divider,
          children: [
            _Heading('2. Data Stored Locally (Guest Mode)', textPrimary),
            _Paragraph(
              'When using Kapiert without signing in, all information stays securely on your device:',
              textSecondary,
            ),
            _Bullet('SQLite Database: Lookup history, quiz answers, streak count, and saved Favorites.', textSecondary),
            _Bullet('App Preferences: Dark/light theme mode and hint preferences.', textSecondary),
            _Paragraph(
              'None of this data is transmitted to our servers when in Guest Mode.',
              textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 14),

        _SectionCard(
          surface: surface,
          divider: divider,
          children: [
            _Heading('3. Cloud Sync (Signed-In Mode)', textPrimary),
            _Paragraph(
              'If you choose to create an account to sync progress across multiple devices:',
              textSecondary,
            ),
            _Bullet('Account info: Email address and optional profile display name.', textSecondary),
            _Bullet('Progress data: Synced history, streaks, and favorites backed up to Supabase.', textSecondary),
            _Bullet('Row Level Security (RLS): All database tables enforce strict RLS — only you can access your data.', textSecondary),
          ],
        ),
        const SizedBox(height: 14),

        _SectionCard(
          surface: surface,
          divider: divider,
          children: [
            _Heading('4. Dictionary Searches', textPrimary),
            _Paragraph(
              'When searching for nouns, the query is processed in-memory by our FastAPI server or Wiktionary fallback. Search queries are not tied to personal user identities.',
              textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 14),

        _SectionCard(
          surface: surface,
          divider: divider,
          children: [
            _Heading('5. Your Rights (GDPR & CCPA)', textPrimary),
            _Paragraph(
              'You maintain complete control over your data:',
              textSecondary,
            ),
            _Bullet('Clear Data: Tap "Clear history" in Settings anytime to permanently delete your local history.', textSecondary),
            _Bullet('Account Erasure: You may delete your account and all associated cloud data upon request.', textSecondary),
            _Bullet('No Trackers: We do not integrate Facebook SDK, Google Analytics, or third-party tracking beacons.', textSecondary),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Shared UI Components ─────────────────────────────────────────────────────

class _HeaderBadge extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _HeaderBadge({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
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

class _SectionCard extends StatelessWidget {
  final Color surface;
  final Color divider;
  final List<Widget> children;

  const _SectionCard({
    required this.surface,
    required this.divider,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  final Color color;

  const _Heading(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  final Color color;

  const _Paragraph(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 13,
          height: 1.5,
          color: color,
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  final Color color;

  const _Bullet(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.derBlue,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                fontSize: 13,
                height: 1.45,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
