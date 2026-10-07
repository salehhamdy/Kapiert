import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/app_config.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/models/auth_user.dart';
import '../../../shared/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../lookup/providers/lookup_provider.dart';
import '../../quiz/providers/quiz_provider.dart';
import '../providers/settings_provider.dart';
import '../../../data/datasources/auth_remote_ds.dart';
import '../../auth/logout_flow.dart';
import '../../profile/screens/profile_screen.dart';
import '../../legal/screens/legal_document_screen.dart';
import '../../legal/providers/terms_consent_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _openProfile() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  void _showLanguageSelector(
    BuildContext context,
    String currentCode,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.selectLanguage,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                ...AppLanguage.values.map((lang) {
                  final isSelected = lang.code == currentCode;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.derBlue
                              .withValues(alpha: isDark ? 0.15 : 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.derBlue
                            : (isDark ? Colors.white : Colors.black)
                                .withValues(alpha: 0.06),
                      ),
                    ),
                    child: ListTile(
                      key: Key('lang_option_${lang.code}'),
                      leading: Text(
                        lang.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        lang.nativeName,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      subtitle: Text(
                        lang.englishName,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppColors.derBlue)
                          : null,
                      onTap: () {
                        ref
                            .read(settingsProvider.notifier)
                            .setLanguage(lang.code);
                        Navigator.pop(ctx);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDarkMode = ref.watch(themeProvider);
    final showHints = ref.watch(showHintsProvider);
    final currentLangCode = ref.watch(languageProvider);
    final currentLang = AppLanguage.fromCode(currentLangCode);
    final serverHealth = ref.watch(serverHealthProvider);
    final authState = ref.watch(authProvider);
    final hasAcceptedTerms = ref.watch(termsConsentProvider);
    final user = authState.user;

    final serverSubtitle = switch (serverHealth) {
      AsyncData(:final value) =>
        '${AppConfig.apiBaseUrl} • ${value ? l10n.online : l10n.offline}',
      AsyncLoading() => '${AppConfig.apiBaseUrl} • ${l10n.checking}',
      _ => '${AppConfig.apiBaseUrl} • ${l10n.unknown}',
    };

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Dark header with user card ────────────────────────────────────
          _UserHeader(user: user, isDark: isDark, onTap: _openProfile),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Account Section ────────────────────────────────────────
                _SectionTitle(title: l10n.sectionAccount, isDark: isDark),
                const SizedBox(height: 12),

                _SettingsTile(
                  key: const Key('settings_profile_tile'),
                  icon: Icons.person_outline_rounded,
                  title: l10n.profileTitle,
                  subtitle: l10n.profileSubtitle,
                  isDark: isDark,
                  onTap: _openProfile,
                ),

                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: l10n.notifications,
                  subtitle: l10n.notificationsSubtitle,
                  isDark: isDark,
                  onTap: () {},
                ),

                _SettingsTile(
                  icon: isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  title: l10n.darkMode,
                  subtitle: l10n.darkModeSubtitle,
                  isDark: isDark,
                  trailing: Switch.adaptive(
                    value: isDarkMode,
                    onChanged: (_) =>
                        ref.read(settingsProvider.notifier).toggleDarkMode(),
                    activeTrackColor: AppColors.derBlue,
                  ),
                ),

                _SettingsTile(
                  key: const Key('settings_language_tile'),
                  icon: Icons.language_rounded,
                  title: l10n.language,
                  subtitle: '${currentLang.flag} ${currentLang.nativeName} (${currentLang.englishName})',
                  isDark: isDark,
                  onTap: () => _showLanguageSelector(
                    context,
                    currentLangCode,
                    isDark,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Preferences Section ───────────────────────────────────
                _SectionTitle(title: l10n.sectionPreferences, isDark: isDark),
                const SizedBox(height: 12),

                _SettingsTile(
                  icon: Icons.lightbulb_outline_rounded,
                  title: l10n.showHints,
                  subtitle: l10n.showHintsSubtitle,
                  isDark: isDark,
                  trailing: Switch.adaptive(
                    value: showHints,
                    onChanged: (val) =>
                        ref.read(settingsProvider.notifier).setShowHints(val),
                    activeTrackColor: AppColors.derBlue,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Server Section ────────────────────────────────────────
                _SectionTitle(title: l10n.sectionServer, isDark: isDark),
                const SizedBox(height: 12),

                _SettingsTile(
                  icon: Icons.cloud_outlined,
                  title: l10n.backendApi,
                  subtitle: serverSubtitle,
                  isDark: isDark,
                  onTap: () => ref.invalidate(serverHealthProvider),
                ),

                const SizedBox(height: 28),

                // ── Data Section ──────────────────────────────────────────
                _SectionTitle(title: l10n.sectionData, isDark: isDark),
                const SizedBox(height: 12),

                _SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: l10n.clearHistory,
                  subtitle: l10n.clearHistorySubtitle,
                  isDark: isDark,
                  onTap: () => _confirmClearHistory(context, isDark),
                ),

                _SettingsTile(
                  icon: Icons.restart_alt_rounded,
                  title: l10n.resetStreak,
                  subtitle: l10n.resetStreakSubtitle,
                  isDark: isDark,
                  onTap: () => _confirmResetStreak(context, isDark),
                ),

                const SizedBox(height: 28),

                // ── Session Section ───────────────────────────────────────
                _SectionTitle(title: l10n.sectionSession, isDark: isDark),
                const SizedBox(height: 12),

                _SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: l10n.changePassword,
                  subtitle: l10n.changePasswordSubtitle,
                  isDark: isDark,
                  onTap: AuthRemoteDS.isEnabled ? () {} : null,
                ),

                // Log out — destructive, uses die-red
                if (user != null)
                  _LogOutTile(
                    isDark: isDark,
                    onTap: () => confirmAndLogout(context, ref),
                  ),

                const SizedBox(height: 28),

                // ── Legal Section ─────────────────────────────────────────
                _SectionTitle(title: l10n.sectionLegal, isDark: isDark),
                const SizedBox(height: 12),

                _SettingsTile(
                  key: const Key('settings_terms_tile'),
                  icon: Icons.description_outlined,
                  title: l10n.termsOfUse,
                  subtitle: l10n.termsSubtitle,
                  isDark: isDark,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LegalDocumentScreen(
                        initialType: LegalDocType.terms,
                      ),
                    ),
                  ),
                ),

                _SettingsTile(
                  key: const Key('settings_privacy_tile'),
                  icon: Icons.shield_outlined,
                  title: l10n.privacyPolicy,
                  subtitle: l10n.privacySubtitle,
                  isDark: isDark,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LegalDocumentScreen(
                        initialType: LegalDocType.privacy,
                      ),
                    ),
                  ),
                ),

                _SettingsTile(
                  key: const Key('settings_consent_status_tile'),
                  icon: hasAcceptedTerms
                      ? Icons.check_circle_outline_rounded
                      : Icons.pending_outlined,
                  title: l10n.consentStatus,
                  subtitle: hasAcceptedTerms
                      ? l10n.consentAcceptedSubtitle
                      : l10n.consentPendingSubtitle,
                  isDark: isDark,
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (hasAcceptedTerms
                              ? AppColors.correctGreen
                              : AppColors.streakOrange)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      hasAcceptedTerms ? l10n.accepted : l10n.pending,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: hasAcceptedTerms
                            ? AppColors.correctGreen
                            : AppColors.streakOrange,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── About Section ─────────────────────────────────────────
                _SectionTitle(title: l10n.sectionAbout, isDark: isDark),
                const SizedBox(height: 12),

                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Kapiert',
                  subtitle: l10n.aboutSubtitle,
                  isDark: isDark,
                ),

                _SettingsTile(
                  icon: Icons.dataset_outlined,
                  title: l10n.dataSources,
                  subtitle: l10n.dataSourcesSubtitle,
                  isDark: isDark,
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    'Kapiert v1.0.0',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color:
                          (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight)
                              .withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.clearHistoryDialogTitle,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          l10n.clearHistoryDialogContent,
          style: GoogleFonts.nunito(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(historyProvider.notifier).clearAll();
              ref.read(quizProvider.notifier).reset();
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.historyCleared)),
                );
              }
            },
            child: Text(
              l10n.clear,
              style: GoogleFonts.nunito(color: AppColors.dieRed),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmResetStreak(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.resetStreakDialogTitle,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          l10n.resetStreakDialogContent,
          style: GoogleFonts.nunito(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(historyProvider.notifier).resetStreak();
              ref.read(lookupProvider.notifier).refreshStreak();
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.streakReset)));
              }
            },
            child: Text(
              l10n.reset,
              style: GoogleFonts.nunito(color: AppColors.dieRed),
            ),
          ),
        ],
      ),
    );
  }
}

