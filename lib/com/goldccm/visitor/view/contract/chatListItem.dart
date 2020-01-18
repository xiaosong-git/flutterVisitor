import 'dart:async';
import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/component/MessageCompent.dart';
import 'package:visitor/com/goldccm/visitor/db/friendDao.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/EventBusUtil.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/MessageCountChangeEvent.dart';
import 'package:visitor/com/goldccm/visitor/db/ChatMessage.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/MessageUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/chat.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/*
 * 消息中心
 * create_time:2019/11/22
 */
class ChatList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ChatListState();
  }
}

class ChatListState extends State<ChatList> {
  StreamSubscription _refreshSub;
  List<ChatMessage> _chatHis = [];
  List<FriendInfo> _chatHisInfo = [];
  final SlidableController slidableController = SlidableController();
  Timer _timer;
  final List<String> actions = [
    '删除',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Theme.of(context).appBarTheme.color,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: null,
        title: new Text("访客",
            textAlign: TextAlign.center,
            style: new TextStyle(fontSize: 18.0, color: Colors.white),
            textScaleFactor: 1.0),
      ),
      body: RefreshIndicator(
          child: ListView.builder(
            itemCount: _chatHis != null ? _chatHis.length : 0,
            itemBuilder: buildMessageListItem,
          ),
          onRefresh: refresh),
    );
  }
  //构建每个聊天体
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
                name: friend.notice!="" && friend.notice!=null ? friend.notice : friend.name !="" && friend.name!=null ? friend.name:"Unknown",
                virtualImageUrl: friend.virtualImageUrl,
                imageServerUrl:RouterUtil.imageServerUrl,
                orgId: friend.orgId.toString());
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ChatPage(user: user)));
          },
          child:MessageCompent(
                headImgUrl: friend.virtualImageUrl,
                realName: friend.notice!="" && friend.notice!=null ? friend.notice : friend.name !="" && friend.name!=null ?friend.name:"Unknown",
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

  //手动刷新聊天栏
  Future refresh() async {
    getLatestMessage();
    return null;
  }

  //关闭
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _refreshSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //监听WebSocket更新
//    _refreshSub = EventBusUtil().eventBus.on<MessageCountChangeEvent>().listen((event) {
//      getLatestMessage();
//    });
    initData();
  }

  //初始化
  initData() async {
    getLatestMessage();
    countDown();
  }
}
