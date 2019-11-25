import 'package:flutter/material.dart';
import 'package:flutter_arcface/flutter_arcface.dart';
import 'package:provider/provider.dart';
import 'com/goldccm/visitor/model/UserModel.dart';
import 'com/goldccm/visitor/util/UMPushUtils.dart';
import 'splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  //userModel 全局数据
  Provider.debugCheckInvalidValueType = null;
  final UserModel userModel = UserModel();
  FlutterArcface.active();
  userModel.init(null);
  //umPush 友盟推送
  UMPush().init();
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider<UserModel>.value(value: userModel),
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