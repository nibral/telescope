import 'dart:convert';

import 'package:telescope/model/character.dart';
import 'package:test/test.dart';

void main() {
  group('fromJson', () {
    test('parse correctly', () {
      var json = JSON.decode('''
      {
        "id": 101,
        "name": "島村 卯月",
        "name_kana": "しまむら うづき",
        "icon_image_ref": "https://truecolor.kirara.ca/icon_char/101.png"
      }      
      ''');

      Character character = Character.fromJson(json);

      expect(character.id, 101);
      expect(character.name, '島村 卯月');
      expect(character.name_kana, "しまむら うづき");
    });
  });
}
