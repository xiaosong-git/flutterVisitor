import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';
import 'package:visitor/com/goldccm/visitor/util/NPushUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'com/goldccm/visitor/model/BadgeModel.dart';
import 'com/goldccm/visitor/model/UserModel.dart';
import 'splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

 // userModel 用户信息
 // badgeModel 消息数量
 // NPush().init() 个推推送
 // RouterUtil.init() 服务器地址初始化

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  final UserModel userModel = UserModel();
  final BadgeModel badgeModel = BadgeModel();
  userModel.init(null);
  badgeModel.init();
  NPush().init();
  RouterUtil.init();
  SystemUiOverlayStyle routerLoginStyle= SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  );
  SystemChrome.setSystemUIOverlayStyle(routerLoginStyle);
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
          GlobalEasyRefreshLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('zh','CH'),
          const Locale('en','US'),
          const Locale('en', ''),
          const Locale('zh','CN'),
        ],
        home:SplashPage(),
      )
    ),
  );

}