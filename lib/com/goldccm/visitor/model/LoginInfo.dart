import 'package:meta/meta.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/NoticeInfo.dart';
import 'dart:convert';
/*
 * 登录信息
 */
class LoginInfo{

  UserInfo user;
  List<NoticeInfo> notices;

  LoginInfo({
     this.user,
     this.notices,
});

  LoginInfo.fromJson(Map json){
    this.user = UserInfo.fromJson(json['user']);
    notices=[];
    for (var noticeItem in json['notices']){
      notices.add(new NoticeInfo.fromJson(noticeItem));
    }
  }

}