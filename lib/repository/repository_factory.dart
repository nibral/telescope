import 'package:telescope/api/starlight_api.dart';
import 'package:telescope/api/starlight_api_impl.dart';
import 'package:telescope/repository/character_list_repository.dart';
import 'package:telescope/repository/character_list_repository_impl.dart';

class RepositoryFactory {
  static final RepositoryFactory _singleton = new RepositoryFactory._internal();

  factory RepositoryFactory() {
    return _singleton;
  }

  StarlightApi _api;
  CharacterListRepository _characterListRepository;

  RepositoryFactory._internal() {
    _api = new StarlightApiImpl();
    _characterListRepository = new CharacterListRepositoryImpl(_api);
  }

  CharacterListRepository getCharacterListRepository() {
    return _characterListRepository;
  }
}
