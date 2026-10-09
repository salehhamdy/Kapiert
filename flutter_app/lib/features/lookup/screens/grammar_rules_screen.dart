import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../domain/models/grammar_rule_hint.dart';
import '../../../shared/router/app_router.dart';
import '../../../shared/theme/app_colors.dart';
import '../providers/lookup_provider.dart';

/// Screen displaying all German article grammar suffix patterns,
/// reliability scores, examples, and exceptions with search and filtering.
class GrammarRulesScreen extends ConsumerStatefulWidget {
  const GrammarRulesScreen({super.key});

  @override
  ConsumerState<GrammarRulesScreen> createState() => _GrammarRulesScreenState();
}

class _GrammarRulesScreenState extends ConsumerState<GrammarRulesScreen> {
  final _searchController = TextEditingController();
  String _selectedArticle = 'all'; // 'all' | 'der' | 'die' | 'das'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final text = _searchController.text.trim().toLowerCase();
      if (text != _searchQuery) {
        setState(() {
          _searchQuery = text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GrammarRuleHint> _filterRules(List<GrammarRuleHint> rules, String langCode) {
    return rules.where((rule) {
      if (_selectedArticle != 'all' && rule.article != _selectedArticle) {
        return false;
      }
      if (_searchQuery.isEmpty) return true;

      final query = _searchQuery.replaceAll('-', '');
      final suffixMatch = rule.suffix.toLowerCase().contains(query);
      final articleMatch = rule.article.toLowerCase().contains(query);
      final localizedMatch = rule.localizedRule(langCode).toLowerCase().contains(query);
      final englishMatch = rule.ruleEn.toLowerCase().contains(query);
      final examplesMatch = rule.examples.any((e) => e.toLowerCase().contains(query));
      final exceptionsMatch = rule.exceptions.any((e) => e.toLowerCase().contains(query));

      return suffixMatch ||
          articleMatch ||
          localizedMatch ||
          englishMatch ||
          examplesMatch ||
          exceptionsMatch;
    }).toList();
  }

  void _onExampleTap(String example) {
    // Strip parenthetical text if any (e.g., "das Stadion" -> "Stadion")
    final cleanWord = example.split(' ').last;
    ref.read(lookupProvider.notifier).lookup(cleanWord);
    ref.read(mainTabProvider.notifier).state = 0;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allRules = GrammarRuleHint.allRules;
    final filteredRules = _filterRules(allRules, l10n.languageCode);

    final derCount = allRules.where((r) => r.article == 'der').length;
    final dieCount = allRules.where((r) => r.article == 'die').length;
    final dasCount = allRules.where((r) => r.article == 'das').length;

    return Scaffold(
      key: const Key('grammar_rules_screen'),
      appBar: AppBar(
        title: Text(
          l10n.grammarRulesTitle,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            key: const Key('grammar_rules_quiz_action'),
            icon: const Icon(Icons.school_rounded, color: AppColors.derBlue),
            tooltip: l10n.startSuffixQuiz,
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.suffixQuiz),
          ),
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
                  '${filteredRules.length}/${allRules.length}',
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
        child: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: TextField(
                key: const Key('grammar_rules_search_field'),
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchRulesHint,
                  hintStyle: GoogleFonts.nunito(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          key: const Key('grammar_rules_clear_search_button'),
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E212B)
                      : const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Suffix Quiz Practice Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: InkWell(
                key: const Key('grammar_rules_practice_banner'),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.suffixQuiz),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.derBlue.withValues(alpha: isDark ? 0.20 : 0.12),
                        AppColors.derBlue.withValues(alpha: isDark ? 0.10 : 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.derBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.derBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.psychology_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.startSuffixQuiz,
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                              ),
                            ),
                            Text(
                              l10n.suffixQuizSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: AppColors.derBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Filter Tabs (All, der, die, das)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _FilterChip(
                    key: const Key('filter_all'),
                    label: '${l10n.allRulesTab} (${allRules.length})',
                    isSelected: _selectedArticle == 'all',
                    color: isDark ? AppColors.derBlue : const Color(0xFF2563EB),
                    isDark: isDark,
                    onTap: () => setState(() => _selectedArticle = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    key: const Key('filter_der'),
                    label: 'der ($derCount)',
                    isSelected: _selectedArticle == 'der',
                    color: AppColors.derBlue,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedArticle = 'der'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    key: const Key('filter_die'),
                    label: 'die ($dieCount)',
                    isSelected: _selectedArticle == 'die',
                    color: AppColors.dieRed,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedArticle = 'die'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    key: const Key('filter_das'),
                    label: 'das ($dasCount)',
                    isSelected: _selectedArticle == 'das',
                    color: AppColors.dasGreen,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedArticle = 'das'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Rule List
            Expanded(
              child: filteredRules.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 56,
                              color: isDark
                                  ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                                  : AppColors.textSecondaryLight.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noRulesFound,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: filteredRules.length,
                      itemBuilder: (context, index) {
                        final rule = filteredRules[index];
                        return _RuleCard(
                          key: Key('rule_card_${rule.article}_${rule.suffix}'),
                          rule: rule,
                          isDark: isDark,
                          l10n: l10n,
                          onExampleTap: _onExampleTap,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color
                : color.withValues(alpha: isDark ? 0.25 : 0.20),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final GrammarRuleHint rule;
  final bool isDark;
  final AppLocalizations l10n;
  final ValueChanged<String> onExampleTap;

  const _RuleCard({
    super.key,
    required this.rule,
    required this.isDark,
    required this.l10n,
    required this.onExampleTap,
  });

  @override
  Widget build(BuildContext context) {
    final articleColor = AppColors.colorForArticle(rule.article);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E212B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: articleColor.withValues(alpha: isDark ? 0.25 : 0.20),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black12).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Suffix chip + Article pill + Reliability badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: articleColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-${rule.suffix}',
                    style: GoogleFonts.firaCode(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: articleColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: articleColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rule.article,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (rule.reliabilityPercent == 100
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        rule.reliabilityPercent == 100
                            ? Icons.verified_rounded
                            : Icons.auto_awesome_rounded,
                        size: 13,
                        color: rule.reliabilityPercent == 100
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${rule.reliabilityPercent}% ${l10n.reliabilityLabel}',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: rule.reliabilityPercent == 100
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Localized Explanation
            Text(
              rule.localizedRule(l10n.languageCode),
              textDirection: l10n.isRtl ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),

            // Examples
            if (rule.examples.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.format_list_bulleted_rounded,
                    size: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${l10n.examplesLabel} (${l10n.tapExampleToLookup}):',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: rule.examples.map((example) {
                  return ActionChip(
                    key: Key('example_chip_$example'),
                    label: Text(
                      example,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: articleColor,
                      ),
                    ),
                    backgroundColor: articleColor.withValues(alpha: isDark ? 0.12 : 0.08),
                    side: BorderSide(
                      color: articleColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => onExampleTap(example),
                  );
                }).toList(),
              ),
            ],

            // Exceptions (if any)
            if (rule.exceptions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${l10n.exceptionsLabel}: ${rule.exceptions.join(', ')}',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
