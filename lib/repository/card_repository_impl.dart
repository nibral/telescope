import 'dart:async';
import 'dart:convert';

import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/model/card.dart';
import 'package:telescope/repository/card_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardRepositoryImpl implements CardRepository {
  StarlightApi _api;

  SharedPreferences _preferences;

  CardRepositoryImpl(this._api, this._preferences);

  @override
  Future<Card> find(int id) {
    String key = 'card_$id';

    String cached = _preferences.getString(key);
    if (cached == null) {
      return _api.getCard(id).then((card) {
        _preferences.setString(key, JSON.encode(card));
        return card;
      });
    }

    return new Future.value(Card.fromJson(JSON.decode(cached)));
  }
}
