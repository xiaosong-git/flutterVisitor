import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
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
import 'package:visitor/com/goldccm/visitor/view/visitor/visitRecord.dart';

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
  List<FunctionLists> _buslist = [
    FunctionLists(
        iconImage: 'assets/images/mine_identify.png',
        iconTitle: '实人认证',
        iconType: '_verify'),
    FunctionLists(
        iconImage: 'assets/images/mine_record.png',
        iconTitle: '访问邀约记录',
        iconType: '_record'),
    FunctionLists(
        iconImage: 'assets/images/mine_setting.png',
        iconTitle: '设置',
        iconType: '_setting')
  ];
  List<FunctionLists> _addlist = [];
  List<FunctionLists> _baseList = [
    FunctionLists(
        iconImage: 'assets/images/mine_identify.png',
        iconTitle: '实人认证',
        iconType: '_verify'),
    FunctionLists(
        iconImage: 'assets/images/mine_record.png',
        iconTitle: '访问邀约记录',
        iconType: '_record'),
    FunctionLists(
        iconImage: 'assets/images/mine_company.png',
        iconTitle: '公司管理',
        iconType: '_companySetting'),
    FunctionLists(
        iconImage: 'assets/images/mine_setting.png',
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
    init();
    getPrivilege();
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
    String status=await RouterUtil.getStatus();
    if(status=="local"){
      _list.clear();
      setState(() {
        //基础权限
        for (int i = 0; i < _buslist.length; i++) {
          _list.add(_buslist[i]);
        }
      });
    }
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
    print(await LocalStorage.load("userInfo"));
    _list.clear();
    setState(() {
      //基础权限
      for (int i = 0; i < _baseList.length; i++) {
        _list.add(_baseList[i]);
      }
    });
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
    }
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
        backgroundColor: Colors.white,
        body: CustomScrollView(
              controller: _minescrollController,
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                    height: ScreenUtil().setHeight(460),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          height: ScreenUtil().setHeight(376),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/mine_background.png"),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Positioned(
                          top: ScreenUtil().setHeight(120),
                          height: ScreenUtil().setHeight(330),
                          left: ScreenUtil().setWidth(56),
                          right: ScreenUtil().setWidth(56),
                          child: Container(
                            height: ScreenUtil().setHeight(290),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: GestureDetector(
                                      onTap: () {
                                        if (userProvider.info.headImgUrl != null ||
                                            userProvider.info.idHandleImgUrl !=
                                                null) {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (context) =>
                                                      HeadImagePage()));
                                        }
                                      },
                                      child:
                                      CachedNetworkImage(
                                        imageUrl: userProvider.info.headImgUrl!=null?RouterUtil.imageServerUrl +
                                            userProvider.info.headImgUrl:"",
                                        placeholder: (context, url) =>
                                            Container(
                                              child: CircularProgressIndicator(backgroundColor: Colors.black,),
                                              width: 10,
                                              height: 10,
                                              alignment: Alignment.center,
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                        imageBuilder: (context,imageProvider)=>CircleAvatar(
                                          backgroundImage: imageProvider,
                                          radius: 100,
                                        ),
                                      )
                                  ),
                                  width: ScreenUtil().setWidth(160),
                                  margin: EdgeInsets.only(left: ScreenUtil().setWidth(28),right: ScreenUtil().setWidth(28)),
                                  height: ScreenUtil().setWidth(160),
                                ),
                                userProvider.info.isAuth=="T"?Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                         Consumer(
                                            builder: (context, UserModel userModel,
                                                widget) =>
                                                    Container(
                                                      child: Text(
                                                          userModel.info.realName != null
                                                              ? userModel.info.realName
                                                              : '未实名认证',
                                                          style: TextStyle(
                                                            color: Color(0xFF373737),
                                                            fontSize: ScreenUtil().setSp(34),
                                                          ),
                                                          softWrap: true,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          textScaleFactor: 1.0),
                                                      width: ScreenUtil().setWidth(110),
                                                    ),
                                          ),
                                       Container(
                                            padding: EdgeInsets.only(left: ScreenUtil().setWidth(10),right:ScreenUtil().setWidth(16) ),
                                            child: Text(
                                              '|',
                                              style: TextStyle(
                                                color: Color(0xFFCFCFCF),
                                                fontSize: ScreenUtil().setSp(34),
                                              ),
                                              softWrap: true,
                                              textScaleFactor: 1.0,
                                            ),
                                          ),
                                        Consumer(
                                            builder: (context, UserModel userModel,
                                                widget) =>
                                                   Container(
                                                child:Text(
                                                    userModel.info.city != null
                                                        ? userModel.info.city
                                                        : '无',
                                                    style: TextStyle(
                                                      color: Color(0xFF666666),
                                                      fontSize: ScreenUtil().setSp(34),
                                                    ),
                                                    softWrap: true,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    textScaleFactor: 1.0) ,
                                                     width: ScreenUtil().setWidth(200),
                                                ) 
                                          ),
                                      ],
                                    ),
                                    Container(
                                      width: ScreenUtil().setWidth(380),
                                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(16)),
                                      child:  Consumer(
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
                                                  color:Color(0xFF666666),
                                                  fontSize: ScreenUtil().setSp(32),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textScaleFactor: 1.0),
                                      )
                                    ),
                                  ]
                                ):Text('信息待完善',style: TextStyle(color: Color(0xFFD5D5D5),fontSize: ScreenUtil().setSp(32))),
                              ],
                            ),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/images/mine_person_background.png"),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  sliver: new SliverList(
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
              CupertinoPageRoute(
                  builder: (context) => RoomHistory(
                        userInfo: userInfo,
                      )));
        } else if (method == "_companySetting") {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => CompanyPage(
                        userInfo: userInfo,
                      ))).then((value) async {
            setState(() {});
          });
        } else if (method == "_setting") {
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => SettingPage()));
        } else if (method == "_verify") {
          if (userInfo.isAuth == "T") {
            ToastUtil.showShortClearToast("您已完成实名认证");
          } else {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => IdentifyPage(
                          userInfo: userInfo,
                        )));
          }
        }else if (method == "_record"){
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => VisitRecord()));
        }
      },
      child: Container(
        height:ScreenUtil().setHeight(110),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: ScreenUtil().setHeight(25),
              child: Image(
                width: ScreenUtil().setWidth(60),
                height: ScreenUtil().setHeight(60),
                image: AssetImage(url),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(35),
              left: ScreenUtil().setWidth(80),
              child: Text(text,style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(30)),),
            ),
            Positioned(
              top: ScreenUtil().setHeight(30),
              right: 0,
              child: Image(
                width: ScreenUtil().setWidth(60),
                height: ScreenUtil().setHeight(60),
                image: AssetImage('assets/images/mine_next.png'),
                color: Color(0xFFE4E4E4),
              ),
            ),
            Positioned(
              left: ScreenUtil().setWidth(70),
              bottom: ScreenUtil().setHeight(0),
              child: Container(
                height: ScreenUtil().setHeight(2),
                width: ScreenUtil().setWidth(600),
                decoration:BoxDecoration(
                  border:Border(
                    bottom: BorderSide(
                      color: Color(0xFFF8F8F8),
                      width: ScreenUtil().setHeight(2),
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              ),
            ),
            method == "_verify"?Positioned(
              top: ScreenUtil().setHeight(35),
              right: ScreenUtil().setWidth(50),
              child: userInfo.isAuth == "T"?Text('已认证',style: TextStyle(color: Color(0xFFD5D5D5),fontSize: ScreenUtil().setSp(30)),textScaleFactor: 1,):RichText( text:TextSpan(
                text:'未认证',style: TextStyle(color: Color(0xFFD5D5D5),fontSize: ScreenUtil().setSp(30)),
                children:<TextSpan>[
                  TextSpan(
                    text: '!',style: TextStyle(color: Color(0xFFFF0000),fontSize: ScreenUtil().setSp(30)),
                  )
                ]

              )),
            ):Container(),
          ],
        ),
      )
    );
  }
}
