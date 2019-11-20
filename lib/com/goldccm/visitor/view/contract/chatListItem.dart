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

class ChatList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ChatListState();
  }
}

class ChatListState extends State<ChatList> {
  UserInfo _userInfo=new UserInfo();
  WebSocketChannel channel = MessageUtils.getChannel();
  List<ChatMessage> _chatHis = [];
  Timer _timer;
  countDown() {
    const oneCall = const Duration(milliseconds: 3000);
    var callback = (timer) => {getLatestMessage()};
    _timer = Timer.periodic(oneCall, callback);
  }

  getLatestMessage() async {
    List<ChatMessage> list = await MessageUtils.getLatestMessage(_userInfo.id);
    setState(() {
      _chatHis = list;
    });
  }

  Future refresh() async{
    getLatestMessage();
    ToastUtil.showShortClearToast("刷新成功");
    return null;
  }

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
  initData() async{
    _userInfo=await LocalStorage.load("userInfo");
    countDown();
  }
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

  Widget buildMessageListItem(BuildContext context, int index) {
    ChatMessage message = _chatHis[index];
    print(message);
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
}
