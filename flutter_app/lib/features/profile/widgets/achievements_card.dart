import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../domain/models/achievement.dart';
import '../../../shared/theme/app_colors.dart';
import '../providers/achievements_provider.dart';
import 'milestone_detail_sheet.dart';

/// Card showing milestone progress, category tabs, and showcase achievement badges.
class AchievementsCard extends ConsumerWidget {
  const AchievementsCard({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(achievementsProvider);
    final totalCount = state.totalCount;
    final unlockedCount = state.unlockedCount;
    final goldColor = const Color(0xFFFFB800);

    if (state.loading) {
      return _CardFrame(
        isDark: isDark,
        child: const SizedBox(
          height: 110,
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    final filtered = state.filteredAchievements;
    // Show top 3: prioritizing unlocked, then highest progress
    final previewList = List<Achievement>.from(filtered)
      ..sort((a, b) {
        if (a.isUnlocked && !b.isUnlocked) return -1;
        if (!a.isUnlocked && b.isUnlocked) return 1;
        return b.progress.compareTo(a.progress);
      });
    final displayItems = previewList.take(3).toList();

    return _CardFrame(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFFB800)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.black87,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.milestonesAndBadges,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      l10n.badgesEarned(unlockedCount, totalCount, (state.unlockedRate * 100).toInt()),
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                key: const Key('profile_view_all_achievements'),
                onPressed: () => showMilestoneDetailSheet(context),
                child: Text(
                  l10n.viewAll,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    color: goldColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Overall progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: state.unlockedRate,
              minHeight: 7,
              color: goldColor,
              backgroundColor: goldColor.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 14),

          // Category tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _MiniFilterChip(
                  label: '${l10n.filterAll} ($totalCount)',
                  selected: state.filter == 'all',
                  isDark: isDark,
                  onTap: () => ref
                      .read(achievementsProvider.notifier)
                      .setFilter('all'),
                ),
                const SizedBox(width: 6),
                for (final cat in AchievementCategory.values) ...[
                  _MiniFilterChip(
                    label: l10n.categoryLabel(cat.name),
                    icon: cat.icon,
                    selected: state.filter == cat.name,
                    isDark: isDark,
                    onTap: () => ref
                        .read(achievementsProvider.notifier)
                        .setFilter(cat.name),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Preview items
          for (final (i, item) in displayItems.indexed) ...[
            if (i > 0) const SizedBox(height: 10),
            _AchievementPreviewTile(achievement: item, isDark: isDark),
          ],

          if (filtered.length > 3) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => showMilestoneDetailSheet(context),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                ),
              ),
              child: Text(
                l10n.exploreAllMilestones(filtered.length),
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }
}

class _AchievementPreviewTile extends StatelessWidget {
  const _AchievementPreviewTile({
    required this.achievement,
    required this.isDark,
  });

  final Achievement achievement;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    final goldColor = const Color(0xFFFFB800);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? goldColor.withValues(alpha: isDark ? 0.08 : 0.05)
            : isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked
              ? goldColor.withValues(alpha: isDark ? 0.35 : 0.4)
              : isDark
                  ? AppColors.dividerDark
                  : AppColors.dividerLight,
          width: isUnlocked ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: isUnlocked
                  ? const LinearGradient(
                      colors: [Color(0xFFFFD54F), Color(0xFFFFB800)],
                    )
                  : null,
              color: isUnlocked
                  ? null
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              achievement.icon,
              size: 20,
              color: isUnlocked
                  ? Colors.black87
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Description & Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.correctGreen,
                        size: 16,
                      )
                    else
                      Text(
                        '${achievement.currentValue}/${achievement.targetValue}',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: achievement.progress,
                    minHeight: 4,
                    color: isUnlocked ? goldColor : AppColors.derBlue,
                    backgroundColor: isUnlocked
                        ? goldColor.withValues(alpha: 0.15)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06)),
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

class _MiniFilterChip extends StatelessWidget {
  const _MiniFilterChip({
    required this.label,
    this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFFFB800);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: isDark ? 0.2 : 0.12)
              : isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? activeColor
                : isDark
                    ? AppColors.dividerDark
                    : AppColors.dividerLight,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 12,
                color: selected
                    ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected
                    ? (isDark ? Colors.white : AppColors.textPrimaryLight)
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

class _CardFrame extends StatelessWidget {
  const _CardFrame({required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: child,
    );
  }
}
