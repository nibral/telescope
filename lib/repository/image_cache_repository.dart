import 'dart:async';
import 'dart:typed_data';

abstract class ImageCacheRepository {
  Future<Uint8List> find(String url);

  void clear();
}
