import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';


class Md5Util{

  final  List hexChar = ['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'];

  factory Md5Util() =>_getInstance();
  static Md5Util get instance => _getInstance();
  static Md5Util _instance;
  Md5Util._internal() {
    // 初始化
  }
  static Md5Util _getInstance() {
    if (_instance == null) {
      _instance = new Md5Util._internal();
    }
    return _instance;
  }

   String encryptByMD5ByHex(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }


  String toHexString(List  b){
   List sb = new List(b.length * 2);
   for(int i = 0 ; i < b.length ; i++){
   sb.add(hexChar.elementAt((b.elementAt(i) & 0xf0) >> 4));
   sb.add(hexChar[b[i] & 0x0f]);
   }
   return sb.toString();
   }


   String encryptByMD5(String str){
    if(str == null){
      return null;
    }
    synchronized(mSync){
      var content = new Utf8Encoder().convert(str);
      var digest = md5.convert(content);
      return base64Encode(digest.bytes);
    }
  }

}