import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/JsonResult.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/util/CacheUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/MessageUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/login/ForgetPassword.dart';
import 'package:visitor/com/goldccm/visitor/view/login/Login.dart';
import 'package:visitor/com/goldccm/visitor/view/Mine/aboutus.dart';
import 'package:visitor/com/goldccm/visitor/view/Mine/securitypage.dart';


///设置
class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingPageState();
  }
}

class SettingPageState extends State<SettingPage> {
  String size;
  String version;
  bool isUpdate=false;
  bool pwdClose=false;
  UserInfo _userInfo=UserInfo();
  @override
  void initState() {
    super.initState();
    getCacheSize();
    getVersion();
    getUser();
    checkVersion();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Container(
        color: Color(0xFFF8F8F8),
        child: Column(
          children: <Widget>[
            Container(
              color: Color(0xFFFFFFFF),
              height: ScreenUtil().setHeight(88)+MediaQuery.of(context).padding.top,
              width: ScreenUtil().setWidth(750),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                        right: ScreenUtil().setWidth(245), left: 0),
                    child: IconButton(
                        icon: Image(
                          image: AssetImage("assets/images/back_white.png"),
                          width: ScreenUtil().setWidth(36),
                          height: ScreenUtil().setHeight(36),
                          color: Color(0xFF595959),),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        }),
                  ),
                  Text('设置', style: TextStyle(color: Color(0xFF373737),
                    fontSize: ScreenUtil().setSp(36),),),
                ],
              ),
            ),
            Container(
              child: Divider(
                height: 1,
              ),
            ),
            Container(
              width: ScreenUtil().setWidth(750),
              color: Color(0xFFFFFFFF),
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(32),right:ScreenUtil().setWidth(32)),
              child: Column(
                children: <Widget>[
                  InkWell(
                    child: Container(
                      child:Stack(
                        children: <Widget>[
                          Positioned(
                            left: ScreenUtil().setWidth(0),
                            top: ScreenUtil().setHeight(30),
                            child: Text('更换手机号码',style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(30)),),
                          ),
                          Positioned(
                            right: ScreenUtil().setWidth(36),
                            top: ScreenUtil().setHeight(36),
                            child: Text(_userInfo.phone!=null?_userInfo.phone:"",style: TextStyle(color: Color(0xFF595959),fontSize: ScreenUtil().setSp(30)),),
                          ),
                          Positioned(
                            right: ScreenUtil().setWidth(0),
                            top: ScreenUtil().setHeight(32),
                            child:   Image(
                              width: ScreenUtil().setWidth(50),
                              height: ScreenUtil().setHeight(50),
                              image: AssetImage('assets/images/mine_next.png'),
                              color: Color(0xFFB0B0B0),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                      height: ScreenUtil().setHeight(100),
                      width: ScreenUtil().setWidth(750-64),
                    ),
                    onTap: (){
                      Navigator.push(context,
                          CupertinoPageRoute(builder: (context) => ChangePhonePage()));
                    },
                  ),
                  pwdClose?Container():Divider(height: 1,),
                  pwdClose?Container():InkWell(
                    child:Container(
                      child:Stack(
                        children: <Widget>[
                          Positioned(
                            left: ScreenUtil().setWidth(0),
                            top: ScreenUtil().setHeight(30),
                            child: Text('修改密码',style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(30)),),
                          ),
                          Positioned(
                            right: ScreenUtil().setWidth(0),
                            top: ScreenUtil().setHeight(32),
                            child:   Image(
                              width: ScreenUtil().setWidth(50),
                              height: ScreenUtil().setHeight(50),
                              image: AssetImage('assets/images/mine_next.png'),
                              color: Color(0xFFB0B0B0),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                      height: ScreenUtil().setHeight(100),
                      width: ScreenUtil().setWidth(750-64),
                    ),
                    onTap: _forget,
                  ),
                  Divider(height: 1,),
                  InkWell(
                    child:Container(
                      child:Stack(
                        children: <Widget>[
                          Positioned(
                            left: ScreenUtil().setWidth(0),
                            top: ScreenUtil().setHeight(30),
                            child: Text('清除缓存',style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(30)),),
                          ),
                          !Platform.isIOS?Positioned(
                            right: ScreenUtil().setWidth(36),
                            top: ScreenUtil().setHeight(36),
                            child: Text('$size',style: TextStyle(color: Color(0xFF595959),fontSize: ScreenUtil().setSp(34)),),
                          ):Positioned(
                            right: ScreenUtil().setWidth(36),
                            top: ScreenUtil().setHeight(36),
                            child: Text('',style: TextStyle(color: Color(0xFF595959),fontSize: ScreenUtil().setSp(34)),),
                          ),
                          Positioned(
                            right: ScreenUtil().setWidth(0),
                            top: ScreenUtil().setHeight(32),
                            child:   Image(
                              width: ScreenUtil().setWidth(50),
                              height: ScreenUtil().setHeight(50),
                              image: AssetImage('assets/images/mine_next.png'),
                              color: Color(0xFFB0B0B0),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                      height: ScreenUtil().setHeight(100),
                      width: ScreenUtil().setWidth(750-64),
                    ),
                    onTap: (){
                      MessageUtils.player?.clear("message.mp3");
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return new Material(
                              type: MaterialType.transparency,
                              child: Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.all(15.0),
                                child: new SizedBox(
                                  height: MediaQuery.of(context).size.height / 3.5,
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        decoration: ShapeDecoration(
                                          color: Color(0xffffffff),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                        child: new Column(
                                          children: <Widget>[
                                            new Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15.0, bottom: 10.0),
                                              child: new Text(
                                                  '确认清空应用的本地缓存数据？',
                                                  style: new TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black45,
                                                  ),textScaleFactor: 1.0
                                              ),
                                            ),
                                            Divider(
                                              height: 0,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: FlatButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  //清除缓存
                                                  CacheUtils cacheUtils = new CacheUtils();
                                                  if (size != "0.00B") {
                                                    cacheUtils.clearCache();
                                                    setState(() {
                                                      size = "0.00B";
                                                    });
                                                  }
                                                  ToastUtil.showShortToast("            清除完毕            ");
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                      30,
                                                  child: Text(
                                                      '清除缓存数据',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 18.0,
                                                          color: Colors.red),textScaleFactor: 1.0
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10.0),
                                        width: MediaQuery.of(context).size.width,
                                        decoration: ShapeDecoration(
                                          color: Color(0xffffffff),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                        child: new Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: FlatButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                    width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                        30,
                                                    child: Text(
                                                      '取消',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 18.0,
                                                          color: Colors.blue),textScaleFactor: 1.0,
                                                    )),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    },
                  ),
                  Divider(height: 1,),
                  InkWell(
                    child:Container(
                      child:Stack(
                        children: <Widget>[
                          Positioned(
                            left: ScreenUtil().setWidth(0),
                            top: ScreenUtil().setHeight(30),
                            child: Text('检查更新',style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(30)),),
                          ),
                          Positioned(
                            right: ScreenUtil().setWidth(36),
                            top: ScreenUtil().setHeight(40),
                            child: isUpdate?
                            Container(
                              width: ScreenUtil().setWidth(70),
                              height: ScreenUtil().setHeight(36),
                              color: Color(0xFFFD3E3E),
                              child: Center(child: Text('NEW',style: TextStyle(color: Colors.white,fontSize: ScreenUtil().setSp(28)),),),):Container(),
                          ),
                          Positioned(
                            right: ScreenUtil().setWidth(0),
                            top: ScreenUtil().setHeight(32),
                            child:   Image(
                              width: ScreenUtil().setWidth(50),
                              height: ScreenUtil().setHeight(50),
                              image: AssetImage('assets/images/mine_next.png'),
                              color: Color(0xFFB0B0B0),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                      height: ScreenUtil().setHeight(100),
                      width: ScreenUtil().setWidth(750-64),
                    ),
                    onTap: (){
                      checkIsUpdate();
                    },
                  ),
                  Divider(height: 1,),
                  InkWell(
                    child: Container(
                      child:Stack(
                        children: <Widget>[
                          Positioned(
                            left: ScreenUtil().setWidth(0),
                            top: ScreenUtil().setHeight(30),
                            child: Text('关于我们',style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(30)),),
                          ),
                          Positioned(
                            right: ScreenUtil().setWidth(0),
                            top: ScreenUtil().setHeight(32),
                            child:   Image(
                              width: ScreenUtil().setWidth(50),
                              height: ScreenUtil().setHeight(50),
                              image: AssetImage('assets/images/mine_next.png'),
                              color: Color(0xFFB0B0B0),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                      height: ScreenUtil().setHeight(100),
                      width: ScreenUtil().setWidth(750-64),
                    ),
                    onTap: (){
                      Navigator.push(context,
                          new CupertinoPageRoute(builder: (BuildContext context) {
                            return new AboutUs();
                          }));
                    },
                  ),
                ],
              ),
            ),
            new Container(
              padding: EdgeInsets.only(top: ScreenUtil().setHeight(180),left: ScreenUtil().setWidth(112),right: ScreenUtil().setWidth(112)),
              child: new SizedBox(
                width: MediaQuery.of(context).size.width,
                height: ScreenUtil().setHeight(90),
                child: new RaisedButton(
                  color: Color(0xFF0073FE),
                  elevation: 10.0,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0),
                  ),
                  child: new Text('退出登录',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36)),),
                  onPressed: () async {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return new Material(
                            //创建透明层
                            type: MaterialType.transparency, //透明类型
                            child: Container(
                              //保证控件居中效果
                              alignment: Alignment.bottomCenter,
                              margin: EdgeInsets.all(15.0),
                              child: new SizedBox(
                                height: MediaQuery.of(context).size.height / 3.5,
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      decoration: ShapeDecoration(
                                        color: Color(0xffffffff),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                        ),
                                      ),
                                      child: new Column(
                                        children: <Widget>[
                                          new Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15.0, bottom: 10.0),
                                            child: new Text(
                                                '确认退出？',
                                                style: new TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.black45,
                                                ),textScaleFactor: 1.0
                                            ),
                                          ),
                                          Divider(
                                            height: 0,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, bottom: 5),
                                            child: FlatButton(
                                              onPressed: () async {
                                                //将保存在sp内的登录识别isLogin置为false
                                                //然后退出应用
                                                Navigator.pop(context);
                                                await outLogin();
                                              },
                                              child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                      30,
                                                  child: Text(
                                                      '退出登录',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 18.0,
                                                          color: Colors.red),textScaleFactor: 1.0
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 10.0),
                                      width: MediaQuery.of(context).size.width,
                                      decoration: ShapeDecoration(
                                        color: Color(0xffffffff),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                        ),
                                      ),
                                      child: new Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, bottom: 5),
                                            child: FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                      30,
                                                  child: Text(
                                                      '取消',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 18.0,
                                                          color: Colors.blue),textScaleFactor: 1.0
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  outLogin() async {
    UserInfo user=await LocalStorage.load("userInfo");
    String url ="app/quit";
    String threshold = await CommonUtil.calWorkKey(userInfo: user);
    var res = await Http().post(url,queryParameters: {
      "token": user.token,
      "userId": user.id,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
    },userCall: true);
    if(res != null&&res!=""){
      if(res is String){
        Map map = jsonDecode(res);
        if(map['verify']['sign']=="success"){

        }
      }
    }
    SharedPreferences sp = await SharedPreferences.getInstance();sp.setBool("isLogin", false);
    MessageUtils.closeChannel();
    Navigator.push(context, CupertinoPageRoute(builder: (context) => Login()));
  }
  //获取缓存的大小
  getCacheSize() async {
    CacheUtils cacheUtils = new CacheUtils();
    size = await cacheUtils.loadCache();
    setState((){
      if(size==null){
        size="0.0B";
      }
    });
  }
  Future getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version=packageInfo.version;
    });
  }
  void _forget() {
    setState(() {
      Navigator.push(context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return new ForgetPasswordPage(text: '修改密码',outer: false,);
          }));
    });
  }
  getUser() async {
    _userInfo=await LocalStorage.load("userInfo");
    String status=await RouterUtil.getStatus();
    if(status=="local"){
      setState(() {
        pwdClose=true;
      });
    }
  }
  checkIsUpdate() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      bool isUpToDate = true;
      //android
      if (Platform.isAndroid) {
        String url =
            "appVersion/updateAndroid/visitor/$buildNumber";
        var res = await Http().post(url, userCall: false);
        if (res != null) {
          if (res is String) {
            Map map = jsonDecode(res);
            if (map['verify']['sign'] == "success") {
              var remoteVersion = (map['data']['versionName']).split(".");
              var localVersion = version.split(".");
              String isForce = map['data']['isImmediatelyUpdate'];
              for (int i = 0; i < remoteVersion.length; i++) {
                if (int.parse(remoteVersion[i]) > int.parse(localVersion[i])) {
                  isUpToDate = false;
                }
              }
              var remoteNum = int.parse(map['data']['versionNum']);
              var localNum = int.parse(buildNumber);
              if (remoteNum > localNum && map['data']['versionName'] == version) {
                isUpToDate = false;
              }
              if (!isUpToDate) {
                String url = map['data']['updateUrl'];
                showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return WillPopScope(
                        child: AlertDialog(
                          title: Row(
                            children: <Widget>[
                              new Image.asset("assets/images/login_logo.png",
                                height: 40.0, width: 40.0,fit: BoxFit.fill,),
                              new Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      20.0, 0.0, 10.0, 0.0),
                                  child: new Text(
                                    "朋悦比邻",
                                  ))
                            ],
                          ),
                          content: new Text(
                            '${map['data']['versionName']}版本更新',
                          ),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text('忽略',
                                  style: TextStyle(color: Colors.grey[400])),
                              onPressed: () {
                                if (isForce == "T") {
                                  ToastUtil.showShortClearToast(
                                      "当前版本太过老旧，请立即更新后使用");
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                            new FlatButton(
                              child: new Text(
                                '立即更新',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () async {
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                            )
                          ],
                        ),
                        onWillPop: () {
                          return null;
                        },
                      );
                    });
              }
            }else{
              ToastUtil.showShortClearToast(map['verify']['desc']);
            }
          }
        }
      }
      //ios
      else if (Platform.isIOS) {
        String url = "appVersion/updateIOS";
        var res = await Http().post(url, userCall: false);
        if (res != null) {
          if (res is String) {
            Map map = jsonDecode(res);
            if (map['verify']['sign'] == "success") {
              var remoteVersion = (map['data']['versionNum']).split(".");
              var localVersion = version.split(".");
              String isForce = map['data']['isImmediatelyUpdate'];
              for (int i = 0; i < remoteVersion.length; i++) {
                if (int.parse(remoteVersion[i]) > int.parse(localVersion[i])) {
                  isUpToDate = false;
                }
              }
              if (!isUpToDate) {
                String url = map['data']['updateUrl'];
                showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return WillPopScope(
                        child: AlertDialog(
                          title: Row(
                            children: <Widget>[
                              new Image.asset("assets/images/login_logo.png",
                                height: 40.0, width: 40.0,fit: BoxFit.fill,),
                              new Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      20.0, 0.0, 10.0, 0.0),
                                  child: new Text(
                                    "朋悦比邻",
                                  ))
                            ],
                          ),
                          content: new Text(
                            '${map['data']['versionNum']}版本更新',
                          ),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text(
                                '稍后',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              onPressed: () {
                                if (isForce == "T") {
                                  ToastUtil.showShortClearToast(
                                      "当前版本太过老旧，请立即更新后使用");
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                            new FlatButton(
                              child: new Text(
                                '立即更新',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () async {
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                            )
                          ],
                        ),
                        onWillPop: () {
                          return null;
                        },
                      );
                    });
              }
            }else{
              ToastUtil.showShortClearToast(map['verify']['desc']);
            }
          }
        }
      }
  }
  //检查版本更新
  checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    bool isUpToDate = true;
    //android
    if (Platform.isAndroid) {
      String url =
          "appVersion/updateAndroid/visitor/$buildNumber";
      var res = await Http().post(url, userCall: false);
      if (res != null) {
        if (res is String) {
          Map map = jsonDecode(res);
          if (map['verify']['sign'] == "success") {
            var remoteVersion = (map['data']['versionName']).split(".");
            var localVersion = version.split(".");
            String isForce = map['data']['isImmediatelyUpdate'];
            for (int i = 0; i < remoteVersion.length; i++) {
              if (int.parse(remoteVersion[i]) > int.parse(localVersion[i])) {
                isUpToDate = false;
                isUpdate = true;
              }
            }
            var remoteNum = int.parse(map['data']['versionNum']);
            var localNum = int.parse(buildNumber);
            if (remoteNum > localNum && map['data']['versionName'] == version) {
              isUpToDate = false;
              isUpdate = true;
            }
          }
        }
      }
    }
    //ios
    else if (Platform.isIOS) {
      String url = "appVersion/updateIOS";
      var res = await Http().post(url, userCall: false);
      if (res != null) {
        if (res is String) {
          Map map = jsonDecode(res);
          if (map['verify']['sign'] == "success") {
            var remoteVersion = (map['data']['versionNum']).split(".");
            var localVersion = version.split(".");
            String isForce = map['data']['isImmediatelyUpdate'];
            for (int i = 0; i < remoteVersion.length; i++) {
              if (int.parse(remoteVersion[i]) > int.parse(localVersion[i])) {
                isUpToDate = false;
                isUpdate = true;
              }
            }
          }
        }
      }
    }
  }
}
