import 'dart:async';

import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/model/character.dart';
import 'package:telescope/model/character_list_item.dart';
import 'package:telescope/repository/character_repository.dart';
import 'package:telescope/repository/character_repository_impl.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class MockStarlightApi extends Mock implements StarlightApi {}

class MockCharacter extends Mock implements Character {}

class MockCharacterListItem extends Mock implements CharacterListItem {}

void main() {
  StarlightApi _api;
  Map<int, Character> _cache;
  CharacterRepository _subject;

  setUp(() {
    _api = new MockStarlightApi();
    _cache = new Map();
    _subject = new CharacterRepositoryImpl(_api, _cache);
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
    test('call api', () async {
      var character = new MockCharacter();
      when(_api.getCharacterList()).thenReturn(new Future(() => [
            character,
          ]));

      await _subject.getList().then((actual) {
        expect(actual[0], character);
      });

      verify(_api.getCharacterList());
    });
  });
}
