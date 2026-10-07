import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/models/word_model.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../../favorites/providers/favorites_provider.dart';

/// Displays the result of an article lookup with rich formatting and favorites toggle.
class ResultCard extends ConsumerWidget {
  final WordModel word;

  const ResultCard({super.key, required this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppTheme.colorForArticle(word.article);
    final isFavorite = ref.watch(favoritesProvider).isFavorite(word.word);
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.15 : 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top accent bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Column(
                  children: [
                // Article (large)
                Text(
                  word.article,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1.1,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(duration: 300.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 4),

                // Word
                Text(
                  word.word,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                const SizedBox(height: 16),

                // Gender + Plural row
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.person_outline_rounded,
                      label: l10n.genderLabel(word.gender),
                      color: color,
                      isDark: isDark,
                    ),
                    if (word.plural != null && word.plural!.isNotEmpty)
                      _InfoChip(
                        icon: Icons.group_outlined,
                        label: 'pl. ${word.plural}',
                        color: color,
                        isDark: isDark,
                      ),
                  ],
                ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                // Translation
                if (word.translation != null && word.translation!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.10 : 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          size: 18,
                          color: color.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            word.translation!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
                ],

                // Example sentence
                _ExampleSentenceView(
                  word: word,
                  color: color,
                  isDark: isDark,
                  l10n: l10n,
                ).animate().fadeIn(delay: 350.ms, duration: 300.ms),

                const SizedBox(height: 16),

                // Source badge
                _SourceBadge(
                  label: l10n.sourceLabel(word.source),
                  isDark: isDark,
                ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
              ],
            ),
          ),
        ],
      ),

      // Star in the upper right corner
      Positioned(
        top: 10,
        right: 12,
        child: Material(
          color: Colors.transparent,
          child: IconButton(
            key: const Key('favorite_star_button'),
            iconSize: 26,
            splashRadius: 22,
            tooltip: isFavorite
                ? l10n.removeFromFavorites
                : l10n.saveToFavorites,
            onPressed: () async {
              final added = await ref
                  .read(favoritesProvider.notifier)
                  .toggleFavorite(word);
              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          added
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFFFB800),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            added
                                ? '${word.fullForm} ${l10n.savedToFavorites}'
                                : '${word.fullForm} ${l10n.removedFromFavorites}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                key: ValueKey<bool>(isFavorite),
                color: isFavorite
                    ? const Color(0xFFFFB800)
                    : (isDark
                        ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
                        : AppColors.textSecondaryLight.withValues(alpha: 0.6)),
                size: 28,
              ),
            ),
          ),
        ),
      ),
    ],
  ),
).animate().fadeIn(duration: 400.ms).slideY(
      begin: 0.05,
      end: 0,
      duration: 400.ms,
      curve: Curves.easeOut,
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
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

class _SourceBadge extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SourceBadge({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark
              ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
              : AppColors.textSecondaryLight.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _ExampleSentenceView extends StatelessWidget {
  final WordModel word;
  final Color color;
  final bool isDark;
  final AppLocalizations l10n;

  const _ExampleSentenceView({
    required this.word,
    required this.color,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final example = word.resolvedExampleSentence;
    if (example.sentence.isEmpty) return const SizedBox.shrink();

    final localizedTranslation = example.translationFor(l10n.languageCode);

    return Container(
      key: const Key('example_sentence_card'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.22 : 0.18),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.format_quote_rounded,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.exampleSentenceHeader,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: color,
                  ),
                ),
              ),
              IconButton(
                key: const Key('copy_sentence_button'),
                iconSize: 18,
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: l10n.copySentence,
                icon: Icon(
                  Icons.content_copy_rounded,
                  size: 16,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: example.sentence));
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.correctGreen,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.sentenceCopied,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          // German sentence
          Text(
            example.sentence,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          // Translated sentence (in active locale)
          Text(
            localizedTranslation,
            textDirection: l10n.isRtl ? TextDirection.rtl : TextDirection.ltr,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              height: 1.3,
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


