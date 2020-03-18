import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
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
import 'package:visitor/com/goldccm/visitor/view/homepage/NewsWebView.dart';
import 'package:visitor/com/goldccm/visitor/view/login/Login.dart';
import 'package:visitor/com/goldccm/visitor/view/login/VerifyCode.dart';
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
  String activeRadioValue = "";
  NewsWebPage _newsWebPage = new NewsWebPage(news_url:"http://121.36.45.232:8082/visitor/xieyi2.html",title:"用户协议",news_bar: false,);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  Widget build(BuildContext context) {
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
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(112), right: ScreenUtil().setWidth(112)),
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
                    Stack(
                      children: <Widget>[
                        Positioned(
                          top: ScreenUtil().setHeight(40),
                          child: Text('+86', style: TextStyle(
                              fontSize: ScreenUtil().setSp(28),
                              color: Color(0xFF6C6C6C)),),
                        ),
                        Container(
                          height: ScreenUtil().setHeight(80),
                          width: ScreenUtil().setWidth(442),
                          margin: EdgeInsets.only(left: ScreenUtil().setWidth(70)),
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
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(90),top: ScreenUtil().setHeight(20)),
                child: Row(
                  children: <Widget>[
                   Radio(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: 'policy',
                        groupValue: activeRadioValue,
                        activeColor: Color(0xFF79B6FF),
                        onChanged:(value){
                          setState(() {
                            activeRadioValue='policy';
                          });
                        },
                      ),
                    Text('我已阅读并接受',style: TextStyle(color:Color(0xFF373737),fontSize: ScreenUtil().setSp(26)),),
                    GestureDetector(
                      child: Text('《朋悦比邻隐私政策》',style: TextStyle(color:Color(0xFF0073FE),fontSize: ScreenUtil().setSp(26))),
                      onTap: (){
                        callPolicy();
                      },
                    )
                  ],
                ),
              ),
              Container(
                height: ScreenUtil().setHeight(150),
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(60),
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
  callPolicy(){
    return YYDialog().build(context)
      ..width = ScreenUtil().setWidth(267*2)
      ..gravity = Gravity.center
      ..borderRadius = 15.0
      ..text(
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(30)),
        alignment: Alignment.center,
        text: "朋悦比邻隐私政策",
        color: Colors.black,
        fontSize: ScreenUtil().setHeight(32),
        fontWeight: FontWeight.bold,
      )
      ..widget(Padding(
        padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(30)),
        child:   Container(
          child: Container(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
            height: ScreenUtil().setHeight(640),
            child: _newsWebPage,
          ),
        ),
      ))
//      ..divider()
//      ..doubleButton(
//        padding: EdgeInsets.only(top: 10.0),
//        gravity: Gravity.center,
//        withDivider: true,
//        text1: "不同意",
//        color1: Colors.black26,
//        fontSize1: ScreenUtil().setSp(36),
//        onTap1: () {
//          setState(() {
//            activeRadioValue='';
//          });
//        },
//        text2: "同意并继续",
//        color2: Colors.blue[600],
//        fontSize2: ScreenUtil().setSp(36),
//        onTap2: () {
//          setState(() {
//            activeRadioValue='policy';
//          });
//        },
//      )
      ..show();
  }
  Future<void> submitPhone() async {
    if(activeRadioValue!='policy'){
      ToastUtil.showShortClearToast("请先同意协议");
    }else{
      if (isComplete) {
        String url =Constant.serverUrl+"user/checkPhone";
        var response = await Http().post(url,queryParameters: {
          "phone":_phoneController.text,
        });
        if(response!=""&&response!=null){
          Map map = jsonDecode(response);
          if(map['verify']['sign']=="fail"){
            ToastUtil.showShortClearToast("手机号已被注册");
          }else{
            Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context)=> VerifyCodePage(phone: _phoneController.text,title: '注册',outer: true,)));
          }
        }
      }else{
        ToastUtil.showShortClearToast("电话号码不正确");
      }
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
  bool isSeen=false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }
  @override
  Widget build(BuildContext context) {
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
                    Stack(
                      children: <Widget>[
                        Positioned(
                          child: Container(
                            height: ScreenUtil().setHeight(80),
                            padding: EdgeInsets.only(left: ScreenUtil().setWidth(18)),
                            child: TextField(
                              obscureText: !isSeen,
                              controller: _pwdController,
                              style: TextStyle(fontSize: ScreenUtil().setSp(32),color: Color(0xFF212121)),
                              decoration: InputDecoration(
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
                        ),
                        Positioned(
                          right: ScreenUtil().setWidth(100),
                          top: ScreenUtil().setHeight(25),
                          child: GestureDetector(
                            child: isEditing?Container(
                              child: Image(image: AssetImage('assets/images/login_cancel.png'),width: ScreenUtil().setWidth(40),height: ScreenUtil().setHeight(40),),
                            ):Container(),
                            onTap: (){
                              setState(() {
                                _pwdController.text="";
                                isComplete=false;
                                isEditing=false;
                              });
                            },
                          ),
                        ),
                        Positioned(
                          right: ScreenUtil().setWidth(40),
                          top: ScreenUtil().setHeight(25),
                          child: GestureDetector(
                            child: isEditing?Container(
                              child: Image(image: isSeen?AssetImage('assets/images/login_visiable.png'):AssetImage('assets/images/login_secret.png'),width: ScreenUtil().setWidth(40),height: ScreenUtil().setHeight(40),),
                            ):Container(),
                            onTap: (){
                              setState(() {
                                isSeen=!isSeen;
                              });
                            },
                          ),
                        ),
                      ],
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
      ),
    );
  }
  void setPwd(){
    if(isComplete){
      LoadingDialog().show(context, "注册中");
      _register().then((value) async {
        Navigator.pop(context);
        if(value=="true"){
          Navigator.of(context).pushAndRemoveUntil(new CupertinoPageRoute(builder: (BuildContext context) => new MyHomeApp(),), (Route route) => route == null);
        }
        if(value=="loginFail"){
          ToastUtil.showShortToast("注册成功");
          Navigator.of(context).pushAndRemoveUntil(new CupertinoPageRoute(builder: (BuildContext context) => new Login(),), (Route route) => route == null);
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
