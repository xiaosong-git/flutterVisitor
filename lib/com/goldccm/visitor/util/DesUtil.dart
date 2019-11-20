import 'package:flutter_des/flutter_des.dart';

/*
 * DES加密
 * Author:ody997<wenkun97@126.com>
 * Email:hwk@growingpine.com
 * create_time:2019/10/16
 */
class DesUtil{

  factory DesUtil() => _desUtil();

  static DesUtil get instance => _desUtil();

  static const iv="12345678";

  static DesUtil _des;

  DesUtil._();

  static DesUtil _desUtil(){
    if(_des==null){
      _des =  DesUtil._();
    }
    return _des;
  }
  decryptHex(String str,String key) async {
    return  await FlutterDes.encryptToHex(str, key, iv: iv);
  }
}