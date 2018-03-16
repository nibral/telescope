import 'dart:async';

import 'package:telescope/model/card.dart';

abstract class CardRepository {
  Future<Card> find(int id);
}
