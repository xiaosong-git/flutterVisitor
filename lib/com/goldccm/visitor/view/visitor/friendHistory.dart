import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/newfriend.dart';
import 'package:visitor/com/goldccm/visitor/view/common/LoadingDialog.dart';
import 'package:visitor/com/goldccm/visitor/view/common/emptyPage.dart';

//好友历史界面
//create_time:2020/1/13
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
  EasyRefreshController _easyRefreshController;
  bool isPerformingRequest = false;
  bool notEmpty=true;
  var _friendBuilderFuture;
  @override
  void initState() {
    super.initState();
    _easyRefreshController=new EasyRefreshController();
    _friendBuilderFuture=_getMoreData();
  }
  @override
  void dispose() {
    _easyRefreshController.dispose();
    super.dispose();
  }
  _buildInviteList(){
    return EasyRefresh(
      child: ListView.separated(
        itemCount: _friendLists.length,
        itemBuilder: (BuildContext context, int index) {
          return     ListTile(
              leading: Container(
                child: CachedNetworkImage(
                  imageUrl:  RouterUtil.imageServerUrl + _friendLists[index].virtualImageUrl,
                  placeholder: (context, url) =>
                      CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error),
                  fit: BoxFit.cover,
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
      ),
      onRefresh: () async{
        refresh();
      },
      onLoad: () async{
        _getMoreData();
      },
      controller: _easyRefreshController,
      enableControlFinishLoad: true,
      firstRefreshWidget: LoadingDialog(text: '加载中',),
      firstRefresh: false,
      emptyWidget: notEmpty!=true?EmptyPage():null,
    );
  }
  refresh() async {
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
              notEmpty = false;
            });
          }else{
            _friendLists.clear();
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
            });
            if (map['data'].length < 10) {
              setState(() {
                count--;
              });
            }
          }
        }
      }
  }
  _getMoreData() async {
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
                notEmpty = false;
              });
            }else{
              _friendLists.clear();
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
              });
              if (map['data'].length < 10) {
                setState(() {
                  count--;
                });
                _easyRefreshController.finishLoad(success: true,noMore: true);
              }else{
                _easyRefreshController.finishLoad(success: true,noMore: true);
              }
            }
          }
        }
  }
  Widget _friendFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('无连接',textScaleFactor: 1.0,);
        break;
      case ConnectionState.waiting:
        return LoadingDialog(text: '加载中',);
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