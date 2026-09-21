import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:derdiedas/core/network/api_client.dart';
import 'package:derdiedas/core/errors/failures.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockHttpClient;
  late ApiClient apiClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    apiClient = ApiClient(baseUrl: 'http://test.com', client: mockHttpClient);
    
    // Register fallback value for mocktail URI matching
    registerFallbackValue(Uri.parse('http://test.com'));
  });

  group('ApiClient', () {
    const tPath = '/lookup/test';
    final tUri = Uri.parse('http://test.com$tPath');

    test('get returns map on 200 OK', () async {
      // Arrange
      const responseBody = '{"word": "Test", "article": "der"}';
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(responseBody, 200),
      );

      // Act
      final result = await apiClient.get(tPath);

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['word'], 'Test');
      verify(() => mockHttpClient.get(tUri)).called(1);
    });

    test('get throws NotFoundFailure on 404', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Not Found', 404),
      );

      // Act & Assert
      expect(() => apiClient.get(tPath), throwsA(isA<NotFoundFailure>()));
    });

    test('get throws NetworkFailure on 500', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Server Error', 500),
      );

      // Act & Assert
      expect(() => apiClient.get(tPath), throwsA(isA<NetworkFailure>()));
    });

    test('getList returns list on 200 OK', () async {
      // Arrange
      const tListPath = '/random/batch/2';
      final tListUri = Uri.parse('http://test.com$tListPath');
      const responseBody = '[{"word": "Test1"}, {"word": "Test2"}]';

      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(responseBody, 200),
      );

      // Act
      final result = await apiClient.getList(tListPath);

      // Assert
      expect(result, isA<List<dynamic>>());
      expect(result.length, 2);
      verify(() => mockHttpClient.get(tListUri)).called(1);
    });
    
    test('checkHealth returns true on 200 OK', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('OK', 200),
      );

      // Act
      final result = await apiClient.checkHealth();

      // Assert
      expect(result, isTrue);
    });

    test('checkHealth returns false on non-200', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Error', 500),
      );

      // Act
      final result = await apiClient.checkHealth();

      // Assert
      expect(result, isFalse);
    });
  });
}
