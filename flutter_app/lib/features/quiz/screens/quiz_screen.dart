import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/achievement.dart';
import '../../../domain/models/srs_item.dart';
import '../../../shared/theme/app_colors.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../srs/providers/srs_provider.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(quizProvider);
    final favState = ref.watch(favoritesProvider);
    final srsState = ref.watch(srsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        children: [
          // ── Header + Score ──
          _buildHeader(isDark, state, ref, favState, srsState),
          const SizedBox(height: 12),

          // ── Progress bar ──
          if (state.total > 0 && !state.isSessionComplete)
            _buildProgressBar(isDark, state),
          const SizedBox(height: 32),

          // ── Word Display ──
          Expanded(
            child: state.loading
                ? _buildLoading(isDark)
                : state.isSessionComplete
                    ? _buildSessionComplete(isDark, ref)
                    : state.currentWord == null
                        ? _buildError(isDark, ref)
                        : _buildQuizContent(isDark, state, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    bool isDark,
    QuizState state,
    WidgetRef ref,
    FavoritesState favState,
    SrsState srsState,
  ) {
    final isFavMode = state.isFavoritesMode;
    final isSrsMode = state.isSrsMode;

    return Column(
      children: [
        if (isSrsMode) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.derBlue
                  .withValues(alpha: isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.derBlue.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.derBlue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Spaced Repetition Review',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.derBlue,
                    ),
                  ),
                ),
                GestureDetector(
                  key: const Key('quiz_exit_srs'),
                  onTap: () =>
                      ref.read(quizProvider.notifier).exitSrsReview(),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Exit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (isFavMode) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB800)
                  .withValues(alpha: isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFB800).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFFB800), size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Focused Review Mode',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFB800),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      ref.read(quizProvider.notifier).exitFavoritesReview(),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Exit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSrsMode
                      ? 'SRS Review'
                      : isFavMode
                          ? 'Focused Quiz'
                          : 'Quiz Mode',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isSrsMode
                      ? 'Practicing scheduled due words'
                      : isFavMode
                          ? 'Reviewing saved favorites'
                          : 'Tap the correct article',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (!isFavMode && !isSrsMode && srsState.dueCount > 0) ...[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  key: const Key('quiz_srs_due_chip'),
                  avatar: const Icon(
                    Icons.psychology_rounded,
                    color: AppColors.derBlue,
                    size: 16,
                  ),
                  label: Text('Due (${srsState.dueCount})'),
                  backgroundColor: AppColors.derBlue
                      .withValues(alpha: isDark ? 0.15 : 0.10),
                  side: BorderSide(
                    color: AppColors.derBlue.withValues(alpha: 0.3),
                  ),
                  onPressed: () {
                    ref
                        .read(quizProvider.notifier)
                        .startSrsReview(srsState.dueItems);
                  },
                ),
              ),
            ],
            if (!isFavMode && !isSrsMode && favState.favorites.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  avatar: const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFB800),
                    size: 16,
                  ),
                  label: Text('Review (${favState.favorites.length})'),
                  backgroundColor: const Color(0xFFFFB800)
                      .withValues(alpha: isDark ? 0.15 : 0.10),
                  side: BorderSide(
                    color: const Color(0xFFFFB800).withValues(alpha: 0.3),
                  ),
                  onPressed: () {
                    ref
                        .read(quizProvider.notifier)
                        .startFavoritesReview(favState.favorites);
                  },
                ),
              ),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(
                    '${state.score}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.correctGreen,
                    ),
                  ),
                  Text(
                    ' / ${state.total}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(bool isDark, QuizState state) {
    final accuracy = state.accuracy;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: accuracy,
            minHeight: 6,
            backgroundColor:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation<Color>(
              accuracy >= 0.7
                  ? AppColors.correctGreen
                  : accuracy >= 0.4
                      ? AppColors.streakOrange
                      : AppColors.incorrectRed,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(accuracy * 100).toInt()}% accuracy',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizContent(bool isDark, QuizState state, WidgetRef ref) {
    final word = state.currentWord!;
    final isFav = ref.watch(favoritesProvider).isFavorite(word.word);
    final srs = state.currentSrsItem;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),

                  if (srs != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (srs.isMastered
                                ? const Color(0xFFFFB800)
                                : AppColors.derBlue)
                            .withValues(alpha: isDark ? 0.14 : 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            srs.isMastered
                                ? Icons.workspace_premium_rounded
                                : Icons.psychology_rounded,
                            size: 14,
                            color: srs.isMastered
                                ? const Color(0xFFFFB800)
                                : AppColors.derBlue,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Stage ${srs.stage} • ${srs.stageName}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: srs.isMastered
                                  ? const Color(0xFFFFB800)
                                  : AppColors.derBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        word.word,
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        iconSize: 26,
                        splashRadius: 20,
                        tooltip: isFav ? 'Favorited' : 'Save for focused review',
                        onPressed: () {
                          ref.read(favoritesProvider.notifier).toggleFavorite(word);
                        },
                        icon: Icon(
                          isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: isFav
                              ? const Color(0xFFFFB800)
                              : (isDark
                                  ? AppColors.textSecondaryDark.withValues(alpha: 0.4)
                                  : AppColors.textSecondaryLight.withValues(alpha: 0.4)),
                        ),
                      ),
                    ],
                  ).animate(key: ValueKey(word.word))
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.1, end: 0, duration: 300.ms),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      _buildArticleButton('der', isDark, state, ref),
                      const SizedBox(width: 12),
                      _buildArticleButton('die', isDark, state, ref),
                      const SizedBox(width: 12),
                      _buildArticleButton('das', isDark, state, ref),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (state.hasAnswered) _buildFeedback(isDark, state),

                  const Spacer(flex: 2),

                  if (state.hasAnswered) ...[
                    const SizedBox(height: 16),
                    _buildNextButton(isDark, ref),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArticleButton(
      String article, bool isDark, QuizState state, WidgetRef ref) {
    final color = AppColors.colorForArticle(article);
    final isSelected = state.selectedArticle == article;
    final isCorrectAnswer = state.currentWord?.article == article;
    final hasAnswered = state.hasAnswered;

    Color bgColor, borderColor, textColor;

    if (!hasAnswered) {
      bgColor = color.withValues(alpha: isDark ? 0.12 : 0.08);
      borderColor = color.withValues(alpha: 0.25);
      textColor = color;
    } else if (isCorrectAnswer) {
      bgColor = AppColors.correctGreen.withValues(alpha: 0.15);
      borderColor = AppColors.correctGreen;
      textColor = AppColors.correctGreen;
    } else if (isSelected && !(state.isCorrect!)) {
      bgColor = AppColors.incorrectRed.withValues(alpha: 0.12);
      borderColor = AppColors.incorrectRed;
      textColor = AppColors.incorrectRed;
    } else {
      bgColor =
          (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03);
      borderColor =
          (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06);
      textColor =
          (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2);
    }

    return Expanded(
      child: GestureDetector(
        key: Key('quiz_button_$article'),
        onTap: () => ref.read(quizProvider.notifier).answer(article),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 80,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                article,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              if (hasAnswered && isCorrectAnswer)
                const Icon(Icons.check_rounded,
                    color: AppColors.correctGreen, size: 20)
              else if (hasAnswered && isSelected && !(state.isCorrect!))
                const Icon(Icons.close_rounded,
                    color: AppColors.incorrectRed, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback(bool isDark, QuizState state) {
    final word = state.currentWord!;
    final feedbackColor =
        state.isCorrect! ? AppColors.correctGreen : AppColors.incorrectRed;
    final srs = state.currentSrsItem;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: feedbackColor.withValues(alpha: isDark ? 0.10 : 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: feedbackColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                state.isCorrect!
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: feedbackColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                state.isCorrect! ? 'Correct!' : 'Incorrect',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: feedbackColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${word.fullForm} — ${word.genderLabel}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          if (word.translation != null && word.translation!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '= ${word.translation}',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
          if (srs != null) ...[
            const SizedBox(height: 10),
            _buildSrsFeedbackBadge(isDark, srs, state.isCorrect!),
          ],
          if (state.unlockedMilestone != null) ...[
            const SizedBox(height: 10),
            _buildMilestoneFeedbackBadge(isDark, state.unlockedMilestone!),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildMilestoneFeedbackBadge(bool isDark, Achievement milestone) {
    const goldColor = Color(0xFFFFB800);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: goldColor.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: goldColor.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: goldColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '🏆 Milestone Unlocked: ${milestone.title}!',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: goldColor,
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 250.ms,
        );
  }

  Widget _buildSrsFeedbackBadge(bool isDark, SrsItem item, bool isCorrect) {
    String intervalText;
    switch (item.stage) {
      case 1:
        intervalText = isCorrect ? '4 hours' : '4 hours (review soon)';
        break;
      case 2:
        intervalText = '1 day';
        break;
      case 3:
        intervalText = '3 days';
        break;
      case 4:
        intervalText = '7 days';
        break;
      case 5:
      default:
        intervalText = '14 days';
        break;
    }

    final badgeColor = isCorrect
        ? (item.isMastered ? const Color(0xFFFFB800) : AppColors.derBlue)
        : AppColors.incorrectRed;

    return Container(
      key: const Key('quiz_srs_feedback_badge'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: isDark ? 0.16 : 0.09),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.isMastered
                ? Icons.workspace_premium_rounded
                : Icons.psychology_rounded,
            size: 15,
            color: badgeColor,
          ),
          const SizedBox(width: 6),
          Text(
            item.isMastered
                ? 'Mastered! • Review in $intervalText'
                : 'Stage ${item.stage} (${item.stageName}) • Next review: $intervalText',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(bool isDark, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        key: const Key('quiz_next_button'),
        onPressed: () => ref.read(quizProvider.notifier).loadNext(),
        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
        label: const Text(
          'Next Word',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? const Color(0xFF3B82F6) : const Color(0xFF1A5CAA),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildSessionComplete(bool isDark, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.correctGreen
                    .withValues(alpha: isDark ? 0.18 : 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_rounded,
                size: 52,
                color: AppColors.correctGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'All Due Reviews Caught Up!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You have reviewed all scheduled nouns for now. Keep practicing in general quiz mode to discover and track new words!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              key: const Key('quiz_complete_continue'),
              onPressed: () =>
                  ref.read(quizProvider.notifier).exitSrsReview(),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Back to General Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? const Color(0xFF3B82F6) : AppColors.derBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: isDark ? const Color(0xFF3B82F6) : AppColors.derBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading word…',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(bool isDark, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Could not load a word.\nIs the backend running?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => ref.read(quizProvider.notifier).loadNext(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
