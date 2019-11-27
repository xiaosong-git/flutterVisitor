import 'dart:convert';
import 'dart:io';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/BadgeUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/addresspage.dart';
import 'package:visitor/com/goldccm/visitor/view/contract/chatListItem.dart';
import 'package:visitor/com/goldccm/visitor/view/homepage/homepage.dart';
import 'package:visitor/com/goldccm/visitor/view/minepage/minepage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'com/goldccm/visitor/httpinterface/http.dart';
import 'com/goldccm/visitor/util/CommonUtil.dart';
import 'com/goldccm/visitor/util/Constant.dart';
import 'com/goldccm/visitor/util/MessageUtils.dart';
import 'com/goldccm/visitor/util/ToastUtil.dart';
import 'com/goldccm/visitor/view/login/Login.dart';

class MyHomeApp extends StatefulWidget {
  final int tabIndex;
  final int type;
  MyHomeApp({Key key, this.tabIndex, this.type}) : super(key: key);
  @override
  HomeState createState() => new HomeState();
}

const double _kTabTextSize = 10.0;
const int INDEX_HOME = 0;
const int INDEX_FRIEND = 1;
const int INDEX_VISITOR = 2;
const int INDEX_MINE = 3;
Color _keyPrimaryColor = Colors.lightBlue;

