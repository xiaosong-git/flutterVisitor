import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/EventBusUtil.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/FriendListEvent.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/MessageCountChangeEvent.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/addresspage.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/chat.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/*
 * 好友详情
 * Author:ody997
 * Email:hwk@growingpine.com
 * 2019/10/16
 */
class FriendDetailPage extends StatefulWidget {
  final FriendInfo user;
  final int type;
  FriendDetailPage({Key key, this.user, this.type}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return FriendDetailPageState();
  }
}

class FriendDetailPageState extends State<FriendDetailPage> {
  FriendInfo _user;
  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }
  deleteSingleFriend() async {
    UserInfo userInfo = await  LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey();
    var response=await Http().post(Constant.deleteUserFriendUrl,queryParameters: {
      "token":userInfo.token,
      "userId":userInfo.id,
      "factor":CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "friendId":_user.userId,
    },userCall: true);
    if(response!=""&&response!=null){
      if(response is String){
        Map responseMap = jsonDecode(response);
        if(responseMap['verify']['sign']=="success"){
          ToastUtil.showShortClearToast("好友已删除");
          Navigator.pop(context);
          Navigator.pop(context);
          EventBusUtil().eventBus.fire(FriendListEvent(1));
        }else{
          ToastUtil.showShortClearToast("删除好友失败");
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('好友信息', textScaleFactor: 1.0),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.more_horiz),
              onPressed: () {
                showOption();
              }),
        ],
      ),
      body: _drawDetail(),
    );
  }

  Widget _drawDetail() {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
          height: 200,
          child: Row(
            children: <Widget>[
              Container(
                height: 60,
                child: CircleAvatar(
                  backgroundImage: _user.virtualImageUrl != null
                      ? NetworkImage(
                          RouterUtil.imageServerUrl + _user.virtualImageUrl,
                        )
                      : _user.realImageUrl != null
                          ? NetworkImage(
                              RouterUtil.imageServerUrl + _user.realImageUrl,
                            )
                          : AssetImage('assets/images/visitor_icon_head.png'),
                  radius: 100,
                ),
                width: 60.0,
                margin: EdgeInsets.all(20),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_user.notice != null && _user.notice !="" ? _user.notice : _user.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textScaleFactor: 1.0),
                  Text("姓名：" + (_user.name != null ? _user.name : '姓名'),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15.0,
                      ),
                      textScaleFactor: 1.0),
                  Text("手机号码：" + (_user.phone != null ? _user.phone : '手机号码'),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15.0,
                      ),
                      textScaleFactor: 1.0),
                  Text(
                      "所属公司：" +
                          (_user.companyName != null ? _user.companyName : '无'),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15.0,
                      ),
                      textScaleFactor: 1.0),
                ],
              ),
            ],
          ),
        ),
        new Container(
          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: new SizedBox(
            width: 300.0,
            height: 50.0,
            child: new RaisedButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('洽谈',
                      style: TextStyle(fontSize: Constant.normalFontSize),
                      textScaleFactor: 1.0),
              onPressed: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatPage(
                              user: widget.user,
                        )));
              },
            ),
          ),
        ),
      ],
    );
  }

  void showOption() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return new Material(
            type: MaterialType.transparency,
            child: Stack(
              children: <Widget>[
                GestureDetector(onTap: (){Navigator.pop(context);},),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: new SizedBox(
                    height: 120,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: ShapeDecoration(
                            color: Color(0xffffffff),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(0.0),
                              ),
                            ),
                          ),
                          child: new Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 0, bottom: 0),
                                child: FlatButton(
                                  onPressed: () async {
                                    deleteSingleFriend();
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Text('删除',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18.0, color: Colors.red),
                                        textScaleFactor: 1.0),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 0, bottom: 0),
                                child: FlatButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Text('添加备注',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18.0, color: Colors.red),
                                        textScaleFactor: 1.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          );
        });
  }
}
