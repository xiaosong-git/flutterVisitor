import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:visitor/com/goldccm/visitor/db/ChatMessage.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/db/friendDao.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/EventBusUtil.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/MessageCountChangeEvent.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/MessageUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';

import '../chat.dart';
import 'MessageCompent.dart';

//聊天主页
class ChatHomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ChatHomePageState();
  }
}
//实现聊天栏展示
//好友搜索
class ChatHomePageState extends State<ChatHomePage>{
  List<ChatMessage> _chatHis = [];
  List<FriendInfo> _chatHisInfo = [];
  Timer _timer;
  final SlidableController slidableController = SlidableController();
  final List<String> actions = ['删除',];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:  AppBar(
          title: Text('消息',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF373737)),),
          centerTitle: true,
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 1,
          brightness: Brightness.light,
          automaticallyImplyLeading: false,
          actions: <Widget>[

          ],
        ),
      body:  _chatHis!=null&&_chatHis.length>0?messagePage():emptyPage(),
    );
  }
  Widget emptyPage(){
    return Container(
      padding: EdgeInsets.only(top: 100),
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Image(
            width: ScreenUtil().setWidth(486),
            height: ScreenUtil().setHeight(416),
            fit: BoxFit.cover,
            image: AssetImage('assets/images/message_empty.png'),
          ),
          Container(
            padding: EdgeInsets.only(top: 20),
            child:Text('快去和好友畅聊吧！',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF373737)),)
          ),
        ],
      ),
    );
  }
  Widget messagePage(){
    return  RefreshIndicator(
        child: ListView.builder(
          itemCount: _chatHis != null ? _chatHis.length : 0,
          itemBuilder: buildMessageListItem,
        ),
        onRefresh: refresh
    );
  }
  Widget buildMessageListItem(BuildContext context, int index) {
    ChatMessage message = _chatHis[index];
    FriendInfo friend = _chatHisInfo[index]??FriendInfo();
    return new Slidable(
      controller:slidableController,
      child:InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          EventBusUtil().eventBus.fire(MessageCountChangeEvent(1));
          FriendInfo user = new FriendInfo(
              userId: message.M_FriendId,
              name: friend.remarkName!="" && friend.remarkName!=null ? friend.remarkName : friend.name !="" && friend.name!=null ? friend.name:"Unknown",
              virtualImageUrl: friend.virtualImageUrl,
              imageServerUrl:RouterUtil.imageServerUrl,
              phone: friend.phone,
              orgId: friend.orgId.toString());
          Navigator.push(context,
              CupertinoPageRoute(builder: (context) => ChatPage(user: user)));
        },
        child:MessageCompent(
          headImgUrl: friend.virtualImageUrl,
          realName: friend.remarkName!="" && friend.remarkName!=null ? friend.remarkName : friend.name !="" && friend.name!=null ?friend.name:"Unknown",
          latestTime: message.M_Time,
          latestMsg: message.M_MessageContent ?? "",
          isSend: message.M_IsSend,
          unreadCount: message.unreadCount,
          imageServerUrl: RouterUtil.imageServerUrl,
        ),
      ),
      actionPane: SlidableScrollActionPane(),
      actionExtentRatio: 0.25,
      secondaryActions: <Widget>[
        SlideAction(
          color: Colors.red,
          child: Center(
            child: Text(
              '删除',
              style: TextStyle(color: Colors.white),
            ),
          ),
          onTap: () {
            deleteSingle(message.M_FriendId);
          },
        ),
      ],
    );
  }
  //读取聊天信息
  getLatestMessage() async {
    _chatHis.clear();
    _chatHisInfo.clear();
    UserInfo userInfo = await LocalStorage.load("userInfo");
    List<ChatMessage> list = await MessageUtils.getLatestMessage(userInfo.id);
    if (list != null) {
      for (var chat in list) {
        if (chat.M_isDeleted!=1) {
          FriendDao friendDao=FriendDao();
          FriendInfo friendInfo=await friendDao.querySingle(chat.M_FriendId);
          if(friendInfo!=null){
            _chatHisInfo.add(friendInfo);
          }else{
            _chatHisInfo.add(FriendInfo());
          }
          _chatHis.add(chat);
        }
      }
    }
    if(mounted){
      setState(() {});
    }
  }
  //定时刷新聊天栏
  countDown() {
    const oneCall = const Duration(milliseconds: 3000);
    var callback = (timer) => {getLatestMessage()};
    _timer = Timer.periodic(oneCall, callback);
  }
  //删除单个聊天栏
  Future deleteSingle(int id) async {
    int count=await MessageUtils.removeLastestMessage(id);
    if(count>0){
      refresh();
    }else{
      ToastUtil.showShortClearToast("删除失败");
    }
  }
  //手动刷新聊天栏
  Future refresh() async {
    getLatestMessage();
    return null;
  }
  //关闭
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
  void initState() {
    super.initState();
    initData();
  }
  //初始化
  initData() async {
    getLatestMessage();
    countDown();
  }
}