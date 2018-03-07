import 'dart:async';

import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/model/card.dart';
import 'package:telescope/repository/card_repository.dart';

class CardRepositoryImpl implements CardRepository {
  StarlightApi _api;

  Map<int, Card> _cache;

  CardRepositoryImpl(this._api, this._cache);

  @override
  Future<Card> find(int id) {
    if (_cache.containsKey(id)) {
      return new Future.value(_cache[id]);
    }

    return _api.getCard(id).then((card) {
      _cache[id] = card;
      return card;
    });
  }
}
