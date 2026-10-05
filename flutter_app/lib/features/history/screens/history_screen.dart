import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/lookup_history.dart';
import '../../../domain/models/word_model.dart';
import '../../../shared/router/app_router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../quiz/providers/quiz_provider.dart';
import '../../sync/providers/sync_provider.dart';
import '../providers/history_provider.dart';
import 'history_tile.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(historyProvider);
    final favState = ref.watch(favoritesProvider);
    final isFavoritesTab = state.filter == 'favorites';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Text(
            'History',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          // ── Stats Cards ──
          _buildStatsRow(isDark, state.stats),
          const SizedBox(height: 20),

          // ── Filter Chips ──
          _buildFilters(isDark, state.filter, ref),
          const SizedBox(height: 16),

          // ── List / Favorites Content ──
          Expanded(
            child: isFavoritesTab
                ? (favState.loading
                    ? const Center(child: CircularProgressIndicator())
                    : favState.favorites.isEmpty
                        ? _buildEmptyFavoritesState(isDark)
                        : _buildFavoritesList(favState.favorites, isDark, ref))
                : (state.loading
                    ? const Center(child: CircularProgressIndicator())
                    : state.entries.isEmpty
                        ? _buildEmptyState(isDark)
                        : _buildList(state.entries, ref)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark, Map<String, dynamic> stats) {
    final total = stats['total'] ?? 0;
    final totalQuiz = stats['totalQuiz'] ?? 0;
    final accuracy = (stats['accuracy'] ?? 0.0) as double;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.history_rounded,
            label: 'Total',
            value: '$total',
            color: AppColors.derBlue,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.quiz_rounded,
            label: 'Quiz',
            value: '$totalQuiz',
            color: AppColors.dasGreen,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.percent_rounded,
            label: 'Accuracy',
            value: '${accuracy.toStringAsFixed(0)}%',
            color: accuracy >= 70
                ? AppColors.correctGreen
                : accuracy >= 40
                    ? AppColors.streakOrange
                    : AppColors.incorrectRed,
            isDark: isDark,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildFilters(bool isDark, String activeFilter, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isActive: activeFilter == 'all',
            onTap: () => ref.read(historyProvider.notifier).setFilter('all'),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '✓ Correct',
            isActive: activeFilter == 'correct',
            onTap: () =>
                ref.read(historyProvider.notifier).setFilter('correct'),
            isDark: isDark,
            activeColor: AppColors.correctGreen,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '✗ Incorrect',
            isActive: activeFilter == 'incorrect',
            onTap: () =>
                ref.read(historyProvider.notifier).setFilter('incorrect'),
            isDark: isDark,
            activeColor: AppColors.incorrectRed,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '⭐ Favorites',
            isActive: activeFilter == 'favorites',
            onTap: () =>
                ref.read(historyProvider.notifier).setFilter('favorites'),
            isDark: isDark,
            activeColor: const Color(0xFFFFB800),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(
      List<WordModel> favorites, bool isDark, WidgetRef ref) {
    return ListView.builder(
      itemCount: favorites.length + 1,
      padding: const EdgeInsets.only(bottom: 40),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildFocusedReviewCard(favorites.length, isDark, ref, favorites);
        }
        final word = favorites[index - 1];
        final articleColor = AppColors.colorForArticle(word.article);

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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: articleColor.withValues(alpha: isDark ? 0.15 : 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                word.article,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: articleColor,
                ),
              ),
            ),
            title: Text(
              word.word,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            subtitle: Text(
              word.plural != null && word.plural!.isNotEmpty
                  ? 'pl. ${word.plural}'
                  : word.translation != null && word.translation!.isNotEmpty
                      ? word.translation!
                      : word.genderLabel,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFB800),
                size: 24,
              ),
              tooltip: 'Remove from Favorites',
              onPressed: () {
                ref.read(favoritesProvider.notifier).removeFavorite(word.word);
              },
            ),
          ),
        ).animate().fadeIn(
              delay: Duration(milliseconds: ((index - 1) * 30).clamp(0, 300)),
              duration: 300.ms,
            );
      },
    );
  }

  Widget _buildFocusedReviewCard(
      int count, bool isDark, WidgetRef ref, List<WordModel> favorites) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFB800).withValues(alpha: isDark ? 0.20 : 0.14),
            AppColors.streakOrange.withValues(alpha: isDark ? 0.12 : 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFB800).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB800).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Color(0xFFFFB800),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Focused Review',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Practice your $count saved words in Quiz mode',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(quizProvider.notifier)
                  .startFavoritesReview(favorites);
              ref.read(mainTabProvider.notifier).state = 1;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB800),
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: const Text(
              'Quiz',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavoritesState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_outline_rounded,
            size: 64,
            color: const Color(0xFFFFB800).withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the star ⭐ on any word card in Lookup\nor Quiz to save it for focused review.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight)
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<LookupHistory> entries, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(syncProvider.notifier).sync();
        await ref.read(historyProvider.notifier).refresh();
      },
      child: ListView.builder(
        itemCount: entries.length,
        padding: const EdgeInsets.only(bottom: 40),
        itemBuilder: (context, index) {
          return HistoryTile(entry: entries[index])
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: (index * 30).clamp(0, 300)),
                duration: 300.ms,
              )
              .slideX(
                begin: 0.05,
                end: 0,
                delay: Duration(milliseconds: (index * 30).clamp(0, 300)),
                duration: 300.ms,
              );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 56,
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12),
          ),
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Look up words or take quizzes\nto see your history here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight)
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;
  final Color? activeColor;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isDark,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.derBlue;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: isDark ? 0.18 : 0.10)
              : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? color.withValues(alpha: 0.4)
                : (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.06),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive
                ? color
                : isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}

