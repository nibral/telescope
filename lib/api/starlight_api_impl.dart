import 'dart:async';

import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/model/character_list_item.dart';

class StarlightApiImpl implements StarlightApi {
  var _characterMap = new Map<int, CharacterListItem>();

  StarlightApiImpl() {
    _characterMap[100] = new CharacterListItem(101, '島村卯月');
    _characterMap[102] = new CharacterListItem(102, '中野有香');
    _characterMap[111] = new CharacterListItem(111, '小日向美穂');
    _characterMap[223] = new CharacterListItem(223, '速水奏');
  }

  @override
  Future<Map<int, CharacterListItem>> getCharacterList() async {
    return _characterMap;
  }
}
