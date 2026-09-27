import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

/// A small color-coded pill showing an article (der/die/das).
/// Used in the article legend and result cards.
class ArticlePill extends StatelessWidget {
  final String article;
  final bool isActive;
  final double fontSize;
  final VoidCallback? onTap;

  const ArticlePill({
    super.key,
    required this.article,
    this.isActive = false,
    this.fontSize = 14,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.colorForArticle(article);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: fontSize * 1.0,
          vertical: fontSize * 0.4,
        ),
        decoration: BoxDecoration(
          color: isActive ? color : color.withValues(alpha: isDark ? 0.15 : 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          article,
          style: TextStyle(
            color: isActive ? Colors.white : color,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

/// A row of three article pills used as a legend.
class ArticleLegend extends StatelessWidget {
  final String? activeArticle;

  const ArticleLegend({super.key, this.activeArticle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ArticlePill(
          article: 'der',
          isActive: activeArticle == 'der',
        ),
        const SizedBox(width: 12),
        ArticlePill(
          article: 'die',
          isActive: activeArticle == 'die',
        ),
        const SizedBox(width: 12),
        ArticlePill(
          article: 'das',
          isActive: activeArticle == 'das',
        ),
      ],
    );
  }
}

