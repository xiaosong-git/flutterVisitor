import 'dart:async';
import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/util/PremissionHandlerUtil.dart';
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
    //权限获取
    await PermissionHandlerUtil().initPermission();
    PermissionHandlerUtil().askStoragePermission();
      _t = new Timer(const Duration(milliseconds: 1500), () {
        //延时操作启动页面后跳转到主页面
        try {
          Navigator.of(context).pushAndRemoveUntil(
              new MaterialPageRoute(
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

    return new Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color:Color.fromRGBO(88, 123, 239, 1.0),
      child: Container(
        child: FittedBox(
          fit: BoxFit.none,
          child: Image.asset('assets/icons/Logo跳转图片.png',scale: 2.0,),
        ),
      ),
    );
  }
 //检测是否登录
  void checkIsLogin() async {
    isLogin = await DataUtils.isLogin();
  }
}
