import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:telescope/infrastructure/application_documents_impl.dart';
import 'package:test/test.dart';

void main() {
  Directory _testDirectory = new Directory('${Directory.current.path}/temp');
  ApplicationDocumentsImpl _subject;

  setUpAll(() {
    // mock path provider
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return new Future.value(_testDirectory.path);
      }
      return null;
    });

    _testDirectory.createSync();

    _subject = new ApplicationDocumentsImpl();
  });

  tearDownAll(() {
    _testDirectory.deleteSync();
  });

  group('load', () {
    test('from file', () async {
      File file = new File('${_testDirectory.path}/foo');
      file.writeAsStringSync('Hello, world!');

      await _subject.load('foo').then((data) {
        expect(data, UTF8.encode('Hello, world!'));
      });

      file.deleteSync();
    });

    test('empty', () async {
      await _subject.load('bar').then((data) {
        expect(data, null);
      });
    });
  });

  group('save', () {
    test('to file', () async {
      List<int> data = UTF8.encode('Goodbye.');

      await _subject.save('bar', data);

      File file = new File('${_testDirectory.path}/bar');
      expect(file.readAsBytesSync(), data);

      file.deleteSync();
    });
  });

  group('clear', () {
    test('all', () async {
      (new File('${_testDirectory.path}/foo')).writeAsStringSync('foo');
      expect(_testDirectory.listSync().length, 1);

      await _subject.clear();

      expect(_testDirectory.listSync().length, 0);
    });
  });
}
