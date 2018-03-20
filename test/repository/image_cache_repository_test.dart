import 'dart:async';
import 'dart:convert';

import 'package:telescope/infrastructure/application_documents.dart';
import 'package:telescope/repository/image_cache_repository.dart';
import 'package:telescope/repository/image_cache_repository_impl.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class MockApplicationDocuments extends Mock implements ApplicationDocuments {}

void main() {
  const String _SLASH_FOO_MD5 = '1effb2475fcfba4f9e8b8a1dbc8f3caf';
  const String _SLASH_BAR_MD5 = '6a764eebfa109a9ef76c113f3f608c6b';

  ApplicationDocuments _documents;

  http.Client _client;

  ImageCacheRepository _subject;

  setUp(() {
    _documents = new MockApplicationDocuments();

    _client = new MockClient((http.Request request) async {
      if (request.url.path == '/foo') {
        return new Future.value(
            new http.Response.bytes(UTF8.encode('Hello, world!'), 200));
      }
      return new Future.value(new http.Response('', 404));
    });

    _subject = new ImageCacheRepositoryImpl(_documents, _client);
  });

  group('find', () {
    test('from remote', () async {
      when(_documents.load(_SLASH_FOO_MD5)).thenReturn(null);

      await _subject.find('/foo').then((actual) {
        expect(actual, UTF8.encode('Hello, world!'));
      });

      verify(_documents.load(_SLASH_FOO_MD5));
      verify(_documents.save(_SLASH_FOO_MD5, UTF8.encode('Hello, world!')));
    });

    test('from local', () async {
      when(_documents.load(_SLASH_BAR_MD5)).thenReturn(UTF8.encode('Goodbye.'));

      await _subject.find('/bar').then((actual) {
        expect(actual, UTF8.encode('Goodbye.'));
      });

      verify(_documents.load(_SLASH_BAR_MD5));
      verifyNever(_documents.save);
    });
  });
}
