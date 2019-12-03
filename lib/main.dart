import 'package:flutter/material.dart';
import 'package:flutter_arcface/flutter_arcface.dart';
import 'package:provider/provider.dart';
import 'com/goldccm/visitor/model/BadgeModel.dart';
import 'com/goldccm/visitor/model/UserModel.dart';
import 'com/goldccm/visitor/util/UMPushUtils.dart';
import 'splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
/*
 * 启动方法
 * userModel 用户信息
 * badgeModel 消息数量
 * FlutterArcFace 虹软人脸识别插件激活
 * UMPush 友盟推送
 */
void main() {
  Provider.debugCheckInvalidValueType = null;
  final UserModel userModel = UserModel();
  final BadgeModel badgeModel = BadgeModel();
  FlutterArcface.active();
  userModel.init(null);
  badgeModel.init();
  UMPush().init();
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider<UserModel>.value(value: userModel),
          ChangeNotifierProvider<BadgeModel>.value(value: badgeModel),
        ],
      child: new MaterialApp(
        title: "朋悦比邻",
        theme: new ThemeData(
          primaryIconTheme: const IconThemeData(color: Colors.white),
          brightness: Brightness.light,
          primaryColor:Colors.blue,
          accentColor: Colors.purple,
          backgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            color: Colors.blue[700],
          )
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('zh','CH'),
          const Locale('en','US'),
        ],
        home: SplashPage(),
      )
    ),
  );
}