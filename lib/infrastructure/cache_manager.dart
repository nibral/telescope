import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CacheManager {
  http.Client _client;

  CacheManager({http.Client client}) {
    this._client = client ?? new http.Client();
  }

  Future<Uint8List> load(String url) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String hash = hex.encode(crypto.md5.convert(UTF8.encode(url)).bytes);
    File file = new File('${directory.path}/$hash');
    if (file.existsSync()) {
      return new Future.value(new Uint8List.fromList(await file.readAsBytes()));
    }

    return _client.readBytes(url).then((data) async {
      await file.writeAsBytes(data.toList());
      return data;
    });
  }
}
