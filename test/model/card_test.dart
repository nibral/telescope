import 'dart:convert';

import 'package:telescope/model/card.dart';
import 'package:test/test.dart';

void main() {
  group('fromJson', () {
    test('parse correctly', () {
      var json = JSON.decode('''
      {
        "id": 100001,
        "name": "島村 卯月",
        "evolution_id": 100002,
        "spread_image_ref": "https://truecolor.kirara.ca/spread/100001.png"
      }
      ''');

      Card card = Card.fromJson(json);

      expect(card.id, 100001);
      expect(card.name, "島村 卯月");
      expect(card.evolution_id, 100002);
      expect(
          card.spread_image_ref, "https://truecolor.kirara.ca/spread/100001.png");
    });
  });
}