class HomeState extends State<MyHomeApp> with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  var tabImages;
  var appBarTitles = ['首页', '访客', '通讯录', '我的'];
  var _pageList;
  WebSocketChannel channel;
  int _msgCount = 0;
  /*
   * 根据选择获得对应的normal或是press的icon
   */
  Image getTabIcon(int curIndex) {
    if (curIndex == _tabIndex) {
      return tabImages[curIndex][1];
    }
    return tabImages[curIndex][0];
  }

  /*
   * 获取bottomTab的颜色和文字
   */
  Text getTabTitle(int curIndex) {
    if (curIndex == _tabIndex) {
      return new Text(appBarTitles[curIndex],
          style: new TextStyle(fontSize: 14.0, color: const Color(0xff1296db)));
    } else {
      return new Text(appBarTitles[curIndex],
          style: new TextStyle(
            fontSize: 14.0,
            color: const Color(0xff515151),
          ));
    }
  }

  /*
   * 根据image路径获取图片
   */
  Image getTabImage(path) {
    return new Image.asset(path, width: 24.0, height: 24.0);
  }

  @override
  void initState() {
    super.initState();
    checkVersion();
    checkDevice();
    initWebSocket();
    initData();
  }

  //检测当前设备的合法性
  Future checkDevice() async {
    UserInfo userInfo = await DataUtils.getUserInfo();
    if (userInfo == null || userInfo.id == null) {
      userInfo = await LocalStorage.load("userInfo");
    }
    String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
    var result = await Http().post(Constant.getUserInfoUrl, queryParameters: {
      "token": userInfo.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": CommonUtil.getAppVersion(),
      "userId": userInfo.id,
    });
    if (result != null) {
      if (!(result is String)) {
        if (result['verify']['sign'] == "tokenFail") {
          ToastUtil.showShortToast("您的账号已在另一台设备登录");
          MessageUtils.closeChannel();
          DataUtils.clearLoginInfo();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Login()));
        }
      }
    }
  }

  //检查版本更新
  checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    bool isUpToDate = true;
    if (Platform.isAndroid) {
      String url =
          Constant.serverUrl + "appVersion/updateAndroid/visitor/$buildNumber";
      var res = await Http().post(url);
      if (res != null) {
        if (res is String) {
          Map map = jsonDecode(res);
          if (map['verify']['sign'] == "success") {
            var remoteVersion = (map['data']['versionName']).split(".");
            var localVersion = version.split(".");
            String isForce = map['data']['isImmediatelyUpdate'];
            for (int i = 0; i < remoteVersion.length; i++) {
              if (int.parse(remoteVersion[i]) > int.parse(localVersion[i])) {
                isUpToDate = false;
              }
            }
            var remoteNum = int.parse(map['data']['versionNum']);
            var localNum = int.parse(buildNumber);
            if (remoteNum > localNum && map['data']['versionName'] == version) {
              isUpToDate = false;
            }
            if (!isUpToDate) {
              String url = map['data']['updateUrl'];
              showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return WillPopScope(
                      child: AlertDialog(
                        title: new Row(
                          children: <Widget>[
                            new Image.asset("assets/icons/ic_launcher.png",
                                height: 35.0, width: 35.0),
                            new Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    30.0, 0.0, 10.0, 0.0),
                                child: new Text(
                                  "朋悦比邻",
                                ))
                          ],
                        ),
                        content: new Text(
                          '${map['data']['versionName']}版本更新',
                        ),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text('稍后',
                                style: TextStyle(color: Colors.grey[400])),
                            onPressed: () {
                              if (isForce == "T") {
                                ToastUtil.showShortClearToast(
                                    "当前版本太过老旧，请立即更新后使用");
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                          new FlatButton(
                            child: new Text(
                              '立即更新',
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () async {
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                          )
                        ],
                      ),
                      onWillPop: () {
                        return null;
                      },
                    );
                  });
            }
          }
        }
      }
    } else if (Platform.isIOS) {
      String url = Constant.serverUrl + "appVersion/updateIOS";
      var res = await Http().post(url);
      if (res != null) {
        if (res is String) {
          Map map = jsonDecode(res);
          if (map['verify']['sign'] == "success") {
            var remoteVersion = (map['data']['versionNum']).split(".");
            var localVersion = version.split(".");
            String isForce = map['data']['isImmediatelyUpdate'];
            for (int i = 0; i < remoteVersion.length; i++) {
              if (int.parse(remoteVersion[i]) > int.parse(localVersion[i])) {
                isUpToDate = false;
              }
            }
            if (!isUpToDate) {
              String url = map['data']['updateUrl'];
              showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return WillPopScope(
                      child: AlertDialog(
                        title: new Row(
                          children: <Widget>[
                            new Image.asset("assets/icons/ic_launcher.png",
                                height: 35.0, width: 35.0),
                            new Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    30.0, 0.0, 10.0, 0.0),
                                child: new Text(
                                  "朋悦比邻",
                                ))
                          ],
                        ),
                        content: new Text(
                          '${map['data']['versionNum']}版本更新',
                        ),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text(
                              '稍后',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            onPressed: () {
                              if (isForce == "T") {
                                ToastUtil.showShortClearToast(
                                    "当前版本太过老旧，请立即更新后使用");
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                          new FlatButton(
                            child: new Text(
                              '立即更新',
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () async {
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                          )
                        ],
                      ),
                      onWillPop: () {
                        return null;
                      },
                    );
                  });
            }
          }
        }
      }
    }
  }

  void initData() {
    setState(() {
      if (widget.tabIndex != null) {
        _tabIndex = widget.tabIndex;
      }
    });
    /*
     * 初始化选中和未选中的icon
     */
    tabImages = [
      [
        getTabImage('assets/images/visitor_tab_homepage_normal.png'),
        getTabImage('assets/images/visitor_tab_homepage_selected.png')
      ],
      [
        getTabImage('assets/images/visitor_tab_visitors_normal.png'),
        getTabImage('assets/images/visitor_tab_visitors_selected.png')
      ],
      [
        getTabImage('assets/images/visitor_tab_friends_normal.png'),
        getTabImage('assets/images/visitor_tab_friends_selected.png')
      ],
      [
        getTabImage('assets/images/visitor_tab_profile_center_normal.png'),
        getTabImage('assets/images/visitor_tab_profile_center_selected.png')
      ]
    ];
    /*
     * 三个子界面
     */
    _pageList = [
      new HomePage(),
      new ChatList(),
      new AddressPage(type: 1,),
      new MinePage(),
    ];
  }

  Future initWebSocket() async {
    UserInfo userInfo = await LocalStorage.load("userInfo");
    _msgCount = await BadgeUtil().getMessageCount(userInfo);
    int userId = userInfo.id;
    String token = userInfo.token;
    MessageUtils.setChannel(userId.toString(), token.toString());
  }

  @override
  Widget build(BuildContext context) {
    _onWillPop() async {
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }

    return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: WillPopScope(
          child: Scaffold(
              body: _pageList[_tabIndex],
              bottomNavigationBar: new BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  new BottomNavigationBarItem(
                      icon: getTabIcon(0), title: getTabTitle(0)),
                  new BottomNavigationBarItem(
                      icon: _msgCount > 0
                          ? Badge(
                              child: getTabIcon(1),
                              badgeContent: Text(
                                _msgCount.toString(),
                                style: TextStyle(color: Colors.white),
                                textScaleFactor: 1.0,
                              ),
                              badgeColor: Colors.red,
                            )
                          : getTabIcon(1),
                      title: getTabTitle(1)),
                  new BottomNavigationBarItem(
                      icon: getTabIcon(2), title: getTabTitle(2)),
                  new BottomNavigationBarItem(
                      icon: getTabIcon(3), title: getTabTitle(3)),
                ],
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                //默认选中首页
                currentIndex: _tabIndex,
                iconSize: 20.0,
                //点击事件
                onTap: (index) {
                  setState(() {
                    _tabIndex = index;
                    if(_tabIndex==1){
                      _msgCount=0;
                    }
                  });
                },
              )),
          onWillPop: () {
            _onWillPop();
            return null;
          },
        ));
  }
}
