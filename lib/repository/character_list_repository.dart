import 'dart:async';

import 'package:telescope/model/character_list_item.dart';

abstract class CharacterListRepository {
  Future<Map<int, CharacterListItem>> findAll();

  Future<CharacterListItem> find(int id);
}
