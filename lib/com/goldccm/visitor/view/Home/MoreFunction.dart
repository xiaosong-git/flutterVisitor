import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/FunctionLists.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/Add/Attendance/attendance.dart';
import 'package:visitor/com/goldccm/visitor/view/Add/Share/RoomList.dart';
/*
 * 更多功能
 * create_time:2019/10/23
 */

class MoreFunction extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MoreFunctionState();
  }
}

class MoreFunctionState extends State<MoreFunction> {
  ScrollController _scrollController = new ScrollController();
  List<FunctionLists> _lists = [
    FunctionLists(
        iconImage: 'assets/icons/shareroom_tearoom.png',
        iconTitle: '茶室',
        iconType: '_teaRoom',
        iconName: '茶室'),
    FunctionLists(
        iconImage: 'assets/icons/shareroom_meetingroom.png',
        iconTitle: '会议室',
        iconType: '_meetingRoom',
        iconName: '会议室'),
    FunctionLists(
        iconImage: 'assets/icons/app_attend.png',
        iconTitle: '打卡',
        iconType: '_attendance',
        iconName: '打卡')
  ];
  List<FunctionLists> _activeLists = [
//    FunctionLists(
//      iconImage: 'assets/icons/app_attend.png',
//      iconTitle: '打卡',
//      iconType: '_attendance',
//      iconName: '打卡')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('全部应用', textScaleFactor: 1.0),
          centerTitle: true,
        ),
        body: Container(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                sliver: new SliverGrid(
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                  ),
                  delegate: new SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return _buildIconTab(
                          _activeLists[index].iconImage,
                          _activeLists[index].iconTitle,
                          _activeLists[index].iconType);
                    },
                    childCount: _activeLists.length,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildIconTab(String imageUrl, String text, String iconType) {
    return new InkWell(
      onTap: () {
        if (iconType == '_teaRoom') {
          _teaRoom();
        } else if (iconType == "_attendance") {
          _attendance();
        }else if(iconType=="_meetingRoom"){
          _meetingRoom();
        }
      },
      child: new Container(
        height: 140.0,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Padding(
                padding: EdgeInsets.only(top: 0.0),
                child: new Image.asset(
                  imageUrl,
                  width: 49,
                  height: 49,
                )),
            new Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: new Text(
                text,
                textScaleFactor: 1.0,
                style: new TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //权限获取
  Future getPrivilege(UserInfo user) async {
    String url = "userAppRole/getRoleMenu";
    String threshold = await CommonUtil.calWorkKey(userInfo: user);
    var res = await Http().post(url,
        queryParameters: {
          "token": user.token,
          "userId": user.id,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
        },
        userCall: false);
    //附加权限
    if (res != null) {
      if (res is String) {
        Map map = jsonDecode(res);
        if (map['data'] != null) {
          for (int j = 0; j < _lists.length; j++) {
            for (int i = 0; i < map['data'].length; i++) {
              if (_lists[j].iconTitle == map['data'][i]['menu_name']) {
                _activeLists.add(_lists[j]);
                break;
              }
            }
          }
        }
      }
      setState(() {});
    }
  }

  _teaRoom() async {
    UserInfo userInfo = await LocalStorage.load("userInfo");
    if (userInfo.isAuth == "T") {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => RoomList(
                    type: 1,
                  )));
    } else {
      ToastUtil.showShortClearToast("请先实人认证");
    }
  }

  _attendance() async {
    UserInfo userInfo = await LocalStorage.load("userInfo");
    if (userInfo.isAuth == "T") {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => AttendancePage()));
    } else {
      ToastUtil.showShortClearToast("请先实人认证");
    }
  }
  _meetingRoom() async {
    UserInfo userInfo = await LocalStorage.load("userInfo");
    if (userInfo.isAuth == "T") {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => RoomList(type: 0,)));
    }else{
      ToastUtil.showShortClearToast("请先实人认证");
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    UserInfo userInfo = await LocalStorage.load("userInfo");
    getPrivilege(userInfo);
  }
}
