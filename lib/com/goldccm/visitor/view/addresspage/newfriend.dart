import 'dart:convert';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/PremissionHandlerUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
/*
 * 新的好友
 * Author:ody997
 * Email:hwk@growingpine.com
 * 2019/10/16
 */
class NewFriendPage extends StatefulWidget {
  final UserInfo userInfo;
  NewFriendPage({Key key, this.userInfo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NewFriendPageState();
  }
}

class NewFriendPageState extends State<NewFriendPage> {
  Presenter presenter = new Presenter();
  List<Person> _request = new List();
  List<Person> _friends = new List();
  UserInfo _userInfo;
  var _requestBuilderFuture;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '新的朋友',
          style: TextStyle(fontSize: 17.0),textScaleFactor: 1.0
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.color,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: FutureBuilder(
        builder: _requestFuture,
        future: _requestBuilderFuture,
      ),
    );
  }

  Widget _requestFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('无连接',textScaleFactor: 1.0);
        break;
      case ConnectionState.waiting:
        return Stack(
          children: <Widget>[
            Opacity(
                opacity: 0.1,
                child: ModalBarrier(
                  color: Colors.black,
                )
            ),
            Center(
              child:Container(
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  //黑色背景
                    color: Colors.black87,
                    //圆角边框
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  //控件里面内容主轴负轴剧中显示
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  //主轴高度最小
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text(
                      '加载中',
                      style: TextStyle(color: Colors.white),textScaleFactor: 1.0
                    )
                  ],
                ),
              ),
            ),
          ],
        );
        break;
      case ConnectionState.active:
        return Text('active',textScaleFactor: 1.0);
        break;
      case ConnectionState.done:
        if (snapshot.hasError) return Text(snapshot.error.toString(),textScaleFactor: 1.0,);
        return _buildRequestList();
        break;
      default:
        return null;
    }
  }

  _buildRequestList() {
    return RefreshIndicator(
        child: CustomScrollView(
          slivers: <Widget>[
            _friendRequest(),
            _findNew(),
          ],
        ),
        onRefresh: init);
  }

  Future init() async {
    await presenter.loadRequest(_userInfo);
    await presenter.loadFriend(_userInfo);
    setState(() {
      _request = presenter.getRequest();
      _friends = presenter.getFriend();
    });
    return null;
  }
  ///读取手机通讯录
  loadContacts() async {
    if(PermissionHandlerUtil.contact!=2){
      PermissionHandlerUtil().askContactPermission();
    }else {
      String _phoneStr = "";
      Iterable<Contact> contacts = await ContactsService.getContacts();
      for (Contact contact in contacts) {
        for (var phone in contact.phones) {
          if (phone != null && phone.value != null) {
            String str = "";
            var cuts = phone.value.split(" ");
            for (var cut in cuts) {
              str = str + cut;
            }
            RegExp exp = RegExp('\^[0-9]*\$');
            if (exp.hasMatch(str)) {
              _phoneStr += str + ",";
            }
          }
        }
      }
      LocalStorage.save("phoneStr", _phoneStr);
    }
  }

  @override
  void initState() {
    super.initState();
    _userInfo = widget.userInfo;
    loadContacts();
    _requestBuilderFuture = init();
  }
  Widget _findNew() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return ListTile(
            leading: Container(
              child: CircleAvatar(
                backgroundImage: _friends[index].imageUrl!=null?NetworkImage(
                    Constant.imageServerUrl + _friends[index].imageUrl):AssetImage("assets/images/visitor_icon_head.png"),
              ),
              height: 50,
              width: 50,
            ),
            title: Text('来自通讯录的好友',textScaleFactor: 1.0,),
            subtitle: Text('${_friends[index].name}',textScaleFactor: 1.0,),
            trailing: Container(
              child: SizedBox(
                  width: 75,
                  height: 35,
                  child: _friends[index].applyType == null
                      ? RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          textColor: Colors.white,
                          color: Colors.blue[200],
                          child: Text(
                            '添加',
                            style: TextStyle(color: Colors.blue[600]),
                            textScaleFactor: 1.0,
                          ),
                          onPressed: () async {
                            presenter.addFriend(_friends[index].name,
                                _friends[index].phone, _userInfo);
                          })
                      : Align(
                    child: Text(
                      '已添加',
                      style: TextStyle(color: Colors.black45),
                      textScaleFactor: 1.0,
                    ),
                    alignment: Alignment.center,
                  )),
            ));
      }, childCount:
      _friends.length != null ? _friends.length : 0
      ),
    );
  }

  Widget _friendRequest() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return Column(children: <Widget>[
          ListTile(
              leading: Container(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                      presenter.getImageUrl() + _request[index].imageUrl),
                ),
                height: 50,
                width: 50,
              ),
              title: Text(_request[index].name,textScaleFactor: 1.0,),
              subtitle: Text('留言',textScaleFactor: 1.0,),
              trailing: Container(
                child: SizedBox(
                    width: 75,
                    height: 35,
                    child: _request[index].applyType == 0
                        ? RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            textColor: Colors.white,
                            color: Colors.blue[200],
                            child: Text(
                              '同意',
                              style: TextStyle(color: Colors.blue[600]),textScaleFactor: 1.0
                            ),
                            onPressed: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => remarkFriendPage(
                                            userId: _request[index].userId,
                                            userInfo: _userInfo,
                                          ))).then((val) => {init()});
                            })
                        : Align(
                            child: Text(
                              '已添加',
                              style: TextStyle(color: Colors.black45),textScaleFactor: 1.0
                            ),
                            alignment: Alignment.center,
                          )),
              )),
          Divider(height: 0),
        ]);
      }, childCount: _request.length != null ? _request.length : 0),
    );
  }
}

