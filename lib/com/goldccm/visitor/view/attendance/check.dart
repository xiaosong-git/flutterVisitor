import 'dart:io';

import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:amap_location_fluttify/amap_location_fluttify.dart';
//import 'package:flutter_arcface/flutter_arcface.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/PremissionHandlerUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
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
  List _tabLists=['上下班打卡','外出打卡'];
  TabController _tabController;
  File _currentPhoto;
  Location _location;
  String shownAddress;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('打卡'),
        actions: <Widget>[
          IconButton(
              icon: Image.asset(
                "assets/icons/user_addfriend.png",
                scale: 2.0,
              ),
              onPressed: () {
                appbarMore();
              }),
        ],
        bottom: TabBar(tabs:_tabLists.map((e)=>Tab(text: e,)).toList(),controller: _tabController,indicatorColor: Colors.blue,),
      ),
      body: TabBarView(children: <Widget>[
        Container(
            child: Card(
              margin: EdgeInsets.all(10),
             child: Column(
               children: <Widget>[
                 Text('定位位置:${shownAddress??""}'),
                 ClipRRect(
                   borderRadius:BorderRadius.all(Radius.circular(30.0)),
                   child: FlatButton(onPressed:checkNormal, child: Column(
                     children: <Widget>[
                       Text(DateTime.now().hour.toString()+":"+DateTime.now().minute.toString()),
                       Text('上班打卡')
                     ],
                   )),
                 ),
               ],
             ),
            )
        ),
        Container(
          child: Center(
            child: Card(
              child: RaisedButton(onPressed: checkOut, child: Text('打外出卡'),),
            )
          ),
        ),
      ],controller: _tabController,),
    );
  }
  @override
  void initState() {
    super.initState();
    _tabController=new TabController(length: _tabLists.length, vsync: this);
    initVariables();
  }
  //获取当前经纬度
  void initVariables()async{
//    if(await requestPermission()){
//      AmapLocation.startLocation(
//          once: true,
//          locationChanged: (location) async {
//            _location=location;
//            shownAddress=await location.address;
//            setState(() {
//
//            });
//          });
//    }
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
                            Divider(
                              height: 0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 0, bottom: 0),
                              child: FlatButton(
                                onPressed: () async {

                                },
                                child: Container(
                                    width: MediaQuery.of(context).size.width - 30,
                                    child: Stack(
                                      children: <Widget>[
                                        Positioned(
                                          child: Container(
                                            height: MediaQuery.of(context).size.height / 15,
                                            alignment: Alignment.center,
                                            child: Text(
                                              '假勤申请',
                                              style: TextStyle(
                                                fontSize: 18.0,
                                              ),
                                            ),
                                          ),
                                          left: 30,
                                        ),
                                        Positioned(
                                          child: Container(
                                            width: 20,
                                            height: MediaQuery.of(context).size.height / 15,
                                            padding: EdgeInsets.only(top: 5),
                                            child: Image.asset('assets/icons/app_newfriend.png', scale: 2.0,),
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                            Divider(
                              height: 0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 0, bottom: 0),
                              child: FlatButton(
                                onPressed: () async {

                                },
                                child: Container(
                                    width: MediaQuery.of(context).size.width - 30,
                                    child: Stack(
                                      children: <Widget>[
                                        Positioned(
                                          child: Container(
                                            height: MediaQuery.of(context).size.height / 15,
                                            alignment: Alignment.center,
                                            child: Text(
                                              '打卡设置',
                                              style: TextStyle(
                                                fontSize: 18.0,
                                              ),
                                            ),
                                          ),
                                          left: 30,
                                        ),
                                        Positioned(
                                          child: Container(
                                            width: 20,
                                            height: MediaQuery.of(context).size.height / 15,
                                            padding: EdgeInsets.only(top: 5),
                                            child: Image.asset('assets/icons/app_newfriend.png', scale: 2.0,),
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ),
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
  void checkNormal() async {
    print('上下班打卡');
    await getPhoto();
    UserInfo userInfo=await LocalStorage.load("userInfo");
    if(_currentPhoto!=null){
      print(_currentPhoto.path);
//      var result=await FlutterArcface.singleImage(path: _currentPhoto.path);
//      print(result);
      SharedPreferences sp = await SharedPreferences.getInstance();
      String head=sp.getString("headPhoto");
      if(head==null){
//        var filepath=await saveNetworkImageToPhoto(Constant.imageServerUrl+userInfo.idHandleImgUrl);
//        await sp.setString("headPhoto",filepath);
      }else{
        String url = "";
      }
    }else{
      ToastUtil.showShortToast("头像检测失败");
    }
  }
  Future getPhoto() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if(image!=null&&image.path!=null){
      image = await FlutterExifRotation.rotateImage(path: image.path);
      setState(() {
        _currentPhoto = image;
      });
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
}