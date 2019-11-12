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
  static load(String name) async {
    if(name=="userInfo"){
      UserInfo userInfo=await DataUtils.getUserInfo();
      if(userInfo!=null&&userInfo.id!=null){
        return userInfo;
      }
      return _userInfo;
    }
    if(name=="privilege"){
      if(_privilegeLists!=null&&_privilegeLists.length>0){
        return _privilegeLists;
      }
    }
    if(name=="phoneStr"){
      if(_phoneStr!=null&&_phoneStr.length>0){
        return _phoneStr;
      }
    }
  }
}