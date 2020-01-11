import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/JsonResult.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/Md5Util.dart';
import 'package:visitor/com/goldccm/visitor/util/NPushUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/RegExpUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/SharedPreferenceUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/common/LoadingDialog.dart';
import 'package:visitor/com/goldccm/visitor/view/login/Login.dart';
import 'package:visitor/home.dart';

import 'Agreement.dart';

class RegisterPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return RegisterPageState();
  }
}
class RegisterPageState extends State<RegisterPage> {
  TextEditingController _phoneController = TextEditingController();
  bool isEditing = false;
  bool isComplete = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: ScreenUtil().setWidth(750),
          height: ScreenUtil().setHeight(1334),
          color: Color(0xFFFFFFFF),
          child: Column(
            children: <Widget>[
              Container(
                height: ScreenUtil().setHeight(88),
                width: ScreenUtil().setWidth(750),
                margin: EdgeInsets.only(top: MediaQuery
                    .of(context)
                    .padding
                    .top),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                          right: ScreenUtil().setWidth(235), left: 0),
                      child: IconButton(
                          icon: Image(
                            image: AssetImage("assets/images/login_back.png"),
                            width: ScreenUtil().setWidth(36),
                            height: ScreenUtil().setHeight(36),
                            color: Color(0xFF0073FE),),
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          }),
                    ),
                    Text('注册', style: TextStyle(color: Color(0xFF0073FE),
                      fontSize: ScreenUtil().setSp(36),),),
                  ],
                ),
              ),
              Container(
                child: Divider(
                  color: Color(0x0F000000),
                  height: ScreenUtil().setHeight(2),
                  thickness: ScreenUtil().setHeight(2),
                ),
              ),
              Container(
                height: ScreenUtil().setHeight(50),
                width: ScreenUtil().setWidth(750),
                margin: EdgeInsets.only(top: ScreenUtil().setHeight(144),
                    left: ScreenUtil().setWidth(112),
                    bottom: ScreenUtil().setHeight(116)),
                child: Text('新用户注册', style: TextStyle(
                    fontSize: ScreenUtil().setSp(36), color: Color(0xFF373737)),),
              ),
              Container(
                width: ScreenUtil().setWidth(750),
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(112),
                    right: ScreenUtil().setWidth(112)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text('手机号码', style: TextStyle(
                          color: Color(0xFFA8A8A8),
                          fontSize: ScreenUtil().setSp(28)),),
                      padding: EdgeInsets.only(
                          bottom: ScreenUtil().setHeight(62)),
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          child: Text('+86', style: TextStyle(
                              fontSize: ScreenUtil().setSp(28),
                              color: Color(0xFF6C6C6C)),),
                          width: ScreenUtil().setWidth(52),
                          height: ScreenUtil().setHeight(40),
                          padding: EdgeInsets.only(
                              top: ScreenUtil().setHeight(15)),
                        ),
                        Container(
                          height: ScreenUtil().setHeight(60),
                          width: ScreenUtil().setWidth(472),
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(18)),
                          child: TextField(
                            controller: _phoneController,
                            style: TextStyle(fontSize: ScreenUtil().setSp(32),
                                color: Color(0xFF212121)),
                            decoration: isEditing ? InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Color(0xFFCFCFCF),
                                    fontSize: ScreenUtil().setSp(28)),
                                suffix: GestureDetector(
                                  child: Container(
                                    child: Image(
                                      image: AssetImage(
                                          'assets/images/login_cancel.png'),
                                      width: ScreenUtil().setWidth(40),
                                      height: ScreenUtil().setHeight(40),),
                                    padding: EdgeInsets.only(
                                        right: ScreenUtil().setWidth(18)),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _phoneController.text = "";
                                      isComplete = false;
                                      isEditing = false;
                                    });
                                  },
                                )
                            ) : InputDecoration(
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Color(0xFFCFCFCF),
                                  fontSize: ScreenUtil().setSp(28)),
                            ),
                            onChanged: (value) {
                              if (value != null && value != "") {
                                isEditing = true;
                                if (RegExpUtil().verifyPhone(value)) {
                                  setState(() {
                                    isComplete = true;
                                  });
                                } else {
                                  setState(() {
                                    isComplete = false;
                                  });
                                }
                              } else {
                                setState(() {
                                  isEditing = false;
                                });
                              }
                            },
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFECECEC),
                                width: ScreenUtil().setHeight(2),
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                height: ScreenUtil().setHeight(170),
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(80),
                    left: ScreenUtil().setWidth(112),
                    right: ScreenUtil().setWidth(112)),
                decoration: BoxDecoration(

                ),
                child: SizedBox(
                  width: ScreenUtil().setWidth(520),
                  height: ScreenUtil().setHeight(90),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Text('下一步', style: TextStyle(
                        fontSize: ScreenUtil().setSp(36),
                        color: Color(0xFFFFFFFF)), textAlign: TextAlign.center,),
                    onPressed: () {
                      submitPhone();
                    },
                    color: isComplete ? Color(0xFF0073FE) : Color(0xFF79B6FF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitPhone() {
    if (isComplete) {
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>UserAgreementDealPage(phone: _phoneController.text,)));
    }
  }
}
/*
 * 注册设置密码
 * create_time:2020/1/9
 */
