import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../domain/models/lookup_history.dart';

/// A single row in the history list.
class HistoryTile extends StatelessWidget {
  final LookupHistory entry;

  const HistoryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final articleColor = AppColors.colorForArticle(entry.article);
    final isQuiz = entry.mode == 'quiz';

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
        trailing: isQuiz
            ? Icon(
                entry.correct
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: entry.correct
                    ? AppColors.correctGreen
                    : AppColors.incorrectRed,
                size: 24,
              )
            : Icon(
                Icons.search_rounded,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                size: 20,
              ),
      ),
    );
  }
}

