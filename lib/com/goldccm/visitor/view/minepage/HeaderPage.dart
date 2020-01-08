/*
 * 个人中心头像修改
 */
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';

class HeadImagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HeadImagePageState();
  }
}

class HeadImagePageState extends State<HeadImagePage> {

  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery,imageQuality: 80,maxHeight: 360,maxWidth: 270);
    setState(() {
      _image = image;
    });
    _uploadImg();
  }


  @override
  void initState() {
    super.initState();
  }
  Future getPhoto() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera,imageQuality: 80,maxHeight: 360,maxWidth: 270);
    print(image.absolute);
    print(await image.length());
    setState(() {
      _image = image;
    });
    _uploadImg();
  }

  @override
  Widget build(BuildContext context) {
    var userProvider=Provider.of<UserModel>(context);
    return WillPopScope(
      child:Scaffold(
          appBar: AppBar(
            title: Text('修改头像',textScaleFactor: 1.0),
            centerTitle: true,
            backgroundColor: Theme.of(context).appBarTheme.color,
            leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){Navigator.pop(context);}),
          ),
          body: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                height: 300,
                width: 300,
                child: ClipOval(
                  child: _image == null
                      ? Image.network(
                    RouterUtil.imageServerUrl +
                        (userProvider.info.headImgUrl != null
                            ? userProvider.info.headImgUrl
                            : userProvider.info.idHandleImgUrl),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                      : Image.file(
                    _image,
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
              Center(
                  child:
                  Container(
                    color: Colors.white,
                    margin: EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width-40,
                    height: 50,
                    child: RaisedButton(child: Text('点击从相册中选取照片',textScaleFactor: 1.0,style: TextStyle(fontSize: 16.0),), onPressed: getImage,elevation: 5.0,color: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),),
                  )
              ),
              Center(
                child:  Container(
                  color: Colors.white,
                  margin: EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width-40,
                  height: 50,
                  child:RaisedButton(child: Text('点击拍摄照片',textScaleFactor: 1.0,style: TextStyle(fontSize: 16.0),), onPressed: getPhoto,elevation: 5.0,color: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
            ],
          )),
      onWillPop: (){
        Navigator.pop(context);
      },
    );
  }
  ///修改后的头像上传和个人信息内的头像地址的修改
  _uploadImg() async {
    UserInfo _userInfo=await LocalStorage.load("userInfo");
    String url = RouterUtil.uploadServerUrl;
    var name = _image.path.split("/");
    var filename = name[name.length - 1];
    FormData formData = FormData.from({
      "userId": _userInfo.id,
      "type": "4",
      "file": new UploadFileInfo(_image, filename),
    });
    var res = await Http().post(url, data: formData);
    Map map = jsonDecode(res);
    var _userProvider=Provider.of<UserModel>(context);
    String nickurl =  Constant.updateNickAndHeadUrl;
    String threshold = await CommonUtil.calWorkKey();
    var nickres = await Http().post(nickurl, queryParameters: {
      "headImgUrl": map['data']['imageFileName'],
      "token": _userInfo.token,
      "userId": _userInfo.id,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
    });
    setState(() {
      _userInfo.headImgUrl = map['data']['imageFileName'];
      DataUtils.updateUserInfo(_userInfo);
      _userProvider.init(_userInfo);
      LocalStorage.save("userInfo", _userInfo);
    });
    if(nickres is String){
      Map nickmap = jsonDecode(nickres);
      if(nickmap['verify']['desc']=="success"){
        ToastUtil.showShortClearToast(nickmap['verify']['desc']);
        Navigator.pop(context);
      }else{
        ToastUtil.showShortClearToast(nickmap['verify']['desc']);
      }
    }
  }

}
