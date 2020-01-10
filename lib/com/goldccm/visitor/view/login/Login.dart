import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/JsonResult.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/RegExpUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/common/LoadingDialog.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/Md5Util.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/SharedPreferenceUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/NPushUtils.dart';
import 'package:visitor/com/goldccm/visitor/view/login/ForgetPassword.dart';
import 'package:visitor/com/goldccm/visitor/view/login/RouterLogin.dart';
import 'package:visitor/home.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'Register.dart';

/*
 * 登录
 * author:ody997<hwk@growingpine.com>
 * create_time:2019/11/28
 * countdown 计数器 60s
 * onTapCallback 回调函数
 * available 状态
 */

class Login extends StatefulWidget {
  final int countdown;
  final Function onTapCallback;
  final bool available;

  Login({
    this.countdown: 60,
    this.onTapCallback,
    this.available: false,
  });

  @override
  State<Login> createState() => new LoginState();
}

/*
 * _codeBtnflag 验证码控制状态
 * _verifyStr 验证码字符
 * _seconds 倒计时
 * _deviceType 1-安卓 2-IOS
 */
class LoginState extends State<Login> with SingleTickerProviderStateMixin{
  int _deviceType = 1;
  int _loginType = 1;
  final int _loginPass = 1;
  final int _loginCode = 2;
  bool _codeBtnflag = true;
  TabController _tabController;
  Timer _timer;
  int _seconds;
  Color msgColor = _availColor;
  static Color _availColor=Color(0xFF0073FE);
  static Color _unavailColor=Color(0xFFCFCFCF);
  String _verifyStr = '获取验证码';
  FocusNode _focusNode;
  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _checkCodeController = new TextEditingController();
  bool isPhoneEditing=true;
  bool isPwdEditing=false;
  bool isCompleted=false;
  bool isSeen=false;
  //tabBar控件和相应的监听事件
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2,vsync: this);
    _tabController.addListener(() {
      if(_tabController.indexIsChanging){
        switch(_tabController.index){
          case 0:
            setState(() {
              _loginType=1;
            });
            break;
          case 1:
            setState(() {
              _loginType=2;
            });
            break;
        }
      }
    });
    if (Platform.isAndroid) {
      _deviceType = 1;
    }
    if (Platform.isIOS) {
      _deviceType = 2;
    }
    _focusNode = FocusNode();
    _seconds = widget.countdown;
    initUserName();
  }

  initUserName() async {
    List userNameLists = await SharedPreferenceUtil.getUsers();
    setState(() {
      if (userNameLists.length > 0 && userNameLists[0].loginName != null) {
        _userNameController.text = userNameLists[0].loginName;
//        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        _cancelTimer();
        if(mounted){
          setState(() {
            _seconds = widget.countdown;
            msgColor = _availColor;
            _codeBtnflag = true;
          });
        }
        return;
      }
      if(mounted){
        setState(() {
          _seconds--;
          _verifyStr = '$_seconds' + 's后重新获取';
          msgColor = _unavailColor;
          _codeBtnflag = false;

          if (_seconds == 0) {
            _verifyStr = '重新发送';
          }
        });
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _tabController.dispose();
    _cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return WillPopScope(
      child: Scaffold(
         body: SingleChildScrollView(
           child: Container(
             width: ScreenUtil().setWidth(750),
             height: ScreenUtil().setHeight(1334),
             color:  Color(0xFFFFFFFF),
             child: Column(
               children: <Widget>[
                 Container(
                   height: ScreenUtil().setHeight(356-88)+MediaQuery.of(context).padding.top,
                   width: ScreenUtil().setWidth(750),
                   child: Container(
                     padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                     child: Image(image: AssetImage("assets/images/login_logo.png"),width: ScreenUtil().setWidth(180),height: ScreenUtil().setHeight(180),),
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/login_background.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                   ),
                 ),
                 Container(
                     height: ScreenUtil().setHeight(60),
//              width: ScreenUtil().setWidth(454),
                     padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(112), 0, ScreenUtil().setWidth(112), 0),
                     margin: EdgeInsets.only(top: ScreenUtil().setHeight(110)),
                     child: Stack(
                       fit: StackFit.passthrough,
                       alignment: Alignment.bottomCenter,
                       children: <Widget>[
                         Container(
                           decoration: BoxDecoration(
                             border: Border(
                               bottom: BorderSide(color: Color(0xFFECECEC), width: ScreenUtil().setHeight(4)),
                             ),
                           ),
                         ),
                         TabBar(
                           indicatorColor: Color(0xFF0073FE),
                           controller: _tabController,
                           labelColor: Color(0xFF0073FE),
                           unselectedLabelColor: Color(0xFFE1E1E1),
                           indicatorWeight: ScreenUtil().setHeight(4),
                           tabs: <Widget>[
                             Container(
                               child:  Tab(
                                 child: Text('密码登录',style: TextStyle(fontSize: ScreenUtil().setSp(32),),),
                               ),
                             ),
                             Container(
                               child:  Tab(
                                 child: Text('验证码登录',style: TextStyle(fontSize: ScreenUtil().setSp(32),),),
                               ),
                             )
                           ],
                         ),
                       ],
                     )
                 ),
                 Container(
                   height: ScreenUtil().setHeight(154),
                   padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(112), ScreenUtil().setHeight(80), ScreenUtil().setWidth(112), 0),
                   child: Row(
                     children: <Widget>[
                       Expanded(
                         flex: 17,
                         child:Image(image: AssetImage('assets/images/login_account.png'),width: ScreenUtil().setWidth(67),height: ScreenUtil().setHeight(67),),
                       ),
                       Expanded(
                         flex: 109,
                         child:Container(
                             padding: EdgeInsets.only(left: ScreenUtil().setWidth(24),top:ScreenUtil().setHeight(35)),
                             child: TextField(
                               maxLines: 1,
                               textAlign: TextAlign.left,
                               textAlignVertical: TextAlignVertical.bottom,
                               keyboardType: TextInputType.phone,
                               controller: _userNameController,
                               inputFormatters: [LengthLimitingTextInputFormatter(11)],
                               maxLengthEnforced: true,
                               decoration: isPhoneEditing?InputDecoration(
                                   hintText: '请输入手机号',
                                   border: InputBorder.none,
                                   hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                                   suffix: GestureDetector(
                                     child: Container(
                                       child: Image(image: AssetImage('assets/images/login_cancel.png'),width: ScreenUtil().setWidth(40),height: ScreenUtil().setHeight(40),),
                                       padding: EdgeInsets.only(right: ScreenUtil().setWidth(18)),
                                     ),
                                     onTap: (){
                                       setState(() {
                                         _userNameController.text="";
                                         isPhoneEditing=false;
                                       });
                                     },
                                   )
                               ):InputDecoration(
                                 border: InputBorder.none,
                                 hintText: '请输入手机号',
                                 hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                               ),
                               onChanged: (value){
                                 if(value!=null&&value.length>0){
                                   if(checkLoginStatus()){
                                     setState(() {
                                       isCompleted=true;
                                     });
                                   }else{
                                     setState(() {
                                       isCompleted=false;
                                     });
                                   }
                                   setState(() {
                                     isPhoneEditing=true;
                                   });
                                 }else{
                                   setState(() {
                                     isPhoneEditing=false;
                                   });
                                 }
                               },
                             ),
                             decoration:BoxDecoration(
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
                     ],
                   ),
                 ),
                 Offstage(
                   offstage: _loginType!=_loginPass,
                   child: Stack(
                     children: <Widget>[
                       Positioned(
                         child:   Container(
                           height: ScreenUtil().setHeight(108),
                           padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(112), ScreenUtil().setHeight(40), ScreenUtil().setWidth(112), 0),
                           child: Row(
                             children: <Widget>[
                               Expanded(
                                   flex: 17,
                                   child: Center(
                                     child:Image(image: AssetImage('assets/images/login_password.png'),width: ScreenUtil().setWidth(66),height: ScreenUtil().setHeight(66),),
                                   )
                               ),
                               Expanded(
                                 flex: 109,
                                 child: Container(
                                     padding: EdgeInsets.only(left: ScreenUtil().setWidth(24),top:ScreenUtil().setHeight(30)),
                                     child: TextField(
                                       maxLines: 1,
                                       textAlign: TextAlign.left,
                                       textAlignVertical: TextAlignVertical.bottom,
                                       maxLengthEnforced: true,
                                       controller: _passwordController,
                                       inputFormatters: [LengthLimitingTextInputFormatter(16)],
                                       obscureText: !isSeen,
                                       decoration: InputDecoration(
                                         border: InputBorder.none,
                                         hintText: '请输入密码',
                                         hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                                       ),
                                       onChanged: (value){
                                         if(value!=null&&value.length>0){
                                           if(checkLoginStatus()){
                                             setState(() {
                                               isCompleted=true;
                                             });
                                           }else{
                                             setState(() {
                                               isCompleted=false;
                                             });
                                           }
                                           setState(() {
                                             isPwdEditing=true;
                                           });
                                         }else{
                                           setState(() {
                                             isPwdEditing=false;
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
                                     )
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                       Positioned(
                         right: ScreenUtil().setWidth(180),
                         top: ScreenUtil().setHeight(50),
                         child: GestureDetector(
                           child: isPwdEditing?Container(
                             child: Image(image: AssetImage('assets/images/login_cancel.png'),width: ScreenUtil().setWidth(40),height: ScreenUtil().setHeight(40),),
                           ):Container(),
                           onTap: (){
                             setState(() {
                               _passwordController.text="";
                               isPwdEditing=false;
                             });
                           },
                         ),
                       ),
                       Positioned(
                         right: ScreenUtil().setWidth(120),
                         top: ScreenUtil().setHeight(50),
                         child: GestureDetector(
                           child: isPwdEditing?Container(
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
                 ),
                 Offstage(
                   offstage: _loginType!=_loginCode,
                   child: Container(
                     height: ScreenUtil().setHeight(108),
                     padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(112), ScreenUtil().setHeight(40), ScreenUtil().setWidth(112), 0),
                     child: Row(
                       children: <Widget>[
                         Expanded(
                             flex: 17,
                             child: Center(
                               child:Image(image: AssetImage('assets/images/login_msgcode.png'),width: ScreenUtil().setWidth(66),height: ScreenUtil().setHeight(66),),
                             )
                         ),
                         Expanded(
                           flex: 109,
                           child: Stack(
                             children: <Widget>[
                               Positioned(
                                 child:  Container(
                                     padding: EdgeInsets.only(left: ScreenUtil().setWidth(24),top:ScreenUtil().setHeight(30)),
                                     child: TextField(
                                       maxLines: 1,
                                       textAlign: TextAlign.left,
                                       textAlignVertical: TextAlignVertical.bottom,
                                       maxLengthEnforced: true,
                                       controller: _checkCodeController,
                                       inputFormatters: [LengthLimitingTextInputFormatter(6)],
                                       decoration: InputDecoration(
                                         border: InputBorder.none,
                                         hintText: '请输入验证码',
                                         hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                                       ),
                                       onChanged: (value){
                                         if(value!=null&&value.length>0){
                                           if(checkLoginStatus()){
                                             setState(() {
                                               isCompleted=true;
                                             });
                                           }else{
                                             setState(() {
                                               isCompleted=false;
                                             });
                                           }
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
                                     )
                                 ),
                               ),
                               Positioned(
                                 right: ScreenUtil().setWidth(0),
                                 bottom: ScreenUtil().setHeight(-16),
                                 child: FlatButton(
                                   child: Text(_verifyStr,style: TextStyle(color: msgColor,fontSize: ScreenUtil().setSp(24)),),
                                   onPressed: () async {
                                     if(_codeBtnflag){
                                       if(RegExpUtil().verifyPhone(_userNameController.text)){
                                         _codeBtnflag = false;
                                         _startTimer();
                                         bool res = await getCheckCode();
                                         if(res!=true){
                                           _seconds=0;
                                         }
                                       }else{
                                         ToastUtil.showShortClearToast("电话号码不对");
                                       }
                                     }
                                   },
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
                 Container(
                   height: ScreenUtil().setHeight(212),
                   padding: EdgeInsets.only(top:ScreenUtil().setHeight(110),left: ScreenUtil().setWidth(112),right:ScreenUtil().setWidth(112)),
                   child: SizedBox(
                     width: ScreenUtil().setWidth(520),
                     height: ScreenUtil().setHeight(102),
                     child: RaisedButton(
                       shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(5.0)),
                       child: Text('登录',style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFFFFFFFF)),textAlign: TextAlign.center,),
                       onPressed: (){
                         if(isCompleted){
                           LoadingDialog().show(context, "登陆中");
                           _loginAction().then((value){
                             Navigator.pop(context);
                             if(value){
                               Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => new MyHomeApp(),), (Route route) => route == null);
                             }
                           });
                         }else{
                           if(_loginType==_loginPass){
                             ToastUtil.showShortClearToast('用户名或密码不正确');
                           }else{
                             ToastUtil.showShortClearToast("验证码不正确");
                           }
                         }
                       },
                       color: isCompleted?Color(0xFF0073FE):Color(0xFF79B6FF),
                     ),
                   ),
                 ),
                 Container(
                   width: ScreenUtil().setWidth(750),
                   height: ScreenUtil().setHeight(40),
                   margin: EdgeInsets.only(top:ScreenUtil().setHeight(46)),
                   padding: EdgeInsets.only(left: ScreenUtil().setWidth(225)),
                   child: Row(
                     children: <Widget>[
                       Container(
                         width:ScreenUtil().setWidth(120),
                         height:ScreenUtil().setHeight(40),
                         alignment: Alignment.center,
                         child: GestureDetector(
                           child: Text('注册账号',style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color(0xFFA8A8A8)),),
                           onTap: _regisit,
                         ),

                       ),
                       Container(
                         width: ScreenUtil().setWidth(52),
                         height:ScreenUtil().setHeight(40),
                         alignment: Alignment.center,
                         child:Text('|',style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color(0xFFA8A8A8)),),
                         padding: EdgeInsets.only(left: ScreenUtil().setWidth(25),right:ScreenUtil().setWidth(25)),
                       ),
                       Container(
                         width:ScreenUtil().setWidth(120),
                         height:ScreenUtil().setHeight(40),
                         alignment: Alignment.center,
                         child: GestureDetector(
                           child: Text('忘记密码',style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color(0xFFA8A8A8)),),
                           onTap: _forget,
                         ),
                       ),
                     ],
                   )
                 ),
                 Container(
                   width: ScreenUtil().setWidth(750),
                   height: ScreenUtil().setHeight(40),
                   margin: EdgeInsets.only(top: ScreenUtil().setHeight(186)),
                   padding: EdgeInsets.only(left: ScreenUtil().setWidth(248*2)),
                   child: InkWell(
                     child: Container(
                       width: ScreenUtil().setWidth(200),
                       height: ScreenUtil().setHeight(40),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.start,
                         children: <Widget>[
                           Text('专属用户登录',style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color(0xFF0073FE)),),
                           Image(image: AssetImage('assets/images/login_next.png'),width: ScreenUtil().setWidth(30),height: ScreenUtil().setHeight(30),),
                         ],
                       ),
                     ),
                     onTap:_router,
                   ),
                 ),
               ],
             ),
           ),
         ),
      ),
      onWillPop: () {
        return Future.value(false);
      },
    );
  }

  void _regisit() {
    setState(() {
      Navigator.push(context,
          new MaterialPageRoute(builder: (BuildContext context) {
        return new RegisterPage();
      }));
    });
  }
  void _router() {
    setState(() {
      Navigator.push(context,
          new MaterialPageRoute(builder: (BuildContext context) {
            return new RouterLogin();
          }));
    });
  }
  void _forget() {
    setState(() {
      Navigator.push(context,
          new MaterialPageRoute(builder: (BuildContext context) {
            return new ForgetPasswordPage();
          }));
    });
  }
  // 获取验证码

  Future<bool> getCheckCode() async {
    bool _userNameCheck = checkLoignUser();
    if (_userNameCheck) {
      String url = Constant.serverUrl+Constant.sendCodeUrl +
          "/" +
          _userNameController.text.toString() +
          "/1";
      var data = await Http().get(url,
          queryParameters: {
            "phone": _userNameController.text.toString(),
            "type": "1"
          },
          userCall: true);
      if (data != null) {
        JsonResult result = JsonResult.fromJson(data);
        if (result.sign == 'success') {
          return true;
        } else {
          ToastUtil.showShortClearToast(result.desc);
          return false;
        }
      }
    } else {
      return _userNameCheck;
    }
  }
  /*
   * 检查登录按钮状态
   */
  bool checkLoginStatus(){
    String loginname = _userNameController.text.toString();
    String password= _passwordController.text.toString();
    String checkcode= _checkCodeController.text.toString();
    if(RegExpUtil().verifyPhone(loginname)&&RegExpUtil().verifyPassWord(password)&&_loginType==_loginPass){
      return true;
    }
    if(RegExpUtil().verifyPhone(loginname)&&RegExpUtil().verifyCode(checkcode)&&_loginType==_loginCode){
      return true;
    }
    return false;
  }
  /*
  *  用户名校验
   */
  bool checkLoignUser() {
    String _loginName = _userNameController.text.toString();
    bool checkResult = true;
    if (_loginName == null || _loginName == "") {
      ToastUtil.showShortClearToast('手机号不能为空');
      checkResult = false;
    } else if (_loginName != '' && _loginName.length != 11) {
      ToastUtil.showShortClearToast('手机号长度不正确');
      checkResult = false;
    } else {
      checkResult = true;
    }
    return checkResult;
  }

  // 密码校验
  bool checkPass() {
    String _pass = _passwordController.text.toString();
    bool checkResult = true;
    if (_pass == null || _pass == "") {
      ToastUtil.showShortClearToast('密码不能为空');
      checkResult = false;
    } else if (_pass != '' && _pass.length < 6 && _pass.length >= 32) {
      ToastUtil.showShortClearToast('密码长度不能小于6位大于32位');
      checkResult = false;
    } else {
      checkResult = true;
    }
    return checkResult;
  }

  /*
   * 手机验证码校验
   */
  bool checkCode() {
    String _checkCode = _checkCodeController.text.toString();
    bool checkResult = true;
    if (_checkCode == null || _checkCode == "") {
      ToastUtil.showShortClearToast('验证码不能为空');
      checkResult = false;
    } else if (_checkCode != '' && _checkCode.length != 6) {
      ToastUtil.showShortClearToast('验证码必须为6位数字');
      checkResult = false;
    } else {
      checkResult = true;
    }
    return checkResult;
  }

  /*
   * _loginPass 密码登录
   * _loginCode 验证码登录
   */
  Future _loginAction() async {
    bool userNameCheck = checkLoignUser();
    String _passNum;
    String _codeNum;
    var data;
    if (userNameCheck && _loginType == _loginPass) {
      bool passCheck = checkPass();
      if (passCheck) {
        _passNum =
            Md5Util().encryptByMD5ByHex(_passwordController.text.toString());
        data = await Http().post(Constant.serverUrl+Constant.loginUrl,
            queryParameters: {
              "phone": _userNameController.text.toString(),
              "style": "1",
              "sysPwd": _passNum,
              "deviceToken": NPush.clientId ?? "",
              "deviceType": _deviceType,
            },
            userCall: true);
      } else {
        return false;
      }
    } else if (_loginType == _loginCode) {
      //验证码登录
      if (checkCode()) {
        _codeNum = _checkCodeController.text.toString();
        data = await Http().post(
          Constant.serverUrl+Constant.loginUrl,
          queryParameters: {
            "phone": _userNameController.text.toString(),
            "style": "1",
            "code": _codeNum,
            "deviceToken": NPush.clientId ?? "",
            "deviceType": _deviceType,
          },
          userCall: true,
        );
      } else {
        return false;
      }
    }
    if (data == "isBlocking") {
      return false;
    }
    if (data != null && data != "") {
      JsonResult result = JsonResult.fromJson(data);
      if (result.sign == 'success') {
        var userMap = result.data['user'];
        print('返回用户信息：$userMap');
        UserInfo userInfo = UserInfo.fromJson(userMap);
        DataUtils.saveLoginInfo(userMap);
        DataUtils.saveUserInfo(userMap);
        SharedPreferenceUtil.saveUser(userInfo);
        Provider.of<UserModel>(context).init(userInfo);
        LocalStorage.save("userInfo", userInfo);
        RouterUtil.apiServerUrl=Constant.serverUrl;
        RouterUtil.webSocketServerUrl=Constant.webSocketServerUrl;
        RouterUtil.uploadServerUrl=Constant.imageServerApiUrl;
        RouterUtil.imageServerUrl=Constant.imageServerUrl;
        RouterUtil.refresh();
        return true;
      } else {
        ToastUtil.showShortClearToast(result.desc);
        return false;
      }
    } else {
      ToastUtil.showShortClearToast("登录异常");
      return false;
    }
  }
}
