import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/theme/app_colors.dart';
import '../providers/suffix_quiz_provider.dart';

/// Interactive quiz drill screen testing mastery of German noun suffix rules.
class SuffixQuizScreen extends ConsumerWidget {
  const SuffixQuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(suffixQuizProvider);

    return Scaffold(
      key: const Key('suffix_quiz_screen'),
      appBar: AppBar(
        title: Text(
          l10n.suffixQuizTitle,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          if (!state.isRoundComplete && state.totalQuestions > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${state.score}/${state.currentIndex + (state.hasAnswered ? 1 : 0)}',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: state.isRoundComplete
            ? _buildRoundComplete(context, ref, state, isDark, l10n)
            : state.currentQuestion == null
                ? const Center(child: CircularProgressIndicator())
                : _buildQuizBody(context, ref, state, isDark, l10n),
      ),
    );
  }

  Widget _buildQuizBody(
    BuildContext context,
    WidgetRef ref,
    SuffixQuizState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final question = state.currentQuestion!;
    final notifier = ref.read(suffixQuizProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Linear progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: state.totalQuestions > 0
                        ? (state.currentIndex + (state.hasAnswered ? 1 : 0)) / state.totalQuestions
                        : 0,
                    minHeight: 6,
                    backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.derBlue),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.questionProgress(state.currentQuestionNumber, state.totalQuestions),
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Question Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E212B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.black12).withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  question.type == SuffixQuestionType.suffixPattern
                      ? l10n.whichArticleSuffix
                      : l10n.whichArticleWord,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.derBlue.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.derBlue.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    question.target,
                    style: question.type == SuffixQuestionType.suffixPattern
                        ? GoogleFonts.firaCode(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.derBlue : const Color(0xFF1D4ED8),
                          )
                        : GoogleFonts.nunito(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                  ),
                ),
                if (question.type == SuffixQuestionType.wordApplication) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Suffix: -${question.rule.suffix}',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 28),

          // 3 Article Buttons (der, die, das)
          Row(
            children: [
              Expanded(
                child: _ArticleQuizButton(
                  key: const Key('suffix_button_der'),
                  article: 'der',
                  color: AppColors.derBlue,
                  isSelected: state.selectedArticle == 'der',
                  isCorrectArticle: question.correctArticle == 'der',
                  hasAnswered: state.hasAnswered,
                  isDark: isDark,
                  onTap: () => notifier.answer('der'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ArticleQuizButton(
                  key: const Key('suffix_button_die'),
                  article: 'die',
                  color: AppColors.dieRed,
                  isSelected: state.selectedArticle == 'die',
                  isCorrectArticle: question.correctArticle == 'die',
                  hasAnswered: state.hasAnswered,
                  isDark: isDark,
                  onTap: () => notifier.answer('die'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ArticleQuizButton(
                  key: const Key('suffix_button_das'),
                  article: 'das',
                  color: AppColors.dasGreen,
                  isSelected: state.selectedArticle == 'das',
                  isCorrectArticle: question.correctArticle == 'das',
                  hasAnswered: state.hasAnswered,
                  isDark: isDark,
                  onTap: () => notifier.answer('das'),
                ),
              ),
            ],
          ),

          // Feedback & Rule Explanation Card
          if (state.hasAnswered) ...[
            const SizedBox(height: 24),
            _buildAnswerFeedback(question, state.isCorrect ?? false, isDark, l10n)
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0, duration: 300.ms),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('suffix_quiz_next_button'),
              onPressed: notifier.nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.derBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                state.currentIndex + 1 >= state.totalQuestions
                    ? l10n.roundComplete
                    : l10n.nextWord,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerFeedback(
    SuffixQuizQuestion question,
    bool isCorrect,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final articleColor = AppColors.colorForArticle(question.correctArticle);

    return Container(
      key: const Key('suffix_quiz_feedback_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
            .withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
              .withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? l10n.correct : l10n.incorrect,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: articleColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${question.correctArticle} ${question.target}',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: articleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question.rule.localizedRule(l10n.languageCode),
            textDirection: l10n.isRtl ? TextDirection.rtl : TextDirection.ltr,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          if (question.rule.exceptions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.exceptionsLabel}: ${question.rule.exceptions.join(', ')}',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoundComplete(
    BuildContext context,
    WidgetRef ref,
    SuffixQuizState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.streakOrange.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 64,
                color: AppColors.streakOrange,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.roundComplete,
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.roundScore(state.score, state.totalQuestions, state.percentAccuracy),
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('suffix_quiz_review_button'),
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l10n.reviewRules,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    key: const Key('suffix_quiz_restart_button'),
                    onPressed: () => ref.read(suffixQuizProvider.notifier).restart(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.derBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.playAgain,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleQuizButton extends StatelessWidget {
  final String article;
  final Color color;
  final bool isSelected;
  final bool isCorrectArticle;
  final bool hasAnswered;
  final bool isDark;
  final VoidCallback onTap;

  const _ArticleQuizButton({
    super.key,
    required this.article,
    required this.color,
    required this.isSelected,
    required this.isCorrectArticle,
    required this.hasAnswered,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    BorderSide borderSide;

    if (!hasAnswered) {
      backgroundColor = color.withValues(alpha: isDark ? 0.15 : 0.08);
      textColor = color;
      borderSide = BorderSide(color: color.withValues(alpha: 0.3), width: 1.5);
    } else if (isCorrectArticle) {
      backgroundColor = color;
      textColor = Colors.white;
      borderSide = BorderSide(color: color, width: 2);
    } else if (isSelected && !isCorrectArticle) {
      backgroundColor = const Color(0xFFEF4444);
      textColor = Colors.white;
      borderSide = const BorderSide(color: Color(0xFFEF4444), width: 2);
    } else {
      backgroundColor = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04);
      textColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
      borderSide = BorderSide(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
        width: 1,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasAnswered ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.fromBorderSide(borderSide),
          ),
          alignment: Alignment.center,
          child: Text(
            article,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
