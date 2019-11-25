// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_saver/image_picker_saver.dart';

void main() {
  group('$ImagePickerSaver', () {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/image_picker_saver');

    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return '';
      });

      log.clear();
    });

    group('#pickImage', () {
      test('passes the image source argument correctly', () async {

        expect(
          log,
          <Matcher>[
            isMethodCall('pickImage', arguments: <String, dynamic>{
              'source': 0,
              'maxWidth': null,
              'maxHeight': null,
            }),
            isMethodCall('pickImage', arguments: <String, dynamic>{
              'source': 1,
              'maxWidth': null,
              'maxHeight': null,
            }),
          ],
        );
      });

      test('passes the width and height arguments correctly', () async {

        expect(
          log,
          <Matcher>[
            isMethodCall('pickImage', arguments: <String, dynamic>{
              'source': 0,
              'maxWidth': null,
              'maxHeight': null,
            }),
            isMethodCall('pickImage', arguments: <String, dynamic>{
              'source': 0,
              'maxWidth': 10.0,
              'maxHeight': null,
            }),
            isMethodCall('pickImage', arguments: <String, dynamic>{
              'source': 0,
              'maxWidth': null,
              'maxHeight': 10.0,
            }),
            isMethodCall('pickImage', arguments: <String, dynamic>{
              'source': 0,
              'maxWidth': 10.0,
              'maxHeight': 20.0,
            }),
          ],
        );
      });

      test('does not accept a negative width or height argument', () {

      });

      test('handles a null image path response gracefully', () async {
        channel.setMockMethodCallHandler((MethodCall methodCall) => null);

      });
    });
  });
}
