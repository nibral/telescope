import 'dart:async';

import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/model/character.dart';
import 'package:telescope/repository/character_repository.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  StarlightApi _api;

  Map<int, Character> _cache;

  CharacterRepositoryImpl(this._api, this._cache);

  @override
  Future<Character> find(int id) {
    if (_cache.containsKey(id)) {
      return new Future.value(_cache[id]);
    }

    return _api.getCharacter(id).then((character) {
      _cache[id] = character;
      return character;
    });
  }
}
