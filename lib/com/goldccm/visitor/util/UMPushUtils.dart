import 'package:flutter_umpush/flutter_umpush.dart';
import 'package:shared_preferences/shared_preferences.dart';
/*
 * 友盟消息推送
 * Author:ody997
 * Email:hwk@growingpine.com
 * 2019/10/16
 */
class UMPush{
  static bool isConnected = false;
  static String registrationId="";
  static List notificationList = [];
  final FlutterUmpush _flutterUmpush = new FlutterUmpush();

  static getToken() async {
    if(registrationId!=""&&registrationId!=null){
      return registrationId;
    }
    SharedPreferences sp;
    await SharedPreferences.getInstance().then((value) {
      sp = value;
    });
    registrationId=sp.getString("deviceToken");
    return registrationId;
  }
  void init()async{
    _flutterUmpush.configure(
      onMessage: (String message) async {
        print("main onMessage: $message");
          notificationList.add(message);
        return true;
      },
      onLaunch: (String message) async {
        print("main onLaunch: $message");
        notificationList.add(message);
        return true;
      },
      onResume: (String message) async {
        print("main onResume: $message");
        notificationList.add(message);
        return true;
      },
      onToken: (String token) async {
        print("main onToken: $token");
        registrationId=token;
        SharedPreferences sp = await SharedPreferences.getInstance();
        await sp.setString("deviceToken", token);
        return true;
      },
    );
  }
}