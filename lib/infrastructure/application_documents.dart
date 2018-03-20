import 'dart:async';

abstract class ApplicationDocuments {
  Future<List<int>> load(String fileName);

  Future<void> save(String fileName, List<int> data);

  Future<void> clear();
}
