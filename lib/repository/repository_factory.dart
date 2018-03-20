import 'dart:async';

import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/api/starlight_api_impl.dart';
import 'package:telescope/infrastructure/application_documents_impl.dart';
import 'package:telescope/repository/card_repository.dart';
import 'package:telescope/repository/card_repository_impl.dart';
import 'package:telescope/repository/character_repository.dart';
import 'package:telescope/repository/character_repository_impl.dart';
import 'package:telescope/repository/image_cache_repository.dart';
import 'package:telescope/repository/image_cache_repository_impl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RepositoryFactory {
  static final RepositoryFactory _singleton = new RepositoryFactory._internal();

  factory RepositoryFactory() {
    return _singleton;
  }

  StarlightApi _api;
  CharacterRepository _characterRepository;
  CardRepository _cardRepository;
  ImageCacheRepository _imageCacheRepository;

  RepositoryFactory._internal() {
    _api = new StarlightApiImpl();
    _imageCacheRepository = new ImageCacheRepositoryImpl(
        new ApplicationDocumentsImpl(), new http.Client());
  }

  Future<CharacterRepository> getCharacterRepository() async {
    if (_characterRepository != null) {
      return _characterRepository;
    }

    _characterRepository = new CharacterRepositoryImpl(
        _api, await SharedPreferences.getInstance());
    return _characterRepository;
  }

  Future<CardRepository> getCardRepository() async {
    if (_cardRepository != null) {
      return _cardRepository;
    }

    _cardRepository =
        new CardRepositoryImpl(_api, await SharedPreferences.getInstance());
    return _cardRepository;
  }

  Future<ImageCacheRepository> getImageCacheRepository() {
    return new Future.value(_imageCacheRepository);
  }

  void invalidateCache() async {
    (await SharedPreferences.getInstance()).clear();
    _imageCacheRepository.clear();
  }
}
