import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/BadgeModel.dart';
import 'package:visitor/com/goldccm/visitor/model/FunctionLists.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/model/provider/BadgeInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/BadgeUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/minepage/HeaderPage.dart';
import 'package:visitor/com/goldccm/visitor/view/minepage/companypage.dart';
import 'package:visitor/com/goldccm/visitor/view/minepage/identifypage.dart';
import 'package:visitor/com/goldccm/visitor/view/minepage/securitypage.dart';
import 'package:visitor/com/goldccm/visitor/view/minepage/settingpage.dart';
import 'package:visitor/com/goldccm/visitor/view/shareroom/roomHistory.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/friendHistory.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/inviteList.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/visitList.dart';
import 'package:cached_network_image/cached_network_image.dart';

/*
   个人中心
   包括个人信息、历史消息、公司管理、安全管理、设置
   author:hwk<hwk@growingpine.com>
   create_time:2019/11/25
 */
class MinePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MinePageState();
  }
}

class MinePageState extends State<MinePage> {
  List<FunctionLists> _addlist = [
    FunctionLists(
        iconImage: 'assets/icons/shareroom_meetingroom.png',
        iconTitle: '会议室',
        iconType: '_meetingRoom'),
    FunctionLists(
        iconImage: 'assets/icons/user_company_setting.png',
        iconTitle: '公司管理',
        iconType: '_companySetting'),
  ];
  List<FunctionLists> _baseList = [
    FunctionLists(
        iconImage: 'assets/icons/user_verify.png',
        iconTitle: '实名认证',
        iconType: '_verify'),
    FunctionLists(
        iconImage: 'assets/icons/user_safe_setting.png',
        iconTitle: '安全管理',
        iconType: '_securitySetting'),
    FunctionLists(
        iconImage: 'assets/icons/user_setting.png',
        iconTitle: '设置',
        iconType: '_setting')
  ];
  List<FunctionLists> _list = [];
  BadgeUtil badge = BadgeUtil();
  int visitBadgeNumTotal = 0;
  int _currentRole = 0;
  bool visitBadgeShow = false;
  bool inviteBadgeShow = false;
  bool friendBadgeShow = false;
  ScrollController _minescrollController = new ScrollController();
  final double expandedHeight = 65.0;
  double get top {
    double res = expandedHeight;
    if (_minescrollController.hasClients) {
      double offset = _minescrollController.offset;
      res -= offset;
    }
    return res;
  }

  //初始化
  //获取个人信息和图片服务器地址
  @override
  void initState() {
    super.initState();
    getPrivilege();
    init();
    _minescrollController.addListener(() {
      var maxScroll = _minescrollController.position.maxScrollExtent;
      var pixel = _minescrollController.position.pixels;
      if (maxScroll == pixel) {
        setState(() {});
      } else {
        setState(() {});
      }
    });
  }

  init() async {
    UserInfo userInfo = await LocalStorage.load("userInfo");
    getAddressInfo(userInfo.id);
  }

  /*
   * 公司角色
   */
  getAddressInfo(int visitorId) async {
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String url = "companyUser/findVisitComSuc";
    String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
    var res = await Http().post(url,
        queryParameters: {
          "token": userInfo.token,
          "userId": userInfo.id,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "visitorId": visitorId,
        },
        userCall: false);
    if (res != null && res != "") {
      if (res is String) {
        Map map = jsonDecode(res);
        if (map['verify']['sign'] == "success") {
          if (map['data'] != null && map['data'].length > 0) {
            for (var info in map['data']) {
              if (info['status'] == "applySuc" &&
                  info['currentStatus'] == "normal") {
                if (info['companyId'] == userInfo.companyId) {
                  _currentRole = 1;
                }
              }
            }
          }
        }
      }
    }
  }

  /*
   * 刷新
   */
  Future freshMine() async {
    getPrivilege();
    updateAuthStatus();
    updateVisitInfo();
    ToastUtil.showShortClearToast("更新完毕");
    return null;
  }

