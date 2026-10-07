import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/models/daily_activity.dart';
import '../../../shared/theme/app_colors.dart';
import '../providers/advanced_stats_provider.dart';

/// Card displaying the weekly activity heatmap, 7-day volume bar chart,
/// and progress trends over time.
class AdvancedStatsCard extends ConsumerWidget {
  const AdvancedStatsCard({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(advancedStatsProvider);
    final stats = state.stats;

    if (state.loading) {
      return _ContainerCard(
        isDark: isDark,
        child: const SizedBox(
          height: 120,
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (stats.totalActivities == 0) {
      return _ContainerCard(
        isDark: isDark,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.derBlue.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_graph_rounded,
                color: AppColors.derBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Complete quizzes or look up words to build your weekly activity heatmap and progress trends.',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final selectedDay = state.selectedDay;
    final last7 = stats.last7Days;

    return _ContainerCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.derBlue.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: AppColors.derBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity Heatmap',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      '${stats.activeDaysCount} of 7 active days this week',
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
              _TrendBadge(
                weekChange: stats.weekOverWeekPercentage,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 7-day Heatmap Grid
          _HeatmapGrid(
            days: last7,
            selectedIndex: state.selectedDayIndex,
            isDark: isDark,
            onSelect: (idx) =>
                ref.read(advancedStatsProvider.notifier).selectDay(idx),
          ),
          const SizedBox(height: 10),

          // Heatmap Legend
          _HeatmapLegend(isDark: isDark),

          // Selected Day Detail Box (if user tapped a day)
          if (selectedDay != null) ...[
            const SizedBox(height: 12),
            _DayDetailPill(activity: selectedDay, isDark: isDark),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1),
          ),

          // Section 2: Progress Over Time Bar Chart
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.dasGreen.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 18,
                  color: AppColors.dasGreen,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Daily Practice Volume',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Volume Bar Chart
          _VolumeBarChart(days: last7, isDark: isDark),
          const SizedBox(height: 18),

          // Key Metrics Summary
          Row(
            children: [
              _MetricTile(
                label: '7-Day Total',
                value: '${stats.currentWeekTotal}',
                unit: 'actions',
                color: AppColors.derBlue,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _MetricTile(
                label: 'Daily Avg',
                value: stats.dailyAverage.toStringAsFixed(1),
                unit: '/ day',
                color: AppColors.dasGreen,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _MetricTile(
                label: 'Best Day',
                value: '${stats.bestDayCount}',
                unit: 'max',
                color: AppColors.streakOrange,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }
}

// ── Heatmap Grid ─────────────────────────────────────────────────────────────

class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({
    required this.days,
    required this.selectedIndex,
    required this.isDark,
    required this.onSelect,
  });

  final List<DailyActivity> days;
  final int? selectedIndex;
  final bool isDark;
  final ValueChanged<int> onSelect;

  static const _weekDayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < days.length; i++) ...[
          Expanded(
            child: _HeatmapCell(
              activity: days[i],
              isSelected: selectedIndex == i,
              isDark: isDark,
              dayLabel: _dayLabel(days[i].date),
              onTap: () => onSelect(i),
            ),
          ),
          if (i < days.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }

  String _dayLabel(DateTime dt) {
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    return _weekDayNames[(dt.weekday - 1) % 7];
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.activity,
    required this.isSelected,
    required this.isDark,
    required this.dayLabel,
    required this.onTap,
  });

  final DailyActivity activity;
  final bool isSelected;
  final bool isDark;
  final String dayLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final level = activity.intensityLevel;
    final color = _colorForLevel(level);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.derBlue
                : isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              dayLabel,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${activity.date.day}',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activity.hasActivity
                    ? (level >= 3 ? Colors.white : AppColors.derBlue)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForLevel(int level) {
    switch (level) {
      case 0:
        return isDark
            ? const Color(0xFF222634)
            : const Color(0xFFF1F3F5);
      case 1:
        return AppColors.derBlue.withValues(alpha: isDark ? 0.35 : 0.22);
      case 2:
        return AppColors.derBlue.withValues(alpha: isDark ? 0.65 : 0.50);
      case 3:
        return AppColors.derBlue.withValues(alpha: isDark ? 0.90 : 0.80);
      case 4:
      default:
        return AppColors.streakOrange;
    }
  }
}

// ── Heatmap Legend ───────────────────────────────────────────────────────────

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Less',
          style: GoogleFonts.nunito(
            fontSize: 10,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(width: 5),
        _legendBox(0),
        const SizedBox(width: 3),
        _legendBox(1),
        const SizedBox(width: 3),
        _legendBox(2),
        const SizedBox(width: 3),
        _legendBox(3),
        const SizedBox(width: 3),
        _legendBox(4),
        const SizedBox(width: 5),
        Text(
          'More',
          style: GoogleFonts.nunito(
            fontSize: 10,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _legendBox(int level) {
    Color color;
    switch (level) {
      case 0:
        color = isDark ? const Color(0xFF222634) : const Color(0xFFF1F3F5);
        break;
      case 1:
        color = AppColors.derBlue.withValues(alpha: isDark ? 0.35 : 0.22);
        break;
      case 2:
        color = AppColors.derBlue.withValues(alpha: isDark ? 0.65 : 0.50);
        break;
      case 3:
        color = AppColors.derBlue.withValues(alpha: isDark ? 0.90 : 0.80);
        break;
      case 4:
      default:
        color = AppColors.streakOrange;
        break;
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }
}

// ── Selected Day Detail Pill ─────────────────────────────────────────────────

class _DayDetailPill extends StatelessWidget {
  const _DayDetailPill({required this.activity, required this.isDark});

  final DailyActivity activity;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final d = activity.date;
    final dateStr = '${_monthName(d.month)} ${d.day}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.derBlue.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.derBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.derBlue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                children: [
                  TextSpan(
                    text: '$dateStr: ',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: activity.hasActivity
                        ? '${activity.totalCount} actions (${activity.quizCount} quizzes, ${(activity.accuracy).toStringAsFixed(0)}% accuracy, ${activity.uniqueWords} words)'
                        : 'No activity recorded on this day.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  String _monthName(int m) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[(m - 1).clamp(0, 11)];
  }
}

// ── Volume Bar Chart ─────────────────────────────────────────────────────────

class _VolumeBarChart extends StatelessWidget {
  const _VolumeBarChart({required this.days, required this.isDark});

  final List<DailyActivity> days;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final maxCount = max(
      1,
      days.fold<int>(0, (m, d) => max(m, d.totalCount)),
    );

    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < days.length; i++) ...[
            Expanded(
              child: _BarColumn(
                activity: days[i],
                maxCount: maxCount,
                isDark: isDark,
              ),
            ),
            if (i < days.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.activity,
    required this.maxCount,
    required this.isDark,
  });

  final DailyActivity activity;
  final int maxCount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final ratio = (activity.totalCount / maxCount).clamp(0.05, 1.0);
    const chartHeight = 56.0;
    final barHeight = activity.totalCount == 0 ? 4.0 : chartHeight * ratio;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (activity.totalCount > 0)
          Text(
            '${activity.totalCount}',
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.derBlue,
            ),
          )
        else
          const SizedBox(height: 14),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            height: barHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: activity.totalCount > 0
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.derBlue, Color(0xFF3B82F6)],
                    )
                  : null,
              color: activity.totalCount == 0
                  ? (isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.05))
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${activity.date.day}',
          style: GoogleFonts.nunito(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

// ── Metric Tiles ─────────────────────────────────────────────────────────────

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

// ── Trend Badge ──────────────────────────────────────────────────────────────

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.weekChange, required this.isDark});

  final double? weekChange;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (weekChange == null) {
      return const SizedBox.shrink();
    }

    final isPositive = weekChange! >= 0;
    final color = isPositive ? AppColors.correctGreen : AppColors.streakOrange;
    final sign = isPositive ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up_rounded : Icons.trending_flat_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$sign${weekChange!.toStringAsFixed(0)}% vs last wk',
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Container Card ───────────────────────────────────────────────────────────

class _ContainerCard extends StatelessWidget {
  const _ContainerCard({required this.isDark, required this.child});

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
