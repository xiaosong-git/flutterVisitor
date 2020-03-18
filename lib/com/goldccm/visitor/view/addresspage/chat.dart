import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/AddressInfo.dart';
import 'package:visitor/com/goldccm/visitor/db/ChatMessage.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/MessageUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/visitAddress.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/visitRequest.dart';
import 'package:visitor/com/goldccm/visitor/view/common/LoadingDialog.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
/*
 * 聊天主界面
 * Author:ody997
 * Email:hwk@growingpine.com
 * 2019/10/16
 */
class ChatPage extends StatefulWidget {
  final FriendInfo user;
  ChatPage({Key key, this.user}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ChatPageState();
  }
}
class ChatPageState extends State<ChatPage> {
  List<ChatMessageWidget> _message = <ChatMessageWidget>[];
  List<AddressInfo> _mineAddress=<AddressInfo>[];
  final TextEditingController _textController = new TextEditingController();
  var _messageBuilderFuture;
  bool _isComposing = false;
  UserInfo _userInfo;
  Timer _timer;
  static String visitStartDate = "开始时间";
  static String visitEndDate = "结束时间";
  static DateTime startDate;
  static DateTime endDate;
  static String inviteStartDate = "开始时间";
  static String inviteEndDate = "结束时间";
  static DateTime IstartDate;
  static DateTime IendDate;
  AddressInfo selectedMineAddress;

