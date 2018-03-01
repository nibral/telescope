import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/model/character.dart';
import 'package:telescope/model/character_list_item.dart';
import 'package:telescope/repository/character_repository.dart';
import 'package:telescope/repository/character_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class MockStarlightApi extends Mock implements StarlightApi {}

class MockCharacter extends Mock implements Character {}

class MockCharacterListItem extends Mock implements CharacterListItem {}

class MockSharedPreference extends Mock implements SharedPreferences {}

void main() {
  StarlightApi _api;
  Map<int, Character> _cache;
  SharedPreferences _preferences;
  CharacterRepository _subject;

  setUp(() async {
    _api = new MockStarlightApi();
    _cache = new Map();
    _preferences = new MockSharedPreference();
    _subject = new CharacterRepositoryImpl(_api, _cache);

    const MethodChannel('plugins.flutter.io/shared_preferences')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{};
      }
      return null;
    });
  });

  group('find', () {
    test('call api when cache is empty.', () async {
      var character = new MockCharacter();
      when(_api.getCharacter(123)).thenReturn(new Future.value(character));

      await _subject.find(123).then((actual) {
        expect(actual, character);
      });

      verify(_api.getCharacter(123));
    });

    test('use cache when object cached.', () async {
      var character = new MockCharacter();
      _cache[123] = character;

      await _subject.find(123).then((actual) {
        expect(actual, character);
      });

      verifyNever(_api.getCharacter(123));
    });
  });

  group('getList', () {
    test('when no data stored, call api', () async {
      var listItem = new MockCharacterListItem();
      when(_api.getCharacterList())
          .thenReturn(new Future.value(<int, CharacterListItem>{
        101: listItem,
      }));
      when(_preferences.getStringList('character_list'))
          .thenReturn(const <String>[]);

      await _subject.getList().then((actual) {
        expect(actual[101], listItem);
      });

      verify(_api.getCharacterList());
    });

    test('when list data stored', () async {
      CharacterListItem listItem =
          new CharacterListItem(101, '島村 卯月', 'しまむら うづき');
      when(_preferences.getStringList('character_list')).thenReturn(<String>[
        JSON.encode(listItem),
      ]);

      await _subject.getList().then((actual) {
        expect(actual[101].id, 101);
        expect(actual[101].name, '島村 卯月');
        expect(actual[101].name_kana, 'しまむら うづき');
      });

      verifyNever(_api.getCharacterList());
    });
  });
}