  /*
   * 更新用户信息
   * save LocalStorage
   * updateUserInfo SP
   * update Provider
   */
  Future updateAuthStatus() async {
    var userProvider = Provider.of<UserModel>(context);
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
    var result = await Http().post(Constant.getUserInfoUrl,
        queryParameters: {
          "token": userInfo.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": CommonUtil.getAppVersion(),
          "userId": userInfo.id,
        },
        debugMode: true);
    if (result != null && result != "") {
      if (result is String) {
        Map map = jsonDecode(result);
        if (map['data'] != null) {
          userInfo.realName = map['data']['realName'];
          userInfo.idType = map['data']['idType'];
          userInfo.idNO = map['data']['idNo'];
          userInfo.idHandleImgUrl = map['data']['idHandleImgUrl'];
          userInfo.isAuth = map['data']['isAuth'];
          userInfo.addr = map['data']['addr'];
          LocalStorage.save("userInfo", userInfo);
          userProvider.init(userInfo);
          DataUtils.updateUserInfo(userInfo);
        }
      }
    }
  }

  /*
   * 更新访问信息数量
   */
  updateVisitInfo() async {
    BadgeInfo badgeInfo = await BadgeUtil().updateVisit();
    Provider.of<BadgeModel>(context).update(badgeInfo);
  }

  /*
   * 权限列表获取
   */
  Future getPrivilege() async {
    _list.clear();
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String url = "userAppRole/getRoleMenu";
    String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
    var res = await Http().post(url, queryParameters: {
      "token": userInfo.token,
      "userId": userInfo.id,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
    });
    //附加权限
    if (res != null) {
      if (res is String) {
        Map map = jsonDecode(res);
        if (map['data'] != null) {
          for (int j = 0; j < _addlist.length; j++) {
            for (int i = 0; i < map['data'].length; i++) {
              if (_addlist[j].iconTitle == map['data'][i]['menu_name']) {
                _list.add(_addlist[j]);
                break;
              }
            }
          }
        }
      }
    } else {}

    setState(() {
      //基础权限
      for (int i = 0; i < _baseList.length; i++) {
        _list.add(_baseList[i]);
      }
    });
  }

