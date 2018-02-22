import 'dart:async';
import 'dart:convert';

import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/model/character_list_item.dart';
import 'package:http/http.dart' as http;

class StarlightApiImpl implements StarlightApi {
  static const _API_HOST = 'https://starlight.kirara.ca/api/v1';

  var _characterMap = new Map<int, CharacterListItem>();

  @override
  Future<Map<int, CharacterListItem>> getCharacterList(
      {bool refresh = false}) async {
    if (refresh || _characterMap.isEmpty) {
      var response = await http.read('$_API_HOST/list/char_t');
      var json = JSON.decode(response);

      var characters = json['result'];
      for (var character in characters) {
        _characterMap[character['chara_id']] =
            CharacterListItem.fromJson(character);
      }
    }

    return _characterMap;
  }
}
