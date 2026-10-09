import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/grammar_rule_hint.dart';

enum SuffixQuestionType {
  suffixPattern,
  wordApplication,
}

class SuffixQuizQuestion {
  final GrammarRuleHint rule;
  final SuffixQuestionType type;
  final String target;
  final String correctArticle;
  final String? exampleWord;

  const SuffixQuizQuestion({
    required this.rule,
    required this.type,
    required this.target,
    required this.correctArticle,
    this.exampleWord,
  });
}

class SuffixQuizState {
  final List<SuffixQuizQuestion> questions;
  final int currentIndex;
  final int score;
  final String? selectedArticle;
  final bool? isCorrect;
  final bool isRoundComplete;
  final int roundLength;

  const SuffixQuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.score = 0,
    this.selectedArticle,
    this.isCorrect,
    this.isRoundComplete = false,
    this.roundLength = 10,
  });

  SuffixQuizQuestion? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get hasAnswered => selectedArticle != null;
  int get currentQuestionNumber => currentIndex + 1;
  int get totalQuestions => questions.length;
  double get progress => totalQuestions > 0 ? currentIndex / totalQuestions : 0.0;
  int get percentAccuracy => totalQuestions > 0 ? ((score / totalQuestions) * 100).round() : 0;

  SuffixQuizState copyWith({
    List<SuffixQuizQuestion>? questions,
    int? currentIndex,
    int? score,
    String? selectedArticle,
    bool? isCorrect,
    bool? isRoundComplete,
    int? roundLength,
    bool clearAnswer = false,
  }) {
    return SuffixQuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      selectedArticle: clearAnswer ? null : (selectedArticle ?? this.selectedArticle),
      isCorrect: clearAnswer ? null : (isCorrect ?? this.isCorrect),
      isRoundComplete: isRoundComplete ?? this.isRoundComplete,
      roundLength: roundLength ?? this.roundLength,
    );
  }
}

class SuffixQuizNotifier extends StateNotifier<SuffixQuizState> {
  final Random _rng;

  SuffixQuizNotifier({Random? random})
      : _rng = random ?? Random(),
        super(const SuffixQuizState()) {
    startRound();
  }

  void startRound({int length = 10}) {
    final allRules = List<GrammarRuleHint>.from(GrammarRuleHint.allRules);
    allRules.shuffle(_rng);

    final questions = <SuffixQuizQuestion>[];
    final selectedRules = allRules.take(min(length, allRules.length)).toList();

    for (var i = 0; i < selectedRules.length; i++) {
      final rule = selectedRules[i];
      // Alternate question type or choose based on whether examples exist
      final isWordApplication = (i % 2 == 1) && rule.examples.isNotEmpty;

      if (isWordApplication) {
        final example = rule.examples[_rng.nextInt(rule.examples.length)];
        questions.add(
          SuffixQuizQuestion(
            rule: rule,
            type: SuffixQuestionType.wordApplication,
            target: example,
            correctArticle: rule.article,
            exampleWord: example,
          ),
        );
      } else {
        questions.add(
          SuffixQuizQuestion(
            rule: rule,
            type: SuffixQuestionType.suffixPattern,
            target: '-${rule.suffix}',
            correctArticle: rule.article,
            exampleWord: rule.examples.isNotEmpty ? rule.examples.first : null,
          ),
        );
      }
    }

    state = SuffixQuizState(
      questions: questions,
      currentIndex: 0,
      score: 0,
      roundLength: questions.length,
      isRoundComplete: false,
    );
  }

  void answer(String article) {
    if (state.hasAnswered || state.isRoundComplete || state.currentQuestion == null) {
      return;
    }

    final question = state.currentQuestion!;
    final isCorrect = article.trim().toLowerCase() == question.correctArticle.toLowerCase();
    final newScore = isCorrect ? state.score + 1 : state.score;

    state = state.copyWith(
      selectedArticle: article,
      isCorrect: isCorrect,
      score: newScore,
    );
  }

  void nextQuestion() {
    if (!state.hasAnswered || state.isRoundComplete) return;

    if (state.currentIndex + 1 >= state.questions.length) {
      state = state.copyWith(isRoundComplete: true);
    } else {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        clearAnswer: true,
      );
    }
  }

  void restart() {
    startRound(length: state.roundLength);
  }
}

final suffixQuizProvider =
    StateNotifierProvider.autoDispose<SuffixQuizNotifier, SuffixQuizState>(
  (ref) => SuffixQuizNotifier(),
);
