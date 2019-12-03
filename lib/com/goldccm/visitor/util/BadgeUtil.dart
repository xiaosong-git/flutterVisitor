import 'dart:convert';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/ChatMessage.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/provider/BadgeInfo.dart';
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

  static BadgeInfo _badgeInfo=new BadgeInfo();
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

  //消息数值初始化
  //TODO 邀约、公告数量待实现
  init() async {
    UserInfo userInfo=await LocalStorage.load("userInfo");
    _badgeInfo.newMessageCount=await getMessageCount(userInfo);
    _badgeInfo.newFriendRequestCount=await requestNewFriendCount();
    _badgeInfo.newVisitCount=await requestConfirmCount();
    _badgeInfo.newNoticeCount=0;
    _badgeInfo.newInviteCount=0;
    return _badgeInfo;
  }
  //更新访问
  updateVisit() async {
    _badgeInfo.newVisitCount=await requestConfirmCount();
    return _badgeInfo;
  }
  //更新消息
  updateMessage() async {
    UserInfo userInfo=await LocalStorage.load("userInfo");
    _badgeInfo.newMessageCount=await getMessageCount(userInfo);
    return _badgeInfo;
  }
  //更新好友
  updateFriendRequest() async {
    _badgeInfo.newFriendRequestCount=await requestNewFriendCount();
    return _badgeInfo;
  }

  //获取访问数量
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
      "requestVer": await CommonUtil.getAppVersion(),
      "userId": userInfo.id,
    }),userCall: false );
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

  //获取新好友数量
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
          "requestVer": await CommonUtil.getAppVersion(),
          "userId": userInfo.id,
        }),userCall: false );
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
  //获取新消息数量
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
    print(_messageCount);
    return _messageCount;
  }

 }