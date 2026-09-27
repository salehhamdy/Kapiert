import 'package:flutter/material.dart';

/// Color coding system for German articles.
/// Consistent across all screens — result cards, quiz buttons, history indicators.
class AppColors {
  AppColors._();

  // Article colors
  static const Color derBlue = Color(0xFF1A5CAA);
  static const Color dieRed = Color(0xFFC4373A);
  static const Color dasGreen = Color(0xFF2D7A3A);

  // UI colors — Light theme
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1D23);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color dividerLight = Color(0xFFE5E7EB);

  // UI colors — Dark theme
  static const Color backgroundDark = Color(0xFF0F1117);
  static const Color surfaceDark = Color(0xFF1A1D28);
  static const Color textPrimaryDark = Color(0xFFF1F3F5);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color dividerDark = Color(0xFF2D3140);

  // Accent / feedback
  static const Color correctGreen = Color(0xFF22C55E);
  static const Color incorrectRed = Color(0xFFEF4444);
  static const Color streakOrange = Color(0xFFF59E0B);

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1D28), Color(0xFF2D3348)],
  );

  /// Returns the color associated with a given article string.
  static Color colorForArticle(String article) {
    switch (article.toLowerCase()) {
      case 'der':
        return derBlue;
      case 'die':
        return dieRed;
      case 'das':
        return dasGreen;
      default:
        return Colors.grey;
    }
  }

  /// Returns a lighter variant of the article color (for backgrounds).
  static Color colorForArticleLight(String article) {
    return colorForArticle(article).withValues(alpha: 0.12);
  }
}
