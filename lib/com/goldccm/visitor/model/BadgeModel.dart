import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/model/provider/BadgeInfo.dart';

class BadgeModel with ChangeNotifier{
  BadgeInfo badgeInfo = new BadgeInfo();
  BadgeInfo get info => badgeInfo;

  Future set(BadgeInfo info) async{
    if(info!=null){
      badgeInfo=info;
    }
    notifyListeners();
  }

  Future init() async{
    badgeInfo=new BadgeInfo(newMessageCount: 0,newFriendRequestCount: 0,newInviteCount: 0,newNoticeCount: 0,newVisitCount: 0);
    notifyListeners();
  }

  Future update(BadgeInfo info) async{
    if(info!=null&&info.newVisitCount>=0&&info.newInviteCount>=0&&info.newNoticeCount>=0&&info.newFriendRequestCount>=0&&info.newMessageCount>=0){
      badgeInfo=info;
    }
    notifyListeners();
  }
  Future clear(BadgeInfo info) async{
    badgeInfo=new BadgeInfo();
    notifyListeners();
  }
}