// ── User header (dark band) ──────────────────────────────────────────────────

class _UserHeader extends StatelessWidget {
  final AppUser? user;
  final bool isDark;
  final VoidCallback onTap;

  const _UserHeader({
    required this.user,
    required this.isDark,
    required this.onTap,
  });

  String _displayName(AppLocalizations l10n) => user?.shownName ?? l10n.guest;

  String get _email => user?.email ?? '';

  String get _initials => user?.initials ?? 'G';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              // K logo mark
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'K',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.derBlue,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kapiert',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    l10n.tabSettings,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User card — opens the profile screen
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('settings_user_card'),
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar circle
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.dasGreen.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _initials,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayName(l10n),
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _email.isNotEmpty ? _email : l10n.viewProfile,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),
        ],
      ),
    );
  }
}

// ── Log out tile (red destructive row) ──────────────────────────────────────

class _LogOutTile extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onTap;

  const _LogOutTile({required this.isDark, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.dieRed.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.dieRed.withValues(alpha: isDark ? 0.18 : 0.12),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.dieRed.withValues(alpha: isDark ? 0.15 : 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.logout_rounded,
            size: 20,
            color: AppColors.dieRed,
          ),
        ),
        title: Text(
          l10n.logOut,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.dieRed,
          ),
        ),
        subtitle: Text(
          l10n.logOutSubtitle,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: AppColors.dieRed.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }
}

// ── Article pill ─────────────────────────────────────────────────────────────
// (Moved to signed_out_screen.dart)

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: isDark
            ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
            : AppColors.textSecondaryLight.withValues(alpha: 0.6),
      ),
    );
  }
}

// ── Settings tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.derBlue.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: AppColors.derBlue),
        ),
        title: Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        trailing:
            trailing ??
            (onTap != null
                ? Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  )
                : null),
      ),
    );
  }
}
