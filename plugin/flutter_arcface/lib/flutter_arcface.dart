import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FlutterArcface {
  static const MethodChannel _channel =
      const MethodChannel('flutter_arcface');

  static Future<String> active() async {
    final String version = await _channel.invokeMethod('activeCode');
    return version;
  }
  static Future<String> singleImage({@required String path}) async{
    final String result = await _channel.invokeMethod("singleImage",<String,dynamic>{'path':path});
    return result;
  }
  static Future<String> compareImage({@required String path1,@required String path2}) async{
    final String result = await _channel.invokeMethod("compareImage",<String,dynamic>{'path1':path1,'path2':path2});
    return result;
  }
}
