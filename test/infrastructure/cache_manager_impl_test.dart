import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:telescope/infrastructure/cache_manager.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  String _directory = '${Directory.current.path}/infrastructure';
  http.Client _client;
  CacheManager _subject;

  group('getImage', () {
    setUp(() {
      const MethodChannel('plugins.flutter.io/path_provider')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return new Future.value(_directory);
        }
        return null;
      });

      _client = new MockClient((http.Request request) async {
        if (request.url.path == '/download') {
          return new Future.value(
              new http.Response.bytes(UTF8.encode('download'), 200));
        }
        return new Future.value(new http.Response('', 404));
      });

      _subject = new CacheManager(client: _client);
    });

    tearDown(() {
      File downloaded =
          new File('$_directory/fd456406745d816a45cae554c788e754');
      if (downloaded.existsSync()) {
        downloaded.deleteSync();
      }
    });

    test('by download', () async {
      await _subject.get('/download').then((actual) {
        expect(actual, UTF8.encode('download'));
      });
    });

    test('by cache', () async {
      await _subject.get('/cache').then((actual) {
        expect(actual, UTF8.encode('cache'));
      });
    });
  });
}
