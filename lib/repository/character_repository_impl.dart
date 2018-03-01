import 'dart:async';

import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/model/character.dart';
import 'package:telescope/model/character_list_item.dart';
import 'package:telescope/repository/character_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Future<Map<int, CharacterListItem>> getList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String key = 'character_list';

    List<String> list = preferences.getStringList(key);
    if (list == null) {
      return _api.getCharacterList().then((r) {
        preferences.setStringList(
            key,
            r.values.map((e) {
              return e.toJson();
            }).toList());
        return r;
      });
    }

    Map<int, CharacterListItem> map = new Map();
    list.forEach((e) {
      CharacterListItem item = CharacterListItem.fromJson(e);
      map[item.id] = item;
    });
    return new Future.value(map);
  }
}
