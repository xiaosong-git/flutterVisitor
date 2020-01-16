import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:city_pickers/city_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/JsonResult.dart';
import 'package:visitor/com/goldccm/visitor/model/RouterList.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/Md5Util.dart';
import 'package:visitor/com/goldccm/visitor/util/NPushUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/SharedPreferenceUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/common/LoadingDialog.dart';
import 'package:visitor/com/goldccm/visitor/view/login/selectAddress.dart';
import '../../../../../home.dart';

/*
 * 专属用户登录
 * create_time:2020/1/2
 */
class RouterLogin extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return RouterLoginState();
  }
}

class RouterLoginState extends State<RouterLogin> with SingleTickerProviderStateMixin {
  List<RouterList> routers= [];
  TabController _tabController;
  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _checkCodeController = new TextEditingController();
  TextEditingController _selectAddressController = new TextEditingController();
  TextEditingController _selectCompanyController = new TextEditingController();
  int _loginType = 1;
  bool _codeBtnflag = true;
  final int _loginPass = 1;
  final int _loginCode = 2;
  Timer _timer;
  Color msgColor = _availColor;
  static Color _availColor=Color(0xFF0073FE);
  static Color _unavailColor=Color(0xFFCFCFCF);
  String _selectAddress;
  int _seconds;
  String _verifyStr = '获取验证码';
  bool isPhoneEditing=false;
  bool isPwdEditing=false;
  bool isSeen=false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2,vsync: this);
    _tabController.addListener(() {
      if(_tabController.indexIsChanging){
        switch(_tabController.index){
          case 0:
            if(mounted){
              setState(() {
                _loginType=1;
              });
            }
            break;
          case 1:
            if(mounted){
              setState(() {
                _loginType=2;
              });
            }
            break;
        }
      }
    });
    initLoginData();
  }
  initLoginData() async {
    List userNameLists = await SharedPreferenceUtil.getUsers();
    RouterList routerList = await RouterUtil.getServerInfo();
    setState(() {
      if (userNameLists.length > 0 && userNameLists[0].loginName != null) {
        _userNameController.text = userNameLists[0].loginName;
//        FocusScope.of(context).requestFocus(_focusNode);
      }
      if(routerList.province!=null&&routerList.area!=null&&routerList.city!=null){
        _selectAddressController.text=routerList.province+"/"+routerList.city+"/"+routerList.area;
        if(routerList.routerName!=null){
          _selectCompanyController.text=routerList.routerName;
          RouterUtil.apiServerUrl="http://${routerList.ip}:${routerList.port}/visitor/";
          RouterUtil.webSocketServerUrl="ws://${routerList.ip}:${routerList.port}/visitor/";
          RouterUtil.uploadServerUrl="http://${routerList.ip}:${routerList.port}/goldccm-imgServer/goldccm/image/gainData";
          RouterUtil.imageServerUrl="http://${routerList.ip}:${routerList.imagePort}/imgserver/";
        }
      }
    });
  }
  @override
  void dispose() {
    _tabController.dispose();
    _selectCompanyController.dispose();
    _selectAddressController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Container(
          width: ScreenUtil().setWidth(750),
          height: ScreenUtil().setHeight(1334)-MediaQuery.of(context).padding.top,
          color:  Color(0xFFFFFFFF),
          child: Column(
            children: <Widget>[
              Container(
                height: ScreenUtil().setHeight(88),
                width: ScreenUtil().setWidth(750),
                margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
               child: Row(
                 children: <Widget>[
                   Container(
                       padding: EdgeInsets.only(right: ScreenUtil().setWidth(165),left: 0),
                       child: IconButton(
                           icon: Image(image: AssetImage("assets/images/login_back.png"),width: ScreenUtil().setWidth(36),height: ScreenUtil().setHeight(36),color: Color(0xFF0073FE),),
                           onPressed: () {
                             setState(() {
                               Navigator.pop(context);
                             });
                           }),
                   ),
                   Text('专属用户登录',style: TextStyle(color: Color(0xFF0073FE),fontSize: ScreenUtil().setSp(36),),),
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
                height: ScreenUtil().setHeight(228),
                alignment: Alignment.center,
                 child: Image(image: AssetImage("assets/images/login_logo.png"),width: ScreenUtil().setWidth(180),height: ScreenUtil().setHeight(180),),
                padding: EdgeInsets.fromLTRB( 0,ScreenUtil().setHeight(18),0,ScreenUtil().setHeight(30)),
              ),
              Container(
                  height: ScreenUtil().setHeight(60),
//              width: ScreenUtil().setWidth(454),
                  padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(112), 0, ScreenUtil().setWidth(112), 0),
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
              Stack(
                children: <Widget>[
                  Positioned(
                    child:    Container(
                      height: ScreenUtil().setHeight(84),
                      padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(112), 0, ScreenUtil().setWidth(112), 0),
                      margin: EdgeInsets.only(top:ScreenUtil().setHeight(54)),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 17,
                            child:Center(
                              child: Image(image: AssetImage('assets/images/login_account.png'),width: ScreenUtil().setWidth(67),height: ScreenUtil().setHeight(67),),
                            ),
                          ),
                          Expanded(
                            flex: 109,
                            child:Container(
                                padding: EdgeInsets.only(left: ScreenUtil().setWidth(24)),
                                child: TextField(
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  keyboardType: TextInputType.phone,
                                  controller: _userNameController,
                                  maxLengthEnforced: true,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '请输入手机号',
                                    hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                                  ),
                                  onChanged: (value){
                                    if(value!=null&&value.length>0){
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
                    right: ScreenUtil().setWidth(130),
                    top: ScreenUtil().setHeight(70),
                    child: GestureDetector(
                      child: isPhoneEditing?Container(
                        child: Image(image: AssetImage('assets/images/login_cancel.png'),width: ScreenUtil().setWidth(40),height: ScreenUtil().setHeight(40),),
                      ):Container(),
                      onTap: (){
                        setState(() {
                          _userNameController.text="";
                          isPhoneEditing=false;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Offstage(
                offstage: _loginType!=_loginPass,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      child:   Container(
                        height: ScreenUtil().setHeight(88),
                        padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(112),0 , ScreenUtil().setWidth(112), 0),
                        margin: EdgeInsets.only(top:ScreenUtil().setHeight(40)),
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
                                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(24)),
                                  child: TextField(
                                    maxLines: 1,
                                    textAlign: TextAlign.left,
                                    textAlignVertical: TextAlignVertical.bottom,
                                    maxLengthEnforced: true,
                                    controller: _passwordController,
                                    obscureText: !isSeen,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '请输入密码',
                                      hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                                    ),
                                    onChanged: (value){
                                      if(value!=null&&value.length>0){
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
                      top: ScreenUtil().setHeight(60),
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
                      top: ScreenUtil().setHeight(60),
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
                )
              ),
              Offstage(
                offstage: _loginType!=_loginCode,
                child:Container(
                  height: ScreenUtil().setHeight(88),
                  padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(112), 0, ScreenUtil().setWidth(112), 0),
                  margin: EdgeInsets.only(top:ScreenUtil().setHeight(40)),
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
                                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(24)),
                                  child: TextField(
                                    maxLines: 1,
                                    textAlign: TextAlign.left,
                                    textAlignVertical: TextAlignVertical.bottom,
                                    maxLengthEnforced: true,
                                    controller: _checkCodeController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '请输入验证码',
                                      hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                                    ),
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
                              bottom: ScreenUtil().setHeight(-5),
                              child: FlatButton(
                                child: Text(_verifyStr,style: TextStyle(color: msgColor,fontSize: ScreenUtil().setSp(24)),),
                                onPressed: () async {
                                  if(_codeBtnflag){
                                    _startTimer();
                                    bool res = await getCheckCode();
                                    if(res!=true){
                                      _seconds=0;
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
//                width: ScreenUtil().setWidth(456),
                height: ScreenUtil().setHeight(90),
                margin: EdgeInsets.only(top:ScreenUtil().setHeight(46),left: ScreenUtil().setWidth(112),right:ScreenUtil().setWidth(112)),
//                padding: EdgeInsets.only(left: ScreenUtil().setWidth(84),right:ScreenUtil().setWidth(26)),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFFECECEC),
                    width: ScreenUtil().setHeight(2),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Stack(
                  children: <Widget>[
                    TextField(
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      maxLengthEnforced: true,
                      maxLines: 1,
                      controller: _selectAddressController,
                      style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color(0xFF212121)),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '企业/单位所在地',
                        hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                      ),
                      readOnly: true,
                      onTap: () async {
                        Result result = await CityPickers.showFullPageCityPicker(context: context);
                        if(result!=null&&result.provinceName!=null){
                          setState(() {
                            routers.clear();
                            _selectAddressController.text=result.provinceName+"/"+result.cityName+"/"+result.areaName;
                            _selectCompanyController.text="";
                            getRouters();
                          });
                        }
//                        Navigator.push(context,MaterialPageRoute(builder: (context)=>SelectAddressPage()));
                      },
                    ),
                    Positioned(
                      top: ScreenUtil().setHeight(40),
                      right: ScreenUtil().setWidth(115),
                      child: Image(image: AssetImage('assets/images/login_triangle.png'),width: ScreenUtil().setWidth(24),height: ScreenUtil().setHeight(18),),
                    ),
                  ],
                ),
              ),
              Container(
//                width: ScreenUtil().setWidth(456),
                height: ScreenUtil().setHeight(90),
                margin: EdgeInsets.only(top:ScreenUtil().setHeight(36),left: ScreenUtil().setWidth(112),right:ScreenUtil().setWidth(112)),
//                padding: EdgeInsets.only(left: ScreenUtil().setWidth(100),right:ScreenUtil().setWidth(26)),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFFECECEC),
                    width: ScreenUtil().setHeight(2),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Stack(
                  children: <Widget>[
                    TextField(
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      maxLengthEnforced: true,
                      controller: _selectCompanyController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '企业/单位名称',
                        hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                      ),
                      readOnly: true,
                      onTap: (){
                        if(routers!=null){
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> RouterSelectPage(lists: routers,))).then((value){
                            if(value!=null){
                              setState(() {
                                _selectCompanyController.text=value.routerName;
                              });
                              RouterUtil.apiServerUrl="http://${value.ip}:${value.port}/visitor/";
                              RouterUtil.webSocketServerUrl="ws://${value.ip}:${value.port}/visitor/";
                              RouterUtil.uploadServerUrl="http://${value.ip}:${value.port}/goldccm-imgServer/goldccm/image/gainData";
                              RouterUtil.imageServerUrl="http://${value.ip}:${value.imagePort}/imgserver/";
                              RouterUtil.refresh();
                              RouterUtil.saveServerInfo(value);
                            }
                          });
                        }
                      },
                    ),
                    Positioned(
                      top: ScreenUtil().setHeight(40),
                      right: ScreenUtil().setWidth(130),
                      child: Image(image: AssetImage('assets/images/login_triangle.png'),width: ScreenUtil().setWidth(24),height: ScreenUtil().setHeight(18),),
                    ),
                  ],
                )
              ),
              Container(
                height: ScreenUtil().setHeight(154),
                padding: EdgeInsets.only(top:ScreenUtil().setHeight(64),left: ScreenUtil().setWidth(112),right:ScreenUtil().setWidth(112)),
                decoration: BoxDecoration(

                ),
                child: SizedBox(
                  width: ScreenUtil().setWidth(520),
                  height: ScreenUtil().setHeight(102),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Text('登录',style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFFFFFFFF)),textAlign: TextAlign.center,),
                    onPressed: (){
                      LoadingDialog().show(context, "登陆中");
                      _loginAction().then((value){
                        Navigator.pop(context);
                        if(value){
                          Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => new MyHomeApp(),), (Route route) => route == null);
                        }
                      });
                    },
                    color: Color(0xFF79B6FF),
                  ),
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(750),
                height: ScreenUtil().setHeight(40),
                margin: EdgeInsets.only(top:ScreenUtil().setHeight(46)),
                decoration: BoxDecoration(

                ),
                alignment: Alignment.center,
                child: GestureDetector(
                  child: Text('忘记密码',style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color(0xFFA8A8A8)),),
                  onTap: (){
                    ToastUtil.showShortClearToast("请联系所在企业修改");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // 获取验证码

  Future<bool> getCheckCode() async {
    bool _userNameCheck = checkLoignUser();
    if (_userNameCheck) {
      String url = Constant.sendCodeUrl +
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
          Fluttertoast.showToast(msg: result.desc);
          return false;
        }
      }
    } else {
      return _userNameCheck;
    }
  }
  /*
  *  用户名校验
   */
  bool checkLoignUser() {
    String _loginName = _userNameController.text.toString();
    bool checkResult = true;
    if (_loginName == null || _loginName == "") {
      ToastUtil.showShortToast('手机号不能为空');
      checkResult = false;
    } else if (_loginName != '' && _loginName.length != 11) {
      ToastUtil.showShortToast('手机号长度不正确');
      checkResult = false;
    } else {
      checkResult = true;
    }
    return checkResult;
  }
  // 开启计时器
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        _cancelTimer();
        _seconds =60;
        msgColor = _availColor;
        _codeBtnflag = true;
        setState(() {});
        return;
      }
      _seconds--;
      _verifyStr = '$_seconds' + 's后重新获取';
      msgColor = _unavailColor;
      _codeBtnflag = false;
      setState(() {});
      if (_seconds == 0) {
        _verifyStr = '重新发送';
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
  }
  Future<void> getRouters() async {
    if(_selectAddressController!=null){
      String url= Constant.serverUrl+"router/1/10";
      List addr = _selectAddressController.text.split("/");
      var response = await Http().post(url,queryParameters: {
        "province":addr[0],
        "city":addr[1],
        "area":addr[2],
      });
      if(response!=""&&response!=null){
        Map resMap = jsonDecode(response);
        for(var row in resMap['data']['rows']){
          RouterList list= RouterList.fromJson(row);
          routers.add(list);
        }
      }
    }
  }

  // 密码校验
  bool checkPass() {
    String _pass = _passwordController.text.toString();
    bool checkResult = true;
    if (_pass == null || _pass == "") {
      ToastUtil.showShortToast('密码不能为空');
      checkResult = false;
    } else if (_pass != '' && _pass.length < 6 && _pass.length >= 32) {
      ToastUtil.showShortToast('密码长度不能小于6位大于32位');
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
      ToastUtil.showShortToast('验证码不能为空');
      checkResult = false;
    } else if (_checkCode != '' && _checkCode.length != 6) {
      ToastUtil.showShortToast('验证码必须为6位数字');
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
        data = await Http().post(Constant.loginUrl,
            queryParameters: {
              "phone": _userNameController.text.toString(),
              "style": "1",
              "sysPwd": _passNum,
              "deviceToken": NPush.clientId ?? "",
              "deviceType": Platform.isAndroid?1:2,
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
          Constant.loginUrl,
          queryParameters: {
            "phone": _userNameController.text.toString(),
            "style": "1",
            "code": _codeNum,
            "deviceToken": NPush.clientId ?? "",
            "deviceType": Platform.isAndroid?1:2,
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
        return true;
      } else {
        ToastUtil.showShortToast(result.desc);
        return false;
      }
    } else {
      ToastUtil.showShortToast("登录异常");
      return false;
    }
  }
}
/*
 * 大楼选择页
 */
class RouterSelectPage extends StatefulWidget{
  final List<RouterList> lists;
  RouterSelectPage({Key key ,this.lists}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return RouterSelectPageState();
  }
}
class RouterSelectPageState extends State<RouterSelectPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('请选择'),
        ),
        body: ListView.builder(itemBuilder: (context,index){
          return ListTile(
            title: Text(widget.lists[index].routerName),
            onTap: (){
               Navigator.pop(context,widget.lists[index]);
            },
          );
        },itemCount: widget.lists.length,)
    );
  }
}