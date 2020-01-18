import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/Md5Util.dart';
import 'package:visitor/com/goldccm/visitor/util/RegExpUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/login/Login.dart';
import 'package:visitor/com/goldccm/visitor/view/login/VerifyCode.dart';

class ForgetPasswordPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ForgetPasswordPageState();
  }
}
class ForgetPasswordPageState extends State<ForgetPasswordPage>{
  TextEditingController _phoneController=TextEditingController();
  bool isEditing=false;
  bool isComplete=false;
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
                margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(right: ScreenUtil().setWidth(205),left: 0),
                      child: IconButton(
                          icon: Image(image: AssetImage("assets/images/login_back.png"),width: ScreenUtil().setWidth(36),height: ScreenUtil().setHeight(36),color: Color(0xFF0073FE),),
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          }),
                    ),
                    Text('忘记密码',style: TextStyle(color: Color(0xFF0073FE),fontSize: ScreenUtil().setSp(36),),),
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
                child: Text('请输入手机号码',style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF373737)),),
              ),
              Container(
                width: ScreenUtil().setWidth(750),
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(112),right: ScreenUtil().setWidth(112)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text('手机号码',style: TextStyle(color: Color(0xFFA8A8A8),fontSize: ScreenUtil().setSp(28)),),
                      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(62)),
                    ),
                    Stack(
                      children: <Widget>[
                        Positioned(
                          top: ScreenUtil().setWidth(40),
                          child:Text('+86',style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color(0xFF6C6C6C)),) ,
                        ),
                        Container(
                          height: ScreenUtil().setHeight(80),
                          width: ScreenUtil().setWidth(442),
                          margin: EdgeInsets.only(left: ScreenUtil().setWidth(70)),
                          child: TextField(
                            controller: _phoneController,
                            style: TextStyle(fontSize: ScreenUtil().setSp(32),color: Color(0xFF212121)),
                            decoration: isEditing?InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                                suffix: GestureDetector(
                                  child: Container(
                                    child: Image(image: AssetImage('assets/images/login_cancel.png'),width: ScreenUtil().setWidth(40),height: ScreenUtil().setHeight(40),),
                                    padding: EdgeInsets.only(right: ScreenUtil().setWidth(18)),
                                  ),
                                  onTap: (){
                                    setState(() {
                                      _phoneController.text="";
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
                                if(RegExpUtil().verifyPhone(value)){
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
                      ],
                    )
                  ],
                ),
              ),
              Container(
                height: ScreenUtil().setHeight(170),
                padding: EdgeInsets.only(top:ScreenUtil().setHeight(80),left: ScreenUtil().setWidth(112),right:ScreenUtil().setWidth(112)),
                decoration: BoxDecoration(

                ),
                child: SizedBox(
                  width: ScreenUtil().setWidth(520),
                  height: ScreenUtil().setHeight(90),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Text('获取验证码',style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFFFFFFFF)),textAlign: TextAlign.center,),
                    onPressed: (){
                      submitPhone();
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
  Future<void> submitPhone() async {
    if(isComplete){
      String url =Constant.serverUrl+"user/checkPhone";
      var response = await Http().post(url,queryParameters: {
        "phone":_phoneController.text,
      });
      if(response!=""&&response!=null){
        Map map = jsonDecode(response);
        if(map['verify']['sign']=="fail"){
          Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context)=>VerifyCodePage(phone: _phoneController.text,title: '忘记密码',)));
        }else{
          ToastUtil.showShortClearToast("手机号未注册");
        }
      }

    }
  }
}
class ResetPassWord extends StatefulWidget{
  final String phone;
  final String code;
  ResetPassWord({Key key,this.phone,this.code}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return ResetPassWordState();
  }
}
class ResetPassWordState extends State<ResetPassWord>{
  TextEditingController _pwdController=TextEditingController();
  bool isEditing=false;
  bool isComplete=false;
  bool isSeen=false;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      body: SingleChildScrollView(
        child:Container(
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
                      padding: EdgeInsets.only(right: ScreenUtil().setWidth(205),left: 0),
                      child: IconButton(
                          icon: Image(image: AssetImage("assets/images/login_back.png"),width: ScreenUtil().setWidth(36),height: ScreenUtil().setHeight(36),color: Color(0xFF0073FE),),
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          }),
                    ),
                    Text('忘记密码',style: TextStyle(color: Color(0xFF0073FE),fontSize: ScreenUtil().setSp(36),),),
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
                              controller: _pwdController,
                              obscureText: !isSeen,
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
                                isEditing=false;
                                isComplete=false;
                              });
                            },
                          ),
                        ),
                        Positioned(
                          right: ScreenUtil().setWidth(30),
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
                padding: EdgeInsets.only(top:ScreenUtil().setHeight(38),left:  ScreenUtil().setWidth(112),right:ScreenUtil().setWidth(112)),
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
                      resetPwd();
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
  //重置密码
  Future<void> resetPwd() async {
    if(isComplete){
      String url = Constant.serverUrl+"user/forget";
      String sysPwd = Md5Util.instance.encryptByMD5ByHex(_pwdController.text.toString());
      var response =await  Http().post(url,queryParameters: {
        "phone":widget.phone,
        "code" :widget.code,
        "sysPwd":sysPwd,
      });
      if(response!=""&&response!=null){
         Map resMap = jsonDecode(response);
         if(resMap['verify']['sign']=="success"){
           ToastUtil.showShortClearToast("重置密码成功");
           Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => new Login(),), (Route route) => route == null);
         }else{
           ToastUtil.showShortClearToast(resMap['verify']['desc']);
         }
      }
    }
  }
}