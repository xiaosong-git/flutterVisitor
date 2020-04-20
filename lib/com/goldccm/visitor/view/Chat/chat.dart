import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/AddressInfo.dart';
import 'package:visitor/com/goldccm/visitor/db/ChatMessage.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/MessageUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/RegExpUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/Add/Visit/fastvisitreq.dart';
import 'package:visitor/com/goldccm/visitor/view/Chat/visitRequest.dart';
import 'package:visitor/com/goldccm/visitor/view/common/LoadingDialog.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'Message/MsgSetting.dart';
/*
 * 聊天主界面
 * Email:hwk@growingpine.com
 * 2019/10/16
 */
class ChatPage extends StatefulWidget {
  final FriendInfo user;
  final int method;
  ChatPage({Key key, this.user,this.method}) : super(key: key);
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
  var dialog;
  UserInfo _userInfo;
  Timer _timer;
  int selectIndex=0;
  TextEditingController _inviteStartControl;
  TextEditingController _inviteAddrControl;
  TextEditingController _inviteEndControl;
  TextEditingController _visitStartControl;
  TextEditingController _visitEndControl;
  TextEditingController _visitReasonControl;
  TextEditingController _visitReasonDetailControl;
  int reasonType=1;
  String startDateText;
  DateTime startDate;
  String endDateText;
  DateTime endDate;
  AddressInfo selectedMineAddress;
  String reasonText="";
  bool addReason=false;

