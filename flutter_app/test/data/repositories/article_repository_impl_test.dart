import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:derdiedas/data/repositories/article_repository_impl.dart';
import 'package:derdiedas/data/datasources/article_remote_ds.dart';
import 'package:derdiedas/domain/models/word_model.dart';

class MockArticleRemoteDS extends Mock implements ArticleRemoteDS {}

void main() {
  late MockArticleRemoteDS mockRemoteDS;
  late ArticleRepositoryImpl repository;

  setUp(() {
    mockRemoteDS = MockArticleRemoteDS();
    repository = ArticleRepositoryImpl(mockRemoteDS);
  });

  group('ArticleRepositoryImpl', () {
    const tWord = WordModel(
      word: 'Test',
      article: 'der',
      gender: 'm',
      source: 'dataset',
    );

    test('lookup calls remoteDS.lookup and returns WordModel', () async {
      // Arrange
      when(() => mockRemoteDS.lookup(any())).thenAnswer((_) async => tWord);

      // Act
      final result = await repository.lookup('Test');

      // Assert
      expect(result, equals(tWord));
      verify(() => mockRemoteDS.lookup('Test')).called(1);
    });

    test('random calls remoteDS.random and returns WordModel', () async {
      // Arrange
      when(() => mockRemoteDS.random()).thenAnswer((_) async => tWord);

      // Act
      final result = await repository.random();

      // Assert
      expect(result, equals(tWord));
      verify(() => mockRemoteDS.random()).called(1);
    });

    test('randomBatch calls remoteDS.randomBatch and returns list of WordModels', () async {
      // Arrange
      final tWordList = [tWord, tWord];
      when(() => mockRemoteDS.randomBatch(count: any(named: 'count')))
          .thenAnswer((_) async => tWordList);

      // Act
      final result = await repository.randomBatch(count: 2);

      // Assert
      expect(result, equals(tWordList));
      verify(() => mockRemoteDS.randomBatch(count: 2)).called(1);
    });

    test('checkHealth calls remoteDS.checkHealth and returns boolean', () async {
      // Arrange
      when(() => mockRemoteDS.checkHealth()).thenAnswer((_) async => true);

      // Act
      final result = await repository.checkHealth();

      // Assert
      expect(result, isTrue);
      verify(() => mockRemoteDS.checkHealth()).called(1);
    });
  });
}
