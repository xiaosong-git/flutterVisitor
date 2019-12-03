import 'dart:math';

//import 'Base64.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';

import 'DataUtils.dart';
import 'Md5Util.dart';
import 'dart:io';
import 'package:package_info/package_info.dart';
import 'dart:convert';



class CommonUtil{

  //获取当前系统时间yyyymmddHHMMss

  static String getCurrentTime(){
    var current = DateTime.now();
//    return current;
    return current.year.toString()+current.month.toString().padLeft(2,'0')+current.day.toString().padLeft(2,'0')+current.hour.toString().padLeft(2,'0')+
    current.minute.toString().padLeft(2,'2')+current.second.toString().padLeft(2,'0');
  }

  static String getCurrentTimeMinis(){
    return new DateTime.now().millisecondsSinceEpoch.toString();

  }

  //计算当前的key，上送服务端校验
  static Future<String> calWorkKey({UserInfo userInfo}) async{
    UserInfo _userInfo;
    if(userInfo!=null&&userInfo.id!=null){
      _userInfo=userInfo;
    }
    else {
      await DataUtils.getUserInfo().then((value) {
        _userInfo = value;
      });
    }
    String userId = Md5Util.instance .encryptByMD5ByHex(_userInfo.id.toString().padLeft(12,'F'));
    String token = Md5Util.instance.encryptByMD5ByHex(_userInfo.token.toString());
    String currDate = Md5Util.instance.encryptByMD5ByHex(getCurrentTime());
    String keyStr = userId.substring(6,12)+currDate.substring(2,14)+token.substring(5,10);
    return Md5Util.instance.encryptByMD5ByHex(keyStr).toUpperCase();
  }
  //获取平台信息
   static String getAppPlat(){
    String appPlat='';
    if(Platform.isAndroid){
      appPlat ="android";
    }else if(Platform.isIOS){
      appPlat = "ios";
    }else if(Platform.isMacOS){
      appPlat = "macos";
    }else if(Platform.isWindows){
      appPlat = "windows";
    }else if(Platform.isLinux){
      appPlat = "linux";
    }else{
      appPlat ="other";
    }
    return appPlat;
   }

   //获取app版本信息
static Future<String>  getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

  /*
   * 生成固定几位的随机数
   * type :类型 1-数字  2-字母  3-数字加字母
   * length：生成随机数长度
   */
  static String getRandData(int type,int length){
    String charModel = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";
    String munModel ="1234567890";
    String charAndnumModel ="qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890";
    String model="";
   if(type==1){
     model = charModel;
   }else if(type==2){
     model = munModel;
   }else{
     model = charAndnumModel;
   }


    String randStr = '';
    for (var i = 0; i < length; i++) {
      randStr = randStr + model[Random().nextInt(model.length)];
    }

    return randStr;
}

  /*
  * Base64加密
  */
  static String encodeBase64(String data){
    var content = utf8.encode(data);
    var digest = base64Encode(content);
    return digest;
  }
  /*
  * Base64解密
  */
  static String decodeBase64(String data){
    return String.fromCharCodes(base64Decode(data));
  }

}