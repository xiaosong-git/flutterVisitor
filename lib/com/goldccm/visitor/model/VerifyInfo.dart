import 'package:meta/meta.dart';
import 'dart:convert';



class VerifyInfo{
   String isAuth ;//是否实名 F:未实名 T:实名 N:正在审核中 E:审核失败
   String isSetTransPwd;    //设置交易密码标识默认F    T：设置 F：未设置
   String validityDate;

  VerifyInfo({
     this.isAuth,
     this.isSetTransPwd,
     this.validityDate,
});

  VerifyInfo.fromJson(Map json) {
    isAuth = json['isAuth'];
    isSetTransPwd = json['isSetTransPwd'];
    validityDate = json['validityDate'];
  }

}