import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../providers/quiz_providers.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(quizProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        children: [
          // ── Header + Score ──
          _buildHeader(isDark, state),
          const SizedBox(height: 12),

          // ── Progress bar ──
          if (state.total > 0) _buildProgressBar(isDark, state),
          const SizedBox(height: 32),

          // ── Word Display ──
          Expanded(
            child: state.loading
                ? _buildLoading(isDark)
                : state.currentWord == null
                    ? _buildError(isDark, ref)
                    : _buildQuizContent(isDark, state, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, QuizState state) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Mode',
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
              'Tap the correct article',
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 1),

        Text(
          word.word,
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ).animate(key: ValueKey(word.word))
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms),

        const SizedBox(height: 40),

        Row(
          children: [
            _buildArticleButton('der', isDark, state, ref),
            const SizedBox(width: 12),
            _buildArticleButton('die', isDark, state, ref),
            const SizedBox(width: 12),
            _buildArticleButton('das', isDark, state, ref),
          ],
        ),

        const SizedBox(height: 28),

        if (state.hasAnswered) _buildFeedback(isDark, state),

        const Spacer(flex: 2),

        if (state.hasAnswered) _buildNextButton(isDark, ref),
      ],
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
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildNextButton(bool isDark, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
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
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
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