  countDown() {
    const oneCall = const Duration(milliseconds: 1000);
    var callback = (timer) => {getUnreadMessage()};
    _timer = Timer.periodic(oneCall, callback);
  }
  @override
  initState() {
    super.initState();
    countDown();
    init();
    _inviteStartControl = TextEditingController();
    _inviteEndControl = TextEditingController();
    _inviteAddrControl = TextEditingController();
    _visitStartControl = TextEditingController();
    _visitEndControl = TextEditingController();
    _visitReasonControl = TextEditingController();
    _visitReasonDetailControl = TextEditingController();
    _messageBuilderFuture = getMessage();
  }
  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _inviteAddrControl.dispose();
    _inviteEndControl.dispose();
    _inviteStartControl.dispose();
    _visitStartControl.dispose();
    _visitEndControl.dispose();
    _visitReasonControl.dispose();
    _visitReasonDetailControl.dispose();
    super.dispose();
  }
  switchMethod(){
    switch(widget.method){
      case 0:
        tapInvite();
        break;
      case 1:
        tapVisit();
        break;
    }
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
        backgroundColor: Color(0xFFFCFCFC),
        appBar: AppBar(
          title: Text('${widget.user.name}',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF373737)),),
          centerTitle: true,
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 1,
          brightness: Brightness.light,
          automaticallyImplyLeading: false,
          leading: IconButton(
              icon: Image(
                image: AssetImage("assets/images/login_back.png"),
                width: ScreenUtil().setWidth(36),
                height: ScreenUtil().setHeight(36),
                color: Color(0xFF373737),),
              onPressed: () {
                setState(() {
                  FocusScope.of(context).requestFocus(FocusNode());
                  Navigator.pop(context);
                });
              }),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.more_horiz,color: Color(0xFF373737),),
              onPressed: (){
                Navigator.push(context,CupertinoPageRoute(builder: (context)=>MsgSettingPage(user: widget.user,)));
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            topToolBar(),
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
  Widget topToolBar(){
    return Container(
      color: Color(0xFFFEFEFE),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          toolBarItem(text:'访问',method: tapVisit,iconUrl: 'assets/images/message_chat_visit.png'),
          toolBarItem(text:'邀约',method: tapInvite,iconUrl: 'assets/images/message_chat_invite.png'),
          toolBarItem(text:'催审',iconUrl: 'assets/images/message_chat_remind.png'),
          toolBarItem(text:'打电话',iconUrl: 'assets/images/message_chat_call.png',method: makingPhoneCall),
        ],
      ),
    );
  }
  Widget toolBarItem({String text,Function method,String iconUrl}){
    return Container(
      padding: EdgeInsets.all(10),
      child: InkWell(
        child: Column(
          children: <Widget>[
            Image(
              image: AssetImage(iconUrl??""),
            ),
            Text(text??""),
          ],
        ),
        onTap: method,
      )
    );
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
//           IconButton(
//             iconSize: ScreenUtil().setWidth(60),
//              icon: Image.asset("assets/images/message_chat_bottom_voice.png"),
//            ),
//          Flexible(
//            child: TextField(
//              controller: _textController,
////              onSubmitted: _handleSubmmited,
//              keyboardType: TextInputType.multiline,
//              decoration: InputDecoration.collapsed(),
//              onChanged: (String text) {
//                setState(() {
//                  _isComposing = text.length > 0;
//                });
//              },
//            ),
//          ),
          Expanded(
            child: TextField(
              controller: _textController,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              minLines: 1,
              decoration: const InputDecoration(
                hintText: '输入',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                isDense: true,
                border: InputBorder.none,
              ),
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
            ),
          ),
//         IconButton(
//           iconSize: ScreenUtil().setWidth(60),
//              icon: Image.asset("assets/images/message_chat_bottom_image.png"),
//         ),
          _isComposing?FlatButton(
            padding: EdgeInsets.all(0),
            child: Text('发送',style: TextStyle(color: Color(0xFFFFFFFF)),),
            color: Colors.blue,
            onPressed: _isComposing
                ? () => _handleSubmmited(_textController.text)
                : null,
          ):IconButton(
              iconSize: ScreenUtil().setWidth(60),
              icon: Image.asset("assets/images/message_chat_bottom_more.png"),
          ),
        ],
      ),
    );
  }
  makingPhoneCall() async {
    if(!RegExpUtil().verifyPhone(widget.user.phone)){
      ToastUtil.showShortClearToast("无法拨打该电话");
      return;
    }
    if (await canLaunch("tel:${widget.user.phone}")) {
      await launch("tel:${widget.user.phone}");
    } else {
      ToastUtil.showShortClearToast("无法拨打该电话");
      throw 'Could not launch ${widget.user.phone}';
    }
  }
  tapInvite(){
    YYDialog().build(context)
      ..width = ScreenUtil().setWidth(536)
      ..height = ScreenUtil().setHeight(644)
      ..borderRadius = 4.0
      ..text(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
        alignment: Alignment.center,
        text: "邀约",
        color: Colors.black,
        fontSize: ScreenUtil().setSp(30),
        fontWeight: FontWeight.w500,
      )
      ..divider()
      ..widget(
        Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
              height: ScreenUtil().setHeight(450),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                            flex: 1,
                            child:  Container(
                              child:Text('开始时间',style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF787878)),),
                            )
                        ),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _inviteStartControl,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '请选择开始时间',
                              hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                              suffixIcon: Image(
                                image: AssetImage('assets/images/mine_next.png'),
                              ),
                            ),
                            style: TextStyle(fontSize: ScreenUtil().setSp(28)),
                            readOnly: true,
                            onTap: (){
                              DatePicker.showDateTimePicker(context, showTitleActions: true,minTime: DateTime.now(),maxTime: DateTime.now().add(Duration(days: 14)), onConfirm: (date) {
                                DateTime currentDate=DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day);
                                if (date.compareTo(currentDate)>=0) {
                                  setState(() {
                                    startDate = date;
                                    startDateText = DateFormat('yyyy-MM-dd HH:mm').format(date);
                                    _inviteStartControl.text=startDateText;
                                  });
                                }else{
                                  ToastUtil.showShortClearToast("时间选择错误");
                                }
                              }, currentTime: DateTime.now(), locale: LocaleType.zh,

                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: ScreenUtil().setWidth(160)),
                      child: Divider(height: 1,),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                            flex:1,
                            child:  Container(
                              child:Text('时长(小时)',style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF787878)),),
                            )
                        ),
                        Expanded(
                          flex:2,
                          child: TextField(
                            controller: _inviteEndControl,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '请选择时长',
                              hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                              suffixIcon: Image(
                                image: AssetImage('assets/images/mine_next.png'),
                              ),
                            ),
                            readOnly: true,
                            style: TextStyle(fontSize: ScreenUtil().setSp(28)),
                            onTap: (){
                              if(startDate==null){
                                ToastUtil.showShortClearToast("开始时间未选择");
                              }else{
                                DatePicker.showPicker(context,pickerModel:CustomPicker(currentTime: startDate),locale: LocaleType.zh,onConfirm: (date){
                                  setState(() {
                                    endDate=date;
                                    endDateText=(date.hour-startDate.hour).toString()+".0";
                                    _inviteEndControl.text=endDateText;
                                  });
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: ScreenUtil().setWidth(160)),
                      child: Divider(height: 1,),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                            flex:1,
                            child:  Container(
                              child:Text('来访地址',style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color(0xFF787878)),),
                            )
                        ),
                        Expanded(
                          flex:2,
                          child:TextField(
                            controller: _inviteAddrControl,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '请选择来访地址',
                                hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                                suffixIcon: Image(
                                  image: AssetImage('assets/images/mine_next.png'),
                                ),

                              ),
                            maxLines: 3,
                            minLines: 1,
                            style: TextStyle(fontSize: ScreenUtil().setSp(28)),
                              readOnly: true,
                              onTap: (){
                                if(_mineAddress.length>0){
                                callAddress();
                                }else{
                                  ToastUtil.showShortClearToast("您没有所属公司");
                                }
                              },
                            ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: ScreenUtil().setWidth(160)),
                      child: Divider(height: 1,),
                    ),
              ],
                ),
            ),
          ],
        )
      )
      ..divider()
      ..doubleButton(
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
        gravity: Gravity.center,
        withDivider: true,
        text1: "取消",
        color1: Colors.black,
        fontSize1: ScreenUtil().setSp(28),
        onTap1: () {

        },
        text2: "确定",
        color2: Colors.black,
        fontSize2: ScreenUtil().setSp(28),
        onTap2: () {
          fastinvite();
        },
      )
      ..show();
  }
  Future<bool> fastinvite() async {
    if(_inviteStartControl.text.toString()==""||_inviteStartControl.text.toString()==""){
      ToastUtil.showShortToast('开始时间不正确');
      return false;
    }
    if(_inviteEndControl.text.toString()==""||_inviteEndControl.text.toString()==""){
      ToastUtil.showShortToast('时长不正确');
      return false;
    }
    if(selectedMineAddress.companyId==null||_inviteAddrControl.text.toString()==""){
      ToastUtil.showShortToast('地址不正确');
      return false;
    }
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String httpUrl="visitorRecord/inviteStranger";
    String threshold=await CommonUtil.calWorkKey(userInfo: userInfo);
    String end=  DateFormat('yyyy-MM-dd HH:mm').format(endDate);
    var parameters={
      "userId": userInfo.id,
      "token": userInfo.token,
      "factor":CommonUtil.getCurrentTime(),
      "threshold":threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "visitorId":widget.user.userId,
      "startDate":_inviteStartControl.text.toString(),
      "endDate":end,
      "companyId":selectedMineAddress.companyId,
    };
    var response=await Http().post(httpUrl,queryParameters: parameters,userCall: true);
    if(response!=null&&response!=""){
      if(response is String){
        Map responseMap = jsonDecode(response);
        if(responseMap['verify']['sign']=="success"){
          ToastUtil.showShortToast('邀约成功，可在个人中心查看');
          Navigator.pop(context);
        }else{
          ToastUtil.showShortToast(responseMap['verify']['desc']);
        }
      }
    }
  }
  callAddress(){
    return dialog=YYDialog().build(context)
      ..gravity = Gravity.bottom
      ..gravityAnimationEnable = true
      ..backgroundColor = Colors.transparent
      ..widget(Container(
        width: 350,
        height: double.parse((45*_mineAddress.length+1*_mineAddress.length-1).toString()),
        margin: EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
        ),
        child: Column(
          children: <Widget>[
            ListView.separated(itemBuilder: (context,index){
              return InkWell(
                child: Container(
                  width: 300,
                  height: 45,
                  child: Center(
                    child: Text(_mineAddress[index].companyName,style: TextStyle(fontSize: ScreenUtil().setSp(32),color:selectIndex==index?Colors.blue:Colors.black),textScaleFactor: 1.0,),
                  ),
                ),
                onTap: (){
                  setState(() {
                    selectIndex=index;
                    _inviteAddrControl.text=_mineAddress[index].companyName;
                    dialog.dismiss();
                    selectedMineAddress=_mineAddress[index];
                  });
                },
              );
            },  separatorBuilder: (context,index){
              return Container(
                child: Divider(
                  height: 1,
                ),
              );
            }, itemCount: _mineAddress.length,shrinkWrap: true,padding: EdgeInsets.all(0),)
          ],
        ),
      ))
      ..widget(InkWell(
        child: Container(
          width: 350,
          height: 45,
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              "取消",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),onTap: (){
        dialog.dismiss();
      },
      ))
      ..show();
  }
  tapVisit(){
    YYDialog().build(context)
      ..width = ScreenUtil().setWidth(536)
      ..height = ScreenUtil().setHeight(644)
      ..borderRadius = 4.0
      ..text(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
        alignment: Alignment.center,
        text: "访问",
        color: Colors.black,
        fontSize: ScreenUtil().setSp(30),
        fontWeight: FontWeight.w500,
      )
      ..divider()
      ..widget(
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                height:ScreenUtil().setHeight(450),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                            flex: 1,
                            child:  Container(
                              child:Text('开始时间',style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF787878)),),
                            )
                        ),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _visitStartControl,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '请选择开始时间',
                              hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                              suffixIcon: Image(
                                image: AssetImage('assets/images/mine_next.png'),
                              ),
                            ),
                            readOnly: true,
                            style: TextStyle(fontSize: ScreenUtil().setSp(28)),
                            onTap: (){
                              DatePicker.showDateTimePicker(context, showTitleActions: true,minTime: DateTime.now(),maxTime: DateTime.now().add(Duration(days: 14)), onConfirm: (date) {
                                DateTime currentDate=DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day);
                                if (date.compareTo(currentDate)>=0) {
                                  setState(() {
                                    startDate = date;
                                    startDateText = DateFormat('yyyy-MM-dd HH:mm').format(date);
                                    _visitStartControl.text=startDateText;
                                  });
                                }else{
                                  ToastUtil.showShortClearToast("时间选择错误");
                                }
                              }, currentTime: DateTime.now(), locale: LocaleType.zh,

                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: ScreenUtil().setWidth(160)),
                      child: Divider(height: 1,),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                            flex:1,
                            child:  Container(
                              child:Text('时长(小时)',style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF787878)),),
                            )
                        ),
                        Expanded(
                          flex:2,
                          child: TextField(
                            controller: _visitEndControl,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '请选择时长',
                              hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                              suffixIcon: Image(
                                image: AssetImage('assets/images/mine_next.png'),
                              ),
                            ),
                            readOnly: true,
                            style: TextStyle(fontSize: ScreenUtil().setSp(28)),
                            onTap: (){
                              if(startDate==null){
                                ToastUtil.showShortClearToast("开始时间未选择");
                              }else{
                                DatePicker.showPicker(context,pickerModel:CustomPicker(currentTime: startDate),locale: LocaleType.zh,onConfirm: (date){
                                  setState(() {
                                    endDate=date;
                                    endDateText=(date.hour-startDate.hour).toString()+".0";
                                    _visitEndControl.text=endDateText;
                                  });
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: ScreenUtil().setWidth(160)),
                      child: Divider(height: 1,),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                            flex:1,
                            child:  Container(
                              child:Text('来访目的',style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF787878)),),
                            )
                        ),
                        Expanded(
                          flex:2,
                          child: TextField(
                            controller: _visitReasonControl,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '请选择来访目的',
                              hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                              suffixIcon: Image(
                                image: AssetImage('assets/images/mine_next.png'),
                              ),
                            ),
                            readOnly: true,
                            style: TextStyle(fontSize: ScreenUtil().setSp(28)),
                            onTap: (){
                                callReason(reasonType);
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: ScreenUtil().setWidth(160)),
                      child: Divider(height: 1,),
                    ),
                    reasonType==5?Container(
                      color: Colors.white,
                      height: ScreenUtil().setHeight(250),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                              flex:1,
                              child:  Container(
                                padding: EdgeInsets.only(left: ScreenUtil().setWidth(88)),
                              )
                          ),
                          Expanded(
                            flex:2,
                            child: TextField(
                              controller: _visitReasonDetailControl,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '请输入来访目的',
                                hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                              ),
                              maxLength: 80,
                              maxLines: 4,
                            ),
                          ),
                        ],
                      ),
                    ):Container(),
                  ],
                ),
              ),
            ],
          )
      )
      ..divider()
      ..doubleButton(
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
        gravity: Gravity.center,
        withDivider: true,
        text1: "取消",
        color1: Colors.black,
        fontSize1: ScreenUtil().setSp(28),
        onTap1: () {

        },
        text2: "确定",
        color2: Colors.black,
        fontSize2: ScreenUtil().setSp(28),
        onTap2: () {
          fastVisit();
        },
      )
      ..show();
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
  callReason(int type){
    return dialog=YYDialog().build(context)
      ..gravity = Gravity.bottom
      ..gravityAnimationEnable = true
      ..backgroundColor = Colors.transparent
      ..widget(Container(
        width: 350,
        height: 227,
        margin: EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
        ),
        child: Column(
          children: <Widget>[
            InkWell(
              child: Container(
                width: 350,
                height: 45,
                child: Center(
                  child: Text('商务拜访',style: TextStyle(fontSize: ScreenUtil().setSp(32),color:type==1?Colors.blue:Colors.black),textScaleFactor: 1.0,),
                ),
              ),
              onTap: (){
                setState(() {
                  reasonType=1;
                  reasonText="商务拜访";
                  _visitReasonControl.text=reasonText;
                  dialog.dismiss();
                });
              },
            ),
            Divider(height: 1,),
            InkWell(
              child:   Container(
                width: 350,
                height: 45,
                child: Center(
                  child: Text('配送服务',style: TextStyle(fontSize: ScreenUtil().setSp(32),color:type==2?Colors.blue:Colors.black),textScaleFactor: 1.0,),
                ),
              ),
              onTap: (){
                setState(() {
                  reasonType=2;
                  reasonText="配送服务";
                  _visitReasonControl.text=reasonText;
                  dialog.dismiss();
                });
              },
            ),
            InkWell(
              child: Container(
                width: 350,
                height: 45,
                child: Center(
                  child: Text('面试',style: TextStyle(fontSize: ScreenUtil().setSp(32),color:type==3?Colors.blue:Colors.black),textScaleFactor: 1.0,),
                ),
              ),
              onTap: (){
                setState(() {
                  reasonType=3;
                  reasonText="面试";
                  _visitReasonControl.text=reasonText;
                  dialog.dismiss();
                });
              },
            ),
            InkWell(
              child:   Container(
                width: 350,
                height: 45,
                child: Center(
                  child: Text('找人',style: TextStyle(fontSize: ScreenUtil().setSp(32),color:type==4?Colors.blue:Colors.black),textScaleFactor: 1.0,),
                ),
              ),
              onTap: (){
                setState(() {
                  reasonType=4;
                  reasonText="找人";
                  _visitReasonControl.text=reasonText;
                  dialog.dismiss();
                });
              },
            ),
            Divider(height: 1,),
            InkWell(
              child:   Container(
                width: 350,
                height: 45,
                child: Center(
                  child: Text('其他',style: TextStyle(fontSize: ScreenUtil().setSp(32),color:type==5?Colors.blue:Colors.black),textScaleFactor: 1.0,),
                ),
              ),
              onTap: (){
                dialog.dismiss();
              },
            ),
          ],
        ),
      ))
      ..widget(InkWell(
        child: Container(
          width: 350,
          height: 45,
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              "取消",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),onTap: (){
        dialog.dismiss();
      },
      ))
      ..show();
  }
  Future<bool> fastVisit() async {
    if(_visitStartControl.text.toString()==""||_visitStartControl.text.toString()==""){
      ToastUtil.showShortToast('开始时间不正确');
      return false;
    }
    if(_visitEndControl.text.toString()==""||_visitEndControl.text.toString()==""){
      ToastUtil.showShortToast('时长不正确');
      return false;
    }
    if(_visitReasonControl.text.toString()==""||_visitReasonControl.text.toString()==""){
      ToastUtil.showShortToast('理由未填写');
      return false;
    }
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String httpUrl=Constant.fastVisitUrl;
    String threshold=await CommonUtil.calWorkKey(userInfo: userInfo);
    String end=  DateFormat('yyyy-MM-dd HH:mm').format(endDate);
    var parameters={
      "userId": userInfo.id,
      "token": userInfo.token,
      "factor":CommonUtil.getCurrentTime(),
      "threshold":threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "visitorId":widget.user.userId,
      "startDate":_visitStartControl.text.toString(),
      "endDate":end,
      "reason":reasonType==5?_visitReasonDetailControl.text.toString():_visitReasonControl.text.toString(),
      "recordType":1,
    };
    var response=await Http().post(httpUrl,queryParameters: parameters,userCall: true);
    if(response!=null&&response!=""){
      if(response is String){
        Map responseMap = jsonDecode(response);
        if(responseMap['verify']['sign']=="success"){
          ToastUtil.showShortToast('访问成功，可在个人中心查看哦');
          Navigator.pop(context);
        }else{
          ToastUtil.showShortToast(responseMap['verify']['desc']);
        }
      }
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
                        color: Color(0xFF0095FF),
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
                        color: Color(0xFFFFFFFF),
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
