import 'dart:async';
import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/component/MessageCompent.dart';
import 'package:visitor/com/goldccm/visitor/model/ChatMessage.dart';
import 'package:visitor/com/goldccm/visitor/model/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/MessageUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/chat.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/*
 * 消息中心
 * author:hwk<hwk@growingpine.com>
 * create_time:2019/11/22
 */
class ChatList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ChatListState();
  }
}

class ChatListState extends State<ChatList> {
  WebSocketChannel channel = MessageUtils.getChannel();
  List<ChatMessage> _chatHis = [];
  Timer _timer;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Theme.of(context).appBarTheme.color,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: null,
        title: new Text(
          "访客",
          textAlign: TextAlign.center,
          style: new TextStyle(fontSize: 18.0, color: Colors.white),textScaleFactor: 1.0
        ),
      ),
      body: RefreshIndicator(
          child: ListView.builder(
            itemCount: _chatHis != null ? _chatHis.length : 0,
            itemBuilder: buildMessageListItem,
          ),
          onRefresh:refresh
      ),
    );
  }
  //构建每个聊天体
  Widget buildMessageListItem(BuildContext context, int index) {
    ChatMessage message = _chatHis[index];
    return new InkWell(
      onTap: () {
        FriendInfo user = new FriendInfo(
            userId: message.M_FriendId,
            name: message.M_FrealName,
            virtualImageUrl: message.M_FheadImgUrl=="null"?null:message.M_FheadImgUrl,
            imageServerUrl: Constant.imageServerUrl,
            orgId: message.M_orgId.toString());
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ChatPage(user: user)));
      },
      child: MessageCompent(
        headImgUrl: message.M_FheadImgUrl=="null"?null:message.M_FheadImgUrl,
        realName: message.M_FrealName,
        latestTime: message.M_Time,
        latestMsg: message.M_MessageContent,
        isSend: message.M_IsSend,
        unreadCount: message.unreadCount,
        imageServerUrl: Constant.imageServerUrl,
      ),
    );
  }
  //定时刷新聊天栏
  countDown() {
    const oneCall = const Duration(milliseconds: 3000);
    var callback = (timer) => {getLatestMessage()};
    _timer = Timer.periodic(oneCall, callback);
  }
  //读取聊天信息
  getLatestMessage() async {
    UserInfo userInfo=await LocalStorage.load("userInfo");
    _chatHis.clear();
    List<ChatMessage> list = await MessageUtils.getLatestMessage(userInfo.id);
    if(list!=null){
      for(var chat in list){
        if(chat.M_FrealName!=null&&chat.M_FriendId!=null){
          _chatHis.add(chat);
        }
      }
    }
    setState(() {
    });
  }
  //手动刷新聊天栏
  Future refresh() async{
    getLatestMessage();
    ToastUtil.showShortClearToast("刷新成功");
    return null;
  }
  //关闭
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initData();
  }
  //初始化
  initData() async{
    getLatestMessage();
    countDown();
  }
}
