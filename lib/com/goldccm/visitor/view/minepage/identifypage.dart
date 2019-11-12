import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/JsonResult.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:city_pickers/city_pickers.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/DesUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';

///实名验证
class IdentifyPage extends StatefulWidget {
  IdentifyPage({Key key, this.userInfo}) : super(key: key);
  final UserInfo userInfo;
  @override
  State<StatefulWidget> createState() {
    return IdentifyPageState();
  }
}

class IdentifyPageState extends State<IdentifyPage> {
  File _image;
  final formKey = GlobalKey<FormState>();
  String realName;
  String idNumber;
  String address="";
  String deatilAddress="";
  UserInfo userInfo;
  String _imageServerApiUrl;
  var areaController = new TextEditingController();
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera,maxWidth: 480,maxHeight: 640);
    if(image!=null&&image.path!=null){
      image = await FlutterExifRotation.rotateImage(path: image.path);
      setState(() {
        _image = image;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    userInfo = widget.userInfo;
    getImageServerApiUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text( '实名认证',   style: new TextStyle(
            fontSize: 17.0, color: Colors.white),textScaleFactor: 1.0),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.color,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){Navigator.pop(context);}),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      height: 100,
                      width: 100,
                      child: ClipOval(
                        child: _image == null
                            ? Image.asset('assets/images/visitor_icon_head.png',
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
                          child: Text('点击拍摄照片',style: TextStyle(color: Colors.white),textScaleFactor: 1.0), onPressed: getImage),
                    ),
                  ],
                ),
              ),
              Container(
                height: 30,
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                alignment: Alignment.centerLeft,
                child: Text(
                  '身份信息（必填）',
                  style: TextStyle(fontSize:14.0,color: Colors.black45),textScaleFactor: 1.0
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                color: Colors.white,
                child: TextFormField(
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '请输入您的真实姓名',
                      hintStyle: TextStyle(
                        fontSize: Constant.normalFontSize,
                      )),
                  style: TextStyle(
                    fontSize: Constant.normalFontSize,
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return '请填入您的真实姓名';
                    }
                    return '';
                  },
                  onSaved: (value) {
                    realName = value;
                  },
                ),
              ),
              Divider(
                height: 0,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                color: Colors.white,
                child: TextFormField(
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '请输入您的身份证号码',
                      hintStyle: TextStyle(
                        fontSize: Constant.normalFontSize,
                      )),
                  validator: (value) {
                    if (value.isEmpty) {
                      return '请输入您的身份证号码';
                    }
                    return '';
                  },
                  style: TextStyle(
                    fontSize: Constant.normalFontSize,
                  ),
                  onSaved: (value) {
                    idNumber = value;
                  },
                ),
              ),
              Container(
                height: 30,
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                alignment: Alignment.centerLeft,
                child: Text('地址信息（选填）',
                  style: TextStyle(fontSize:14.0,color: Colors.black45),textScaleFactor: 1.0
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                color: Colors.white,
                child: InkWell(
                  onTap: () async {
                    Result result = await CityPickers.showCityPicker(
                      context: context,
                    );
                    setState(() {
                      print(result);
                      if (result != null) {
                        areaController.text = result.provinceName +
                            "-" +
                            result.cityName +
                            "-" +
                            result.areaName;
                        address = result.provinceName +
                            result.cityName +
                            result.areaName;
                      }
                    });
                  },
                  child: TextFormField(
                    enabled: false,
                    controller: areaController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '请选择所在地区',
                        hintStyle: TextStyle(
                          fontSize: Constant.normalFontSize,
                        )),
                    style: TextStyle(
                      fontSize: Constant.normalFontSize,
                    ),
                  ),
                ),
              ),
              Divider(
                height: 0,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                color: Colors.white,
                child: TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '请输入详细地址信息，如道路、门牌号、小区、楼栋号、单元室等',
                      hintStyle: TextStyle(
                        fontSize: Constant.normalFontSize,
                      )),
                  style: TextStyle(
                    fontSize: Constant.normalFontSize,
                  ),
                  onSaved: (value) {
                    deatilAddress = value;
                  },
                ),
              ),
              new Container(
                padding: EdgeInsets.all(30.0),
                child: new SizedBox(
                  width: 300.0,
                  height: 50.0,
                  child: new RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: new Text('提交',textScaleFactor: 1.0),
                    onPressed: () async {
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        identify();
                      }
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  getImageServerApiUrl() async {
    String url = Constant.getParamUrl + "imageServerApiUrl";
    var response = await Http.instance
        .get(url, queryParameters: {"paramName": "imageServerApiUrl"});
    if (!mounted) return;
    setState(() {
      JsonResult responseResult = JsonResult.fromJson(response);
      if (responseResult.sign == 'success') {
        _imageServerApiUrl = responseResult.data;
        DataUtils.savePararInfo("imageServerApiUrl", _imageServerApiUrl);
      } else {
        ToastUtil.showShortToast(responseResult.desc);
      }
    });
  }
  identify() async {
    if (_image == null) {
      ToastUtil.showShortClearToast("未检测到头像");
    } else {
      String preurl = Constant.serverUrl + Constant.isVerifyUrl;
      String url = Constant.serverUrl + Constant.verifyUrl;
      String threshold = await CommonUtil.calWorkKey();
      var preres = await Http().post(preurl, queryParameters: {
        "token": userInfo.token,
        "userId": userInfo.id,
        "factor": CommonUtil.getCurrentTime(),
        "threshold": threshold,
        "requestVer": CommonUtil.getAppVersion(),
      },debugMode: true);
      Map premap = jsonDecode(preres);
      if (premap['verify']['sign'] == "fail") {
        String imageurl = Constant.imageServerApiUrl;
        var name = _image.path.split("/");
        var filename = name[name.length - 1];
        FormData formData = FormData.from({
          "userId": userInfo.id,
          "type": "3",
          "files": new UploadFileInfo(_image, filename),
        });
        var  headers = Map<String, String>();
        headers['Content-type']="application/x-www-form-urlencoded";
        var imageres = await Http().postExt(imageurl, data: formData,headers: headers);
        Map imagemap = jsonDecode(imageres);
        String threshold = await CommonUtil.calWorkKey();
        if (imagemap['data']['imageFileName'] != null) {
          var res = await Http().post(url, queryParameters: {
            "token":userInfo.token,
            "userId":userInfo.id,
            "factor":CommonUtil.getCurrentTime(),
            "threshold": threshold,
            "requestVer": CommonUtil.getAppVersion(),
            "realName": realName.trim(),
            "idNO": await DesUtil().decryptHex(idNumber.trim(),userInfo.workKey),
            "address": address + " " + deatilAddress,
            "idHandleImgUrl": imagemap['data']['imageFileName'],
            "idType":0,
          },debugMode: true);
          if(res is String){
            Map map = jsonDecode(res);
            if(map['verify']['sign']=="success"){
              ToastUtil.showShortClearToast("实名认证成功");
              Navigator.pop(context);
            }else{
              ToastUtil.showShortClearToast(map['verify']['desc']);
            }
          }
        } else {
          ToastUtil.showShortClearToast("头像上传失败，请重新上传！");
        }
      } else {
        ToastUtil.showShortClearToast("已经实名验证过");
      }
    }
  }
}

