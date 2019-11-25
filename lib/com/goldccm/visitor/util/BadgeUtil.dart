import 'dart:convert';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/ChatMessage.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'CommonUtil.dart';
import 'MessageUtils.dart';

/*
 * 消息数量提醒及更新
 * Author:ody997
 * Email:hwk@growingpine.com
 * 2019/10/16
 */
class BadgeUtil{
  static int _visitConfirmCount=0;
  static int _messageCount=0;
  static int _newFriendCount=0;

  static BadgeUtil _badge;

  factory BadgeUtil()=> _badgeUtil();

  BadgeUtil get instance => _badgeUtil();

  BadgeUtil._();

  static BadgeUtil _badgeUtil(){
    if(_badge==null){
      _badge=BadgeUtil._();
    }
    return _badge;
  }

  requestConfirmCount() async {
    String method1 = "visitorRecord/visitMyPeople/1/1";
    String method2 = "visitorRecord/visitMyCompany/1/1";
    int count1=await request(method1);
    int count2=await request(method2);
    return count1 + count2 ;
  }
  request(String method) async {
    int count=0;
    String url = Constant.serverUrl+method;
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
    var res = await Http().post(url,queryParameters:({
      "token": userInfo.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": CommonUtil.getAppVersion(),
      "userId": userInfo.id,
    }));
    if(res !=null){
      if(res is String){
        Map map = jsonDecode(res);
        if(map['verify']['sign']=="success"){
          count=int.parse(map['verify']['count']);
        }
      }
    }
    return count;
  }
  Future<int> requestNewFriendCount() async{
    String method = "userFriend/beAgreeingFriendList";
    int count=0;
    String url = Constant.serverUrl+method;
    UserInfo userInfo = await LocalStorage.load("userInfo");
        String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
        var res = await Http().post(url,queryParameters:({
          "token": userInfo.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": CommonUtil.getAppVersion(),
          "userId": userInfo.id,
        }));
        if(res !=null){
          if(res is String){
            Map map = jsonDecode(res);
            if(map['verify']['sign']=="success"){
              if(map['data']!=null){
                count=map['data'].length;
              }
            }
      }
    }
    return count;
  }
  Future<int> getMessageCount(UserInfo userInfo) async{
    _messageCount=0;
    List<ChatMessage> list = await MessageUtils.getLatestMessage(userInfo.id);
    if(list!=null){
      for(var chat in list){
        if(chat.unreadCount!=null){
          _messageCount=_messageCount+chat.unreadCount;
        }
      }
    }
    return _messageCount;
  }
 }