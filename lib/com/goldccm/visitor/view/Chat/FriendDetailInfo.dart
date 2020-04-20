import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';

//好友详细信息页
class FriendDetailInfoPage extends StatefulWidget {
  final FriendInfo friend;
  FriendDetailInfoPage({Key key, this.friend}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return FriendDetailInfoPageState();
  }
}

class FriendDetailInfoPageState extends State<FriendDetailInfoPage> {
  String notice;
  String remark;
  TextEditingController _remarkTextController;
  TextEditingController _noticeTextController;
  @override
  void initState() {
    super.initState();
    remark = widget.friend.remarkName ?? "";
    notice = widget.friend.notice ?? "";
    _remarkTextController = TextEditingController();
    _noticeTextController = TextEditingController();
    initData();
  }

  @override
  void dispose() {
    _remarkTextController.dispose();
    _noticeTextController.dispose();
    super.dispose();
  }

  initData() {
    print(remark);
    setState(() {
      _remarkTextController.text = remark;
      _noticeTextController.text = notice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '添加备注',
          textScaleFactor: 1.0,
          style: TextStyle(
              fontSize: ScreenUtil().setSp(36), color: Color(0xFF373737)),
        ),
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
              color: Color(0xFF373737),
            ),
            onPressed: () {
              setState(() {
                FocusScope.of(context).requestFocus(FocusNode());
                Navigator.pop(context);
              });
            }),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              width: ScreenUtil().setWidth(750),
              height: ScreenUtil().setHeight(100),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                    left: ScreenUtil().setWidth(62),
                    child: Text(
                      '备注',
                      style: TextStyle(color: Color(0xFF787878), fontSize: 15),
                    ),
                  ),
                  Positioned(
                    left: ScreenUtil().setWidth(146),
                    child: Container(
                      width: ScreenUtil().setWidth(578),
                      child: TextField(
                        controller: _remarkTextController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '请输入',
                            hintStyle: TextStyle(
                              fontSize: 15,
                            )),
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              color: Colors.white,
              width: ScreenUtil().setWidth(750),
              height: ScreenUtil().setHeight(300),
              margin: EdgeInsets.only(top: 10),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                    left: ScreenUtil().setWidth(62),
                    top: 5,
                    child: Text(
                      '描述',
                      style: TextStyle(color: Color(0xFF787878), fontSize: 15),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: ScreenUtil().setWidth(146),
                    child: Container(
                      width: ScreenUtil().setWidth(578),
                      child: TextField(
                        controller: _noticeTextController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '请输入',
                            hintStyle: TextStyle(
                              fontSize: 15,
                            )),
                        minLines: 4,
                        maxLines: 4,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 50),
              width: ScreenUtil().setWidth(526),
              height: ScreenUtil().setHeight(90),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                child: Text(
                  '保存',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(36),
                      color: Color(0xFFFFFFFF)),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  updateInfo();
                },
                color: Color(0xFF0073FE),
              ),
            )
          ],
        ),
      ),
    );
  }

  updateInfo() async {
    print(widget.friend.toString());
    if(_remarkTextController.text==""){
      ToastUtil.showShortClearToast("备注不能为空");
      return;
    }
    String url = "/userFriend/updateFriendRemark";
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url, queryParameters: {
      "token": userInfo.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "userId": userInfo.id,
      "friendId":widget.friend.belongId,
      "detail":_noticeTextController.text.toString(),
      "remark":_remarkTextController.text.toString(),
    });
    if (res is String) {
      Map map = jsonDecode(res);
      List<String> lists=List<String>();
      lists.add(_remarkTextController.text.toString());
      lists.add(_noticeTextController.text.toString());
      if (map['verify']['sign'] == "success") {
        Navigator.pop(context,lists);
      }
    }
  }
}
