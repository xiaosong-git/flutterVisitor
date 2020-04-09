import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/EventBusUtil.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/FriendCountChangeEvent.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/FriendListEvent.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/common/error.dart';

//新的好友

class NewFriendPage extends StatefulWidget {
  final UserInfo userInfo;
  NewFriendPage({Key key, this.userInfo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NewFriendPageState();
  }
}
class NewFriendPageState extends State<NewFriendPage> {
  List<Person> _request = new List();
  List<Person> _friends = new List();
  UserInfo _userInfo;
  var _requestBuilderFuture;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新的好友',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF373737)),),
        centerTitle: true,
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 1,
        brightness: Brightness.light,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Image(
              image: AssetImage("assets/images/login_back.png"),
              width: ScreenUtil().setWidth(36),
              height: ScreenUtil().setHeight(36),
              color: Color(0xFF373737),),
            onPressed: () {
              setState(() {
                FocusScope.of(context).requestFocus(FocusNode());
                Navigator.pop(context);
              });
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
        return Text('无连接', textScaleFactor: 1.0);
        break;
      case ConnectionState.waiting:
        return Container(color: Colors.white,);
        break;
      case ConnectionState.active:
        return Text('active', textScaleFactor: 1.0);
        break;
      case ConnectionState.done:
        if (snapshot.hasError) return ErrorPage();
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
          ],
        ),
        onRefresh: init);
  }
  //初始化
  //加载潜在好友列表
  Future init() async {
    await loadAll("");
    return null;
  }


  loadAll(String phoneStr) async {
    _request.clear();
    String url="userFriend/newFriend";
    UserInfo userInfo=await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url, queryParameters: {
      "token": userInfo.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "userId": userInfo.id,
      "phone":"",
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
            if (user.name != null && user.name != "") {
              if(user.applyType=='同意'){
                setState(() {
                  _request.add(user);
                });
              }
            }
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    EventBusUtil().eventBus.fire(FriendCountChangeEvent(0));
    _userInfo = widget.userInfo;
    _requestBuilderFuture = init();
  }

  Widget _friendRequest() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return Column(children: <Widget>[
          ListTile(
              leading: Container(
                child: CachedNetworkImage(
                imageUrl: RouterUtil.imageServerUrl + _request[index].imageUrl,
                placeholder: (context, url) => Container(
                  child: CircularProgressIndicator(backgroundColor: Colors.black,),
                  width: 10,
                  height: 10,
                  alignment: Alignment.center,
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  backgroundImage: AssetImage("assets/icons/ic_launcher.png"),
                  radius: 100,
                ),
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  backgroundImage: imageProvider,
                  radius: 100,
                ),
                  fit: BoxFit.fill,
               ),
                width: 50,
                height: 50,
              ),
              title: Text(
                _request[index].name,
                textScaleFactor: 1.0,
              ),
              subtitle: Text(
                '留言',
                textScaleFactor: 1.0,
              ),
              trailing: Container(
                child: SizedBox(
                    width: 75,
                    height: 35,
                    child: _request[index].applyType == '同意'
                        ? RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            textColor: Colors.white,
                            color: Colors.blue[200],
                            child: Text('同意',
                                style: TextStyle(color: Colors.blue[600]),
                                textScaleFactor: 1.0),
                            onPressed: () async {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => remarkFriendPage(
                                            userId: _request[index].userId,
                                            userInfo: _userInfo,
                                          ))  );
                            })
                        : Align(
                            child: Text('已添加',
                                style: TextStyle(color: Colors.black45),
                                textScaleFactor: 1.0),
                            alignment: Alignment.center,
                          )),
              )),
          Divider(height: 0),
        ]);
      }, childCount: _request.length ?? 0),
    );
  }
}

class Person {
  String name;
  String nickname;
  String phone;
  String imageUrl;
  String applyType;
  int userId;

  Person(
      {this.name,
      this.nickname,
      this.phone,
      this.imageUrl,
      this.applyType,
      this.userId});
}

class remarkFriendPage extends StatelessWidget {
  final int userId;
  final UserInfo userInfo;
  remarkFriendPage({Key key, this.userId, this.userInfo}) : super(key: key);
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String remark = "";

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Scaffold(
            appBar: AppBar(
              title: Text('朋友备注', textScaleFactor: 1.0),
              centerTitle: true,
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: new RaisedButton(
                    color: Colors.green,
                    textColor: Colors.white,
                    child: new Text('完成',
                        style: TextStyle(fontSize: Constant.normalFontSize),
                        textScaleFactor: 1.0),
                    onPressed: () async {
                      formKey.currentState.save();
                      bool result=await agreeRequest(userId, remark, userInfo);
                      if(result){
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
                      child: Text('为朋友添加备注', textScaleFactor: 1.0),
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
                    ),
                  ),
                ],
              ),
            ))));
  }

  Future<bool> agreeRequest(int friendId, String remark, UserInfo user) async {
    String url = "userFriend/agreeFriend";
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url, queryParameters: {
      "token": user.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "userId": user.id,
      "friendId": friendId,
      "type": "1",
      "remark": remark,
    });
    if (res is String) {
      Map map = jsonDecode(res);
      ToastUtil.showShortClearToast(map['verify']['desc']);
      if (map['verify']['sign'] == "success") {
        EventBusUtil().eventBus.fire(FriendListEvent(1));
        EventBusUtil().eventBus.fire(FriendCountChangeEvent(0));
        return true;
      }
      ToastUtil.showShortClearToast(map['verify']['desc']);
    }
    return false;
  }
}
