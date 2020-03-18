import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'com/goldccm/visitor/util/DataUtils.dart';
import 'home.dart';
import 'package:visitor/com/goldccm/visitor/view/login/Login.dart';

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SplashState();
  }
}

class SplashState extends State<SplashPage> {
  Timer _t;
  bool isLogin;
  @override
  initState() {
    super.initState();
    checkIsLogin();
    checkPermission();
  }

  Future checkPermission() async {
    if(Platform.isAndroid){

    }
    //权限获取
      _t = new Timer(const Duration(milliseconds: 2000), () {
        //延时操作启动页面后跳转到主页面
        try {
          Navigator.of(context).pushAndRemoveUntil(
              new CupertinoPageRoute(
                  builder: (BuildContext context) =>
                  isLogin == true ? new MyHomeApp() : new Login()
              ),
                  (Route route) => route == null);
        } catch (e) {}
      });
  }
  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    return new Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Container(
        child: FittedBox(
          fit: BoxFit.cover,
          child: Image.asset('assets/images/app_splash.png'),
        ),
      ),
    );
  }
 //检测是否登录
  void checkIsLogin() async {
    isLogin = await DataUtils.isLogin();
  }
}
