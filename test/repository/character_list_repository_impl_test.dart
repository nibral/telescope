import 'dart:async';

import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/repository/character_list_repository.dart';
import 'package:telescope/repository/character_list_repository_impl.dart';
import 'package:telescope/model/character_list_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockStarlightApi extends Mock implements StarlightApi {}

void main() {
  StarlightApi _api;
  CharacterListRepository _subject;
  Map<int, CharacterListItem> _characterList;

  setUp(() {
    _api = new MockStarlightApi();
    _subject = new CharacterListRepositoryImpl(_api);

    _characterList = new Map<int, CharacterListItem>();
    _characterList[1] = new CharacterListItem(1, 'uzuki');
    _characterList[2] = new CharacterListItem(2, 'rin');
    _characterList[3] = new CharacterListItem(3, 'mio');
  });

  group('findAll', () {
    test('call api', () async {
      when(_api.getCharacterList())
          .thenReturn(new Future(() => _characterList));

      await _subject.findAll();

      verify(_api.getCharacterList());
    });
  });

  group('find', () {
    test('call api', () async {
      when(_api.getCharacterList())
          .thenReturn(new Future(() => _characterList));

      await _subject.find(2).then((actual) {
        expect(actual, _characterList[2]);
      });

      verify(_api.getCharacterList());
    });
  });
}
