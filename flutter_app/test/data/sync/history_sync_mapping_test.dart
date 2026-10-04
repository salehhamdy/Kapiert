import 'package:derdiedas/core/utils/uuid.dart';
import 'package:derdiedas/data/dto/history_dto.dart';
import 'package:derdiedas/domain/models/lookup_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('uuidV4', () {
    final pattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );

    test('produces RFC 4122 v4 format', () {
      for (var i = 0; i < 100; i++) {
        expect(uuidV4(), matches(pattern));
      }
    });

    test('is unique across many calls', () {
      final ids = {for (var i = 0; i < 5000; i++) uuidV4()};
      expect(ids.length, 5000);
    });
  });

  group('LookupHistory map round-trip', () {
    test('preserves clientId', () {
      final entry = LookupHistory(
        clientId: 'abc',
        timestamp: DateTime(2026, 10, 4, 12, 30),
        word: 'Buch',
        article: 'das',
        correct: true,
        mode: 'lookup',
      );
      final back = LookupHistory.fromMap({...entry.toMap(), 'id': 7});
      expect(back.clientId, 'abc');
      expect(back.id, 7);
      expect(back.word, 'Buch');
    });

    test('omits client_id when null (legacy rows)', () {
      final entry = LookupHistory(
        timestamp: DateTime(2026),
        word: 'Kind',
        article: 'das',
        correct: false,
        mode: 'quiz',
      );
      expect(entry.toMap().containsKey('client_id'), isFalse);
    });
  });

  group('HistoryDto remote mapping', () {
    test('toRemote converts types and sends UTC timestamp', () {
      final local = DateTime(2026, 10, 4, 9, 15);
      final remote = HistoryDto.toRemote({
        'id': 1,
        'client_id': 'cid',
        'timestamp': local.toIso8601String(),
        'word': 'Tisch',
        'article': 'der',
        'correct': 0,
        'mode': 'quiz',
        'synced': 0,
      }, 'user-1');

      expect(remote['user_id'], 'user-1');
      expect(remote['client_id'], 'cid');
      expect(remote['correct'], isFalse);
      expect(remote.containsKey('id'), isFalse);
      expect(remote.containsKey('synced'), isFalse);
      expect(
        DateTime.parse(remote['timestamp'] as String).isAtSameMomentAs(local),
        isTrue,
      );
      expect((remote['timestamp'] as String).endsWith('Z'), isTrue);
    });

    test('fromRemote produces a synced local row', () {
      final row = HistoryDto.fromRemote({
        'id': 42,
        'client_id': 'cid',
        'timestamp': '2026-10-04T06:15:00+00:00',
        'word': 'Lampe',
        'article': 'die',
        'correct': true,
        'mode': 'lookup',
      });

      expect(row['synced'], 1);
      expect(row['correct'], 1);
      expect(row.containsKey('id'), isFalse, reason: 'local id is autoincrement');
      final parsed = LookupHistory.fromMap({...row, 'id': 1});
      expect(
        parsed.timestamp
            .isAtSameMomentAs(DateTime.utc(2026, 10, 4, 6, 15)),
        isTrue,
      );
    });
  });
}
