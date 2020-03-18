import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/login/ForgetPassword.dart';
import 'package:visitor/com/goldccm/visitor/view/login/Register.dart';

/*
 * 验证码校验页
 * create_time:2020/1/8
 */
class VerifyCodePage extends StatefulWidget{
  final String phone;
  final String title;
  final bool outer;
  VerifyCodePage({Key key,this.phone,this.title,this.outer}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return VerifyCodePageState();
  }
}
class VerifyCodePageState extends State<VerifyCodePage>{
  TextEditingController _codeController=TextEditingController();
  String msg="60s后重新获取验证码";
  Timer _timer;
  int countDown = 60;
  bool isWork=false;
  @override
  Widget build(BuildContext context) {
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
                      padding: EdgeInsets.only(right: ScreenUtil().setWidth(235),left: 0),
                      child: IconButton(
                          icon: Image(image: AssetImage("assets/images/login_back.png"),width: ScreenUtil().setWidth(36),height: ScreenUtil().setHeight(36),color: Color(0xFF0073FE),),
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          }),
                    ),
                    Text(widget.title,style: TextStyle(color: Color(0xFF0073FE),fontSize: ScreenUtil().setSp(36),),),
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
                margin: EdgeInsets.only(top: ScreenUtil().setHeight(144),left: ScreenUtil().setWidth(112),bottom: ScreenUtil().setHeight(16)),
                child: Text('验证码已发送至手机',style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF373737)),),
              ),
              Container(
                padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(60),left: ScreenUtil().setWidth(112)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Text('+86',style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color(0xFF0073FE)),),
                      padding: EdgeInsets.only(right: ScreenUtil().setWidth(46)),
                    ),
                    Container(
                      child: Text('${widget.phone}',style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color(0xFF0073FE))),
                    ),
                  ],
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(750),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text('请输入验证码',style: TextStyle(color: Color(0xFFA8A8A8),fontSize: ScreenUtil().setSp(28)),),
                      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(42),left: ScreenUtil().setWidth(110)),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(110)),
                      child: PinInputTextField(
                        pinLength: 6,
                        decoration: UnderlineDecoration(
                          color:  Colors.grey[300],
                          lineHeight: ScreenUtil().setHeight(2),
                        ),
                        controller: _codeController,
                        autoFocus: false,
                        textInputAction: TextInputAction.go,
                        keyboardType: TextInputType.phone,
                        onSubmit: (pin) {
                          debugPrint('submit pin:$pin');
                        },
                        onChanged: (pin){
                          if(pin.length==6){
                            verifyCode(_codeController.text.toString());
                          }
                        },
                      ),
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
                    child: Text(msg,style: TextStyle(fontSize: ScreenUtil().setSp(36),color:Color(0xFFFFFFFF)),textAlign: TextAlign.center,),
                    onPressed: (){
                      if(isWork) {
                        sendCode();
                      }
                    },
                    color: isWork?Color(0xFF0073FE):Color(0xFF79B6FF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    sendCode();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  //发送验证码
  Future<void> sendCode() async {
    String url = RouterUtil.apiServerUrl+Constant.sendCodeUrl;
    if(widget.outer){
      url =  Constant.serverUrl+Constant.sendCodeUrl;
    }
    String phone = widget.phone;
    String type = "1";
    url = url + "/" + phone + "/" + type;
    String res = await Http().get(url);
      Map map = jsonDecode(res);
      if (map['verify']['sign'] == "success") {
        setState(() {
          countDown = 60;
        });
        timeCountDown();
      } else {
        ToastUtil.showShortClearToast(map['verify']['desc']);
      }
  }

  void timeCountDown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countDown <= 0) {
        setState(() {
          isWork = true;
          msg="获取验证码";
        });
      } else {
        setState(() {
          isWork = false;
          countDown = countDown - 1;
          msg="${countDown}s后重新获取验证码";
        });
      }
    });
  }
    Future<void> verifyCode(String code) async {
    String url=RouterUtil.apiServerUrl+"code/verifyCode";
    if(widget.outer){
       url=Constant.serverUrl+"code/verifyCode";
    }
    var response=await Http().post(url,queryParameters: {
      "phone":widget.phone,
      "code":code,
      "type":2,
    });
    if(response!=""&&response!=null){
      Map resMap=jsonDecode(response);
      if(resMap['verify']['sign']=="success"){
        if(widget.title=="注册"){
          Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context)=>SetPasswordPage(phone: widget.phone,code:code)));
        }else if(widget.title=="忘记密码"){
          Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context)=>ResetPassWord(phone: widget.phone,code:code,outer: widget.outer,)));
        }
      }else{
        ToastUtil.showShortClearToast(resMap['verify']['desc']);
        setState(() {
          code="";
          _codeController.text="";
        });
      }
    }
  }
}