import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/VisitInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/newfriend.dart';

class FriendHistory extends StatefulWidget{
  final UserInfo userInfo;
  FriendHistory({Key key,this.userInfo}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return FriendHistoryState();
  }
}

class FriendHistoryState extends State<FriendHistory>{
  int count = 1;
  List<FriendInfo> _friendLists = <FriendInfo>[];
  ScrollController _scrollController = new ScrollController();
  bool isPerformingRequest = false;
  bool notEmpty=true;
  var _friendBuilderFuture;
  @override
  void initState() {
    super.initState();
    _friendBuilderFuture=_getMoreData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  _buildInviteList(){
    return ListView.separated(
      itemCount: _friendLists.length,
      itemBuilder: (BuildContext context, int index) {
          return     ListTile(
              leading: Container(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                      RouterUtil.imageServerUrl + _friendLists[index].virtualImageUrl),
                ),
                height: 50,
                width: 50,
              ),
              title: Text( _friendLists[index].name,textScaleFactor: 1.0,),
              subtitle: Text('留言',textScaleFactor: 1.0,),
              trailing: Container(
                child: SizedBox(
                    width: 75,
                    height: 35,
                    child:  _friendLists[index].applyType == 0
                        ? RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        textColor: Colors.white,
                        color: Colors.blue[200],
                        child: Text(
                          '同意',
                          style: TextStyle(color: Colors.blue[600],),textScaleFactor: 1.0,
                        ),
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => remarkFriendPage(
                                    userId:  _friendLists[index].userId,
                                    userInfo:widget.userInfo
                                  )));
                        })
                        : Align(
                      child: Text(
                        '已添加',
                        style: TextStyle(color: Colors.black45),textScaleFactor: 1.0,
                      ),
                      alignment: Alignment.centerRight,
                    )),
              ));
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          child: Divider(
            height: 0,
          ),
        );
      },
      padding: EdgeInsets.all(8),
      controller: _scrollController,
    );
  }
  _getMoreData() async {
    _friendLists.clear();
    if (!isPerformingRequest) {
      Future.delayed(Duration(seconds: 1), () async {
        setState(() => isPerformingRequest = true);
        String url =  "userFriend/findFriendApplyMe";
        String threshold = await CommonUtil.calWorkKey();
        var res = await Http().post(url,
            queryParameters: ({
              "token": widget.userInfo.token,
              "factor": CommonUtil.getCurrentTime(),
              "threshold": threshold,
              "requestVer": await CommonUtil.getAppVersion(),
              "userId": widget.userInfo.id,
            }),userCall: false);
        if (res is String) {
          Map map = jsonDecode(res);
          if(map['verify']['sign']=="success"){
            if(map['data'].length==0){
              setState(() {
                isPerformingRequest = true;
                notEmpty = false;
              });
            }else{
              for (var data in map['data']) {
                FriendInfo info = new FriendInfo(
                  name: data['realName'],
                  applyType: data['applyType'],
                  phone: data['phone'],
                  virtualImageUrl: data['idHandleImgUrl'],
                  userId: data['userId']
                );
                if(info.userId!=widget.userInfo.id&&data['realName']!=null){
                  _friendLists.add(info);
                }
              }
              setState(() {
                count++;
                isPerformingRequest = false;
              });
              if (map['data'].length < 10) {
                setState(() {
                  count--;
                  isPerformingRequest = true;
                });
              }
            }
          }
        }
      });
    } else {
      ToastUtil.showShortToast("已加载到底哦！");
    }
  }
  Widget _friendFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('无连接',textScaleFactor: 1.0,);
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
                      style: TextStyle(color: Colors.white),textScaleFactor: 1.0,
                    )
                  ],
                ),
              ),
            ),
          ],
        );
        break;
      case ConnectionState.active:
        return Text('active',textScaleFactor: 1.0,);
        break;
      case ConnectionState.done:
        if (snapshot.hasError) return Text(snapshot.error.toString(),textScaleFactor: 1.0,);
        return _buildInviteList();
        break;
      default:
        return null;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('好友记录',textScaleFactor: 1.0,),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.color,
      ),
      body: notEmpty==true?FutureBuilder(
        builder: _friendFuture,
        future: _friendBuilderFuture,
      ):Column(
        children: <Widget>[
          Container(
            child: Center(
                child: Image.asset('assets/images/visitor_icon_nodata.png')),
            padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
          ),
          Center(child: Text('您还没有好友记录',textScaleFactor: 1.0,))
        ],
      ),
    );
  }
}