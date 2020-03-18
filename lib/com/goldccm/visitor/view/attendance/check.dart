import 'dart:convert';
import 'dart:io';
import 'package:amap_location/amap_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_arcface/flutter_arcface.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:intl/intl.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/checkInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/PremissionHandlerUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/attendance/statistical.dart';
import 'package:visitor/com/goldccm/visitor/view/common/LoadingDialog.dart';
/*
 * 打卡界面
 * email:hwk@growingpine.com
 * create_time:2019/10/28
 */
class CheckPointPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return CheckPointPageState();
  }
}
/*
 * _location 定位位置
 */
class CheckPointPageState extends State<CheckPointPage> with SingleTickerProviderStateMixin{
//  List _tabLists=['上下班打卡','外出打卡'];
//  TabController _tabController;
  File _currentPhoto;
  String shownAddress;
  AMapLocation _location;
  CheckInfo _checkInfo;
  String shownStr="暂无打卡";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('人脸打卡'),
        actions: <Widget>[
          IconButton(
              icon: Image.asset(
                "assets/images/visitor_icon_add.png",
                scale: 2.0,
              ),
              onPressed: () {
                appbarMore();
              }),
        ],
//        bottom: TabBar(tabs:_tabLists.map((e)=>Tab(text: e,)).toList(),controller: _tabController,indicatorColor: Colors.blue,),
      ),
      body: Container(
          width: ScreenUtil().setWidth(750),
          child: Card(
            margin: EdgeInsets.all(10),
            child:Container(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child:Text('当前位置:${shownAddress??""}',style: TextStyle(fontSize:16,),overflow: TextOverflow.ellipsis,maxLines: 2,),
                  ),
//                ClipRRect(
//                  borderRadius:BorderRadius.all(Radius.circular(30.0)),
//                  child: FlatButton(onPressed:checkNormal, child: Column(
//                    children: <Widget>[
//                      Text(DateFormat('HH:mm').format(DateTime.now())),
//                      Text(shownStr)
//                    ],
//                  ),),
//                ),
                  Container(
                    width: 130,
                    height: 130,
                    decoration:ShapeDecoration(
                        shape:  CircleBorder(
                            side: const BorderSide(
                                color: Colors.blue,
                                width: 8.0,
                                style:BorderStyle.solid
                            )
                        ),
                        color: Colors.white
                    ),
                    padding: EdgeInsets.only(top: 30),
                    child: FlatButton(onPressed:() async {
                      LoadingDialog().show(context, '请等待');
                      await checkNormal();
                      setState(() {
                        Navigator.pop(context);
                      });
                      }, child: Column(
                      children: <Widget>[
                        Text(DateFormat('HH:mm').format(DateTime.now()),style: TextStyle(fontSize: 28),),
                        Text('打卡',style: TextStyle(fontSize: 14),)
                      ],
                    ),
                    ),
                  ),
                ],
              ),
            )
          )
      ),
