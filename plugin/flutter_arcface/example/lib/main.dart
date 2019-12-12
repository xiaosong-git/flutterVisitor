import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';
//import 'package:flutter/services.dart';
import 'package:flutter_arcface/flutter_arcface.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _image;
  String localPath="";
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
//     await FlutterArcface.platformVersion;
//    String platformVersion;
//    // Platform messages may fail, so we use a try/catch PlatformException.
//    try {
//      Map<PermissionGroup, PermissionStatus> permissions =
//      await PermissionHandler()
//          .requestPermissions([PermissionGroup.storage]);
//      if(permissions.entries.elementAt(0).value==PermissionStatus.granted){
//        Map<PermissionGroup, PermissionStatus> permissions =
//        await PermissionHandler()
//            .requestPermissions([PermissionGroup.phone]);
//        if(permissions.entries.elementAt(0).value==PermissionStatus.granted){
//
//        }
//      }
//    } on PlatformException {
//      platformVersion = 'wrong';
//    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body:  Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              height: 100,
              width: 100,
              child: ClipOval(
                child: _image == null
                    ? Image.asset('visitor_icon_head.png',
                    width: 100, height: 100)
                    : Image.file(
                  _image,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            Center(
              child: RaisedButton(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  child: Text('点击拍摄照片',style: TextStyle(color: Colors.white),), onPressed: getImage),
            ),
            Center(
              child: RaisedButton(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  child: Text('图片检测（单张）',style: TextStyle(color: Colors.white),), onPressed: detectImage),
            ),
            Center(
              child: RaisedButton(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  child: Text('加载图片，saveRotateImage中的图片',style: TextStyle(color: Colors.white),), onPressed: saveRomoteImage),
            ),
            Center(
              child: RaisedButton(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  child: Text('图片检测（比较），先点击拍摄照片，再加载图片，然后进行比较',style: TextStyle(color: Colors.white),), onPressed:compareImage),
            ),
          ],
        ),
      ),
    );
  }
  Future getImage() async {
    var image = await ImagePickerSaver.pickImage(source:ImageSource.gallery);
    if(image!=null&&image.path!=null){
      image = await FlutterExifRotation.rotateImage(path: image.path);
      setState(() {
        _image = image;
      });
    }
  }
  Future saveRomoteImage() async {
   var filepath=await saveNetworkImageToPhoto("http://47.98.205.206/imgserver/user/273/1571118968290.jpg");
   localPath=filepath;
  }
  Future detectImage() async {
    var result= await FlutterArcface.singleImage(path:_image.path);
    print(result);
//    try {
//      Map<PermissionGroup, PermissionStatus> permissions =
//      await PermissionHandler()
//          .requestPermissions([PermissionGroup.storage]);
//      if(permissions.entries.elementAt(0).value==PermissionStatus.granted){
//        Map<PermissionGroup, PermissionStatus> permissions =
//        await PermissionHandler()
//            .requestPermissions([PermissionGroup.phone]);
//        if(permissions.entries.elementAt(0).value==PermissionStatus.granted){
//
//        }
//      }
//    } on PlatformException {
//     print('wrong');
//    }
  }
  Future compareImage() async {
    if(localPath==""){
      print("缺少本地图片");
    }else{
      var result= await FlutterArcface.compareImage(path1:localPath,path2: _image.path);
      print(result);
    }
//    try {
//      Map<PermissionGroup, PermissionStatus> permissions =
//      await PermissionHandler()
//          .requestPermissions([PermissionGroup.storage]);
//      if(permissions.entries.elementAt(0).value==PermissionStatus.granted){
//        Map<PermissionGroup, PermissionStatus> permissions =
//        await PermissionHandler()
//            .requestPermissions([PermissionGroup.phone]);
//        if(permissions.entries.elementAt(0).value==PermissionStatus.granted){
//
//        }
//      }
//    } on PlatformException {
//      print('wrong');
//    }
  }
  ///save netwrok image to photo
  Future<String> saveNetworkImageToPhoto(String url, {bool useCache: true}) async {
    var data = await getNetworkImageData(url, useCache: useCache);
    var filePath = await ImagePickerSaver.saveFile(fileData: data,title: 'headImage',description: 'to compare the face');
    return filePath;
  }
}
