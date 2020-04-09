import 'dart:async';
import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visitor/com/goldccm/visitor/db/ChatMessage.dart';
import 'package:visitor/com/goldccm/visitor/db/friendDao.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/EventBusUtil.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/FriendListEvent.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/BadgeModel.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/model/provider/BadgeInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/MessageUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/Chat/Book/FirstNameList.dart';
import 'package:visitor/com/goldccm/visitor/view/Chat/Book/contacts.dart';
import 'package:visitor/com/goldccm/visitor/view/Chat/Book/newfriend.dart';
import 'package:visitor/com/goldccm/visitor/view/Chat/Book/search.dart';
import 'package:visitor/com/goldccm/visitor/view/Chat/Message/frienddetail.dart';
import 'package:lpinyin/lpinyin.dart';

import 'addfriend.dart';

/*
 * 通讯录模块
 * 提供一个用户好友列表
 * 用于查看用户详情和开启聊天
 * author:ody997
 * email:hwk@growingpine.com
 * create_time:2019/10/23
 */
class AddressPage extends StatefulWidget {
  final int type;
  AddressPage({Key key, this.type}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddressPageState();
  }
}

///_userList是存放好友信息的列表
///_userModel是Provider管理的变量类
class AddressPageState extends State<AddressPage> {
  Presenter _presenter = new Presenter();
  StreamSubscription _friendListSub;
  List<FriendInfo> _userLists = new List<FriendInfo>();
  List<FriendInfo> _chatHisInfo = [];
  List<ChatMessage> _chatHis = [];
  UserModel _userModel;
  bool initFlag = false;
  var alphabet = [
    '☀',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    '#'
  ];
  @override
  void initState() {
    super.initState();
    initAddress();
    _friendListSub =
        EventBusUtil().eventBus.on<FriendListEvent>().listen((event) {
      _handleRefresh();
    });
  }

  //初始化好友列表
  initAddress() async {
    _presenter.loadUserList();
    _userLists=_presenter.userlists;
    getLatestMessage();
  }

  getLatestMessage() async {
    _chatHis.clear();
    _chatHisInfo.clear();
    UserInfo userInfo = await LocalStorage.load("userInfo");
    List<ChatMessage> list = await MessageUtils.getLatestMessage(userInfo.id);
    if (list != null) {
      for (var chat in list) {
        if (chat.M_isDeleted != 1) {
          FriendDao friendDao = FriendDao();
          FriendInfo friendInfo = await friendDao.querySingle(chat.M_FriendId);
          if (friendInfo != null) {
            _chatHisInfo.add(friendInfo);
          } else {
            _chatHisInfo.add(FriendInfo());
          }
          _chatHis.add(chat);
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _friendListSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userModel = Provider.of<UserModel>(context);
    return Scaffold(
        backgroundColor: Color(0xFFFCFCFC),
        appBar: AppBar(
          title: Text(
            '通讯录',
            textScaleFactor: 1.0,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(36), color: Color(0xFF373737)),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 1,
          brightness: Brightness.light,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Image(
                width: 40,
                height: 40,
                image: AssetImage("assets/images/Chat_Friend_Search.png"),
              ),
              onPressed: search,
            ),
            IconButton(
              icon: Image(
                width: 40,
                height: 40,
                image: AssetImage("assets/images/Chat_Friend_Add.png"),
              ),
              onPressed: callOption,
            ),
          ],
        ),
        body: RefreshIndicator(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        color: Color(0xFFFFFFFF),
                        child: ListTile(
                          title: Text('新的好友', textScaleFactor: 1.0),
                          leading: Provider.of<BadgeModel>(context)
                                      .badgeInfo
                                      .newFriendRequestCount >
                                  0
                              ? Badge(
                                  child: Image(
                                    image: AssetImage(
                                      "assets/images/chat_new.png",
                                    ),
                                    width: 40,
                                    height: 40,
                                  ),
                                  badgeContent: Text(
                                    Provider.of<BadgeModel>(context)
                                        .badgeInfo
                                        .newFriendRequestCount
                                        .toString(),
                                    style: TextStyle(color: Colors.white),
                                    textScaleFactor: 1.0,
                                  ),
                                  badgeColor: Colors.red,
                                )
                              : Image(
                                  image: AssetImage(
                                    "assets/images/chat_new.png",
                                  ),
                                  width: 40,
                                  height: 40,
                                ),
                          trailing: Image(
                            width: 20,
                            height: 20,
                            image: AssetImage('assets/images/mine_next.png'),
                            fit: BoxFit.fill,
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => NewFriendPage(
                                          userInfo: _userModel.info,
                                        ))).then((val) {});
                          },
                        ),
                      ),
                      Container(
                        child: Divider(
                          height: 1,
                        ),
                        padding: EdgeInsets.only(left: 60),
                      ),
                      Container(
                        color: Color(0xFFFFFFFF),
                        child: ListTile(
                          title: Text('我的好友', textScaleFactor: 1.0),
                          leading: Image(
                            image: AssetImage(
                              "assets/images/chat_friends.png",
                            ),
                            width: 40,
                            height: 40,
                          ),
                          trailing: Image(
                            width: 20,
                            height: 20,
                            image: AssetImage('assets/images/mine_next.png'),
                            fit: BoxFit.fill,
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => FirstNameList(
                                          userLists: _userLists,
                                        ))).then((val) {});
                          },
                        ),
                      ),
                      Container(
                        child: Divider(
                          height: 1,
                        ),
                        padding: EdgeInsets.only(left: 60),
                      ),
                      Container(
                        color: Color(0xFFFFFFFF),
                        child: ListTile(
                          title: Text('手机通讯录', textScaleFactor: 1.0),
                          leading: Provider.of<BadgeModel>(context)
                                      .badgeInfo
                                      .newFriendRequestCount >
                                  0
                              ? Badge(
                                  child: Image(
                                    image: AssetImage(
                                      "assets/images/chat_friends.png",
                                    ),
                                    width: 40,
                                    height: 40,
                                  ),
                                  badgeContent: Text(
                                    Provider.of<BadgeModel>(context)
                                        .badgeInfo
                                        .newFriendRequestCount
                                        .toString(),
                                    style: TextStyle(color: Colors.white),
                                    textScaleFactor: 1.0,
                                  ),
                                  badgeColor: Colors.red,
                                )
                              : Image(
                                  image: AssetImage(
                                    "assets/images/chat_friends.png",
                                  ),
                                  width: 40,
                                  height: 40,
                                ),
                          trailing: Image(
                            width: 20,
                            height: 20,
                            image: AssetImage('assets/images/mine_next.png'),
                            fit: BoxFit.fill,
                          ),
                          onTap: () {
                            openContact();
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        color: Color(0xFFFFFFFF),
                        padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                        child: Text(
                          '常用联系人',
                          style:
                              TextStyle(color: Color(0xFF373737), fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                _chatHisInfo.length==0||_chatHisInfo==null ? _buildInfoWithoutData() : _buildInfo(),
              ],
            ),
            onRefresh: _handleRefresh));
  }

  Future _handleRefresh() async {
    await initAddress();
    return null;
  }

  openContact() async {
    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => ContactsPage()));
  }

  search() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => FriendSearch(
                  userList: _userLists,
                )));
  }

  callOption() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => AddFriendPage(
                  userInfo: _userModel.info,
                )));
  }

  Widget _buildInfoWithoutData() {
    return SliverToBoxAdapter(
      child: Container(
          padding: EdgeInsets.only(top: 60),
          child: Column(
            children: <Widget>[
              Image(
                height: 150,
                fit: BoxFit.fitHeight,
                image: AssetImage('assets/images/book_empty_background.png'),
              ),
              Text(
                '暂无好友',
                textScaleFactor: 1,
                style: TextStyle(fontSize: 18, color: Color(0xFF373737)),
              )
            ],
          )),
    );
  }

  Widget _buildInfo() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              Container(
                child: ListTile(
                  title: Text(_chatHisInfo[index].remarkName != null
                      ? _chatHisInfo[index].remarkName
                      : _chatHisInfo[index].name),
                  leading: _chatHisInfo[index].virtualImageUrl != null &&
                          _chatHisInfo[index].virtualImageUrl != ""
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(
                              RouterUtil.imageServerUrl +
                                  _chatHisInfo[index].virtualImageUrl),
                        )
                      : _chatHisInfo[index].realImageUrl != null &&
                              _chatHisInfo[index].realImageUrl != ""
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                  RouterUtil.imageServerUrl +
                                      _chatHisInfo[index].realImageUrl),
                            )
                          : CircleAvatar(
                              backgroundImage: AssetImage(
                                  "assets/images/visitor_icon_head.png"),
                            ),
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => FriendDetailPage(
                                  user: _chatHisInfo[index],
                                  type: widget.type,
                                ))).then((value){
                          setState(() {
                            _presenter.loadUserList();
                          });
                    });
                  },
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(120)),
                child: Divider(height: 1,),
              )
            ],
          );
        },
        childCount: _chatHisInfo.length ?? 0,
      ),
    );
  }
}

