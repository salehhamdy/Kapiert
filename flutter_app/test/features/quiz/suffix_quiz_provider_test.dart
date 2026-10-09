import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

import 'package:derdiedas/features/quiz/providers/suffix_quiz_provider.dart';

void main() {
  group('SuffixQuizProvider Unit Tests', () {
    test('initializes with 10 questions and valid state', () {
      final notifier = SuffixQuizNotifier(random: Random(42));
      final state = notifier.state;

      expect(state.questions.length, 10);
      expect(state.currentIndex, 0);
      expect(state.score, 0);
      expect(state.hasAnswered, isFalse);
      expect(state.isRoundComplete, isFalse);
      expect(state.currentQuestion, isNotNull);
      expect(['der', 'die', 'das'].contains(state.currentQuestion!.correctArticle), isTrue);
    });

    test('answer correctly increments score and sets isCorrect = true', () {
      final notifier = SuffixQuizNotifier(random: Random(42));
      final question = notifier.state.currentQuestion!;

      notifier.answer(question.correctArticle);

      expect(notifier.state.hasAnswered, isTrue);
      expect(notifier.state.selectedArticle, question.correctArticle);
      expect(notifier.state.isCorrect, isTrue);
      expect(notifier.state.score, 1);
    });

    test('answer incorrectly does not increment score and sets isCorrect = false', () {
      final notifier = SuffixQuizNotifier(random: Random(42));
      final question = notifier.state.currentQuestion!;
      final wrongArticle = question.correctArticle == 'der' ? 'die' : 'der';

      notifier.answer(wrongArticle);

      expect(notifier.state.hasAnswered, isTrue);
      expect(notifier.state.selectedArticle, wrongArticle);
      expect(notifier.state.isCorrect, isFalse);
      expect(notifier.state.score, 0);
    });

    test('ignoring secondary answer attempts on same question', () {
      final notifier = SuffixQuizNotifier(random: Random(42));
      final question = notifier.state.currentQuestion!;

      notifier.answer(question.correctArticle);
      expect(notifier.state.score, 1);

      // Attempt to answer again with wrong article
      final wrongArticle = question.correctArticle == 'der' ? 'die' : 'der';
      notifier.answer(wrongArticle);
      expect(notifier.state.score, 1);
      expect(notifier.state.selectedArticle, question.correctArticle);
    });

    test('nextQuestion advances to next question and resets answered state', () {
      final notifier = SuffixQuizNotifier(random: Random(42));
      final firstQuestion = notifier.state.currentQuestion!;

      notifier.answer(firstQuestion.correctArticle);
      notifier.nextQuestion();

      expect(notifier.state.currentIndex, 1);
      expect(notifier.state.hasAnswered, isFalse);
      expect(notifier.state.selectedArticle, isNull);
      expect(notifier.state.isCorrect, isNull);
    });

    test('completing all questions sets isRoundComplete = true', () {
      final notifier = SuffixQuizNotifier(random: Random(42));
      notifier.startRound(length: 2);

      // Question 1
      notifier.answer(notifier.state.currentQuestion!.correctArticle);
      notifier.nextQuestion();

      // Question 2
      notifier.answer(notifier.state.currentQuestion!.correctArticle);
      notifier.nextQuestion();

      expect(notifier.state.isRoundComplete, isTrue);
      expect(notifier.state.score, 2);
    });

    test('restart starts a fresh round with reset score and index', () {
      final notifier = SuffixQuizNotifier(random: Random(42));
      notifier.startRound(length: 2);

      notifier.answer(notifier.state.currentQuestion!.correctArticle);
      notifier.nextQuestion();
      notifier.answer(notifier.state.currentQuestion!.correctArticle);
      notifier.nextQuestion();

      expect(notifier.state.isRoundComplete, isTrue);

      notifier.restart();

      expect(notifier.state.isRoundComplete, isFalse);
      expect(notifier.state.currentIndex, 0);
      expect(notifier.state.score, 0);
      expect(notifier.state.hasAnswered, isFalse);
    });
  });
}
