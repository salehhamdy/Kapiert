import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 28),

          // ── Preferences Section ──
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

          _SettingsTile(
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: isDark ? 'Dark mode' : 'Light mode',
            subtitle: 'Switch app appearance',
            isDark: isDark,
            trailing: Switch.adaptive(
              value: widget.isDarkMode,
              onChanged: (_) => widget.onThemeToggle(),
              activeTrackColor: AppColors.derBlue,
            ),
          ),

          const SizedBox(height: 28),

          // ── Server Section ──
          _SectionTitle(title: 'Server', isDark: isDark),
          const SizedBox(height: 12),

          _SettingsTile(
            icon: Icons.cloud_outlined,
            title: 'Backend API',
            subtitle: _serverSubtitle(),
            isDark: isDark,
            onTap: _checkServerHealth,
          ),

          _SettingsTile(
            icon: Icons.account_circle_outlined,
            title: 'Account sync',
            subtitle: SupabaseService.isEnabled
                ? 'Supabase configured • Sign-in coming soon'
                : 'Guest mode (local storage only)',
            isDark: isDark,
          ),

          const SizedBox(height: 28),

          // ── Data Section ──
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

          // ── About Section ──
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

          const SizedBox(height: 16),

          // Footer
          Center(
            child: Text(
              'Made with ❤️ for German learners',
              style: TextStyle(
                fontSize: 13,
                color: (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight)
                    .withValues(alpha: 0.6),
              ),
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
    return '$url • offline (start backend locally)';
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
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'This will remove all your lookup and quiz history. This cannot be undone.',
          style: TextStyle(
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
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.incorrectRed),
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
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Your streak will be reset to 0. This cannot be undone.',
          style: TextStyle(
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
            child: const Text(
              'Reset',
              style: TextStyle(color: AppColors.incorrectRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
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
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
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
