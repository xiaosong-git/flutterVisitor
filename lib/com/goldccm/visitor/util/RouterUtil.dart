/*
 * 路由地址配置
 * 用于切换企业版和通用版
 */
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/RouterList.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';

class RouterUtil{

  factory RouterUtil() => _rUtil();

  static RouterUtil get instance => _rUtil();

  static RouterUtil _routerUtil;

  RouterUtil._internal();

  static RouterUtil _rUtil(){
    if(_routerUtil==null){
      _routerUtil=RouterUtil._internal();
    }
    return _routerUtil;
  }
  //服务器列表
  static List<RouterList> routerLists;

 //当前链接的服务器
  static String apiServerUrl=Constant.serverUrl;
  static String imageServerUrl=Constant.imageServerUrl;
  static String webSocketServerUrl=Constant.webSocketServerUrl;
  static String uploadServerUrl=Constant.imageServerApiUrl;

  static refresh(){
     Http.modifyChange(apiServerUrl);
  }
}