import 'dart:async';

import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/api/starlight_api_impl.dart';
import 'package:telescope/repository/card_repository.dart';
import 'package:telescope/repository/card_repository_impl.dart';
import 'package:telescope/repository/character_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telescope/repository/character_repository_impl.dart';

class RepositoryFactory {
  static RepositoryFactory _singleton = new RepositoryFactory._internal();

  factory RepositoryFactory({SharedPreferences preferences}) {
    if (preferences != null) {
      _singleton = new RepositoryFactory(preferences: preferences);
    }

    return _singleton;
  }

  StarlightApi _api;
  CharacterRepository _characterRepository;
  CardRepository _cardRepository;
  SharedPreferences _preferences;

  RepositoryFactory._internal({SharedPreferences preferences}) {
    _api = new StarlightApiImpl();
    _characterRepository = null;
    _cardRepository = new CardRepositoryImpl(_api, new Map());
    _preferences = preferences;
  }

  Future<CharacterRepository> getCharacterRepository() async {
    if (_characterRepository != null) {
      return _characterRepository;
    }

    _preferences ??= await SharedPreferences.getInstance();
    _characterRepository =
        new CharacterRepositoryImpl(_api, new Map(), _preferences);

    return _characterRepository;
  }

  CardRepository getCardRepository() {
    return _cardRepository;
  }
}
