// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ImagePickerSaver {
  static const MethodChannel _channel =
      MethodChannel('plugins.flutter.io/image_picker_saver');

  /// Returns a [File] object pointing to the image that was picked.
  ///
  /// The [source] argument controls where the image comes from. This can
  /// be either [ImageSource.camera] or [ImageSource.gallery].
  ///
  /// If specified, the image will be at most [maxWidth] wide and
  /// [maxHeight] tall. Otherwise the image will be returned at it's
  /// original width and height.

  static Future<String> saveFile({@required Uint8List fileData, String title, String description}) async {
    assert(fileData != null);

    String filePath = await _channel.invokeMethod(
      'saveFile',
      <String, dynamic>{
        'fileData': fileData,
        'title': title,
        'description': description
      },
    );
    debugPrint("saved filePath:" + filePath);
    //process ios return filePath
    if(filePath.startsWith("file://")){
      filePath=filePath.replaceAll("file://", "");
    }
    return  filePath;
  }
}
