import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/util/CacheUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/MessageUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/login/Login.dart';


///设置
class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingPageState();
  }
}

class SettingPageState extends State<SettingPage> {
  String size;
  @override
  void initState() {
    super.initState();
    getCacheSize();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: new AppBar(
        title: const Text('设置',style: TextStyle(fontSize: 17.0),textScaleFactor: 1.0),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.color,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: new Column(
        children: <Widget>[
          new Container(
            child: new Column(
              children: <Widget>[
                Center(
                  child: new Image.asset('assets/icons/ic_launcher.png',
                      scale: 0.8),
                ),
                new Container(
                  padding: EdgeInsets.all(10.0),
                  child: Center(
                    child: new Text('版本号 3.2.1',textScaleFactor: 1.0),
                  ),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(0, 50.0, 0, 50.0),
          ),
          new Container(
            padding: EdgeInsets.all(10.0),
            child: new SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              child: new RaisedButton(
                elevation: 10.0,
                color: Colors.blue,
                textColor: Colors.white,
                child: new Text('清除缓存,当前大小$size',textScaleFactor: 1.0),
                //清除缓存
                onPressed: () async {
                  MessageUtils.player?.clear("message.mp3");
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
            ),
          ),
          new Container(
            padding: EdgeInsets.all(10.0),
            child: new SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              child: new RaisedButton(
                color: Colors.blue,
                elevation: 10.0,
                textColor: Colors.white,
                child: new Text('安全退出',textScaleFactor: 1.0),
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
    );
  }
  outLogin() async {
    UserInfo user=await LocalStorage.load("userInfo");
    String url =Constant.serverUrl+"app/quit";
    String threshold = await CommonUtil.calWorkKey(userInfo: user);
    var res = await Http().post(url,queryParameters: {
      "token": user.token,
      "userId": user.id,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": CommonUtil.getAppVersion(),
    });
    if(res != null){
      if(res is String){
        Map map = jsonDecode(res);
        if(map['verify']['sign']=="success"){
          SharedPreferences sp = await SharedPreferences.getInstance();sp.setBool("isLogin", false);
          MessageUtils.closeChannel();
          Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
        }
      }
    }
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
}
