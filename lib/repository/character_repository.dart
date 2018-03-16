import 'dart:async';

import 'package:telescope/model/character.dart';
import 'package:telescope/model/character_list_item.dart';

abstract class CharacterRepository {
  Future<Character> find(int id);

  Future<Map<int, CharacterListItem>> getList();
}
