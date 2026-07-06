import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';
import '../models/lookup_history.dart';
import '../services/storage_service.dart';
import '../widgets/history_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<LookupHistory> _entries = [];
  Map<String, dynamic> _stats = {};
  String _filter = 'all'; // 'all' | 'correct' | 'incorrect'
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final filterArg = _filter == 'all' ? null : _filter;
    final entries = await StorageService.getHistory(filter: filterArg);
    final stats = await StorageService.getStats();

    setState(() {
      _entries = entries;
      _stats = stats;
      _loading = false;
    });
  }

  void _setFilter(String filter) {
    if (_filter == filter) return;
    _filter = filter;
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Text(
            'History',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          // ── Stats Cards ──
          _buildStatsRow(isDark),
          const SizedBox(height: 20),

          // ── Filter Chips ──
          _buildFilters(isDark),
          const SizedBox(height: 16),

          // ── List ──
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? _buildEmptyState(isDark)
                    : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    final total = _stats['total'] ?? 0;
    final totalQuiz = _stats['totalQuiz'] ?? 0;
    final accuracy = (_stats['accuracy'] ?? 0.0) as double;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.history_rounded,
            label: 'Total',
            value: '$total',
            color: AppColors.derBlue,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.quiz_rounded,
            label: 'Quiz',
            value: '$totalQuiz',
            color: AppColors.dasGreen,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.percent_rounded,
            label: 'Accuracy',
            value: '${accuracy.toStringAsFixed(0)}%',
            color: accuracy >= 70
                ? AppColors.correctGreen
                : accuracy >= 40
                    ? AppColors.streakOrange
                    : AppColors.incorrectRed,
            isDark: isDark,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildFilters(bool isDark) {
    return Row(
      children: [
        _FilterChip(
          label: 'All',
          isActive: _filter == 'all',
          onTap: () => _setFilter('all'),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: '✓ Correct',
          isActive: _filter == 'correct',
          onTap: () => _setFilter('correct'),
          isDark: isDark,
          activeColor: AppColors.correctGreen,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: '✗ Incorrect',
          isActive: _filter == 'incorrect',
          onTap: () => _setFilter('incorrect'),
          isDark: isDark,
          activeColor: AppColors.incorrectRed,
        ),
      ],
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _entries.length,
        padding: const EdgeInsets.only(bottom: 40),
        itemBuilder: (context, index) {
          return HistoryTile(entry: _entries[index])
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: (index * 30).clamp(0, 300)),
                duration: 300.ms,
              )
              .slideX(
                begin: 0.05,
                end: 0,
                delay: Duration(milliseconds: (index * 30).clamp(0, 300)),
                duration: 300.ms,
              );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 56,
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12),
          ),
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Look up words or take quizzes\nto see your history here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight)
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;
  final Color? activeColor;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isDark,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.derBlue;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: isDark ? 0.18 : 0.10)
              : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? color.withValues(alpha: 0.4)
                : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive
                ? color
                : isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
