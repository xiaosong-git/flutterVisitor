import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';

/*
  本地数据存储类
  主要是SP在首次启动时没法获取到数据时提供数据
 */
class LocalStorage{

  static UserInfo _userInfo;
  static List _privilegeLists;
  static String _phoneStr;
  //读取
  static save(String name,dynamic value){
    if(name=="userInfo"){
      _userInfo=value;
    }
    if(name=="privilege"){
      _privilegeLists=value;
    }
    if(name=="phoneStr"){
      _phoneStr=value;
    }
  }
  //存储
  //先从sp中读取，存在则替换当前变量并返回，不存在直接返回当前变量
  static load(String name) async {
    if(name=="userInfo"){
      UserInfo userInfo=await DataUtils.getUserInfo();
      if(userInfo!=null&&userInfo.id!=null){
        _userInfo=userInfo;
        return userInfo;
      }
      return _userInfo;
    }
    if(name=="privilege"){
        return _privilegeLists;
    }
    if(name=="phoneStr"){
      return _phoneStr;
    }
  }
}