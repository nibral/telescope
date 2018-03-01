import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/api/starlight_api_impl.dart';
import 'package:telescope/repository/character_repository.dart';
import 'package:telescope/repository/character_repository_impl.dart';

class RepositoryFactory {
  static final RepositoryFactory _singleton = new RepositoryFactory._internal();

  factory RepositoryFactory() {
    return _singleton;
  }

  StarlightApi _api;
  CharacterRepository _characterRepository;

  RepositoryFactory._internal() {
    _api = new StarlightApiImpl();
    _characterRepository = new CharacterRepositoryImpl(_api, new Map());
  }

  CharacterRepository getCharacterRepository() {
    return _characterRepository;
  }
}
