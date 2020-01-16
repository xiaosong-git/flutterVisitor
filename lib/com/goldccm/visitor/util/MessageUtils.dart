import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visitor/com/goldccm/visitor/db/chatDao.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/EventBusUtil.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/FriendCountChangeEvent.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/MessageCountChangeEvent.dart';
import 'package:visitor/com/goldccm/visitor/db/ChatMessage.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/TimerUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

/*
 * WebSocket消息监听类
 * editor:ody997
 * email:hwk@growingpine.com
 * create_time:2019/11/13
 */
class MessageUtils {
  //单例
  static MessageUtils _message;
  static MessageUtils get instance => _messageUtils();
  factory MessageUtils() => _messageUtils();
  MessageUtils._internal();

  static WebSocketChannel _channel;
  static bool _isOpen = false;
  static String userID;
  static String userToken;
  static int reCount = 0;
  static TimerUtil _timerUtil = TimerUtil(mInterval: 30000);
  static bool received = true;
  static MessageUtils _messageUtils() {
    if (_message == null) {
      _message = MessageUtils._internal();
    }
    return _message;
  }

  //消息提示音
  static AudioCache player = AudioCache(
    prefix: 'audio/',
    fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.RELEASE),
  );

  //init
  //userID 用户id
  //userToken 用户密钥
  static setChannel(String id, String token) {
    debugPrint('userId${id}token${token}Websocket连接');
    if (_channel == null) {
      userID = id;
      userToken = token;
      _channel = IOWebSocketChannel.connect(
         RouterUtil.webSocketServerUrl + 'chat?userId=$id&token=$token');
      if (_channel != null) {
        _channel.stream.listen(_onData, onError: _onError, onDone: _onDone);
        _isOpen = true;
        reCount = 0;
        received = true;
        detect();
      }
    }
  }

  //检测心跳
  static detect() {
    _timerUtil.setOnTimerTickCallback((int tick) async {
      if (received == true) {
        _channel?.sink?.add("ping");
        received = false;
      } else {
        closeChannel();
      }
    });
    _timerUtil.startTimer();
  }

  //自动检测断线重连
  static reconnect() async {
    bool isLogin = await DataUtils.isLogin();
    if (isLogin) {
      debugPrint('Websocket重新连接');
      closeChannel();
      Future.delayed(Duration(seconds: 10), () {
        if (reCount < 3) {
          if (_channel == null) {
            _channel = IOWebSocketChannel.connect(RouterUtil.webSocketServerUrl +
                'chat?userId=$userID&token=$userToken');
            if (_channel != null) {
              _channel.stream
                  .listen(_onData, onError: _onError, onDone: _onDone);
              _isOpen = true;
              received = true;
              detect();
            }
          }
          reCount++;
//      setChannel(userID,userToken);
        } else {
          debugPrint('Websocket重连失败');
        }
      });
    }
  }

  //聊天主动重连
  static chatReconnect() async {
    bool isLogin = await DataUtils.isLogin();
    if (isLogin) {
      closeChannel();
      if (_channel == null) {
        _channel = IOWebSocketChannel.connect(RouterUtil.webSocketServerUrl +
            'chat?userId=$userID&token=$userToken');
        if (_channel != null) {
          _channel.stream.listen(_onData, onError: _onError, onDone: _onDone);
          _isOpen = true;
          received = true;
          detect();
        }
      }
    }
  }

  //关闭
  static closeChannel() {
    _timerUtil?.cancel();
    _channel?.sink?.close();
    _channel = null;
    _isOpen=false;
  }

  static isOpen() {
    return _isOpen;
  }

  static getChannel() {
    return _channel;
  }

  //关闭
  static _onDone() async {
    debugPrint("Websocket关闭");
    _isOpen = false;
    reconnect();
  }

  //错误
  static _onError(err) {
    debugPrint(err.runtimeType.toString());
    WebSocketChannelException ex = err;
    debugPrint(ex.message);
    _isOpen = false;
    reconnect();
  }

  /*
    接收数据
    type=1是普通消息
    type=2是接收好友发送的访问邀约消息
    type=3是自己发送的访问邀约消息被通过或拒绝的回馈消息
  */
  static _onData(event) async {
    if (event == "pong") {
      received = true;
    } else {
      print(event);
      Map map = jsonDecode(event);
      if (map['code'] != null) {
        if (map['code'] == "200") {
          if (map['type'] == 1) {
            await updateLastMessage();
          }
          if (map['type'] == 2) {
            await updateMessageVisitId(map['id']);
          }
        } else {
          ToastUtil.showShortClearToast(map['desc']);
        }
      } else {
        //播放提示音
        player.play("message.mp3");
        //更新消息数
        if (map['type'] == 1 || map['type'] == 2 || map['type'] == 3) {
          EventBusUtil().eventBus.fire(MessageCountChangeEvent(0));
        }
        ChatMessage msg;
        ChatDao chatDao = new ChatDao();
        if (map['type'] == 1) {
          msg = new ChatMessage(
            M_FriendId: int.parse(map['fromUserId'].toString()),
            M_Status: "0",
            M_IsSend: "1",
            M_MessageContent: map['message'].toString(),
            M_Time: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
            M_MessageType: map['type'].toString(),
            M_userId: int.parse(map['toUserId'].toString()),
            M_FrealName: map['realName'].toString(),
            M_FheadImgUrl: map['headImgUrl'].toString(),
            M_FnickName: map['nickName'].toString(),
            M_orgId: map['orgId'],
            M_isSended: 1,
          );
          chatDao.insertNewMessage(msg);
        } else if (map['type'] == 2) {
          msg = new ChatMessage(
            M_cStatus: map['cstatus'].toString(),
            M_Status: "0",
            M_IsSend: "1",
            M_MessageType: "3",
            M_userId: int.parse(map['toUserId'].toString()),
            M_FriendId: int.parse(map['fromUserId'].toString()),
            M_Time: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
            M_StartDate: map['startDate'].toString(),
            M_visitId: int.parse(map['id'].toString()),
            M_EndDate: map['endDate'].toString(),
            M_FheadImgUrl: map['headImgUrl'] != null
                ? map['idHandleImgUrl'].toString()
                : map['idHandleImgUrl'].toString(),
            M_FnickName: map['nickName'].toString(),
            M_FrealName: map['realName'].toString(),
            M_companyName: map['companyName'].toString(),
            M_recordType: map['recordType'].toString(),
            M_answerContent: map['answerContent'].toString(),
            M_MessageContent: map['recordType'] == "1" ? '访问消息' : '邀约消息',
            M_isSended: 1,
            M_orgId: map['orgId'].toString(),
          );
          chatDao.insertNewMessage(msg);
        } else if (map['type'] == 3) {
          msg = new ChatMessage(
            M_FriendId: int.parse(map['fromUserId'].toString()),
            M_userId: int.parse(map['toUserId'].toString()),
            M_Status: "0",
            M_IsSend: "1",
            M_Time: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
            M_cStatus: map['cstatus'].toString(),
            M_visitId: int.parse(map['id'].toString()),
            M_StartDate: map['startDate'].toString(),
            M_EndDate: map['endDate'].toString(),
            M_companyName: map['companyName'].toString(),
            M_FheadImgUrl: map['headImgUrl'] != null
                ? map['idHandleImgUrl'].toString()
                : map['idHandleImgUrl'].toString(),
            M_FnickName: map['nickName'].toString(),
            M_FrealName: map['realName'].toString(),
            M_MessageType: "2",
            M_recordType: map['recordType'].toString(),
            M_answerContent: map['answerContent'].toString(),
            M_MessageContent: map['recordType'] == "1" ? '访问消息' : '邀约消息',
            M_isSended: 1,
            M_orgId: map['orgId'].toString(),
          );
          chatDao.updateMessage(msg);
//          chatDao.insertNewMessage(msg);
          ChatMessage notice = new ChatMessage(
            M_FriendId: int.parse(map['fromUserId'].toString()),
            M_userId: int.parse(map['toUserId'].toString()),
            M_Status: "0",
            M_IsSend: "1",
            M_Time: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().add(Duration(seconds: 1))),
            M_cStatus: map['cstatus'].toString(),
            M_visitId: int.parse(map['id'].toString()),
            M_StartDate: map['startDate'].toString(),
            M_EndDate: map['endDate'].toString(),
            M_companyName: map['companyName'].toString(),
            M_MessageType: "notice",
            M_recordType: map['recordType'].toString(),
            M_answerContent: map['answerContent'].toString(),
            M_isSended: 1,
            M_MessageContent: "您有一条信息已审核",
          );
          chatDao.insertNewMessage(notice);
        } else if (map['type'] == 4) {
          EventBusUtil().eventBus.fire(FriendCountChangeEvent(map['count']));
        } else {}
        if (msg == null) {
          debugPrint('插入数据库失败');
        }
      }
    }
  }

  //通过FriendID获取本地消息列表
  static getMessageList(int id) async {
    ChatDao chatDao = new ChatDao();
    List<ChatMessage> list = await chatDao.getMessageListByUserId(id);
    return list;
  }

  //插入单条记录
  static insertSingleMessage(ChatMessage chatMsg) {
    ChatDao chatDao = new ChatDao();
    chatDao.insertNewMessage(chatMsg);
  }

  //通过FriendID获取最新一条消息
  static getLatestMessage(int userId) async {
    ChatDao chatDao = new ChatDao();
    List<ChatMessage> list = await chatDao.getLatestMessage(userId);
    return list;
  }
  static removeLastestMessage(int friendID) async {
    ChatDao chatDao=new ChatDao();
    int count = await chatDao.removeLatestMessage(friendID);
    return count;
  }
  //通过FriendID获取未读消息列表
  static getUnreadMessageList(int id) async {
    ChatDao chatDao = new ChatDao();
    List<ChatMessage> list = await chatDao.getUnreadMessageListByUserId(id);
    return list;
  }

  //移除最后一条消息
  static removeLastMessage() async {
    ChatDao chatDao = new ChatDao();
    int count = await chatDao.removeLastMessage();
    return count;
  }

  //通过visitID更新消息状态
  static updateMessageStatus(int id) async {
    ChatDao chatDao = new ChatDao();
    int count = await chatDao.updateMessageStatus(id);
    return count;
  }

  //更新邀约消息
  static updateInviteMessage(ChatMessage msg) async {
    ChatDao chatDao = new ChatDao();
    int count = await chatDao.updateMessageByVisitId(msg);
    return count;
  }

  //更新visitID
  static updateMessageVisitId(int visitID) async {
    ChatDao chatDao = new ChatDao();
    int count1 = await chatDao.updateLastMessageStatus();
    int count2 = await chatDao.updateLastMessageVisitID(visitID);
    return count1 + count2;
  }

  //更新最后一条信息的状态为发送成功
  static updateLastMessage() async {
    ChatDao chatDao = new ChatDao();
    int count = await chatDao.updateLastMessageStatus();
    return count;
  }
}
