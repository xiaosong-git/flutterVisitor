import 'dart:convert';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/addfriend.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/frienddetail.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/newfriend.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/search.dart';
import 'package:lpinyin/lpinyin.dart';

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
  List<FriendInfo> _userLists = new List<FriendInfo>();
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
    _initRefresh();
  }

  @override
  Widget build(BuildContext context) {
    _userModel = Provider.of<UserModel>(context);
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Consumer(
            builder: (context, UserModel userModel, widget) => Text(
                  '通讯录',
                  style: new TextStyle(fontSize: 18.0, color: Colors.white),textScaleFactor: 1.0
                ),
          ),
          leading: null,
          backgroundColor: Theme.of(context).appBarTheme.color,
          actions: <Widget>[
            IconButton(
                icon: Image.asset(
                  "assets/icons/添加新好友@2x.png",
                  scale: 2.0,
                ),
                onPressed: () {
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
                                height:
                                    MediaQuery.of(context).size.height / 3.5,
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
                                                if (_userModel.info.isAuth ==
                                                    "T") {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              AddFriendPage(
                                                                userInfo:
                                                                    _userModel
                                                                        .info,
                                                              )));
                                                } else {
                                                  ToastUtil.showShortClearToast(
                                                      "请先实名认证");
                                                }
                                              },
                                              child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      30,
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Positioned(
                                                        child: Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              15,
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            '添加好友',
                                                            style: TextStyle(
                                                              fontSize: 18.0,
                                                            ),textScaleFactor: 1.0
                                                          ),
                                                        ),
                                                        left: 30,
                                                      ),
                                                      Positioned(
                                                        child: Container(
                                                          width: 20,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              15,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 5),
                                                          child: Image.asset(
                                                            'assets/icons/添加@2x.png',
                                                            scale: 2.0,
                                                          ),
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
                                                if (_userModel.info.isAuth ==
                                                    "T") {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              NewFriendPage(
                                                                userInfo:
                                                                    _userModel
                                                                        .info,
                                                              ))).then((value) {
                                                    Navigator.pop(context);
                                                    _handleRefresh();
                                                  });
                                                } else {
                                                  ToastUtil.showShortClearToast(
                                                      "请先实名认证");
                                                }
                                              },
                                              child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      30,
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Positioned(
                                                        child: Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              15,
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            '新的朋友',
                                                            style: TextStyle(
                                                              fontSize: 18.0,
                                                            ),textScaleFactor: 1.0
                                                          ),
                                                        ),
                                                        left: 30,
                                                      ),
                                                      Positioned(
                                                        child: Container(
                                                          width: 20,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              15,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 5),
                                                          child: Image.asset(
                                                            'assets/icons/新的好友@2x.png',
                                                            scale: 2.0,
                                                          ),
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
                      });
                }),
          ],
        ),
        body: RefreshIndicator(
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    initFlag == true
                        ? Expanded(child: _buildInfoWithoutData())
                        : Expanded(child: _buildInfo()),
                  ],
                ),
                Positioned(
                  top: 120,
                  right: 0,
                  bottom: 10,
                  width: 40,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return new Container(
                        margin:
                            EdgeInsets.only(left: 20.0, right: 10.0, top: 3.5),
                        height: 8.0,
                        child: new Text(
                          '${alphabet[index]}',
                          style: TextStyle(
                            fontSize: 8.0,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                    itemCount: alphabet.length,
                  ),
                ),
              ],
            ),
            onRefresh: _handleRefresh));
  }

  Future _handleRefresh() async {
    await _presenter.loadUserList();
    setState(() {
      _userLists = _presenter.getUserList();
      initFlag = _presenter.getFlag();
    });
    return null;
  }

  Future _initRefresh() async {
    await _presenter.loadUserList();
    setState(() {
      _userLists = _presenter.getUserList();
      initFlag = _presenter.getFlag();
    });
    return null;
  }

  Widget _buildInfoWithoutData() {
    _userModel = Provider.of<UserModel>(context);
    return ListView.separated(
        itemCount: 1,
        separatorBuilder: (context, index) {
          return Container(
            child: Divider(
              height: 0,
            ),
          );
        },
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              Container(
                child: Container(
                    height: 58.0,
                    child: new Card(
                        margin: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        color: Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: new Container(
                          child: new Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 5.0,
                              ),
                              Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    cursorWidth: 0.0,
                                    decoration: new InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(top: 0.0),
                                        hintText: '查找',
                                        border: InputBorder.none),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FriendSearch(
                                                    userList: _userLists,
                                                  )));
                                    },
                                  ),
                                ),
                              ),
                              new IconButton(
                                icon: new Icon(Icons.cancel),
                                color: Colors.grey,
                                iconSize: 18.0,
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ))),
              ),
              Container(
                child: ListTile(
                  title: Text('新的朋友',textScaleFactor: 1.0),
                  leading: Container(
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange,
                    ),
                    child: Image.asset(
                      "assets/icons/添加新好友@2x.png",
                      color: Colors.white,
                      scale: 1.7,
                    ),
                  ),
                  trailing: Image.asset('assets/icons/更多@2x.png', scale: 1.7),
                  onTap: () {
                    if (_userModel.info.isAuth == "T") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewFriendPage(
                                    userInfo: _userModel.info,
                                  )));
                    } else {
                      ToastUtil.showShortClearToast("请先实名认证");
                    }
                  },
                ),
              ),
              Divider(
                height: 0,
              ),
            ],
          );
        });
  }

  Widget _buildInfo() {
    return ListView.separated(
        itemCount: _userLists.length != null ? _userLists.length : 0,
        separatorBuilder: (context, index) {
          return Container(
            child: Divider(
              height: 0,
            ),
          );
        },
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Column(
              children: <Widget>[
                Container(
                  child: Container(
                      height: 58.0,
                      child: new Card(
                          margin: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          color: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: new Container(
                            child: new Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 5.0,
                                ),
                                Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      cursorWidth: 0.0,
                                      decoration: new InputDecoration(
                                          contentPadding:
                                              EdgeInsets.only(top: 0.0),
                                          hintText: '查找',
                                          border: InputBorder.none),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    FriendSearch(
                                                      userList: _userLists,
                                                    )));
                                      },
                                    ),
                                  ),
                                ),
                                new IconButton(
                                  icon: new Icon(Icons.cancel),
                                  color: Colors.grey,
                                  iconSize: 18.0,
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ))),
                ),
                Container(
                  child: ListTile(
                    title: Text('新的朋友',textScaleFactor: 1.0),
                    leading: Container(
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                      ),
                      child: Image.asset(
                        "assets/icons/添加新好友@2x.png",
                        color: Colors.white,
                        scale: 1.7,
                      ),
                    ),
                    trailing: Image.asset('assets/icons/更多@2x.png', scale: 1.7),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewFriendPage(
                                    userInfo: _userModel.info,
                                  ))).then((val) {
                        _handleRefresh();
                      });
                    },
                  ),
                ),
                Divider(
                  height: 0,
                ),
                Container(
                  color: Colors.white,
                  height: 40,
                  child: ListTile(
                    title: Text(_userLists[index].firstZiMu),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(_userLists[index].name),
                    leading: _userLists[index].virtualImageUrl != null &&
                            _userLists[index].virtualImageUrl != ""
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                                Constant.imageServerUrl +
                                    _userLists[index].virtualImageUrl),
                          )
                        :  _userLists[index].realImageUrl != null &&
                        _userLists[index].realImageUrl != ""
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(
                          Constant.imageServerUrl +
                              _userLists[index].realImageUrl),
                    ):CircleAvatar(
                            backgroundImage: AssetImage(
                                "assets/images/visitor_icon_head.png"),
                          ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FriendDetailPage(
                                    user: _userLists[index],
                                    type: widget.type,
                                  )));
                    },
                  ),
                )
              ],
            );
          } else if (_userLists[index].firstZiMu !=
              _userLists[index - 1].firstZiMu) {
            return Column(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  height: 40,
                  child: ListTile(
                    title: Text(_userLists[index].firstZiMu),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(_userLists[index].name),
                    leading: _userLists[index].virtualImageUrl != null &&
                        _userLists[index].virtualImageUrl != ""
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(
                          Constant.imageServerUrl +
                              _userLists[index].virtualImageUrl),
                    )
                        :  _userLists[index].realImageUrl != null &&
                        _userLists[index].realImageUrl != ""
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(
                          Constant.imageServerUrl +
                              _userLists[index].realImageUrl),
                    ):CircleAvatar(
                      backgroundImage: AssetImage(
                          "assets/images/visitor_icon_head.png"),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FriendDetailPage(
                                    user: _userLists[index],
                                    type: widget.type,
                                  )));
                    },
                  ),
                )
              ],
            );
          } else {
            return Container(
              color: Colors.white,
              child: ListTile(
                title: Text(_userLists[index].name),
                leading: _userLists[index].virtualImageUrl != null &&
                    _userLists[index].virtualImageUrl != ""
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(
                      Constant.imageServerUrl +
                          _userLists[index].virtualImageUrl),
                )
                    :  _userLists[index].realImageUrl != null &&
                    _userLists[index].realImageUrl != ""
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(
                      Constant.imageServerUrl +
                          _userLists[index].realImageUrl),
                ):CircleAvatar(
                  backgroundImage: AssetImage(
                      "assets/images/visitor_icon_head.png"),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FriendDetailPage(
                                user: _userLists[index],
                                type: widget.type,
                              )));
                },
              ),
            );
          }
        });
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
  List<FriendInfo> _userlists = new List<FriendInfo>();
  String _imageUrl = "";
  bool initFlag = false;
  getUserList() {
    return _userlists;
  }

  getImageUrl() {
    return _imageUrl;
  }

  getFlag() {
    return initFlag;
  }

  loadUserList() async {
    _userlists.clear();
    UserInfo user = await LocalStorage.load("userInfo");
    _imageUrl = await DataUtils.getPararInfo("imageServerUrl");
    String threshold = await CommonUtil.calWorkKey(userInfo: user);
    String url = Constant.serverUrl + Constant.findUserFriendUrl;
    var res = await Http().post(url, queryParameters: {
      "token": user.token,
      "userId": user.id,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": CommonUtil.getAppVersion(),
    });
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
            FriendInfo user = FriendInfo(
              name: userInfo['realName'],
              phone: userInfo['phone'],
              realImageUrl: userInfo['idHandleImgUrl'],
              virtualImageUrl: userInfo['headImgUrl'],
              companyName: userInfo['companyName'],
              userId: userInfo['id'],
              notice: userInfo['remark'],
              orgId: userInfo['orgId'].toString(),
              imageServerUrl: _imageUrl,
              firstZiMu: PinyinHelper.getFirstWordPinyin(userInfo['realName'])
                  .substring(0, 1)
                  .toUpperCase(),
            );
            _userlists.add(user);
          }
          _userlists.sort((a, b) => PinyinHelper.getFirstWordPinyin(a.name)
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
        ToastUtil.showShortClearToast("您的账号在另一台设备登录，请退出重新登录");
      }
    }
  }
}

List<Choice> choices = <Choice>[
  Choice(title: '添加好友', icon: Icons.person_add, value: 1),
  Choice(title: '新的朋友', icon: Icons.portrait, value: 2),
];
