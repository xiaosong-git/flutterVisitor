import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/JsonResult.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:city_pickers/city_pickers.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/DesUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:visitor/com/goldccm/visitor/view/common/LoadingDialog.dart';

/*
 * 实名认证
 * editor:ody997
 * email:hwk@growingpine.com
 * create_time:2019/11/12
 */
class IdentifyPage extends StatefulWidget {
  IdentifyPage({Key key, this.userInfo}) : super(key: key);
  final UserInfo userInfo;
  @override
  State<StatefulWidget> createState() {
    return IdentifyPageState();
  }
}
/*
 * _image 头像图片
 * realName 真实姓名
 * idNumber 身份证号码
 * address 地区
 * detailAddress 详细地址
 * _imageServerApiUrl 图片服务器地址
 */
class IdentifyPageState extends State<IdentifyPage> {
  File _image;
  final formKey = GlobalKey<FormState>();
  String realName;
  String idNumber;
  String address="";
  String detailAddress="";
  UserInfo userInfo;
  String _imageServerApiUrl;
  Map imageMap;
  var areaController = new TextEditingController();

  /*
   * 获取本地拍摄的图片
   */
  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera,imageQuality: 80,maxHeight: 360,maxWidth: 270);
    if(image!=null&&image.path!=null){
      image = await FlutterExifRotation.rotateImage(path: image.path);
      setState(() {
        _image = image;
      });
      ToastUtil.showShortToast("人像上传成功");
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
                    detailAddress = value;
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
                        //调用identify
                        LoadingDialog().show(context, "请求认证中");
                        identify().then((value){
                          Navigator.pop(context);
                          if(value){
                            Navigator.pop(context);
                          }
                        });
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
  /*
   * 获取图片服务器地址
   */
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
  /*
   * 实名认证
   * 先将头像上传
   * 然后验证是否已经实名
   * 是则实名，否返回上一页
   */
  Future<bool> identify() async {
    if (_image == null) {
      ToastUtil.showShortToast("请上传头像");
      return false;
    }
      String preurl = Constant.isVerifyUrl;
      String url = Constant.verifyUrl;
      String threshold = await CommonUtil.calWorkKey();
      var preres = await Http().post(preurl, queryParameters: {
        "token": userInfo.token,
        "userId": userInfo.id,
        "factor": CommonUtil.getCurrentTime(),
        "threshold": threshold,
        "requestVer": await CommonUtil.getAppVersion(),
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
        var imageres = await Http().postExt(imageurl, data: formData,headers: headers,debugMode: true);
        imageMap = jsonDecode(imageres);
        String threshold = await CommonUtil.calWorkKey();
        if (imageMap['data']['imageFileName'] != null) {
          var res = await Http().post(url, queryParameters: {
            "token":userInfo.token,
            "userId":userInfo.id,
            "factor":CommonUtil.getCurrentTime(),
            "threshold": threshold,
            "requestVer": await CommonUtil.getAppVersion(),
            "realName": realName.trim(),
            "idNO": await DesUtil().decryptHex(idNumber.trim(),userInfo.workKey),
            "address": address + " " + detailAddress,
            "idHandleImgUrl": imageMap['data']['imageFileName'],
            "idType":01,
          },debugMode: true,userCall: true);
          if(res is String&&res!=""){
            Map map = jsonDecode(res);
            if(map['verify']['sign']=="success"){
              ToastUtil.showShortToast("认证成功");
              await updateAuthStatus();
              return true;
            }else{
              ToastUtil.showShortToast(map['verify']['desc']);
             return false;
            }
          }else{
            ToastUtil.showShortToast("认证失败");
          }
        } else {
          ToastUtil.showShortToast("头像上传失败");
          return false;
        }
      } else {
        ToastUtil.showShortToast("您已实名");
        return true;
      }
      return true;
  }
  /*
   * 更新实名状态
   * save LocalStorage
   * updateUserInfo SP
   * update Provider
   */
  Future updateAuthStatus() async {
    var userProvider=Provider.of<UserModel>(context);
    UserInfo userInfo = await LocalStorage.load("userInfo");
    userInfo.realName=realName;
    userInfo.idType="01";
    userInfo.idNO=await DesUtil().decryptHex(idNumber.trim(),userInfo.workKey);
    userInfo.idHandleImgUrl=imageMap['data']['imageFileName'];
    userInfo.isAuth="T";
    userInfo.addr=address + " " + detailAddress;
    LocalStorage.save("userInfo",userInfo);
    userProvider.init(userInfo);
    DataUtils.updateUserInfo(userInfo);
  }
}

