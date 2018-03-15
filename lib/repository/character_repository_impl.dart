import 'dart:async';
import 'dart:convert';

import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/model/character.dart';
import 'package:telescope/model/character_list_item.dart';
import 'package:telescope/repository/character_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  StarlightApi _api;

  SharedPreferences _preferences;

  CharacterRepositoryImpl(this._api, this._preferences);

  @override
  Future<Character> find(int id, {bool refresh: false}) {
    String key = 'character_$id';

    String cached = _preferences.getString(key);
    if (cached == null || refresh) {
      return _api.getCharacter(id).then((character) {
        _preferences.setString(key, JSON.encode(character));
        return character;
      });
    }

    return new Future.value(Character.fromJson(JSON.decode(cached)));
  }

  @override
  Future<Map<int, CharacterListItem>> getList({bool refresh: false}) {
    String key = 'character_list';

    List<String> list = _preferences.getStringList(key);
    if (list == null || refresh) {
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
