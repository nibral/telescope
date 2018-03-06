import 'dart:async';
import 'dart:convert';

import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/model/character.dart';
import 'package:telescope/model/character_list_item.dart';
import 'package:telescope/repository/character_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  StarlightApi _api;

  Map<int, Character> _cache;

  SharedPreferences _preferences;

  CharacterRepositoryImpl(this._api, this._cache, this._preferences);

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

  @override
  Future<Map<int, CharacterListItem>> getList() {
    String key = 'character_list';

    List<String> list = _preferences.getStringList(key);
    if (list == null) {
      return _api.getCharacterList().then((r) {
        _preferences.setStringList(
            key,
            r.values.map((e) {
              return JSON.encode(e);
            }).toList());
        return r;
      });
    }

    Map<int, CharacterListItem> map = new Map();
    list.forEach((e) {
      CharacterListItem item = CharacterListItem.fromJson(JSON.decode(e));
      map[item.id] = item;
    });
    return new Future.value(map);
  }
}
