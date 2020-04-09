import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';

//照片裁剪
class EditImagePage extends StatefulWidget{
  final String type;
  EditImagePage({Key key,this.type}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return EditImagePageState();
  }
}
class EditImagePageState extends State<EditImagePage>{
  final cropKey = GlobalKey<CropState>();
  File _file;
  File _sample;
  File _lastCropped;
  @override
  void initState() {
    super.initState();
    _openImage();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
          children: <Widget>[
            _sample!=null?Container(
              color: Colors.black,
              child: Crop(
                key: cropKey,
                image: FileImage(_sample),
                aspectRatio: 4.0 / 4.0,
              ),
            ):Container(),
            Positioned(
              bottom: 20,
              left: 20,
              child:FlatButton(
                child:Text('取消',style: TextStyle(color: Colors.white),),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FlatButton(
                child: Text('确定',style: TextStyle(color: Colors.white),),
                onPressed: _cropImage,
              ),
            )
          ],
      )
    );
  }
  Future<void> _openImage() async {
    var file;
    if(widget.type=="gallery"){
      file = await ImagePicker.pickImage(source: ImageSource.gallery,maxWidth: 1280,maxHeight: 720);
    }
    if(widget.type=="camera"){
      file = await ImagePicker.pickImage(source: ImageSource.camera,maxWidth: 1280,maxHeight: 720);
    }
    if(file!=null){
      var sample = await ImageCrop.sampleImage(
        file: file,
        preferredSize: context.size.longestSide.ceil(),
      );
      _sample?.delete();
      setState(() {
        _sample = sample;
        _file = file;
      });
    }else{
      Navigator.pop(context);
    }
  }

  Future<void> _cropImage() async {
    var scale = cropKey.currentState.scale;
    var area = cropKey.currentState.area;
    if (area == null) {
      // cannot crop, widget is not setup
      return;
    }
    print(scale);
    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    var sample = await ImageCrop.sampleImage(
      file: _file,
      preferredSize: (2000 / scale).round(),
    );

    var file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );
    sample?.delete();
    _lastCropped?.delete();
    _lastCropped = file;
    Navigator.pop(context,_lastCropped);
  }
}