import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/model/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
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
                          Constant.imageServerUrl + _user.virtualImageUrl,
                        )
                      : _user.realImageUrl != null
                          ? NetworkImage(
                              Constant.imageServerUrl + _user.realImageUrl,
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
                  Text(_user.notice != null ? _user.notice : '备注',
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
            //创建透明层
            type: MaterialType.transparency, //透明类型
            child: Container(
              //保证控件居中效果
              alignment: Alignment.bottomCenter,
//              margin: EdgeInsets.all(15.0),
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
                                Navigator.pop(context);
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
          );
        });
  }
}
