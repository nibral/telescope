import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:telescope/infrastructure/application_documents.dart';
import 'package:telescope/repository/image_cache_repository.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart' as http;

class ImageCacheRepositoryImpl extends ImageCacheRepository {
  ApplicationDocuments _documents;

  http.Client _client;

  ImageCacheRepositoryImpl(this._documents, this._client);

  @override
  Future<Uint8List> find(String url) async {
    String hash = hex.encode(crypto.md5.convert(UTF8.encode(url)).bytes);

    List<int> data = await _documents.load(hash);
    if (data != null) {
      return new Future.value(new Uint8List.fromList(data));
    }

    return _client.readBytes(url).then((response) async {
      await _documents.save(hash, response.toList());
      return response;
    });
  }

  @override
  void clear() async {
    await _documents.clear();
  }
}
