import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/EventBusUtil.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/FriendListEvent.dart';
import 'package:visitor/com/goldccm/visitor/eventbus/MessageCountChangeEvent.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DialogUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/RegExpUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../FriendDetailInfo.dart';
import '../chat.dart';
import 'MsgSetting.dart';

/*
 * 好友详情
 * Author:ody997
 * Email:hwk@growingpine.com
 * 2019/10/16
 */
class FriendDetailPage extends StatefulWidget {
  final FriendInfo user;
  final int type;
  FriendDetailPage({Key key, this.user, this.type}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return FriendDetailPageState();
  }
}

class FriendDetailPageState extends State<FriendDetailPage> {
  ScrollController _scrollController = new ScrollController();
  FriendInfo _user;
  String belongTo="公司";
  var optionDialog;
  var deleteDialog;
  @override
  void initState() {
    super.initState();
    _user = widget.user;
    getStatus();
  }
  updateInfo(){
    Future.delayed(Duration(milliseconds: 500),(){
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => FriendDetailInfoPage(friend: widget.user,))).then((value){
        if(value!=null&&value.length>0){
          setState(() {
            widget.user.remarkName=value[0];
            widget.user.notice=value[1];
          });
        }
      });
    });
  }
  deleteSingleFriend() async {
    YYDialog().build(context)
      ..width = 220
      ..borderRadius = 4.0
      ..text(
        padding: EdgeInsets.all(25.0),
        alignment: Alignment.center,
        text: "确认删除该好友吗？",
        color: Colors.black,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
      )
      ..divider()
      ..doubleButton(
        padding: EdgeInsets.only(top: 10.0),
        gravity: Gravity.center,
        withDivider: true,
        text1: "取消",
        color1: Colors.black,
        fontSize1: 14.0,
        fontWeight1: FontWeight.bold,
        onTap1: () {

        },
        text2: "确定",
        color2: Colors.redAccent,
        fontSize2: 14.0,
        fontWeight2: FontWeight.bold,
        onTap2: () {
          deleteFriend();
        },
      )
      ..show();
  }
  deleteFriend() async {
    UserInfo userInfo = await  LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey();
    var response=await Http().post(Constant.deleteUserFriendUrl,queryParameters: {
      "token":userInfo.token,
      "userId":userInfo.id,
      "factor":CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "friendId":_user.userId,
    },userCall: true);
    if(response!=""&&response!=null){
      if(response is String){
        Map responseMap = jsonDecode(response);
        if(responseMap['verify']['sign']=="success"){
          Navigator.pop(context);
          EventBusUtil().eventBus.fire(FriendListEvent(1));
        }else{
          ToastUtil.showShortClearToast("删除好友失败");
        }
      }
    }
  }
  getStatus() async {
    String status=await RouterUtil.getStatus();
    if(status=="local"){
      setState(() {
        belongTo="部门";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 220,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: RouterUtil.imageServerUrl +
                        widget.user.virtualImageUrl,
                    placeholder: (context, url) =>
                        Image(
                          height: 220+MediaQuery.of(context).padding.top,
                          fit: BoxFit.fitWidth,
                          width: MediaQuery.of(context).size.width,
                          image: AssetImage('assets/images/message_chat_detail_back.png'),
                        ),
                    errorWidget: (context, url, error) =>
                        Image(
                          height: 220+MediaQuery.of(context).padding.top,
                          fit: BoxFit.fitWidth,
                          width: MediaQuery.of(context).size.width,
                          image: AssetImage('assets/images/message_chat_detail_back.png'),
                        ),
                    imageBuilder: (context,imageProvider)=>
                        Image(
                      image: imageProvider,
                      height: 220+MediaQuery.of(context).padding.top,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 220+MediaQuery.of(context).padding.top,
                    decoration: BoxDecoration(color: Color.fromRGBO(0,0,0,0.2)),
                  ),
                ],
              )
            ),
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: IconButton(
                icon: Image(
                  image: AssetImage("assets/images/login_back.png"),
                  width: ScreenUtil().setWidth(36),
                  height: ScreenUtil().setHeight(36),
                  color: Colors.white,),
                onPressed: () {
                  setState(() {
                    FocusScope.of(context).requestFocus(FocusNode());
                    Navigator.pop(context);
                  });
                }),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.more_horiz,color: Colors.white,),
                onPressed: (){
                  var lists={
                    'add':['添加备注','assets/images/message_chat_option_addNotice.png',updateInfo],
                    'delete':['删除好友','assets/images/message_chat_option_delete.png',deleteSingleFriend]
                  };
                  showOption(lists);
                },
              ),
            ],
            brightness: Brightness.dark,
            automaticallyImplyLeading: false,
          ),
          SliverPadding(
            padding: EdgeInsets.all(20),
           sliver: SliverToBoxAdapter(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[
                 Container(
                   padding: EdgeInsets.only(bottom: 5),
                   child: Text(widget.user.remarkName??"",textScaleFactor: 1,style: TextStyle(fontSize: 18,color: Color(0xFF373737)),),
                 ),
                 titleListItem('$belongTo',widget.user.companyName??""),
                 titleListItem('电话',widget.user.phone??""),
                 titleListItem('描述',widget.user.notice??""),
               ],
             ),
           ), 
          ),
        ],
      ),
      bottomSheet: topToolBar(),
    );
  }
  Widget titleListItem(String title,String content){
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(right: 10,top: 5,bottom: 5),
          child: Text(title,textScaleFactor: 1,style: TextStyle(fontSize: 14,color: Color(0xFFCFCFCF)),),
        ),
        Container(
          child: Text(content,textScaleFactor: 1,style: TextStyle(fontSize: 15,color: Color(0xFF373737)),),
        )
      ],
    );
  }
  Widget topToolBar(){
    return Container(
      height: 100,
      color: Color(0xFFFEFEFE),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          toolBarItem(text:'发消息',iconUrl: 'assets/images/message_chat_talking.png',method: goToChat),
          toolBarItem(text:'访问',iconUrl: 'assets/images/message_chat_visit.png',method: goToVisit),
          toolBarItem(text:'邀约',iconUrl: 'assets/images/message_chat_invite.png',method: goToInvite),
          toolBarItem(text:'打电话',iconUrl: 'assets/images/message_chat_call.png',method: makingPhoneCall),
        ],
      ),
    );
  }
  goToChat(){
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => ChatPage(
              user: widget.user,
            )));
  }
  goToInvite(){
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => ChatPage(
              user: widget.user,
              method: 0,
            )));
  }
  goToVisit(){
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => ChatPage(
              user: widget.user,
              method: 1,
            )));
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
  Widget toolBarItem({String text,Function method,String iconUrl}){
    return Container(
        padding: EdgeInsets.all(10),
        child: InkWell(
          child: Column(
            children: <Widget>[
              Image(
                height: 46,
                width: 46,
                fit: BoxFit.fill,
                image: AssetImage(iconUrl??""),
              ),
              Text(text??""),
            ],
          ),
          onTap: method,
        )
    );
  }

  void showOption(Map<String,List> maps) {
    optionDialog=YYDialog().build(context)
      ..width = 110
      ..borderRadius = 10.0
      ..gravity = Gravity.rightTop
      ..barrierColor = Colors.transparent
      ..margin = EdgeInsets.only(top: MediaQuery.of(context).padding.top+50, right: 10)
      ..widget(
        ListView.builder(itemBuilder: (context,index){
          return InkWell(
            child: Row(children: <Widget>[
              Expanded(
                  flex: 2,
                  child:Container(
                    padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                    child: Image(
                      width: 14,
                      height: 14,
                      image: AssetImage(maps.entries.elementAt(index).value[1]),
                    ),
                  )
              ),
              Expanded(
                flex: 4,
                child: Text(maps.entries.elementAt(index).value[0],style: TextStyle(fontSize: 14,color: Color(0xFF595959)),),
              ),
            ],),onTap: (){
              optionDialog.dismiss();
             maps.entries.elementAt(index).value[2]();
            }
          );
        },itemCount: maps.entries.length,shrinkWrap: true,padding: EdgeInsets.all(0),)
      )..show();
  }
}
