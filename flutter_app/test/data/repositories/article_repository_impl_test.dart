import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:derdiedas/data/repositories/article_repository_impl.dart';
import 'package:derdiedas/data/datasources/article_local_ds.dart';
import 'package:derdiedas/data/datasources/article_remote_ds.dart';
import 'package:derdiedas/domain/models/word_model.dart';

class MockArticleRemoteDS extends Mock implements ArticleRemoteDS {}
class MockArticleLocalDS extends Mock implements ArticleLocalDS {}

void main() {
  late MockArticleRemoteDS mockRemoteDS;
  late MockArticleLocalDS mockLocalDS;
  late ArticleRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const WordModel(
      word: 'Fallback',
      article: 'der',
      gender: 'm',
      source: 'offline',
    ));
  });

  setUp(() {
    mockRemoteDS = MockArticleRemoteDS();
    mockLocalDS = MockArticleLocalDS();
    repository = ArticleRepositoryImpl(mockRemoteDS, mockLocalDS);
  });

  group('ArticleRepositoryImpl', () {
    const tWord = WordModel(
      word: 'Test',
      article: 'der',
      gender: 'm',
      source: 'dataset',
    );

    const tCachedWord = WordModel(
      word: 'Test',
      article: 'der',
      gender: 'm',
      source: 'offline_cache',
    );

    test('lookup calls remoteDS.lookup, caches word, and returns WordModel', () async {
      // Arrange
      when(() => mockRemoteDS.lookup(any())).thenAnswer((_) async => tWord);
      when(() => mockLocalDS.cacheWord(any())).thenAnswer((_) async {});

      // Act
      final result = await repository.lookup('Test');

      // Assert
      expect(result, equals(tWord));
      verify(() => mockRemoteDS.lookup('Test')).called(1);
      verify(() => mockLocalDS.cacheWord(tWord)).called(1);
    });

    test('lookup falls back to localDS when remote fails and returns cached WordModel', () async {
      // Arrange
      when(() => mockRemoteDS.lookup(any()))
          .thenThrow(Exception('No internet connection'));
      when(() => mockLocalDS.lookup(any())).thenAnswer((_) async => tCachedWord);

      // Act
      final result = await repository.lookup('Test');

      // Assert
      expect(result, equals(tCachedWord));
      verify(() => mockRemoteDS.lookup('Test')).called(1);
      verify(() => mockLocalDS.lookup('Test')).called(1);
    });

    test('lookup rethrows when remote fails and word not in local cache', () async {
      // Arrange
      when(() => mockRemoteDS.lookup(any()))
          .thenThrow(Exception('Server unreachable'));
      when(() => mockLocalDS.lookup(any())).thenAnswer((_) async => null);

      // Act & Assert
      expect(() => repository.lookup('Test'), throwsException);
    });

    test('random calls remoteDS.random and caches word on success', () async {
      // Arrange
      when(() => mockRemoteDS.random()).thenAnswer((_) async => tWord);
      when(() => mockLocalDS.cacheWord(any())).thenAnswer((_) async {});

      // Act
      final result = await repository.random();

      // Assert
      expect(result, equals(tWord));
      verify(() => mockRemoteDS.random()).called(1);
      verify(() => mockLocalDS.cacheWord(tWord)).called(1);
    });

    test('random falls back to localDS on remote network failure', () async {
      // Arrange
      when(() => mockRemoteDS.random()).thenThrow(Exception('Network timeout'));
      when(() => mockLocalDS.getRandomWord()).thenAnswer((_) async => tCachedWord);

      // Act
      final result = await repository.random();

      // Assert
      expect(result, equals(tCachedWord));
      verify(() => mockLocalDS.getRandomWord()).called(1);
    });

    test('randomBatch calls remoteDS.randomBatch and caches words on success', () async {
      // Arrange
      final tWordList = [tWord, tWord];
      when(() => mockRemoteDS.randomBatch(count: any(named: 'count')))
          .thenAnswer((_) async => tWordList);
      when(() => mockLocalDS.cacheWords(any())).thenAnswer((_) async {});

      // Act
      final result = await repository.randomBatch(count: 2);

      // Assert
      expect(result, equals(tWordList));
      verify(() => mockRemoteDS.randomBatch(count: 2)).called(1);
      verify(() => mockLocalDS.cacheWords(tWordList)).called(1);
    });

    test('randomBatch falls back to localDS when remote fails', () async {
      // Arrange
      final tCachedList = [tCachedWord];
      when(() => mockRemoteDS.randomBatch(count: any(named: 'count')))
          .thenThrow(Exception('Network offline'));
      when(() => mockLocalDS.getRandomBatch(count: any(named: 'count')))
          .thenAnswer((_) async => tCachedList);

      // Act
      final result = await repository.randomBatch(count: 2);

      // Assert
      expect(result, equals(tCachedList));
      verify(() => mockLocalDS.getRandomBatch(count: 2)).called(1);
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
