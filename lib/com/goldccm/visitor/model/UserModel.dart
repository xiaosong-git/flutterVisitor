import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';

class UserModel with ChangeNotifier{
  UserInfo _userInfo = new UserInfo();
  UserInfo get info=> _userInfo;

  Future init(UserInfo userInfo) async {
    if(userInfo!=null) {
      _userInfo = userInfo;
    }else{
      var user = await LocalStorage.load("userInfo");
      if(user!=null){
        _userInfo=user;
      }
    }
    notifyListeners();
  }
}