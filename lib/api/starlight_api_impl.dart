import 'dart:async';
import 'dart:convert';

import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/model/card.dart';
import 'package:telescope/model/character.dart';
import 'package:telescope/model/character_list_item.dart';
import 'package:http/http.dart' as http;

class StarlightApiImpl implements StarlightApi {
  static const _API_HOST = 'https://starlight.kirara.ca/api/v1';

  @override
  Future<Map<int, CharacterListItem>> getCharacterList() async {
    Map<int, CharacterListItem> characterList = new Map();

    var response = await http.read('$_API_HOST/list/char_t');
    var json = JSON.decode(response);

    var characters = json['result'];
    for (var character in characters) {
      characterList[character['chara_id']] =
          CharacterListItem.fromJson(character);
    }

    return characterList;
  }

  @override
  Future<Character> getCharacter(int id) async {
    Map<int, Character> characterMap = new Map();

    var response = await http.read('$_API_HOST/char_t/$id');
    var json = JSON.decode(response);

    var characters = json['result'];
    for (var character in characters) {
      characterMap[character['chara_id']] = Character.fromJson(character);
    }

    return characterMap[id];
  }

  @override
  Future<Card> getCard(int id) async {
    Map<int, Card> cardMap = new Map();

    var response = await http.read('$_API_HOST/card_t/$id');
    var json = JSON.decode(response);

    var cards = json['result'];
    for (var card in cards) {
      cardMap[card['id']] = Card.fromJson(card);
    }

    return cardMap[id];
  }
}
