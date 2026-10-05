import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                      label: word.genderLabel,
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

                const SizedBox(height: 16),

                // Source badge
                _SourceBadge(
                  label: word.sourceLabel,
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
            iconSize: 26,
            splashRadius: 22,
            tooltip: isFavorite
                ? 'Remove from Favorites'
                : 'Save to Favorites for focused review',
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
                                ? '${word.fullForm} saved to Favorites'
                                : '${word.fullForm} removed from Favorites',
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