  countDown() {
    const oneCall = const Duration(milliseconds: 1000);
    var callback = (timer) => {getUnreadMessage()};
    _timer = Timer.periodic(oneCall, callback);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
  //M_MessageType 1 - 普通聊天消息   2 - 访问普通消息  3 - 访问审核消息
  getUnreadMessage() async {
    if (widget.user.userId != null) {
      List<ChatMessage> msgLists = await MessageUtils.getUnreadMessageList(widget.user.userId);
      if (msgLists != null) {
        for (ChatMessage msg in msgLists) {
          if (msg.M_MessageType == "1") {
            ChatMessageWidget message = new ChatMessageWidget(
              text: msg.M_MessageContent,
              type: msg.M_IsSend,
              imageURL: msg.M_IsSend=="0"?_userInfo.headImgUrl!=null?_userInfo.headImgUrl:_userInfo.idHandleImgUrl:widget.user.virtualImageUrl!=null&&widget.user.virtualImageUrl!=""?widget.user.virtualImageUrl:widget.user.realImageUrl,
              message: msg,
            );
            setState(() {
              _message.insert(0, message);
            });
          }
          if (msg.M_MessageType == "2") {
            ChatMessageWidget message = new ChatMessageWidget(
              type:   msg.M_IsSend=="0"?"2":"3",
              status: msg.M_cStatus,
              startDate: msg.M_StartDate,
              endDate: msg.M_EndDate,
              companyName: msg.M_companyName,
              visitor: _userInfo.realName,
              inviter: widget.user.name,
              id: msg.M_visitId,
              imageURL: msg.M_IsSend=="0"?_userInfo.headImgUrl!=null?_userInfo.headImgUrl:_userInfo.idHandleImgUrl:widget.user.virtualImageUrl!=null&&widget.user.virtualImageUrl!=""?widget.user.virtualImageUrl:widget.user.realImageUrl,
              isAccept:msg.M_cStatus=="applyConfirm"?-2:msg.M_cStatus=="applySuccess"?1:-1,
              recordType: msg.M_recordType,
              message: msg,
            );
            setState(() {
              _message.insert(0, message);
            });
          }
          if(msg.M_MessageType == "3"){
            ChatMessageWidget message = new ChatMessageWidget(
              type:  "4",
              status: msg.M_cStatus,
              startDate: msg.M_StartDate,
              endDate: msg.M_EndDate,
              companyName: msg.M_companyName,
              visitor: widget.user.name,
              inviter: _userInfo.realName,
              id: msg.M_visitId,
              sendId: widget.user.userId,
              imageURL: msg.M_IsSend=="0"?_userInfo.headImgUrl!=null?_userInfo.headImgUrl:_userInfo.idHandleImgUrl:widget.user.virtualImageUrl!=null&&widget.user.virtualImageUrl!=""?widget.user.virtualImageUrl:widget.user.realImageUrl,
              isAccept:msg.M_cStatus=="applyConfirm"?0:msg.M_cStatus=="applySuccess"?1:-1,
              recordType: msg.M_recordType,
              message: msg,
            );
            setState(() {
              _message.insert(0, message);
            });
          }
          if(msg.M_MessageType=="notice"){
            ChatMessageWidget message=new ChatMessageWidget(
              type: "notice",
              message: ChatMessage(
                M_MessageContent: msg.M_MessageContent,
              ),
            );
            setState(() {
              _message.insert(0, message);
            });
          }
        }
        int count = await MessageUtils.updateMessageStatus(widget.user.userId);
        if (count > 0) {
          print('已读最新信息$count条');
        }
        setState(() {

        });
      }
    }
  }  getAddressInfo(int visitorId) async {
    String url = "companyUser/findVisitComSuc";
    String threshold = await CommonUtil.calWorkKey();
    List<AddressInfo> _list=<AddressInfo>[];
    var res = await Http().post(url,queryParameters: {
      "token": _userInfo.token,
      "userId": _userInfo.id,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "visitorId":visitorId,
    },userCall: false );
    if(res !=null){
      if(res is String){
        Map map = jsonDecode(res);
        if(map['verify']['sign']=="success"){
          if(map['data']!=null&&map['data'].length>0){
            for(var info in map['data']){
              if(info['status']=="applySuc"&&info['currentStatus']=="normal"){
                AddressInfo addressInfo=new AddressInfo(id: info['id'],companyId: info['companyId'],sectionId: info['sectionId'],userId: info['userId'],postId: info['postId'],userName: info['userName'],createDate: info['createDate'],createTime: info['createTime'],companyName: info['companyName'],currentStatus: info['currentStatus'],sectionName: info['sectionName'],status: info['status'],secucode: info['secucode'],sex: info['sex'],roleType: info['roleType']);
                _list.add(addressInfo);
              }
            }
          }
        }
        else{
          ToastUtil.showShortClearToast(map['verify']['desc']);
        }
      }
    }
    return _list;
  }

  @override
  initState() {
    super.initState();
    countDown();
    init();
    _messageBuilderFuture = getMessage();
  }
  init() async {
    UserInfo user=await LocalStorage.load("userInfo");
    setState(() {
      _userInfo=user;
    });
    _mineAddress=await getAddressInfo(user.id);
  }
  reInit(){
    countDown();
    _messageBuilderFuture = getMessage();
  }
  getMessage() async {
    _message.clear();
    if (widget.user.userId != null) {
      List<ChatMessage> msgLists = await MessageUtils.getMessageList(widget.user.userId);
      if (msgLists != null) {
        for (ChatMessage msg in msgLists) {
          if (msg.M_MessageType == "1") {
            ChatMessageWidget message = new ChatMessageWidget(
              text: msg.M_MessageContent,
              type: msg.M_IsSend,
              imageURL: msg.M_IsSend=="0"?_userInfo.headImgUrl!=null?_userInfo.headImgUrl:_userInfo.idHandleImgUrl:widget.user.virtualImageUrl!=null&&widget.user.virtualImageUrl!=""?widget.user.virtualImageUrl:widget.user.realImageUrl,
            );
            _message.insert(0, message);
          }
          if (msg.M_MessageType == "2") {
            ChatMessageWidget message = new ChatMessageWidget(
              type:   msg.M_IsSend=="0"?"2":"3",
              status: msg.M_cStatus,
              startDate: msg.M_StartDate,
              endDate: msg.M_EndDate,
              companyName: msg.M_companyName,
              visitor: _userInfo.realName,
              inviter: widget.user.name,
              id: msg.M_visitId,
              isAccept:msg.M_cStatus=="applyConfirm"?-2:msg.M_cStatus.trim()=="applySuccess"?1:-1,
              imageURL: msg.M_IsSend=="0"?_userInfo.headImgUrl!=null?_userInfo.headImgUrl:_userInfo.idHandleImgUrl:widget.user.virtualImageUrl!=null&&widget.user.virtualImageUrl!=""?widget.user.virtualImageUrl:widget.user.realImageUrl,
              recordType: msg.M_recordType,
              message: msg,
            );
            _message.insert(0, message);
          }
          if(msg.M_MessageType == "3"){
            ChatMessageWidget message = new ChatMessageWidget(
              type:  "4",
              status: msg.M_cStatus,
              startDate: msg.M_StartDate,
              endDate: msg.M_EndDate,
              companyName: widget.user.companyName,
              visitor: widget.user.name,
              inviter:  _userInfo.realName,
              id: msg.M_visitId,
              sendId: widget.user.userId,
              isAccept:msg.M_cStatus=="applyConfirm"?0:msg.M_cStatus=="applySuccess"?1:-1,
              imageURL: msg.M_IsSend=="0"?_userInfo.headImgUrl!=null?_userInfo.headImgUrl:_userInfo.idHandleImgUrl:widget.user.virtualImageUrl!=null&&widget.user.virtualImageUrl!=""?widget.user.virtualImageUrl:widget.user.realImageUrl,
              recordType:msg.M_recordType,
              message: msg,
            );
            _message.insert(0, message);
          }
          if(msg.M_MessageType=="notice"){
            ChatMessageWidget message=new ChatMessageWidget(
              type: "notice",
              message: ChatMessage(
                M_MessageContent: msg.M_MessageContent,
              ),
            );
            _message.insert(0, message);
          }
        }

        int count = await MessageUtils.updateMessageStatus(widget.user.userId);
        if (count > 0) {
          print('已读全部信息$count条');
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text('${widget.user.name}',style:TextStyle(fontSize: 17.0),),
          backgroundColor: Theme.of(context).appBarTheme.color,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
            FocusScope.of(context).requestFocus(FocusNode());
            Navigator.pop(context);
          }),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(5),
                  child: new SizedBox(
                    height: 40.0,
                    child: new RaisedButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      child: new Text('邀约',textScaleFactor: 1.0),
                      onPressed: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                              title: Text('邀约时间',textScaleFactor: 1.0),
                              content: StatefulBuilder(
                                  builder: (context, StateSetter setState) {
                                    return Container(
                                        height: 150,
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.date_range),
                                                Container(
                                                    width: 200,
                                                    padding: EdgeInsets.only(
                                                        left: 10),
                                                    child: OutlineButton(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey),
                                                      onPressed: () {
                                                        DatePicker
                                                            .showDateTimePicker(context, showTitleActions: true, onConfirm: (date) {
                                                          if (IendDate == null ||date.compareTo(IendDate) == -1) {
                                                            setState(() {
                                                              IstartDate = date;
                                                              inviteStartDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
                                                            });
                                                          }else{
                                                            setState(() {
                                                              IstartDate = date;
                                                              inviteStartDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
                                                              IendDate = null;
                                                              inviteEndDate ="";
                                                            });
                                                          }
                                                        },currentTime: DateTime.now(), locale: LocaleType.zh);
                                                      },
                                                      child: Text(
                                                        inviteStartDate,
                                                        style: TextStyle(color: Colors.blue),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.date_range),
                                                Container(
                                                    width: 200,
                                                    padding: EdgeInsets.only(left: 10),
                                                    child: OutlineButton(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey),
                                                      onPressed: () {
                                                        DatePicker.showDateTimePicker(context, showTitleActions: true, onConfirm: (date) {
                                                          if (IstartDate == null ||date.compareTo(IstartDate) == 1) {
                                                            setState(() {
                                                              IendDate = date;
                                                              inviteEndDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
                                                            });
                                                          }else{
                                                            ToastUtil.showShortClearToast("时间选择错误");
                                                          }
                                                        }, currentTime: DateTime.now(), locale: LocaleType.zh);
                                                      },
                                                      child: Text(inviteEndDate, style: TextStyle(color: Colors.blue),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.home),
                                                Container(
                                                    width: 200,
                                                    padding: EdgeInsets.only(left: 10),
                                                    child: OutlineButton(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey),
                                                      onPressed: () {
                                                        Navigator.push(context,CupertinoPageRoute(builder: (context)=>VisitAddress(lists: _mineAddress,))).then((value){
                                                          selectedMineAddress=_mineAddress[value];
                                                        });
                                                      },
                                                      child: Text(selectedMineAddress!=null?selectedMineAddress.companyName!=null?selectedMineAddress.companyName:"":'选择邀约地址',style: TextStyle(color: Colors.blue),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ));
                                  }),
                              actions: <Widget>[
                                new FlatButton(
                                  child: new Text("取消",
                                      style: TextStyle(color: Colors.red),textScaleFactor: 1.0),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                new FlatButton(
                                  child: new Text("确定",
                                      style: TextStyle(color: Colors.blue),textScaleFactor: 1.0),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    if(selectedMineAddress==null){
                                      ToastUtil.showShortClearToast("地址不能为空");
                                    }
                                    else if(IstartDate==null){
                                      ToastUtil.showShortClearToast("开始日期不能为空");
                                    }
                                    else if(IendDate==null){
                                      ToastUtil.showShortClearToast("截止日期不能为空");
                                    }
                                    else{
                                      ChatMessage chatMessage = new ChatMessage(
                                        M_cStatus: "applyConfirm",
                                        M_Time: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                                        M_userId: _userInfo.id,
                                        M_FriendId: widget.user.userId,
                                        M_StartDate: inviteStartDate,
                                        M_EndDate: inviteEndDate,
                                        M_Status: "0",
                                        M_IsSend: "0",
                                        M_companyName: widget.user.companyName,
                                        M_MessageType: "2",
                                        M_recordType: "2",
                                        M_isSended: 0,
                                        M_MessageContent: '邀约信息',
                                        M_FrealName: widget.user.name,
                                        M_FnickName: widget.user.nickname,
                                        M_FheadImgUrl: widget.user.virtualImageUrl,
                                        M_orgId: widget.user.orgId,
                                      );
                                      commitVisit(chatMessage,selectedMineAddress);
                                    }
                                  },
                                ),
                              ],
                            ));
                      },
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  child: new SizedBox(
                    height: 40.0,
                    child: new RaisedButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      child: new Text('访问',textScaleFactor: 1.0),
                      onPressed: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                              title: Text('访问时间',textScaleFactor: 1.0),
                              content: StatefulBuilder(
                                  builder: (context, StateSetter setState) {
                                    return Container(
                                        height: 150,
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.date_range),
                                                Container(
                                                    width: 200,
                                                    padding: EdgeInsets.only(
                                                        left: 10),
                                                    child: OutlineButton(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey),
                                                      onPressed: () {
                                                        DatePicker
                                                            .showDateTimePicker(context, showTitleActions: true, onConfirm: (date) {
                                                          if (endDate == null ||date.compareTo(endDate) == -1) {
                                                            setState(() {
                                                              startDate = date;
                                                              visitStartDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
                                                            });
                                                          }else{
                                                            setState(() {
                                                              startDate = date;
                                                              visitStartDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
                                                              endDate = null;
                                                              visitEndDate ="";
                                                            });
                                                          }
                                                        },currentTime: DateTime.now(), locale: LocaleType.zh);
                                                      },
                                                      child: Text(
                                                        visitStartDate,
                                                        style: TextStyle(color: Colors.blue),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.date_range),
                                                Container(
                                                    width: 200,
                                                    padding: EdgeInsets.only(left: 10),
                                                    child: OutlineButton(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey),
                                                      onPressed: () {
                                                        DatePicker.showDateTimePicker(context, showTitleActions: true, onConfirm: (date) {
                                                          if (startDate == null ||date.compareTo(startDate) == 1) {
                                                            setState(() {
                                                              endDate = date;
                                                              visitEndDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
                                                            });
                                                          }else{
                                                            ToastUtil.showShortClearToast("时间选择错误");
                                                          }
                                                        }, currentTime: DateTime.now(), locale: LocaleType.zh);
                                                      },
                                                      child: Text(visitEndDate, style: TextStyle(color: Colors.blue),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ));
                                  }),
                              actions: <Widget>[
                                new FlatButton(
                                  child: new Text("取消",
                                      style: TextStyle(color: Colors.red),textScaleFactor: 1.0),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                new FlatButton(
                                  child: new Text("确定",
                                      style: TextStyle(color: Colors.blue),textScaleFactor: 1.0),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    if(startDate==null){
                                      ToastUtil.showShortClearToast("开始日期不能为空");
                                    }
                                    else if(endDate==null){
                                      ToastUtil.showShortClearToast("截止日期不能为空");
                                    }
                                    else{
                                      ChatMessage chatMessage = new ChatMessage(
                                        M_cStatus: "applyConfirm",
                                        M_Time: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                                        M_userId: _userInfo.id,
                                        M_FriendId: widget.user.userId,
                                        M_StartDate: visitStartDate,
                                        M_EndDate: visitEndDate,
                                        M_Status: "0",
                                        M_IsSend: "0",
                                        M_companyName: widget.user.companyName,
                                        M_MessageType: "2",
                                        M_recordType:  "1",
                                        M_isSended: 0,
                                        M_MessageContent: '访问信息',
                                        M_FrealName: widget.user.name,
                                        M_FnickName: widget.user.nickname,
                                        M_FheadImgUrl: widget.user.virtualImageUrl,
                                        M_orgId: widget.user.orgId,
                                      );
                                      commitVisit(chatMessage,null);
                                    }
                                  },
                                ),
                              ],
                            ));
                      },
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  child: new SizedBox(
                    height: 40.0,
                    child: new RaisedButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      child: new Text('催审',textScaleFactor: 1.0),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  FutureBuilder(
                    builder: _messageFuture,
                    future: _messageBuilderFuture,
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  Container(
                    decoration:
                    BoxDecoration(color: Theme.of(context).cardColor),
                    child: _buildTextComposer(),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _messageFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('无连接',textScaleFactor: 1.0);
        break;
      case ConnectionState.waiting:
        return Text('加载中',textScaleFactor: 1.0);
        break;
      case ConnectionState.active:
        return Text('active',textScaleFactor: 1.0);
        break;
      case ConnectionState.done:
        if (snapshot.hasError) return Text('Error',textScaleFactor: 1.0);
        return _buildMessageList();
        break;
      default:
        return null;
    }
  }

  Widget _buildMessageList() {
    return Flexible(
      child: ListView.builder(
        itemBuilder: (_, int index) => _message[index],
        padding: EdgeInsets.all(8),
        reverse: true,
        itemCount: _message.length,
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _textController,
//              onSubmitted: _handleSubmmited,
              decoration: InputDecoration.collapsed(),
              onChanged: (String text) {
                setState(() {
                  _isComposing = text.length > 0;
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: _isComposing
                  ? () => _handleSubmmited(_textController.text)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
  /*
   * 断线重连
   */
  reconnect() async {
    LoadingDialog().show(context, '重新连接中');
    await MessageUtils.chatReconnect();
    Future.delayed(Duration(seconds: 5)).then((value){
      if(MessageUtils.isOpen()){
        Navigator.pop(context);
        ToastUtil.showShortClearToast("重连成功");
      }else{
        Navigator.pop(context);
        ToastUtil.showShortClearToast("与聊天服务器断开了连接");
        Navigator.pop(context);
      }
    });
  }
  /*
    * 发送访问消息
    */
  commitVisit(ChatMessage message,AddressInfo addr) async {
    WebSocketChannel channel=MessageUtils.getChannel();
    //检测webSocket服务器连接
    if(MessageUtils.isOpen()){
      var object = {
        "toUserId": message.M_FriendId,
        "startDate": message.M_StartDate,
        "endDate": message.M_EndDate,
        "cstatus": message.M_cStatus,
        "recordType": message.M_recordType,
        "type": int.parse(message.M_MessageType),
      };
      if(addr!=null){
       object = {
         "toUserId": message.M_FriendId,
         "startDate": message.M_StartDate,
         "endDate": message.M_EndDate,
         "cstatus": message.M_cStatus,
         "recordType": message.M_recordType,
         "type": int.parse(message.M_MessageType),
         "companyId":addr.companyId,
       };
      }
      //发送到服务器
      var send = jsonEncode(object);
     channel.sink.add(send);
      //保存到本地数据库
      MessageUtils.insertSingleMessage(message);
    }else{
      reconnect();
    }
  }
  /*
    * 发送普通聊天消息
    */
  Future _handleSubmmited(String text) async {
    WebSocketChannel channel=MessageUtils.getChannel();
    _textController.clear();
    if (MessageUtils.isOpen()) {
      //向WebSocket服务器发送json消息体
      var object = {
        "toUserId": widget.user.userId,
        "message": text,
        "type": 1,
      };
      var send = jsonEncode(object);
      channel.sink.add(send);
      //将这条消息保存至本地数据库
      String time = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      ChatMessage chat = new ChatMessage(
        M_userId: _userInfo.id,
        M_Status: "0",
        M_Time: time,
        M_IsSend: "0",
        M_MessageType: "1",
        M_FriendId: widget.user.userId,
        M_MessageContent: text,
        M_FrealName: widget.user.name,
        M_FheadImgUrl: widget.user.virtualImageUrl,
        M_orgId: widget.user.orgId.toString(),
        M_isSended: 0,
      );
      MessageUtils.insertSingleMessage(chat);
      //插入到当前页面消息中
      setState(() {
        _isComposing = false;
      });
    } else {
      reconnect();
    }
  }
}


class ChatMessageState extends State<ChatMessageWidget>{
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return _switchMessage(context);
  }
  _switchMessage(context) {
    if (widget.type != null) {
      if (widget.type == "0") {
        return new Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerRight,
                    width: 250,
                    child: Container(
                      child: Text(widget.text,
                          softWrap: true,
                          style: TextStyle(fontSize: 17, color: Colors.white)),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.all(10),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 16.0),
                child: CircleAvatar(
                  backgroundImage:widget.imageURL!=null?NetworkImage(RouterUtil.imageServerUrl+widget.imageURL):AssetImage("assets/images/visitor_icon_head.png"),
                ),
              ),
            ],
          ),
        );
      } else if (widget.type == "1") {
        return new Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  backgroundImage:widget.imageURL!=null?NetworkImage(RouterUtil.imageServerUrl+widget.imageURL):AssetImage("assets/images/visitor_icon_head.png"),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    width: 250,
                    child: Container(
                      child: Text(widget.text,
                          softWrap: true,
                          style: TextStyle(fontSize: 17, color: Colors.white),textScaleFactor: 1.0),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.all(10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      } else if (widget.type == "2") {
        return new Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      alignment: Alignment.centerRight,
                      width: 250,
                      child: GestureDetector(
                        child: Container(
                          child: Center(
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Text(widget.message.M_recordType=="1"?'访问':'邀约',style: TextStyle(fontSize: 20),textScaleFactor: 1.0),
                                  ListTile(
                                    title: Text('开始时间',style: TextStyle(fontSize: 14),textScaleFactor: 1.0),
                                    subtitle: Text(widget.startDate,style: TextStyle(fontSize: 18),textScaleFactor: 1.0),
                                  ),
                                  ListTile(
                                    title: Text('结束时间',style: TextStyle(fontSize: 14),textScaleFactor: 1.0),
                                    subtitle: Text(widget.endDate,style: TextStyle(fontSize: 18),textScaleFactor: 1.0),
                                  ),
                                  Text('点击查看详情',style: TextStyle(color: Colors.grey,fontSize: 12),textScaleFactor: 1.0),
                                ],
                              ),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        onTap: (){
                          Navigator.push(context, CupertinoPageRoute(builder: (context)=>VisitRequest(id:widget.id,chatMessage: widget.message,userInfo: widget.userInfo,mineAddress: widget.mineAddress,)));
                        },
                      )
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 16.0),
                child: CircleAvatar(
                  backgroundImage:widget.imageURL!=null?NetworkImage(RouterUtil.imageServerUrl+widget.imageURL):AssetImage("assets/images/visitor_icon_head.png"),
                ),
              ),
            ],
          ),
        );
      }
      else if (widget.type == "3") {
        return new Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  backgroundImage:widget.imageURL!=null?NetworkImage(RouterUtil.imageServerUrl+widget.imageURL):AssetImage("assets/images/visitor_icon_head.png"),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      alignment: Alignment.centerLeft,
                      width: 250,
                      child: GestureDetector(
                        child: Container(
                          child: Center(
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Text(widget.message.M_recordType=="1"?'访问':'邀约',style: TextStyle(fontSize: 20),textScaleFactor: 1.0),
                                  ListTile(
                                    title: Text('开始时间',style: TextStyle(fontSize: 14),textScaleFactor: 1.0),
                                    subtitle: Text(widget.startDate,style: TextStyle(fontSize: 18),textScaleFactor: 1.0),
                                  ),
                                  ListTile(
                                    title: Text('结束时间',style: TextStyle(fontSize: 14),textScaleFactor: 1.0),
                                    subtitle: Text(widget.endDate,style: TextStyle(fontSize: 18),textScaleFactor: 1.0),
                                  ),
                                  Text('点击查看详情',style: TextStyle(color: Colors.grey,fontSize: 12),textScaleFactor: 1.0),
                                ],
                              ),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        onTap: (){
                          Navigator.push(context, CupertinoPageRoute(builder: (context)=>VisitRequest(id:widget.id,chatMessage: widget.message,userInfo: widget.userInfo,mineAddress: widget.mineAddress,)));
                        },
                      )
                  ),
                ],
              ),
            ],
          ),
        );
      }
      else if(widget.type=="4") {
        return new Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  backgroundImage: widget.imageURL != null ? NetworkImage(
                      RouterUtil.imageServerUrl + widget.imageURL) : AssetImage(
                      "assets/images/visitor_icon_head.png"),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      alignment: Alignment.centerLeft,
                      width: 250,
                      child: GestureDetector(
                        child: Container(
                          child: Center(
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Text(widget.message.M_recordType=="1"?'访问':'邀约',style: TextStyle(fontSize: 20),textScaleFactor: 1.0),
                                  ListTile(
                                    title: Text('开始时间',style: TextStyle(fontSize: 14),textScaleFactor: 1.0),
                                    subtitle: Text(widget.startDate,style: TextStyle(fontSize: 18),textScaleFactor: 1.0),
                                  ),
                                  ListTile(
                                    title: Text('结束时间',style: TextStyle(fontSize: 14),textScaleFactor: 1.0),
                                    subtitle: Text(widget.endDate,style: TextStyle(fontSize: 18),textScaleFactor: 1.0),
                                  ),
                                  Text('点击查看详情',style: TextStyle(color: Colors.grey,fontSize: 12),textScaleFactor: 1.0,),
                                ],
                              ),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(context, CupertinoPageRoute(
                              builder: (context) =>
                                  VisitRequest(id:widget.id,chatMessage: widget.message,userInfo: widget.userInfo,mineAddress:widget.mineAddress,)));
                        },
                      )
                  ),
                ],
              ),
            ],
          ),
        );
      }
      else if(widget.type=="notice"){
        return Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(widget.message.M_MessageContent!=null?widget.message.M_MessageContent:"",style: TextStyle(fontSize: 16,color: Colors.grey),textScaleFactor: 1.0),
          ),
        );
      }
    }
  }
}

class ChatMessageWidget extends StatefulWidget {
  final String text;
  final String type;
  final String companyName;
  final String visitor;
  final String inviter;
  final String status;
  final String startDate;
  final String endDate;
  final int sendId;
  final String imageURL;
  final int id;
  final int isAccept;
  final String recordType;
  final ChatMessage message;
  final List<AddressInfo> mineAddress;
  final UserInfo userInfo;
  @override
  State<StatefulWidget> createState() {
    return ChatMessageState();
  }
  ChatMessageWidget({this.message,this.mineAddress,this.userInfo,this.text, this.type, this.visitor, this.inviter, this.companyName, this.startDate, this.endDate, this.status, this.id, this.sendId, this.isAccept,this.recordType,this.imageURL});
}
