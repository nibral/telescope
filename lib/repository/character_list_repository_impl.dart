import 'dart:async';

import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/model/character_list_item.dart';
import 'package:telescope/repository/character_list_repository.dart';

class CharacterListRepositoryImpl implements CharacterListRepository {
  StarlightApi _api;

  CharacterListRepositoryImpl(this._api);

  @override
  Future<Map<int, CharacterListItem>> findAll() {
    return _api.getCharacterList();
  }

  @override
  Future<CharacterListItem> find(int id) {
    return findAll().then((list) => list[id]);
  }
}
