/*
 * 权限获取
 * author:ody997
 * email:hwk@growingpine.com
 * create_time:2019/10/18
 */
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/*
 * 权限获取类
 * create_time:2019/10/18
 */
class PermissionHandlerUtil{
  /*
   * contact 通讯录权限
   * storage 读写权限
   * location 定位权限
   */
    static int contact;
    static int storage;
    static int position;
    static PermissionHandlerUtil _permission;

    factory  PermissionHandlerUtil() => _permissionHandlerUtil();
    PermissionHandlerUtil get instance=>_permissionHandlerUtil();

    PermissionHandlerUtil._();

    static PermissionHandlerUtil _permissionHandlerUtil(){
      if(_permission==null){
        _permission=PermissionHandlerUtil._();
      }
      return _permission;
    }
    /*
     * 初始化权限状态
     */
    initPermission() async {
      PermissionStatus contactsPermission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.contacts);
      PermissionStatus storagePermission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      PermissionStatus locationPermission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.location);
      contact=contactsPermission.value;
      storage=storagePermission.value;
      position=locationPermission.value;
    }
    /*
     * 通讯录权限
     */
    askContactPermission()async{
      if(contact==null){
        print("通讯录权限尚未完成初始化");
      }else if(contact==2){
        print("通讯录权限已经获取");
      }else{
        Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler()
            .requestPermissions([PermissionGroup.contacts]);
        if(permissions.entries.elementAt(0).value==PermissionStatus.denied){
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      }
    }
    /*
     * 读写权限
     */
    askStoragePermission() async {
      if(storage==null){
        print("存储权限尚未完成初始化");
      }else if(storage==2){
        print("存储权限已经获取");
      }else{
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
            .requestPermissions([PermissionGroup.storage]);
        if(permissions.entries.elementAt(0).value==PermissionStatus.denied){

        }
      }
    }
    /*
     * 定位权限
     */
    Future<bool> askPositionPermission() async{
      if(position==null){
        print("定位权限尚未初始化");
        return false;
      }else if(position==2){
        print("定位权限已经获取");
        return true;
      }else{
        Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler()
            .requestPermissions([PermissionGroup.location]);
        if(permissions.entries.elementAt(0).value==PermissionStatus.granted){
            return true;
        }
        return false;
      }
    }
}