import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/RegExpUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';

class FriendRequestNote extends StatefulWidget{
  final FriendInfo user;
  final String phone;
  FriendRequestNote({Key key,this.phone,this.user}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return FriendRequestNoteState();
  }
}
class FriendRequestNoteState extends State<FriendRequestNote>{
  TextEditingController _auth;
  TextEditingController _note;
  @override
  void initState() {
    super.initState();
    _auth=TextEditingController();
    _note=TextEditingController();
  }
  @override
  void dispose() {
    _auth.dispose();
    _note.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:  AppBar(
          title: Text('好友验证',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF373737)),),
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
        ),
      body: SingleChildScrollView(
        child:Column(
          children: <Widget>[
            Container(
              height: 280,
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('验证信息',style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF787878)),),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child:TextField(
                      controller:_auth,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '请输入',
                        hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                      ),
                    ),
                    decoration: BoxDecoration(
                      border:Border(
                        bottom: BorderSide(
                          color: Color(0xFFF8F8F8),
                          width: ScreenUtil().setHeight(2),
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                  Text('备注',style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF787878)),),
                  TextField(
                    controller:_note,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '',
                      hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                    ),
                    maxLength: 80,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: ScreenUtil().setHeight(102)),
                color: Colors.white,
                child: SizedBox(
                  width: ScreenUtil().setWidth(508),
                  height: ScreenUtil().setHeight(90),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Text('发送申请',style: TextStyle(color: Color(0xFFFFFFFF),fontSize: ScreenUtil().setSp(32)),),
                    color: Color(0xFF0073FE),
                    onPressed: (){
                      addFriend();
                    },
                  ),
                )
            ),
          ],
        )
      ),
    );
  }
  addFriend() async {
    if(!RegExpUtil().verifyPhone(widget.user.phone??"")){
      ToastUtil.showShortClearToast("手机号码不正确");
      return ;
    }
    String url ="userFriend/addUserFriend";
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url, queryParameters: {
      "token": userInfo.token,
      "factor":CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "userId":userInfo.id,
      "friendId":widget.user.userId,
      "phone":widget.user.phone,
      "authentication":_auth.text,
      "remarkMsg":_note.text,
    },userCall: true);
    if(res !=null&&res!=""&&res!="isBlocking"){
      if(res is String){
        Map map = jsonDecode(res);
        if(map['verify']['sign']=="success"){
          ToastUtil.showShortClearToast('好友申请已发送');
        }else{
          ToastUtil.showShortClearToast(map['verify']['desc']);
        }
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }else{
      ToastUtil.showShortToast("请求失败");
    }
  }
}