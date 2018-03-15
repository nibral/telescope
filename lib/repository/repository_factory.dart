import 'dart:async';

import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/api/starlight_api_impl.dart';
import 'package:telescope/repository/card_repository.dart';
import 'package:telescope/repository/card_repository_impl.dart';
import 'package:telescope/repository/character_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telescope/repository/character_repository_impl.dart';

class RepositoryFactory {
  static final RepositoryFactory _singleton = new RepositoryFactory._internal();

  factory RepositoryFactory() {
    return _singleton;
  }

  StarlightApi _api;
  CharacterRepository _characterRepository;
  CardRepository _cardRepository;

  RepositoryFactory._internal() {
    _api = new StarlightApiImpl();
  }

  Future<CharacterRepository> getCharacterRepository(
      {SharedPreferences preferences}) async {
    if (preferences != null) {
      return new CharacterRepositoryImpl(_api, preferences);
    }

    if (_characterRepository != null) {
      return _characterRepository;
    }

    _characterRepository = new CharacterRepositoryImpl(
        _api, await SharedPreferences.getInstance());
    return _characterRepository;
  }

  Future<CardRepository> getCardRepository(
      {SharedPreferences preferences}) async {
    if (preferences != null) {
      return new CardRepositoryImpl(_api, preferences);
    }

    if (_cardRepository != null) {
      return _cardRepository;
    }

    _cardRepository =
        new CardRepositoryImpl(_api, await SharedPreferences.getInstance());
    return _cardRepository;
  }
}