class Choice {
  Choice({this.title, this.icon, this.value});
  String title;
  IconData icon;
  int value;
}

///自定义类
///用于存放变量和操作变量
class Presenter {
  List<FriendInfo> userlists = new List<FriendInfo>();
  String _imageUrl = "";
  bool initFlag = false;

  getImageUrl() {
    return _imageUrl;
  }

  loadUserList() async {
    FriendDao friendDao = FriendDao();
    userlists.clear();
    UserInfo user = await LocalStorage.load("userInfo");
    _imageUrl = await DataUtils.getPararInfo("imageServerUrl");
    String threshold = await CommonUtil.calWorkKey(userInfo: user);
    String url = Constant.findUserFriendUrl;
    var res = await Http().post(url,
        queryParameters: {
          "token": user.token,
          "userId": user.id,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
        },
        debugMode: true,
        userCall: false);
    if (res is String) {
      Map map = jsonDecode(res);
      if (map['verify']['sign'] == "success") {
        if (map['data'] != null) {
          initFlag = false;
          List userList = map['data'];
          if (userList.length == 0) {
            initFlag = true;
          }
          for (var userInfo in userList) {
            if (userInfo['realName'] != null &&
                userInfo['phone'] != null &&
                userInfo['realName'] != "" &&
                userInfo['phone'] != "") {
              FriendInfo _userInfo = FriendInfo.fromJson(userInfo, user.id);
              userlists.add(_userInfo);
              bool isExist = await friendDao.isExist(_userInfo.userId);
              if (!isExist) {
                friendDao.insertFriendInfo(_userInfo);
              } else {
                friendDao.updateFriendInfo(_userInfo);
              }
            }
          }
          if (userlists.length == 0) {
            initFlag = true;
          }
          userlists.sort((a, b) => PinyinHelper.getFirstWordPinyin(a.name)
              .substring(0, 1)
              .compareTo(
                  PinyinHelper.getFirstWordPinyin(b.name).substring(0, 1)));
        } else {
          initFlag = true;
        }
      }
    } else {
      initFlag = true;
      if (res['verify']['sign'] == "tokenFail") {
        ToastUtil.showShortClearToast("您的账号在另一台设备登录");
      }
    }
  }
}

