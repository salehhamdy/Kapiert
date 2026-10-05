import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/lookup_history.dart';
import '../../../domain/models/word_model.dart';
import '../../../shared/theme/app_colors.dart';
import '../../favorites/providers/favorites_provider.dart';

/// A single row in the history list with favorite toggle support.
class HistoryTile extends ConsumerWidget {
  final LookupHistory entry;

  const HistoryTile({super.key, required this.entry});

  static String _genderForArticle(String article) {
    switch (article.toLowerCase()) {
      case 'der':
        return 'm';
      case 'die':
        return 'f';
      case 'das':
        return 'n';
      default:
        return 'm';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final articleColor = AppColors.colorForArticle(entry.article);
    final isQuiz = entry.mode == 'quiz';
    final isFavorite = ref.watch(favoritesProvider).isFavorite(entry.word);

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: articleColor.withValues(alpha: isDark ? 0.15 : 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            entry.article,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: articleColor,
            ),
          ),
        ),
        title: Text(
          entry.word,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Text(
          isQuiz ? 'Quiz' : 'Lookup',
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 22,
              splashRadius: 20,
              tooltip: isFavorite ? 'Favorited' : 'Save to Favorites',
              onPressed: () {
                final model = WordModel(
                  word: entry.word,
                  article: entry.article,
                  gender: _genderForArticle(entry.article),
                  source: 'history',
                );
                ref.read(favoritesProvider.notifier).toggleFavorite(model);
              },
              icon: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isFavorite
                    ? const Color(0xFFFFB800)
                    : (isDark
                        ? AppColors.textSecondaryDark.withValues(alpha: 0.4)
                        : AppColors.textSecondaryLight.withValues(alpha: 0.4)),
              ),
            ),
            const SizedBox(width: 4),
            isQuiz
                ? Icon(
                    entry.correct
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: entry.correct
                        ? AppColors.correctGreen
                        : AppColors.incorrectRed,
                    size: 22,
                  )
                : Icon(
                    Icons.search_rounded,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    size: 18,
                  ),
          ],
        ),
      ),
    );
  }
}