//      body: TabBarView(children: <Widget>[
//        Container(
//            child: Card(
//              margin: EdgeInsets.all(10),
//             child: Column(
//               children: <Widget>[
//                 Text('定位位置:${shownAddress??""}'),
//                 ClipRRect(
//                   borderRadius:BorderRadius.all(Radius.circular(30.0)),
//                   child: FlatButton(onPressed:checkNormal, child: Column(
//                     children: <Widget>[
//                       Text(DateFormat('HH:mm').format(DateTime.now())),
//                       Text(shownStr)
//                     ],
//                   )),
//                 ),
//               ],
//             ),
//            )
//        ),
//        Container(
//          child: Center(
//            child: Card(
//              child: RaisedButton(onPressed: checkOut, child: Text('打外出卡'),),
//            )
//          ),
//        ),
//      ],controller: _tabController,),
    );
  }
  @override
  void initState() {
    super.initState();
    AMapLocationClient.startup(new AMapLocationOption(
        desiredAccuracy: CLLocationAccuracy.kCLLocationAccuracyHundredMeters));
//    _tabController=new TabController(length: _tabLists.length, vsync: this);
    initVariables();
//    verifyRules();
  }
  @override
  void dispose() {
    //AMapLocationClient.stopLocation();
    AMapLocationClient.shutdown();
    super.dispose();
  }
  //获取当前经纬度
  Future initVariables()async{
    if(await requestPermission()){
//      AMapLocationClient.onLocationUpate.listen((AMapLocation loc){
////        if(!mounted)return;
////        setState(() {
////          _location = loc;
////          shownAddress = getLocationStr(loc);
////        });
////      });
////      AMapLocationClient.startLocation();
      AMapLocation loc = await AMapLocationClient.getLocation(true);
      setState(() {
        _location = loc;
        shownAddress = getLocationStr(loc);
      });
    }
  }
  void appbarMore(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(top: 60, right: 10.0),
                child: new SizedBox(
                  height: MediaQuery.of(context).size.height / 3.5,
                  width: 160,
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: ShapeDecoration(
                          color: Color(0xffffffff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                        ),
                        child: new Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 0, bottom: 0),
                              child: FlatButton(
                                onPressed: () async {
                                  Navigator.push(context, CupertinoPageRoute(builder: (context)=>StatisticalPage()));
                                },
                                child: Container(
                                    width: MediaQuery.of(context).size.width - 30,
                                    child: Stack(
                                      children: <Widget>[
                                        Positioned(
                                          child: Container(
                                            height: MediaQuery.of(context).size.height / 15,
                                            alignment: Alignment.center,
                                            child: Text('打卡记录', style: TextStyle(fontSize: 18.0,),
                                            ),
                                          ),
                                          left: 30,
                                        ),
                                        Positioned(
                                          child: Container(
                                            width: 20,
                                            height: MediaQuery.of(context).size.height / 15,
                                            padding: EdgeInsets.only(top: 5),
                                            child: Image.asset('assets/icons/app_add.png', scale: 2.0,),
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ),
//                            Divider(
//                              height: 0,
//                            ),
//                            Padding(
//                              padding: const EdgeInsets.only(
//                                  top: 0, bottom: 0),
//                              child: FlatButton(
//                                onPressed: () async {
//
//                                },
//                                child: Container(
//                                    width: MediaQuery.of(context).size.width - 30,
//                                    child: Stack(
//                                      children: <Widget>[
//                                        Positioned(
//                                          child: Container(
//                                            height: MediaQuery.of(context).size.height / 15,
//                                            alignment: Alignment.center,
//                                            child: Text(
//                                              '假勤申请',
//                                              style: TextStyle(
//                                                fontSize: 18.0,
//                                              ),
//                                            ),
//                                          ),
//                                          left: 30,
//                                        ),
//                                        Positioned(
//                                          child: Container(
//                                            width: 20,
//                                            height: MediaQuery.of(context).size.height / 15,
//                                            padding: EdgeInsets.only(top: 5),
//                                            child: Image.asset('assets/icons/app_newfriend.png', scale: 2.0,),
//                                          ),
//                                        ),
//                                      ],
//                                    )),
//                              ),
//                            ),
//                            Divider(
//                              height: 0,
//                            ),
//                            Padding(
//                              padding: const EdgeInsets.only(
//                                  top: 0, bottom: 0),
//                              child: FlatButton(
//                                onPressed: () async {
//
//                                },
//                                child: Container(
//                                    width: MediaQuery.of(context).size.width - 30,
//                                    child: Stack(
//                                      children: <Widget>[
//                                        Positioned(
//                                          child: Container(
//                                            height: MediaQuery.of(context).size.height / 15,
//                                            alignment: Alignment.center,
//                                            child: Text(
//                                              '打卡设置',
//                                              style: TextStyle(
//                                                fontSize: 18.0,
//                                              ),
//                                            ),
//                                          ),
//                                          left: 30,
//                                        ),
//                                        Positioned(
//                                          child: Container(
//                                            width: 20,
//                                            height: MediaQuery.of(context).size.height / 15,
//                                            padding: EdgeInsets.only(top: 5),
//                                            child: Image.asset('assets/icons/app_newfriend.png', scale: 2.0,),
//                                          ),
//                                        ),
//                                      ],
//                                    )),
//                              ),
//                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        );
  }
  /*
   * 打卡
   * 先调用摄像头获取现在的人脸图片
   * 进行活体检测
   * 再检查本地缓存图片中有没有用于比对的原始人脸图片
   * 没有则从网络上缓存到本地，有开启比对
   * 根据比对的结果打卡
   */
   checkNormal() async {
     await initVariables();
    if(_location==null){
      ToastUtil.showShortClearToast("无法定位");
      return ;
    }
    await getPhoto();
    UserInfo userInfo=await LocalStorage.load("userInfo");
    if(_currentPhoto!=null){
      print(_currentPhoto.path);
      var result=await FlutterArcface.singleImage(path: _currentPhoto.path);
//      检测活体
      if(result=="ALIVE"){
        var filepath=await saveNetworkImageToPhoto(RouterUtil.imageServerUrl+userInfo.idHandleImgUrl);
        var compareResult=await FlutterArcface.compareImage(path1: _currentPhoto.path, path2: filepath);
        double comRes=double.parse(compareResult);
        print(comRes);
//        如果对比结果大于80%
        if(comRes>0.8){
          await updateRecord();
        }
        else{
          ToastUtil.showShortToast("人脸特征不符合");
        }
      }else{
        ToastUtil.showShortToast("未检测到活体");
      }

    }else{
      ToastUtil.showShortToast("人脸检测失败");
    }
  }
  Future getPhoto() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if(image!=null&&image.path!=null){
      image = await FlutterExifRotation.rotateImage(path: image.path);
      setState(() {
        _currentPhoto = image;
      });
    }else{
      _currentPhoto = null;
    }
  }
  Future<bool> requestPermission()async{
    return await PermissionHandlerUtil().askPositionPermission();
  }
  checkOut(){
    print('外出打卡');
  }
  Future<String> saveNetworkImageToPhoto(String url, {bool useCache: true}) async {
    var data = await getNetworkImageData(url, useCache: useCache);
    var filePath = await ImagePickerSaver.saveFile(fileData: data,title: 'headImage',description: 'to compare the face');
    return filePath;
  }
  String getLocationStr(AMapLocation loc) {
    if (loc == null) {
      return "正在定位";
    }

    if (loc.isSuccess()) {
      if (loc.hasAddress()) {
        return "${loc.formattedAddress}";
      } else {
        return "定位失败";
      }
    } else {
      return "定位失败，错误：{code=${loc.code},description=${loc.description}";
    }
  }
  //校正当前打卡记录
//  verifyRules() async {
//    _checkInfo=null;
//    UserInfo userInfo = await LocalStorage.load("userInfo");
//    String url="work/gainWork";
//    String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
//    var res = await Http().post(url,
//        queryParameters: {
//          "token": userInfo.token,
//          "userId": userInfo.id,
//          "factor": CommonUtil.getCurrentTime(),
//          "threshold": threshold,
//          "requestVer": await CommonUtil.getAppVersion(),
//          "companyId": userInfo.companyId,
//          "date":"2"
//        },
//        userCall: false);
//    if(res is String){
//      Map map = jsonDecode(res);
//      if(map['verify']['sign']=="success"){
//        for(int i=0;i<map['data']['group'].length;i++){
//          if(map['data']['group'][i]['needCheckinTime'].length>6){
//            String str=map['data']['group'][i]['needCheckinDate']+" "+map['data']['group'][i]['needCheckinTime'];
//            DateTime dateTime=DateTime.parse(str);
//            print(DateTime.now().difference(dateTime).inMinutes);
//            if(-30<=DateTime.now().difference(dateTime).inMinutes&&DateTime.now().difference(dateTime).inMinutes<=30){
//              _checkInfo=CheckInfo.fromJson(map['data']['group'][i]);
//              setState(() {
//                if(map['data']['group'][i]['checkinType']==1){
//                  shownStr="上班打卡";
//                }
//                if(map['data']['group'][i]['checkinType']==2){
//                  shownStr="下班打卡";
//                }
//              });
//              break;
//            }else{
//              setState(() {
//                if(!mounted){
//                  shownStr="暂无打卡";
//                }
//              });
//            }
//          }
//        }
//      }
//    }
//  }
  //更新打卡记录
  updateRecord() async {
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String url="work/saveWork";
    String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
    var res = await Http().post(url,
        queryParameters: {
          "token": userInfo.token,
          "userId": userInfo.id,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
//          "groupId":_checkInfo.groupId,
//          "statisticsId":_checkInfo.statisticsId,
//          "checkinType":_checkInfo.checkinType,
          "checkinDate":DateFormat('yyyy-MM-dd').format(DateTime.now()),
          "checkinTime":DateFormat('HH:mm:ss').format(DateTime.now()),
          "locationDetail":_location.formattedAddress,
          "lat":(_location.latitude*1000000).toInt(),
          "lng":(_location.longitude*1000000).toInt(),
          "companyId":userInfo.companyId,
        },
        userCall: false);
    if(res is String){
      Map map = jsonDecode(res);
      ToastUtil.showShortClearToast(map['verify']['desc']);
    }
  }
}