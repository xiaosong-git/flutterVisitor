import 'package:flutter/material.dart';
import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:visitor/com/goldccm/visitor/util/PremissionHandlerUtil.dart';
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
  Location _location;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('打卡'),
        actions: <Widget>[
          IconButton(
              icon: Image.asset(
                "assets/icons/添加新好友@2x.png",
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
          child: Center(
            child: Card(
             child: Column(
               children: <Widget>[
                 Text('定位位置:${_location.address}'),
                 FlatButton(onPressed: checkNormal, child: Text('打上下班卡'),),
               ],
             ),
            )
          ),
        ),
        Container(
          child: Center(
            child: Card(
              child: FlatButton(onPressed: checkOut, child: Text('打外出卡'),),
            )
          ),
        ),
      ],controller: _tabController,),
    );
  }
  @override
  void initState() {
    _tabController=new TabController(length: _tabLists.length, vsync: this);
    super.initState();
  }
  appbarMore(){
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
                                            child: Image.asset('assets/icons/添加@2x.png', scale: 2.0,),
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
                                            child: Image.asset('assets/icons/新的好友@2x.png', scale: 2.0,),
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
                                            child: Image.asset('assets/icons/新的好友@2x.png', scale: 2.0,),
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
  checkNormal() async {
    print('上下班打卡');
    if(await requestPermission()){
      AmapLocation.startLocation(
        once: true,
            locationChanged: (location){
            setState(() {
                _location=location;
            });
        });
    }
  }
  Future<bool> requestPermission()async{
    return await PermissionHandlerUtil().askPositionPermission();
  }
  checkOut(){
    print('外出打卡');
  }
}