import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ContactsUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/Common/error.dart';

import 'newfriend.dart';

class ContactsPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ContactsPageState();
  }
}
class ContactsPageState extends State<ContactsPage>{
  var _contactsBuilderFuture;
  List<Person> _friends = new List();
  List<Person> _selectFriends = new List();
  TextEditingController textController = new TextEditingController();
  @override
  void initState() {
    super.initState();
    _contactsBuilderFuture = init();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child:IconButton(
                  icon: Image(
                    image: AssetImage("assets/images/login_back.png"),
                    width: 20,
                    height: 20,
                    fit: BoxFit.fill,
                    color: Color(0xFF373737),),
                  onPressed: () {
                    setState(() {
                      FocusScope.of(context).requestFocus(FocusNode());
                      Navigator.pop(context);
                    });
                  }),
            ),
            Expanded(
              flex: 9,
              child: Container(
                height:40,
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child:  TextField(
                        decoration: new InputDecoration(
                          hintText: '搜索',
                          hintStyle: TextStyle(fontSize:16),
                          contentPadding: const EdgeInsets.only(bottom: 5),
                          border: InputBorder.none,),
                        onChanged: onSearchTextChanged,
                        controller: textController, style: TextStyle(height: 1,fontSize: 16),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:Color(0xFFF6F6F6),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 1,
        brightness: Brightness.light,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
        builder: _contactsFuture,
        future: _contactsBuilderFuture,
      ),
    );
  }
  _buildRequestList() {
    return RefreshIndicator(
        child: CustomScrollView(
          slivers: <Widget>[
            _findNew(),
          ],
        ),
        onRefresh: init);
  }
  void onSearchTextChanged(String value) {
    if(value!=""){
      List<Person> _lists = new List<Person>();
      if (value == "") {
        textController.text = "";
      } else {
        for(var user in _friends){
          if(user.name.contains(textController.text)){
            _lists.add(user);
          }
        }
      }
      setState(() {
        _selectFriends=_lists;
      });
    }else{
      loadAll();
    }
  }
  Widget _findNew() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        print(_selectFriends[index].applyType);
        return ListTile(
            leading: Container(
              child: CachedNetworkImage(
                imageUrl: RouterUtil.imageServerUrl + _selectFriends[index].imageUrl,
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
              ),
              height: 50,
              width: 50,
            ),
            title: Text(
              '来自通讯录的好友',
              textScaleFactor: 1.0,
            ),
            subtitle: Text(
              '${_selectFriends[index].name}',
              textScaleFactor: 1.0,
            ),
            trailing: Container(
              child: SizedBox(
                  width: 75,
                  height: 35,
                  child: _selectFriends[index].applyType == "null"
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
                        addFriend(_selectFriends[index].name,
                          _selectFriends[index].phone,);
                      })
                      : _selectFriends[index].applyType == "0"
                      ? Align(
                    child: Text(
                      '申请中',
                      style: TextStyle(color: Colors.black45),
                      textScaleFactor: 1.0,
                    ),
                    alignment: Alignment.center,
                  )
                      : Align(
                    child: Text(
                      '已添加',
                      style: TextStyle(color: Colors.black45),
                      textScaleFactor: 1.0,
                    ),
                    alignment: Alignment.center,
                  )),
            ));
      }, childCount: _selectFriends.length ?? 0),
    );
  }
  addFriend(String name, String phone) async {
    String url = "userFriend/addFriendByPhoneAndUser";
    UserInfo user=await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url, queryParameters: {
      "token": user.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "userId": user.id,
      "phone": phone,
      "realName": name,
    });
    if (res is String) {
      Map map = jsonDecode(res);
      ToastUtil.showShortClearToast(map['verify']['desc']);
    }
    setState(() {

    });
  }
  //初始化
  Future init() async {
    await loadAll();
    return null;
  }
  Widget _contactsFuture(BuildContext context, AsyncSnapshot snapshot) {
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
        if (snapshot.hasError) return Text(snapshot.error.toString(), textScaleFactor: 1.0);
        return _buildRequestList();
        break;
      default:
        return null;
    }
  }
  loadAll() async {
    _friends.clear();
    String phone=await ContactsUtil().getContacts();
    String url="userFriend/findIsUserByPhone";
    UserInfo _userInfo=await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url, queryParameters: {
      "token": _userInfo.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "userId": _userInfo.id,
      "phoneStr":phone,
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
                applyType: userInfo['applyType'].toString(),
                nickname: userInfo['nickName'],);
            if (user.name != null && user.name != ""&&user.phone!=_userInfo.phone) {
                setState(() {
                  _friends.add(user);
                });
            }
          }
          setState(() {
            _selectFriends=_friends;
          });
        }
      }
    }
  }
}