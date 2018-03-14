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

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  StarlightApi _api;
  SharedPreferences _preferences;
  CharacterRepository _subject;

  setUp(() async {
    _api = new MockStarlightApi();
    _preferences = new MockSharedPreferences();
    _subject = new CharacterRepositoryImpl(_api, _preferences);

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
      var character = new MockCharacter();
      when(_api.getCharacter(123)).thenReturn(new Future.value(character));

      await _subject.find(123).then((actual) {
        expect(actual, character);
      });

      verify(_api.getCharacter(123));
    });

    test('when force refresh, call api', () async {
      var character = new MockCharacter();
      when(_api.getCharacter(123)).thenReturn(new Future.value(character));
      var cached = new Character(123, '島村 卯月', 'しまむら うづき', '');
      when(_preferences.getString('character_123'))
          .thenReturn(JSON.encode(cached));

      await _subject.find(123, refresh: true).then((actual) {
        expect(actual, character);
      });

      verify(_api.getCharacter(123));
    });

    test('when object cached, use cache.', () async {
      var character = new Character(123, '島村 卯月', 'しまむら うづき', '');
      when(_preferences.getString('character_123'))
          .thenReturn(JSON.encode(character));

      await _subject.find(123).then((actual) {
        expect(actual.id, character.id);
        expect(actual.name, character.name);
        expect(actual.nameKana, character.nameKana);
        expect(actual.iconImageUrl, character.iconImageUrl);
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
      when(_preferences.getStringList('character_list')).thenReturn(null);

      await _subject.getList().then((actual) {
        expect(actual[101], listItem);
      });

      verify(_api.getCharacterList());
    });

    test('when force refresh, call api.', () async {
      var listItem = new MockCharacterListItem();
      when(_api.getCharacterList())
          .thenReturn(new Future.value(<int, CharacterListItem>{
        101: listItem,
      }));
      CharacterListItem cached =
          new CharacterListItem(101, '島村 卯月', 'しまむら うづき', [100001]);
      when(_preferences.getStringList('character_list'))
          .thenReturn(<String>[JSON.encode(cached)]);

      await _subject.getList(refresh: true).then((actual) {
        expect(actual[101], listItem);
      });

      verify(_api.getCharacterList());
    });

    test('when list data cached, use cache.', () async {
      CharacterListItem listItem =
          new CharacterListItem(101, '島村 卯月', 'しまむら うづき', [100001]);
      when(_preferences.getStringList('character_list'))
          .thenReturn(<String>[JSON.encode(listItem)]);

      await _subject.getList().then((actual) {
        expect(actual[101].id, 101);
        expect(actual[101].name, '島村 卯月');
        expect(actual[101].nameKana, 'しまむら うづき');
        expect(actual[101].cardIdList[0], 100001);
      });

      verifyNever(_api.getCharacterList());
    });
  });
}
