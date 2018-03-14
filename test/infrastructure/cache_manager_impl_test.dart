import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:telescope/infrastructure/cache_manager.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;

void main() {
  String _currentPath = '${Directory.current.path}';
  File _cached;
  http.Client _client;
  CacheManager _subject;

  group('getImage', () {
    setUp(() {
      // mock path provider
      const MethodChannel('plugins.flutter.io/path_provider')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return new Future.value(_currentPath);
        }
        return null;
      });

      // mock http response
      _client = new MockClient((http.Request request) async {
        if (request.url.path == '/download') {
          return new Future.value(
              new http.Response.bytes(UTF8.encode('download'), 200));
        }
        return new Future.value(new http.Response('', 404));
      });

      // generate cache file
      String cacheFilePath = '/cache';
      String hash =
          hex.encode(crypto.md5.convert(UTF8.encode(cacheFilePath)).bytes);
      _cached = new File('$_currentPath/$hash');
      _cached.writeAsStringSync('cache');

      _subject = new CacheManager(client: _client);
    });

    tearDown(() {
      // delete downloaded file and cache file
      String downloadedPath = '/download';
      String hash =
          hex.encode(crypto.md5.convert(UTF8.encode(downloadedPath)).bytes);
      File downloaded = new File('$_currentPath/$hash');
      if (downloaded.existsSync()) {
        downloaded.deleteSync();
      }
      _cached.deleteSync();
    });

    test('by download', () async {
      await _subject.load('/download').then((actual) {
        expect(actual, UTF8.encode('download'));
      });
    });

    test('by cache', () async {
      await _subject.load('/cache').then((actual) {
        expect(actual, UTF8.encode('cache'));
      });
    });
  });
}
