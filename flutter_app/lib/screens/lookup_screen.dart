import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';
import '../models/lookup_history.dart';
import '../models/word_model.dart';
import '../services/article_service.dart';
import '../services/storage_service.dart';
import '../widgets/article_pill.dart';
import '../widgets/result_card.dart';

class LookupScreen extends StatefulWidget {
  const LookupScreen({super.key});

  @override
  State<LookupScreen> createState() => _LookupScreenState();
}

class _LookupScreenState extends State<LookupScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _service = ArticleService.forPlatform();

  bool _loading = false;
  WordModel? _result;
  String? _error;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _streak = StorageService.getStreak();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final word = _controller.text.trim();
    if (word.isEmpty) return;

    _focusNode.unfocus();
    setState(() {
      _loading = true;
      _result = null;
      _error = null;
    });

    final result = await _service.lookupWord(word);

    // Update streak on any successful activity
    await StorageService.updateStreak();

    setState(() {
      _loading = false;
      _streak = StorageService.getStreak();

      switch (result) {
        case LookupSuccess(:final word):
          _result = word;
          // Log to history
          StorageService.addHistory(LookupHistory(
            timestamp: DateTime.now(),
            word: word.word,
            article: word.article,
            correct: true,
            mode: 'lookup',
          ));
        case LookupNotFound(:final query):
          _error = '"$query" was not found.';
        case LookupError(:final message):
          _error = message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(isDark),
            const SizedBox(height: 24),

            // ── Article Legend ──
            ArticleLegend(activeArticle: _result?.article)
                .animate()
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 28),

            // ── Search Input ──
            _buildSearchField(isDark),
            const SizedBox(height: 16),

            // ── Check Button ──
            _buildCheckButton(isDark),
            const SizedBox(height: 28),

            // ── Result / Error / Loading ──
            if (_loading) _buildLoading(),
            if (_error != null) _buildError(isDark),
            if (_result != null) ResultCard(word: _result!),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Wordmark logo ───────────────────────────────────────────────────
        Expanded(
          child: Image.asset(
            'assets/images/wordmark.png',
            height: 52,
            alignment: Alignment.centerLeft,
            fit: BoxFit.contain,
          ),
        ),
        // ── Streak badge ────────────────────────────────────────────────────
        if (_streak > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.streakOrange.withValues(alpha: 0.15),
                  AppColors.streakOrange.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.streakOrange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '$_streak',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.streakOrange,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideX(
                begin: 0.2,
                end: 0,
                duration: 400.ms,
                curve: Curves.easeOut,
              ),
      ],
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        decoration: InputDecoration(
          hintText: 'Enter a German noun',
          hintStyle: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
                : AppColors.textSecondaryLight.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _result = null;
                      _error = null;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _lookup(),
      ),
    );
  }

  Widget _buildCheckButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _loading ? null : _lookup,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? const Color(0xFF3B82F6)
              : const Color(0xFF1A5CAA),
          foregroundColor: Colors.white,
          disabledBackgroundColor: (isDark ? Colors.white : Colors.black)
              .withValues(alpha: 0.08),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Check Article',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF3B82F6)
                  : AppColors.derBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Looking up…',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.incorrectRed.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.incorrectRed.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.incorrectRed.withValues(alpha: 0.8),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).shake(
          hz: 2,
          offset: const Offset(4, 0),
          duration: 300.ms,
        );
  }
}
