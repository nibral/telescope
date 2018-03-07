import 'dart:async';

import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/model/card.dart';
import 'package:telescope/repository/card_repository.dart';
import 'package:telescope/repository/card_repository_impl.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class MockStarlightApi extends Mock implements StarlightApi {}

class MockCard extends Mock implements Card {}

void main() {
  StarlightApi _api;
  Map<int, Card> _cache;
  CardRepository _subject;

  setUp(() {
    _api = new MockStarlightApi();
    _cache = new Map();
    _subject = new CardRepositoryImpl(_api, _cache);
  });

  group('find', () {
    test('call api when cache is empty.', () async {
      var card = new MockCard();
      when(_api.getCard(123)).thenReturn(new Future.value(card));

      await _subject.find(123).then((actual) {
        expect(actual, card);
      });

      verify(_api.getCard(123));
    });

    test('use cache when object cached.', () async {
      var card = new MockCard();
      _cache[123] = card;

      await _subject.find(123).then((actual) {
        expect(actual, card);
      });

      verifyNever(_api.getCard(123));
    });
  });
}
