import 'dart:async';

import 'package:telescope/model/character.dart';

abstract class CharacterRepository {
  Future<Character> find(int id);
}
