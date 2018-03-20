import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:telescope/infrastructure/application_documents.dart';

class ApplicationDocumentsImpl extends ApplicationDocuments {
  @override
  Future<List<int>> load(String fileName) async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = new File('${directory.path}/$fileName');
    if (file.existsSync()) {
      return new Future.value(await file.readAsBytes());
    } else {
      return null;
    }
  }

  @override
  Future<void> save(String fileName, List<int> data) async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = new File('${directory.path}/$fileName');
    await file.writeAsBytes(data);
    return new Future.value();
  }

  @override
  Future<void> clear() async {
    Directory directory = await getApplicationDocumentsDirectory();
    directory.listSync().forEach((entity) {
      if (entity is File) {
        entity.deleteSync();
      }
    });
    return new Future.value();
  }
}