class Person {
  String name;
  String nickname;
  String phone;
  String imageUrl;
  int applyType;
  int userId;

  Person(
      {this.name,
      this.nickname,
      this.phone,
      this.imageUrl,
      this.applyType,
      this.userId});
}

class Presenter {
  List<Person> _request = new List<Person>();
  List<Person> _friends = new List<Person>();
  String _phoneStr = "";
  String _imageUrl;

  Future<bool> agreeRequest(int friendId, String remark, UserInfo user) async {
    String url = Constant.serverUrl + "userFriend/agreeFriend";
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url, queryParameters: {
      "token": user.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": CommonUtil.getAppVersion(),
      "userId": user.id,
      "friendId": friendId,
      "type": "1",
      "remark": remark,
    });
    if (res is String) {
      Map map = jsonDecode(res);
      ToastUtil.showShortClearToast(map['verify']['desc']);
      if (map['verify']['sign'] == "success") {
        return true;
      }
      ToastUtil.showShortClearToast(map['verify']['desc']);
    }
    return false;
  }

  addFriend(String name, String phone, UserInfo user) async {
    String url = Constant.serverUrl + "userFriend/addFriendByPhoneAndUser";
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url, queryParameters: {
      "token": user.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": CommonUtil.getAppVersion(),
      "userId": user.id,
      "phone": phone,
      "realName": name,
    });
    if (res is String) {
      Map map = jsonDecode(res);
      ToastUtil.showShortClearToast(map['verify']['desc']);
    }
  }

  getFriend() {
    return _friends;
  }

  getImageUrl() {
    return _imageUrl;
  }

  getRequest() {
    return _request;
  }

  Future loadFriend(UserInfo user) async {
    _friends.clear();
    String url = Constant.serverUrl + "userFriend/findIsUserByPhone";
    String threshold = await CommonUtil.calWorkKey();
    String str =await LocalStorage.load("phoneStr");
    _imageUrl = await DataUtils.getPararInfo("imageServerUrl");
    if (str != "") {
      var res = await Http().post(url, queryParameters: {
        "token": user.token,
        "factor": CommonUtil.getCurrentTime(),
        "threshold": threshold,
        "requestVer": CommonUtil.getAppVersion(),
        "userId": user.id,
        "phoneStr": str!=null?str:"",
      },debugMode: true);
      if (res is String) {
        Map map = jsonDecode(res);
        if (map['verify']['sign'] == "success") {
          List userList = map['data'];
          if (userList == null) {
            return;
          }
          for (var userInfo in userList) {
            Person user = Person(
                name: userInfo['realName'],
                phone: userInfo['phone'],
                imageUrl: userInfo['idHandleImgUrl'],
                userId: userInfo['id'],
                applyType: userInfo['applyType'],
                nickname: userInfo['nickName']);
            if(user.name!=null&&user.name!=""){
              _friends.add(user);
            }
          }
        }
      }
    }
  }

  Future loadRequest(UserInfo user) async {
    _request.clear();
    String url = Constant.serverUrl + "userFriend/beAgreeingFriendList";
    String threshold = await CommonUtil.calWorkKey();
    _imageUrl = await DataUtils.getPararInfo("imageServerUrl");
    var res = await Http().post(url, queryParameters: {
      "token": user.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": CommonUtil.getAppVersion(),
      "userId": user.id,
    });
    if (res is String) {
      Map map = jsonDecode(res);
      if (map['verify']['sign'] == "success") {
        List userList = map['data'];
        if (userList != null) {
          for (var userInfo in userList) {
            Person user = Person(
                name: userInfo['realName'],
                phone: userInfo['phone'],
                imageUrl: userInfo['idHandleImgUrl'],
                userId: userInfo['id'],
                nickname: userInfo['nickName'],
                applyType: userInfo['applyType']);
            if(user.name!=null&&user.name!=""){
              _request.add(user);
            }
          }
        }
      }
    }
  }
}

class remarkFriendPage extends StatelessWidget {
  final int userId;
  final UserInfo userInfo;
  remarkFriendPage({Key key, this.userId, this.userInfo}) : super(key: key);
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Presenter _presenter = new Presenter();
  String remark = "";
  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Scaffold(
            appBar: AppBar(
              title: Text('朋友备注',textScaleFactor: 1.0),
              centerTitle: true,
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: new RaisedButton(
                    color: Colors.green,
                    textColor: Colors.white,
                    child: new Text(
                      '完成',
                      style: TextStyle(fontSize: Constant.normalFontSize),textScaleFactor: 1.0
                    ),
                    onPressed: () async {
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        var result=_presenter.agreeRequest(userId, remark, userInfo);
                          Navigator.pop(context);
                          Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
                child: Container(
              height: 120,
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Align(
                    child: Container(
                      child: Text(
                        '为朋友添加备注',textScaleFactor: 1.0
                      ),
                      padding: EdgeInsets.only(top: 10.0),
                    ),
                    alignment: Alignment(-0.85, 0),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: '请输入备注',
                        enabledBorder: new UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black12, width: 1.0),
                        ),
                        hintStyle: TextStyle(fontSize: Constant.normalFontSize),
                      ),
                      onSaved: (value) {
                        remark = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return '输入不能为空';
                        }
                      },
                    ),
                  ),
                ],
              ),
            ))));
  }
}
