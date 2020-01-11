/*
 * 路由地址配置
 * 用于切换企业版和通用版
 */
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/RouterList.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';

/*
 * 服务器操作类
 * create_time:2020/1/11
 */
class RouterUtil{
  static final String serverIP="serverIP";
  static final String serverPort="serverPort";
  static final String serverIPort="serverIPort";
  static final String serverID="serverID";
  static final String serverName="serverName";
  static final String serverAddress="serverAddress";
  static final String serverProvince="serverProvince";
  static final String serverCity="serverCity";
  static final String serverArea="serverArea";

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
  static init() async {
    RouterList rList=await getServerInfo();
    if(rList!=null){
      RouterUtil.apiServerUrl="http://${rList.ip}:${rList.port}/visitor/";
      RouterUtil.webSocketServerUrl="ws://${rList.ip}:${rList.port}/visitor/";
      RouterUtil.uploadServerUrl="http://${rList.ip}:${rList.port}/goldccm-imgServer/goldccm/image/gainData";
      RouterUtil.imageServerUrl="http://${rList.ip}:${rList.imagePort}/imgserver/";
    }
  }
  static refresh(){
     Http.modifyChange(apiServerUrl);
  }
  static saveServerInfo(RouterList routerList) async {
    SharedPreferences sp;
    await SharedPreferences.getInstance().then((value) {
      sp = value;
    });
    if(routerList.routerID!=null){
      await sp.setString(serverID, routerList.routerID);
    }
    if(routerList.ip!=null){
      await sp.setString(serverIP, routerList.ip);
    }
    if(routerList.routerName!=null){
      await sp.setString(serverName, routerList.routerName);
    }
    if(routerList.routerAddress!=null){
      await sp.setString(serverAddress,routerList.routerAddress);
    }
    if(routerList.port!=null){
      await sp.setString(serverPort, routerList.port);
    }
    if(routerList.imagePort!=null){
      await sp.setString(serverIPort,routerList.imagePort);
    }
    if(routerList.province!=null){
      await sp.setString(serverProvince,routerList.province);
    }
    if(routerList.city!=null){
      await sp.setString(serverCity,routerList.city);
    }
    if(routerList.area!=null){
      await sp.setString(serverArea, routerList.area);
    }
  }
  static Future<RouterList> getServerInfo()async{
    SharedPreferences sp;
    await SharedPreferences.getInstance().then((value) {
      sp = value;
    });
    RouterList routerList = new RouterList();
    routerList.routerID=sp.getString(serverID);
    routerList.routerName=sp.getString(serverName);
    routerList.routerAddress=sp.getString(serverAddress);
    routerList.ip=sp.getString(serverIP);
    routerList.port=sp.getString(serverPort);
    routerList.imagePort=sp.getString(serverIPort);
    routerList.province=sp.getString(serverProvince);
    routerList.city=sp.getString(serverCity);
    routerList.area=sp.getString(serverArea);
    return routerList;
  }
}