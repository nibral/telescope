import 'dart:async';

import 'package:flutter/services.dart';
import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/model/card.dart';
import 'package:telescope/repository/card_repository.dart';
import 'package:telescope/repository/card_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class MockStarlightApi extends Mock implements StarlightApi {}

class MockCard extends Mock implements Card {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  final String _encodedTestCard = '''
      {
        "id": 100001,
        "name": "島村 卯月",
        "evolution_id": 100002,
        "spread_image_ref": "https://truecolor.kirara.ca/spread/100001.png"
      }
      ''';

  StarlightApi _api;
  SharedPreferences _preferences;
  CardRepository _subject;

  setUp(() {
    _api = new MockStarlightApi();
    _preferences = new MockSharedPreferences();
    _subject = new CardRepositoryImpl(_api, _preferences);

    const MethodChannel('plugins.flutter.io/shared_preferences')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{};
      }
      return null;
    });
  });

  group('find', () {
    test('when cache is empty, call api.', () async {
      var card = new MockCard();
      when(_api.getCard(100001)).thenReturn(new Future.value(card));

      await _subject.find(100001).then((actual) {
        expect(actual, card);
      });

      verify(_api.getCard(100001));
    });

    test('when force refresh, call api.', () async {
      var card = new MockCard();
      when(_api.getCard(100001)).thenReturn(new Future.value(card));
      when(_preferences.getString('card_100001')).thenReturn(_encodedTestCard);

      await _subject.find(100001, refresh: true).then((actual) {
        expect(actual, card);
      });

      verify(_api.getCard(100001));
    });

    test('when object cached, use cache.', () async {
      when(_preferences.getString('card_100001')).thenReturn(_encodedTestCard);

      await _subject.find(100001).then((actual) {
        expect(actual.id, 100001);
        expect(actual.name, '島村 卯月');
        expect(actual.evolutionCardId, 100002);
        expect(actual.spreadImageUrl,
            'https://truecolor.kirara.ca/spread/100001.png');
      });

      verifyNever(_api.getCard(100001));
    });
  });
}