class SetPasswordPage extends StatefulWidget{
  final String phone;
  final String code;
  SetPasswordPage({Key key,this.phone,this.code}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return SetPasswordPageState();
  }
}
class SetPasswordPageState extends State<SetPasswordPage>{
  TextEditingController _pwdController=TextEditingController();
  bool isEditing=false;
  bool isComplete=false;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      body: Container(
        width: ScreenUtil().setWidth(750),
        height: ScreenUtil().setHeight(1334),
        color: Color(0xFFFFFFFF),
        child: Column(
          children: <Widget>[
            Container(
              height: ScreenUtil().setHeight(88),
              width: ScreenUtil().setWidth(750),
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(right: ScreenUtil().setWidth(235),left: 0),
                    child: IconButton(
                        icon: Image(image: AssetImage("assets/images/login_back.png"),width: ScreenUtil().setWidth(36),height: ScreenUtil().setHeight(36),color: Color(0xFF0073FE),),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        }),
                  ),
                  Text('注册',style: TextStyle(color: Color(0xFF0073FE),fontSize: ScreenUtil().setSp(36),),),
                ],
              ),
            ),
            Container(
              child: Divider(
                color: Color(0x0F000000),
                height: ScreenUtil().setHeight(2),
                thickness: ScreenUtil().setHeight(2),
              ),
            ),
            Container(
              height: ScreenUtil().setHeight(50),
              width: ScreenUtil().setWidth(750),
              margin: EdgeInsets.only(top: ScreenUtil().setHeight(144),left: ScreenUtil().setWidth(112),bottom: ScreenUtil().setHeight(116)),
              child: Text('请输入新密码',style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF373737)),),
            ),
            Container(
              width: ScreenUtil().setWidth(750),
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(112),right: ScreenUtil().setWidth(112)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text('新密码',style: TextStyle(color: Color(0xFFA8A8A8),fontSize: ScreenUtil().setSp(28)),),
                    padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(62)),
                  ),
                  Container(
                    height: ScreenUtil().setHeight(60),
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(18)),
                    child: TextField(
                      controller: _pwdController,
                      style: TextStyle(fontSize: ScreenUtil().setSp(32),color: Color(0xFF212121)),
                      decoration: isEditing?InputDecoration(
                          hintText: '请输入新密码',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                          suffix: GestureDetector(
                            child: Container(
                              child: Image(image: AssetImage('assets/images/login_cancel.png'),width: ScreenUtil().setWidth(40),height: ScreenUtil().setHeight(40),),
                              padding: EdgeInsets.only(right: ScreenUtil().setWidth(18)),
                            ),
                            onTap: (){
                              setState(() {
                                _pwdController.text="";
                                isComplete=false;
                                isEditing=false;
                              });
                            },
                          )
                      ):InputDecoration(
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                      ),
                      onChanged:(value){
                        if(value!=null&&value!=""){
                          isEditing=true;
                          if(RegExpUtil().verifyPassWord(value)){
                            setState(() {
                              isComplete=true;
                            });
                          }else{
                            setState(() {
                              isComplete=false;
                            });
                          }
                        }else{
                          setState(() {
                            isEditing=false;
                          });
                        }
                      },
                    ),
                    decoration: BoxDecoration(
                      border:Border(
                        bottom: BorderSide(
                          color: Color(0xFFECECEC),
                          width: ScreenUtil().setHeight(2),
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                  isEditing?Container(
                    height: ScreenUtil().setHeight(54),
                    child: Text('请输入同时包含字母及数字的8-16位密码',style: TextStyle(color: Color(0xFF0095FF),fontSize: ScreenUtil().setSp(24)),),
                    padding: EdgeInsets.only(top: ScreenUtil().setHeight(12)),
                  ):Container(
                    height: ScreenUtil().setHeight(54),
                    child: Text('',style: TextStyle(color: Color(0xFF0095FF),fontSize: ScreenUtil().setSp(24)),),
                    padding: EdgeInsets.only(top: ScreenUtil().setHeight(12)),
                  ),
                ],
              ),
            ),
            Container(
              height: ScreenUtil().setHeight(170-35),
              padding: EdgeInsets.only(top:ScreenUtil().setHeight(38),left: ScreenUtil().setWidth(112),right:ScreenUtil().setWidth(112)),
              decoration: BoxDecoration(

              ),
              child: SizedBox(
                width: ScreenUtil().setWidth(520),
                height: ScreenUtil().setHeight(90),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Text('完成',style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFFFFFFFF)),textAlign: TextAlign.center,),
                  onPressed: (){
                    setPwd();
                  },
                  color: isComplete?Color(0xFF0073FE):Color(0xFF79B6FF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void setPwd(){
    if(isComplete){
      LoadingDialog().show(context, "注册中");
      _register().then((value) async {
        Navigator.pop(context);
        if(value=="true"){
          Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => new MyHomeApp(),), (Route route) => route == null);
        }
        if(value=="loginFail"){
          ToastUtil.showShortToast("注册成功");
          Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => new Login(),), (Route route) => route == null);
        }
      });
    }
  }
  Future<String> _register() async {
    String sysPwd = Md5Util.instance
        .encryptByMD5ByHex(_pwdController.text.toString());
    var response = await Http.instance.post(
        Constant.serverUrl+Constant.registerUrl,
        queryParameters: {
          "phone": widget.phone,
          "code": widget.code,
          "sysPwd": sysPwd
        }, userCall: true);
    if (response == "isBlocking" || response == "" || response == null) {
      ToastUtil.showShortClearToast("注册失败");
      return "false";
    }
    JsonResult result = JsonResult.fromJson(response);
    if (result.sign == 'success') {
      String _passNum =
      Md5Util().encryptByMD5ByHex(_pwdController.text.toString());
      var data = await Http.instance.post(
          Constant.serverUrl+Constant.loginUrl,
          queryParameters: {
            "phone": widget.phone,
            "style": "1",
            "sysPwd": _passNum,
            "deviceToken": NPush.clientId ?? "",
            "deviceType": Platform.isAndroid ? 1 : 2,
          }, userCall: true);
      if (data == "" || data == null || data == "isBlocking") {
        return "loginFail";
      }
      JsonResult loginResult = JsonResult.fromJson(data);
      if (loginResult.sign == 'success') {
        var userMap = loginResult.data['user'];
        print(userMap);
        UserInfo userInfo = UserInfo.fromJson(userMap);
        DataUtils.saveLoginInfo(userMap);
        DataUtils.saveUserInfo(userMap);
        //DataUtils.saveNoticeInfo(noticeMap);
        Provider.of<UserModel>(context).init(userInfo);
        LocalStorage.save("userInfo", userInfo);
        SharedPreferenceUtil.saveUser(userInfo);
        return "true";
      } else {
        ToastUtil.showShortClearToast(loginResult.desc);
        return "false";
      }
    } else {
      ToastUtil.showShortClearToast(result.desc);
      return "false";
    }
  }
}