  @override
  void dispose() {
    _minescrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserModel>(context);
    var badgeProvider = Provider.of<BadgeModel>(context);
    return RefreshIndicator(
      onRefresh: freshMine,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Stack(
          children: <Widget>[
            CustomScrollView(
              controller: _minescrollController,
              slivers: <Widget>[
                SliverAppBar(
                  title: Text("我的",
                      textAlign: TextAlign.center,
                      style: new TextStyle(fontSize: 18.0, color: Colors.white),
                      textScaleFactor: 1.0),
                  expandedHeight: 100.0,
                  backgroundColor: Theme.of(context).appBarTheme.color,
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  leading: null,
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 150, 20, 0),
                  sliver: new SliverGrid(
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                    ),
                    delegate: new SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return _buildIconTab(
                          _list[index].iconImage,
                          _list[index].iconTitle,
                          _list[index].iconType,
                          userProvider.info);
                    }, childCount: _list.length),
                  ),
                ),
              ],
            ),
            Positioned(
              top: top,
              height: 200,
              left: 15,
              right: 15,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 20.0,
                child: Container(
                    height: 120,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              child: GestureDetector(
                                onTap: () {
                                  if (userProvider.info.headImgUrl != null ||
                                      userProvider.info.idHandleImgUrl !=
                                          null) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                HeadImagePage()));
                                  }
                                },
                                child:
                                  CachedNetworkImage(
                                          imageUrl: Constant.imageServerUrl +
                                              userProvider.info.headImgUrl,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                          imageBuilder: (context,imageProvider)=>CircleAvatar(
                                            backgroundImage: imageProvider,
                                            radius: 100,
                                          ),
                                  )
                              ),
                              width: 60.0,
                              margin: EdgeInsets.all(20),
                              height: 60.0,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Consumer(
                                    builder: (context, UserModel userModel,
                                            widget) =>
                                        Text(
                                            userModel.info.realName != null
                                                ? userModel.info.realName
                                                : '您还未实名认证',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                            ),
                                            textScaleFactor: 1.0)),
                                Consumer(
                                  builder: (context, UserModel userModel,
                                          widget) =>
                                      Text(
                                          Provider.of<UserModel>(context)
                                                      .info
                                                      .companyName !=
                                                  null
                                              ? Provider.of<UserModel>(context)
                                                  .info
                                                  .companyName
                                              : '',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0,
                                          ),
                                          textScaleFactor: 1.0),
                                )
                              ],
                            ),
                          ],
                        ),
                        Container(
                          child: Divider(
                            height: 5,
                            color: Colors.black12,
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          child: Row(
                              children: <Widget>[
                                Material(
                                  color: Colors.white,
                                  child: InkWell(
                                    child: Container(
                                      width: 80,
                                      padding: EdgeInsets.all(15),
                                      child: Column(
                                        children: <Widget>[
                                          Badge(
                                            child: Image.asset(
                                              "assets/icons/app_visit.png",
                                              scale: 7.0,
                                            ),
                                            badgeColor: Colors.red,
                                            showBadge: visitBadgeShow,
                                          ),
                                          Text('访问', textScaleFactor: 1.0),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      if (userProvider.info.isAuth == "T") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => VisitList(
                                                      currentRole: _currentRole,
                                                    ))).then((value) {
                                          updateVisitInfo();
                                        });
                                      } else {
                                        ToastUtil.showShortClearToast("请先实名认证");
                                      }
                                    },
                                    splashColor: Colors.black12,
                                    borderRadius: BorderRadius.circular(18.0),
                                    radius: 30,
                                  ),
                                ),
                                Material(
                                  color: Colors.white,
                                  child: InkWell(
                                    child: Container(
                                      width: 80,
                                      padding: EdgeInsets.all(15),
                                      child: Column(
                                        children: <Widget>[
                                          Image.asset(
                                            "assets/icons/app_invite.png",
                                            scale: 7.0,
                                          ),
                                          Text('邀约', textScaleFactor: 1.0),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      if (userProvider.info.isAuth == "T") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    InviteList(
                                                      userInfo:
                                                          userProvider.info,
                                                    )));
                                      } else {
                                        ToastUtil.showShortClearToast("请先实名认证");
                                      }
                                    },
                                    splashColor: Colors.black12,
                                    borderRadius: BorderRadius.circular(18.0),
                                    radius: 30,
                                  ),
                                ),
                                Material(
                                  color: Colors.white,
                                  child: InkWell(
                                    child: Container(
                                      width: 80,
                                      padding: EdgeInsets.all(15),
                                      child: Column(
                                        children: <Widget>[
                                          Image.asset(
                                            "assets/icons/app_friend.png",
                                            scale: 7.0,
                                          ),
                                          Text('好友', textScaleFactor: 1.0),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      if (userProvider.info.isAuth == "T") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    FriendHistory(
                                                      userInfo:
                                                          userProvider.info,
                                                    )));
                                      } else {
                                        ToastUtil.showShortClearToast("请先实名认证");
                                      }
                                    },
                                    splashColor: Colors.black12,
                                    borderRadius: BorderRadius.circular(18.0),
                                    radius: 30,
                                  ),
                                ),
                              ],
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround),
                        ),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconTab(
      String url, String text, String method, UserInfo userInfo) {
    return InkWell(
      onTap: () async {
        if (method == "_meetingRoom") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RoomHistory(
                        userInfo: userInfo,
                      )));
        } else if (method == "_companySetting") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CompanyPage(
                        userInfo: userInfo,
                      ))).then((value) async {
            setState(() {});
          });
        } else if (method == "_securitySetting") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SecurityPage(userInfo: userInfo)));
        } else if (method == "_setting") {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SettingPage()));
        } else if (method == "_verify") {
          if (userInfo.isAuth == "T") {
            ToastUtil.showShortClearToast("您已完成实名认证");
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => IdentifyPage(
                          userInfo: userInfo,
                        )));
          }
        }
      },
      child: new Container(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Padding(
                padding: EdgeInsets.only(top: 0.0),
                child: new Image.asset(
                  url,
                  width: 49,
                  height: 49,
                )),
            new Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: new Text(text,
                  style:
                      new TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textScaleFactor: 1.0),
            ),
          ],
        ),
      ),
    );
  }
}
