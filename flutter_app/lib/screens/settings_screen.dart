import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_config.dart';
import '../constants/colors.dart';
import '../services/article_service.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const SettingsScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showHints = true;
  bool? _serverOnline;

  @override
  void initState() {
    super.initState();
    _showHints = StorageService.getShowHints();
    _checkServerHealth();
  }

  Future<void> _checkServerHealth() async {
    final online = await ArticleService.forPlatform().checkHealth();
    if (mounted) setState(() => _serverOnline = online);
  }

  // ── Logout flow ────────────────────────────────────────────────────────────

  Future<void> _showLogoutConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      barrierDismissible: true,
      builder: (ctx) => const _LogoutConfirmationDialog(),
    );
    if (confirmed == true && mounted) {
      await _performLogout();
    }
  }

  Future<void> _performLogout() async {
    final streak = StorageService.getStreak();
    final user = SupabaseService.currentUser;
    final displayName = user?.userMetadata?['full_name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        user?.email?.split('@').first ??
        'there';

    await SupabaseService.signOut();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => SignedOutScreen(
            displayName: displayName,
            streak: streak,
          ),
        ),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = SupabaseService.currentUser;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Dark header with user card ────────────────────────────────────
          _UserHeader(user: user, isDark: isDark),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Account Section ────────────────────────────────────────
                _SectionTitle(title: 'Account', isDark: isDark),
                const SizedBox(height: 12),

                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Daily reminders and streak alerts',
                  isDark: isDark,
                  onTap: () {},
                ),

                _SettingsTile(
                  icon: isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  title: 'Dark mode',
                  subtitle: 'Switch app appearance',
                  isDark: isDark,
                  trailing: Switch.adaptive(
                    value: widget.isDarkMode,
                    onChanged: (_) => widget.onThemeToggle(),
                    activeTrackColor: AppColors.derBlue,
                  ),
                ),

                _SettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  subtitle: 'English',
                  isDark: isDark,
                  onTap: () {},
                ),

                const SizedBox(height: 28),

                // ── Preferences Section ───────────────────────────────────
                _SectionTitle(title: 'Preferences', isDark: isDark),
                const SizedBox(height: 12),

                _SettingsTile(
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'Show hints & explanations',
                  subtitle: 'Display extra info on result cards',
                  isDark: isDark,
                  trailing: Switch.adaptive(
                    value: _showHints,
                    onChanged: (val) {
                      setState(() => _showHints = val);
                      StorageService.setShowHints(val);
                    },
                    activeTrackColor: AppColors.derBlue,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Server Section ────────────────────────────────────────
                _SectionTitle(title: 'Server', isDark: isDark),
                const SizedBox(height: 12),

                _SettingsTile(
                  icon: Icons.cloud_outlined,
                  title: 'Backend API',
                  subtitle: _serverSubtitle(),
                  isDark: isDark,
                  onTap: _checkServerHealth,
                ),

                const SizedBox(height: 28),

                // ── Data Section ──────────────────────────────────────────
                _SectionTitle(title: 'Data', isDark: isDark),
                const SizedBox(height: 12),

                _SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Clear history',
                  subtitle: 'Remove all lookup and quiz history',
                  isDark: isDark,
                  onTap: () => _confirmClearHistory(context, isDark),
                ),

                _SettingsTile(
                  icon: Icons.restart_alt_rounded,
                  title: 'Reset streak',
                  subtitle: 'Set your streak back to 0',
                  isDark: isDark,
                  onTap: () => _confirmResetStreak(context, isDark),
                ),

                const SizedBox(height: 28),

                // ── Session Section ───────────────────────────────────────
                _SectionTitle(title: 'Session', isDark: isDark),
                const SizedBox(height: 12),

                _SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change password',
                  subtitle: 'Update your account password',
                  isDark: isDark,
                  onTap: SupabaseService.isEnabled ? () {} : null,
                ),

                // Log out — destructive, uses die-red
                _LogOutTile(isDark: isDark, onTap: _showLogoutConfirmation),

                const SizedBox(height: 28),

                // ── About Section ─────────────────────────────────────────
                _SectionTitle(title: 'About', isDark: isDark),
                const SizedBox(height: 12),

                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Kapiert',
                  subtitle: 'Version 1.0.0 • German Article Trainer',
                  isDark: isDark,
                ),

                _SettingsTile(
                  icon: Icons.dataset_outlined,
                  title: 'Data sources',
                  subtitle: 'german-nouns dataset (~100k) + Wiktionary API',
                  isDark: isDark,
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    'Kapiert v1.0.0',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: (isDark
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

  String _serverSubtitle() {
    final url = AppConfig.apiBaseUrl;
    if (_serverOnline == null) return '$url • checking…';
    if (_serverOnline!) return '$url • online';
    return '$url • offline';
  }

  void _confirmClearHistory(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear History?',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'This will remove all your lookup and quiz history. This cannot be undone.',
          style: GoogleFonts.nunito(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              StorageService.clearHistory();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            child: Text(
              'Clear',
              style: GoogleFonts.nunito(color: AppColors.dieRed),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmResetStreak(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Streak?',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Your streak will be reset to 0. This cannot be undone.',
          style: GoogleFonts.nunito(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              StorageService.resetStreak();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Streak reset')),
              );
            },
            child: Text(
              'Reset',
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
  final dynamic user; // SupabaseService.currentUser (User?)
  final bool isDark;

  const _UserHeader({required this.user, required this.isDark});

  String get _displayName {
    if (user == null) return 'Guest';
    return (user.userMetadata?['full_name'] as String?) ??
        (user.userMetadata?['name'] as String?) ??
        user.email?.split('@').first ??
        'User';
  }

  String get _email => user?.email ?? '';

  String get _initials {
    final name = _displayName;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'G';
  }

  @override
  Widget build(BuildContext context) {
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
                    'Settings',
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

          // User card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        _displayName,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (_email.isNotEmpty)
                        Text(
                          _email,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
          'Log out',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.dieRed,
          ),
        ),
        subtitle: Text(
          'Sign out of your account',
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: AppColors.dieRed.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }
}

// ── Logout confirmation dialog (blurred backdrop) ────────────────────────────

class _LogoutConfirmationDialog extends StatelessWidget {
  const _LogoutConfirmationDialog();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon bubble
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.dieRed.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.dieRed,
                  size: 28,
                ),
              ).animate().scale(
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1, 1),
                    duration: 300.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 18),

              Text(
                'Log out?',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your streak and history will be saved.\nYou can sign back in anytime.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 28),

              // Buttons
              Row(
                children: [
                  // Cancel — neutral
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(
                          color: AppColors.dividerLight,
                        ),
                        backgroundColor: AppColors.backgroundLight,
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Log out — red
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dieRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Log out',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 250.ms)
            .scale(
              begin: const Offset(0.92, 0.92),
              end: const Offset(1, 1),
              duration: 280.ms,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}

// ── Signed-out screen ────────────────────────────────────────────────────────

class SignedOutScreen extends StatelessWidget {
  final String displayName;
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

              // Icon bubble
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

              // Title
              Text(
                'Logged out',
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
              const SizedBox(height: 12),

              // Farewell message
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
                    WidgetSpan(
                      child: const Text('🔥', style: TextStyle(fontSize: 15)),
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

              // Article pills
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

              // Sign in again — primary dark button
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

              // Create new account — ghost link
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

// ── Article pill ─────────────────────────────────────────────────────────────

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

// ── Section title ────────────────────────────────────────────────────────────

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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
        trailing: trailing ??
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
