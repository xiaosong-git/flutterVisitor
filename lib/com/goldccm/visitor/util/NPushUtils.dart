import 'dart:io';

import 'package:getuiflut/getuiflut.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
/*
 * 友盟消息推送
 * Author:ody997
 * Email:hwk@growingpine.com
 * 2019/10/16
 */
class NPush{

  static NPush _nPush;
  factory NPush() => _umP();
  NPush get instance => _umP();
  NPush._internal();
  static NPush _umP(){
    if(_nPush==null){
      _nPush=NPush._internal();
    }
    return _nPush;
  }
  //个推用户标识，需要上传到服务器与用户id关联
  static String clientId="";
  static String deviceToken="";
  static String voipToken="";
  static String payLoadInfo="";
  static String registrationId="";
  static String notificationState="";
  static String receivePayLoad="";
  static String notificationResponse="";
  static String appLinkPayLoad="";
  static String receiveVoipPayLoad="";
  final Getuiflut _getuiflut=new Getuiflut();

  Future<String> getClientId() async {
    String getClientId="";
    try {
      getClientId = await Getuiflut.getClientId;
      print(getClientId);
    } catch(e) {
      print(e.toString());
    }
    return clientId;
  }

  void init()async{
    if(Platform.isIOS){
      Getuiflut().startSdk(
          appId: "VAnoRfQ8kk69vx2rrR9tS4",
          appKey: "6oDzNCRD1PAvAE293LLaY9",
          appSecret: "dnYA43YSz16"
      );
    }
    if(Platform.isAndroid){
      try{
        Getuiflut.initGetuiSdk;
      }catch(e){
        print(e.toString());
      }
    }
    Getuiflut().addEventHandler(
      //注册收到cid的回调
      onReceiveClientId: (String message) async {
        print("flutter onReceiveClientId: $message");
        clientId=message;
      },
      //透传消息内容走这里
      onReceiveMessageData: (Map<String, dynamic> msg) async {
        print("flutter onReceiveMessageData: $msg");
        ToastUtil.showShortClearToast("收到透传消息");
      },
      //消息到达的回调
      onNotificationMessageArrived: (Map<String, dynamic> msg) async {
        print("flutter onNotificationMessageArrived");
        notificationState='Arrived';
      },
      //消息点击的回调
      onNotificationMessageClicked: (Map<String, dynamic> msg) async {
        print("flutter onNotificationMessageClicked");
        notificationState='Clicked';
      },
      onRegisterDeviceToken: (String message) async {
        deviceToken=message;
      },
      onReceivePayload: (Map<String, dynamic> message) async {

      },
      onReceiveNotificationResponse: (Map<String, dynamic> message) async {

      },
      onAppLinkPayload: (String message) async {

      },
      onRegisterVoipToken: (String message) async {

      },
      onReceiveVoipPayLoad: (Map<String, dynamic> message) async {

      },
    );
  }
  void stopPush(){
    Getuiflut().stopPush();
  }
  void resumePush(){
    Getuiflut().resumePush();
  }
  void bindAlias({String alias,String sn}){
    Getuiflut().bindAlias(alias, sn);
  }
  void unBindAlias({String alias,String sn}){
    Getuiflut().unbindAlias(alias, sn, true);
  }
  void setTags(List list){
    Getuiflut().setTag(list);
  }
  void setBadge(int num){
    Getuiflut().setBadge(num);
  }
  void resetBadge(){
    Getuiflut().resetBadge();
  }
}