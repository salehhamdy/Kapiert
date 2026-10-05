import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/models/auth_user.dart';
import '../../../shared/theme/app_colors.dart';
import '../../auth/logout_flow.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/sign_in_screen.dart';
import '../../auth/screens/sign_up_screen.dart';
import '../../history/providers/history_provider.dart';
import '../../sync/providers/sync_provider.dart';
import '../profile_format.dart';
import '../widgets/edit_name_sheet.dart';
import '../widgets/profile_avatar.dart';

/// User profile: identity, progress stats, article mastery and account
/// actions. Works for both signed-in users and guests.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Stats (esp. streak) may be stale if the user has been practising.
    Future.microtask(() {
      if (mounted) ref.read(historyProvider.notifier).refresh();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(syncProvider.notifier).sync();
    await ref.read(historyProvider.notifier).refresh();
  }

  Future<void> _editName(AppUser user) async {
    final saved = await showEditNameSheet(context, user.shownName);
    if (saved && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name updated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final stats = ref.watch(historyProvider).stats;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        edgeOffset: MediaQuery.paddingOf(context).top,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHeader(
                user: user,
                firstActivity: stats['firstActivity'] as DateTime?,
                onEdit: user == null ? null : () => _editName(user),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (user == null)
                      _GuestCard(isDark: isDark)
                    else
                      _SyncCard(isDark: isDark),
                    const SizedBox(height: 28),
                    _SectionTitle('Your progress', isDark: isDark),
                    const SizedBox(height: 12),
                    _StatsGrid(stats: stats, isDark: isDark),
                    const SizedBox(height: 28),
                    _SectionTitle('Article mastery', isDark: isDark),
                    const SizedBox(height: 12),
                    _ArticleMasteryCard(stats: stats, isDark: isDark),
                    if (user != null) ...[
                      const SizedBox(height: 28),
                      _SectionTitle('Account', isDark: isDark),
                      const SizedBox(height: 12),
                      _ProfileTile(
                        key: const Key('profile_edit_name_tile'),
                        icon: Icons.badge_outlined,
                        title: 'Display name',
                        subtitle: user.shownName,
                        isDark: isDark,
                        onTap: () => _editName(user),
                      ),
                      _ProfileTile(
                        icon: Icons.alternate_email_rounded,
                        title: 'Email',
                        subtitle: user.email.isEmpty ? '—' : user.email,
                        isDark: isDark,
                      ),
                      _ProfileTile(
                        icon: user.provider == 'google'
                            ? Icons.g_mobiledata_rounded
                            : Icons.key_rounded,
                        title: 'Sign-in method',
                        subtitle: user.provider == 'email'
                            ? 'Email & password'
                            : providerLabel(user.provider),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _LogOutButton(
                        onTap: () => confirmAndLogout(context, ref),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.firstActivity,
    required this.onEdit,
  });

  final AppUser? user;
  final DateTime? firstActivity;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final name = user?.shownName ?? 'Guest';
    final initials = user?.initials ?? 'G';
    final since = user?.createdAt ?? firstActivity;
    final canPop = Navigator.of(context).canPop();

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.paddingOf(context).top + 4,
        8,
        28,
      ),
      child: Stack(
        children: [
          // Soft article-coloured glows behind the avatar.
          Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: _GlowPainter())),
          ),
          Column(
            children: [
              Row(
                children: [
                  if (canPop)
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      'Profile',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),
              ProfileAvatar(initials: initials, imageUrl: user?.avatarUrl)
                  .animate()
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    duration: 450.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        key: const Key('profile_display_name'),
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (onEdit != null) ...[
                      const SizedBox(width: 6),
                      _HeaderIconButton(
                        icon: Icons.edit_rounded,
                        tooltip: 'Edit name',
                        onTap: onEdit!,
                      ),
                    ],
                  ],
                ),
              ),
              if (user != null && user!.email.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  user!.email,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (user == null)
                    const _HeaderChip(
                      icon: Icons.phone_android_rounded,
                      label: 'Guest · on this device',
                    )
                  else
                    _HeaderChip(
                      icon: user!.provider == 'google'
                          ? Icons.g_mobiledata_rounded
                          : Icons.mail_outline_rounded,
                      label: providerLabel(user!.provider),
                    ),
                  if (since != null)
                    _HeaderChip(
                      icon: Icons.calendar_today_rounded,
                      label: user != null
                          ? 'Member since ${formatMonthYear(since)}'
                          : 'Learning since ${formatMonthYear(since)}',
                    ),
                ],
              ).animate().fadeIn(delay: 150.ms, duration: 350.ms),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    void glow(Offset c, double r, Color color) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: c, radius: r));
      canvas.drawCircle(c, r, paint);
    }

    final cx = size.width / 2;
    glow(Offset(cx - 110, 70), 120, AppColors.derBlue);
    glow(Offset(cx + 120, 110), 110, AppColors.dieRed);
    glow(Offset(cx, size.height - 10), 120, AppColors.dasGreen);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.1),
        shape: const CircleBorder(),
        child: InkWell(
          key: const Key('profile_edit_name_button'),
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(icon, size: 15, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.75)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sync status / guest CTA ──────────────────────────────────────────────────

class _SyncCard extends ConsumerWidget {
  const _SyncCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncProvider);

    final (
      IconData icon,
      Color color,
      String title,
      String subtitle,
    ) = switch (sync.status) {
      SyncStatus.syncing => (
        Icons.sync_rounded,
        AppColors.derBlue,
        'Syncing…',
        'Updating history, streak and settings',
      ),
      SyncStatus.error => (
        Icons.cloud_off_rounded,
        AppColors.dieRed,
        'Sync paused',
        'We\'ll retry automatically — or tap Sync now',
      ),
      SyncStatus.idle => (
        Icons.cloud_done_rounded,
        AppColors.dasGreen,
        'Cloud sync on',
        sync.lastSyncedAt == null
            ? 'Your progress is backed up to your account'
            : 'Last synced ${formatRelative(sync.lastSyncedAt!)}',
      ),
    };

    return _Card(
      isDark: isDark,
      borderColor: color.withValues(alpha: 0.25),
      child: Row(
        children: [
          _IconBubble(icon: icon, color: color, spinning: sync.isSyncing),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _titleStyle(isDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: _subtitleStyle(isDark)),
              ],
            ),
          ),
          TextButton(
            key: const Key('profile_sync_now'),
            onPressed: sync.isSyncing
                ? null
                : () => ref.read(syncProvider.notifier).sync(),
            child: Text(
              'Sync now',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0);
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [AppColors.derBlue, AppColors.dieRed, AppColors.dasGreen],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _IconBubble(
                  icon: Icons.cloud_upload_outlined,
                  color: AppColors.derBlue,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Keep your progress safe',
                        style: _titleStyle(isDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Create a free account to sync your history and '
                        'streak across all your devices.',
                        style: _subtitleStyle(isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('profile_guest_sign_in'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Sign in'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    key: const Key('profile_guest_sign_up'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.derBlue,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create account',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0);
  }
}

// ── Stats grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.isDark});

  final Map<String, dynamic> stats;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final streak = (stats['streak'] as int?) ?? 0;
    final unique = (stats['uniqueWords'] as int?) ?? 0;
    final quiz = (stats['totalQuiz'] as int?) ?? 0;
    final accuracy = ((stats['accuracy'] as num?) ?? 0).toDouble();

    final accuracyColor = quiz == 0
        ? AppColors.textSecondaryLight
        : accuracy >= 70
        ? AppColors.correctGreen
        : accuracy >= 40
        ? AppColors.streakOrange
        : AppColors.incorrectRed;

    final cards = [
      _StatTile(
        icon: Icons.local_fire_department_rounded,
        color: AppColors.streakOrange,
        value: '$streak',
        label: streak == 1 ? 'Day streak' : 'Days streak',
        isDark: isDark,
      ),
      _StatTile(
        icon: Icons.menu_book_rounded,
        color: AppColors.derBlue,
        value: '$unique',
        label: 'Words practised',
        isDark: isDark,
      ),
      _StatTile(
        icon: Icons.quiz_rounded,
        color: AppColors.dasGreen,
        value: '$quiz',
        label: 'Quiz answers',
        isDark: isDark,
      ),
      _StatTile(
        icon: Icons.track_changes_rounded,
        color: accuracyColor,
        value: quiz == 0 ? '—' : '${accuracy.toStringAsFixed(0)}%',
        label: 'Quiz accuracy',
        isDark: isDark,
      ),
    ];

    Widget row(int a, int b) => Row(
      children: [
        Expanded(child: cards[a]),
        const SizedBox(width: 12),
        Expanded(child: cards[b]),
      ],
    );

    return Column(children: [row(0, 1), const SizedBox(height: 12), row(2, 3)])
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms)
        .slideY(begin: 0.05, end: 0);
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      borderColor: color.withValues(alpha: 0.18),
      child: Row(
        children: [
          _IconBubble(icon: icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _subtitleStyle(isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Article mastery ──────────────────────────────────────────────────────────

class _ArticleMasteryCard extends StatelessWidget {
  const _ArticleMasteryCard({required this.stats, required this.isDark});

  final Map<String, dynamic> stats;
  final bool isDark;

  static const _articles = ['der', 'die', 'das'];

  @override
  Widget build(BuildContext context) {
    final raw = stats['byArticle'];
    final byArticle = raw is Map ? raw : const {};
    Map<String, int> of(String a) =>
        (byArticle[a] as Map?)?.cast<String, int>() ?? const {};

    final total = _articles.fold<int>(
      0,
      (sum, a) => sum + (of(a)['total'] ?? 0),
    );

    if (total == 0) {
      return _Card(
        isDark: isDark,
        child: Row(
          children: [
            _IconBubble(
              icon: Icons.insights_rounded,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Look up or quiz a few words to see how you do with '
                'der, die and das.',
                style: _subtitleStyle(isDark),
              ),
            ),
          ],
        ),
      );
    }

    // Weakest article = lowest quiz accuracy, once there's enough signal.
    String? weakest;
    double weakestAcc = 101;
    for (final a in _articles) {
      final s = of(a);
      final quiz = s['quiz'] ?? 0;
      if (quiz < 5) continue;
      final acc = (s['correct'] ?? 0) / quiz * 100;
      if (acc < weakestAcc) {
        weakestAcc = acc;
        weakest = a;
      }
    }

    return _Card(
      isDark: isDark,
      child: Column(
        children: [
          for (final (i, a) in _articles.indexed) ...[
            if (i > 0) const SizedBox(height: 16),
            _ArticleRow(
              article: a,
              total: of(a)['total'] ?? 0,
              share: (of(a)['total'] ?? 0) / total,
              quiz: of(a)['quiz'] ?? 0,
              correct: of(a)['correct'] ?? 0,
              isDark: isDark,
            ),
          ],
          if (weakest != null && weakestAcc < 90) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.colorForArticle(
                  weakest,
                ).withValues(alpha: isDark ? 0.14 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates_rounded,
                    size: 18,
                    color: AppColors.colorForArticle(weakest),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: _subtitleStyle(isDark),
                        children: [
                          const TextSpan(text: 'Focus on '),
                          TextSpan(
                            text: weakest,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.colorForArticle(weakest),
                            ),
                          ),
                          const TextSpan(
                            text: ' — it\'s your lowest quiz accuracy.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }
}

class _ArticleRow extends StatelessWidget {
  const _ArticleRow({
    required this.article,
    required this.total,
    required this.share,
    required this.quiz,
    required this.correct,
    required this.isDark,
  });

  final String article;
  final int total;
  final double share;
  final int quiz;
  final int correct;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.colorForArticle(article);
    final acc = quiz == 0 ? null : correct / quiz;

    return Row(
      children: [
        Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            article,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$total ${total == 1 ? 'word' : 'words'}',
                    style: _titleStyle(isDark).copyWith(fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    acc == null
                        ? 'no quiz yet'
                        : '${(acc * 100).toStringAsFixed(0)}% correct',
                    style: _subtitleStyle(isDark).copyWith(
                      fontWeight: FontWeight.w700,
                      color: acc == null ? null : color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: acc ?? share),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 8,
                    color: acc == null ? color.withValues(alpha: 0.45) : color,
                    backgroundColor: color.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Account tiles ────────────────────────────────────────────────────────────

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: _cardDecoration(isDark),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: _IconBubble(icon: icon, color: AppColors.derBlue, size: 40),
        title: Text(title, style: _subtitleStyle(isDark)),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _titleStyle(isDark).copyWith(fontSize: 15),
        ),
        trailing: onTap == null
            ? null
            : Icon(
                Icons.edit_outlined,
                size: 18,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
      ),
    );
  }
}

class _LogOutButton extends StatelessWidget {
  const _LogOutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const Key('profile_logout'),
      onPressed: onTap,
      icon: const Icon(Icons.logout_rounded, size: 18),
      label: Text(
        'Log out',
        style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.dieRed,
        minimumSize: const Size.fromHeight(50),
        side: BorderSide(color: AppColors.dieRed.withValues(alpha: 0.35)),
        backgroundColor: AppColors.dieRed.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ── Shared bits ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {required this.isDark});

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color:
            (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight)
                .withValues(alpha: 0.6),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.isDark, required this.child, this.borderColor});

  final bool isDark;
  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(isDark, borderColor: borderColor),
      child: child,
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
    required this.color,
    this.size = 42,
    this.spinning = false,
  });

  final IconData icon;
  final Color color;
  final double size;
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    Widget glyph = Icon(icon, size: size * 0.5, color: color);
    if (spinning) {
      glyph = glyph
          .animate(onPlay: (c) => c.repeat())
          .rotate(begin: 0, end: -1, duration: 1.seconds);
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: glyph,
    );
  }
}

BoxDecoration _cardDecoration(bool isDark, {Color? borderColor}) {
  return BoxDecoration(
    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color:
          borderColor ??
          (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

TextStyle _titleStyle(bool isDark) => GoogleFonts.nunito(
  fontSize: 15,
  fontWeight: FontWeight.w800,
  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
);

TextStyle _subtitleStyle(bool isDark) => GoogleFonts.nunito(
  fontSize: 12.5,
  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
);
