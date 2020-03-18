import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/RoomInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/shareroom/RoomDetail.dart';

/*
 * 共享 - 房间列表
 * email:hwk@growingpine.com
 * create_time:2019/10/22
 */
class RoomList extends StatefulWidget{
  final int type;
  RoomList({Key key,this.type}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return RoomListState();
  }
}
class RoomListState extends State<RoomList>{
  int count=1;
  List<RoomInfo> roomLists=new List<RoomInfo>();
  bool isPerformingRequest = false;
  ScrollController _scrollController = new ScrollController();
  var _roomListBuilderFuture;
  bool notEmpty=true;
  String roomName="共享";
  getRoomLists(int type) async {
    UserInfo userInfo=await DataUtils.getUserInfo();
    String url = "meeting/list/$count/10";
    String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
    var res = await Http().post(url,queryParameters: {
      "token": userInfo.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "userId": userInfo.id,
      "type" : type,
    },debugMode: true);
    if(res is String) {
      Map map = jsonDecode(res);
      if (map['verify']['sign'] == "success") {
        if (map['data']['total'] ==0) {
          setState(() {
            isPerformingRequest = true;
            notEmpty = false;
          });
        }else {
          if(map['data']['total']<10){
            setState(() {
              isPerformingRequest = true;
            });
          }
          for (var room in map['data']['rows']) {
            RoomInfo info = new RoomInfo(id: room['id'],
                roomName: room['room_name'],
                roomOpenTime: room['room_open_time'],
                roomCloseTime: room['room_close_time'],
                roomIntro: room['room_short_content'],
                roomPrice: room['room_price'].toString(),
                roomAddress: room['room_addr'],
                roomStatus: room['room_status'].toString(),
                roomManager: room['room_manager'].toString(),
                roomType: room['room_type'],
                roomSize: room['room_size'],
                roomImage: room['room_image'].split(","),
                isOpen: room['is_open'],
                roomCancelHour: room['rooom_cancle_hour'],
                roomOrgCode: room['room_orgcode'],
                roomPercent: room['room_percent'].toString());
            setState(() {
              roomLists.add(info);
            });
          }
          setState(() {
            count++;
          });
        }
      }
      else{
        ToastUtil.showShortClearToast(map['verify']['desc']);
      }
    }
  }
  _getMoreData(int type) async {
    if (!isPerformingRequest) {
      Future.delayed(Duration(seconds: 1),() async {
        setState(() => isPerformingRequest = true);
        UserInfo userInfo=await DataUtils.getUserInfo();
        String url="meeting/list/$count/10";
        String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
        var res = await Http().post(url,queryParameters: ({
          "token": userInfo.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "userId": userInfo.id,
          "type" : type,
        }));
        if(res is String){
          Map map = jsonDecode(res);
          for(var room in map['data']['rows']){
            RoomInfo info = new RoomInfo(id:room['id'],roomName: room['room_name'],roomOpenTime: room['room_open_time'],roomCloseTime: room['room_close_time'],roomIntro: room['room_short_content'],roomPrice: room['room_price'],isOpen: room['is_open'],roomAddress: room['room_addr'],roomStatus: room['room_status'],roomManager: room['room_manager'],roomType: room['room_type'],roomImage: room['room_image'],roomCancelHour: room['rooom_cancle_hour'],roomOrgCode: room['room_orgcode'],roomPercent: room['room_percent']);
            roomLists.add(info);
          }
          setState(() {
            count++;
            isPerformingRequest = false;
          });
          if(map['data']['rows'].length==0){
            setState(() {
              count--;
              isPerformingRequest = true;
            });
            ToastUtil.showShortClearToast("已加载到底。");
          }
        }
      });
    }
  }
  @override
  void initState() {
    super.initState();
    if(widget.type==0){
      setState(() {
        roomName="共享会议室";
      });
    }else if(widget.type==1){
      setState(() {
        roomName="共享茶室";
      });
    }
    _roomListBuilderFuture=getRoomLists(widget.type);
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        _getMoreData(widget.type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title:Text(roomName, style: new TextStyle(
            fontSize: 17.0, color: Colors.white),textScaleFactor: 1.0,),
        backgroundColor: Theme.of(context).appBarTheme.color,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){Navigator.pop(context);}),
      ),
      body: notEmpty==true?FutureBuilder(
          builder:_roomListFuture,
          future: _roomListBuilderFuture,
      ):Column(
        children: <Widget>[
          Container(
            child: Center(
                child: Image.asset('assets/images/visitor_icon_nodata.png')),
            padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
          ),
          Center(child: Text('暂无会议室列表',textScaleFactor: 1.0,))
        ],
      ),
    );
  }
  Widget _roomListFuture(BuildContext context, AsyncSnapshot snapshot) {
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
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                  child: CircularProgressIndicator(backgroundColor: Colors.black,),
                  width: 10,
                  height: 10,
                  alignment: Alignment.center,
                ),
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
        return _buildRoomList();
        break;
      default:
        return null;
    }
  }
  _buildRoomList(){
    return ListView.separated(
      separatorBuilder: (context,index){
        return Container(
          child: Divider(
            height: 0,
          ),
        );
      },
      itemBuilder: (_, int index) => index==roomLists.length?ListTile(title: Text('加载中',textScaleFactor: 1.0,),):roomListWidget(roomLists[index]),
      itemCount: isPerformingRequest==true?roomLists.length:roomLists.length+1,
      controller: _scrollController,
    );
  }
  Widget roomListWidget(RoomInfo room){
    return   Container(
        width: MediaQuery.of(context).size.width,
        height: 188,
        child:InkWell(
          child:Container(
            padding: EdgeInsets.all(10),
            child: Stack(
              children: <Widget>[
                Positioned(
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child:
                    (room.roomImage[0]!=null&&room.roomImage[0]!="")?Image.network(RouterUtil.imageServerUrl+room.roomImage[0]) : Image.asset("assets/images/visitor_icon_nodata.png"),
                  ),
                  width: 104,
                  height: 132,
                  left: 8,
                  top: 8,
                ),
                Positioned(
                  child: Text(room.roomName!=null?'${room.roomName.length<10?room.roomName:room.roomName.substring(0,10)+"..."}':"",overflow: TextOverflow.ellipsis,maxLines: 1,softWrap:true,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),textScaleFactor: 1.0,),
                  left: 120,
                  width: 210,
                  top: 8,
                ),
                Positioned(
                  child: Text(room.roomAddress!=null?'${room.roomAddress}':"",overflow: TextOverflow.ellipsis,maxLines: 2,textScaleFactor: 1.0,),
                  left: 120,
                  width: 210,
                  top: 38,
                ),
                Positioned(
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.blue[200],
                    ),
                    child: Text('开放时间：${room.roomOpenTime}-${room.roomCloseTime}',style: TextStyle(fontSize: 10.0,color: Colors.blue[700]),textScaleFactor: 1.0,),
                  ),
                  top: 88,
                  left:120,
                ),
                Positioned(
                  child:  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.orange[200],
                    ),
                    child: room.roomType==1?Text('容纳约1-10人',style: TextStyle(fontSize: 10.0,color: Colors.orange[700]),textScaleFactor: 1.0,):room.roomType==2?Text('容纳约10-20人',style: TextStyle(fontSize: 10.0,color: Colors.orange[700]),textScaleFactor: 1.0,):Text('容纳约30人以上',style: TextStyle(fontSize: 10.0,color: Colors.orange[700]),textScaleFactor: 1.0,)
                  ),
                  top: 88,
                  left: 236,
                ),
                Positioned(
                  child: RichText(
                    text: TextSpan(
                      text: '¥',
                      style: TextStyle(fontSize: 14.0,color: Colors.red),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${room.roomPrice}',
                          style: TextStyle(fontSize: 24.0,fontWeight: FontWeight.bold,color: Colors.red),
                        ),
                        TextSpan(
                          text: '/小时',
                          style: TextStyle(fontSize: 16.0,color: Colors.black87),
                        )
                      ],
                    ),
                    textScaleFactor: 1.0,
                  ),
                  top: 115,
                  left: 120,
                )
              ],
            ),
          ),
          onTap: (){
            if(room.isOpen=="is") {
              Navigator.push(context, CupertinoPageRoute(
                  builder: (context) => RoomDetail(roomInfo: room,)));
            }else{
              ToastUtil.showShortClearToast("会议室暂不开放");
            }
          },
        )
    );
  }
}
