/*
 * 路由地址配置
 * 用于切换企业版和通用版
 */
import 'package:visitor/com/goldccm/visitor/model/RouterList.dart';

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
  static String apiServerUrl;
  static String imageServerUrl;
  static String webSocketServerUrl;
  static String uploadServerUrl;

}