import 'dart:convert';

import 'package:telescope/model/character_list_item.dart';
import 'package:test/test.dart';

void main() {
  group('fromJson', () {
    test('parse correctly', () {
      var json = JSON.decode('''
      {
        "chara_id": 101,
        "conventional": "Shimamura Uzuki",
        "kanji_spaced": "島村 卯月",
        "kana_spaced": "しまむら うづき",
        "cards": [
          100001,
          100075,
          100255,
          100293,
          100447
        ],
        "ref": "/api/v1/char_t/101"
      }      
      ''');

      CharacterListItem item = CharacterListItem.fromJson(json);

      expect(item.id, 101);
      expect(item.name, '島村 卯月');
      expect(item.nameKana, "しまむら うづき");
    });
  });

  group('toJson', () {
    test('encode correctly', () {
      var map = {
        'chara_id': 101,
        'kanji_spaced': "島村 卯月",
        'kana_spaced': "しまむら うづき",
        'cards': [
          100001,
          100075,
          100255,
          100293,
          100447,
        ],
      };

      CharacterListItem item = new CharacterListItem(
        101,
        '島村 卯月',
        'しまむら うづき',
        [
          100001,
          100075,
          100255,
          100293,
          100447,
        ],
      );

      expect(item.toJson(), map);
    });
  });
}
