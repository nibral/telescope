import 'dart:async';

import 'package:telescope/model/card.dart';
import 'package:telescope/model/character.dart';
import 'package:telescope/model/character_list_item.dart';

abstract class StarlightApi {
  Future<Map<int, CharacterListItem>> getCharacterList();

  Future<Character> getCharacter(int id);

  Future<Card> getCard(int id);
}
