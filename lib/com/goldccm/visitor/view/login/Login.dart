import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/JsonResult.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/util/BadgeUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/Md5Util.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/SharedPreferenceUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/UMPushUtils.dart';
import 'package:visitor/home.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'GestureLogin.dart';
import 'Regisit.dart';

final Color _availableStyle = Colors.blue;

/// 墨水瓶（`InkWell`）不可用时使用的样式。
final Color _unavailableStyle = Colors.grey;

final TextStyle _labelStyle =
    new TextStyle(fontSize: 15.0, color: Colors.blue, fontFamily: '楷体_GB2312');

class Login extends StatefulWidget {
  final int countdown;

  /// 用户点击时的回调函数。
  final Function onTapCallback;

  /// 是否可以获取验证码，默认为`false`。
  final bool available;

  Login({
    this.countdown: 60,
    this.onTapCallback,
    this.available: false,
  });

  @override
  State<Login> createState() => new LoginState();
}

class LoginState extends State<Login> {
  int _deviceType = 1;
  int _loginType = 1;
  final int _loginPass = 1;
  final int _loginCode = 2;
  bool _codeBtnflag = true;
  Timer _timer;

  /// 当前倒计时的秒数。
  int _seconds;

  /// 当前墨水瓶（`InkWell`）的字体样式。
  Color colorStyle = _availableStyle;

  /// 当前墨水瓶（`InkWell`）的文本。
  String _verifyStr = '获取验证码';

  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _checkCodeController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid){
      _deviceType=1;
    }
    if(Platform.isIOS){
      _deviceType=2;
    }
    _seconds = widget.countdown;
  }

  /// 启动倒计时的计时器。
  void _startTimer() {
    // 计时器（`Timer`）组件的定期（`periodic`）构造函数，创建一个新的重复计时器。
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        _cancelTimer();
        _seconds = widget.countdown;
        colorStyle = _availableStyle;
        _codeBtnflag = true;
        setState(() {});
        return;
      }
      _seconds--;
      _verifyStr = '已发送$_seconds' + 's';
      colorStyle = _unavailableStyle;
      _codeBtnflag = false;
      setState(() {});
      if (_seconds == 0) {
        _verifyStr = '重新发送';
      }
    });
  }

  /// 取消倒计时的计时器。
  void _cancelTimer() {
    // 计时器（`Timer`）组件的取消（`cancel`）方法，取消计时器。
    _timer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _buttonLogin;
    return WillPopScope(
      child: Scaffold(
        //color: Colors.white,
          body: new SingleChildScrollView(
              child: new ConstrainedBox(
                  constraints: new BoxConstraints(
                    minHeight: 120.0,
                  ),
                  child: new Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: new Column(children: <Widget>[
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: GestureDetector(
                                  onTap: _regisit, //写入方法名称就可以了，但是是无参的
                                  child: new Text('注册', style: _labelStyle)),
                            ),
                          ]),
                      new Padding(
                        padding: const EdgeInsets.only(top: 70),
                        child: new Image.asset("assets/icons/ic_launcher.png"),
                      ),
                      new Padding(
                          padding: const EdgeInsets.only(
                              top: 30.0, left: 20.0, right: 20.0),
                          child: new ConstrainedBox(
                            constraints:
                            BoxConstraints(maxHeight:MediaQuery.of(context).size.height/10, maxWidth: 400),
                            child: new TextField(
                              autocorrect: true,
                              keyboardType: TextInputType.number,
                              maxLines: 1,
                              maxLength: 11,
                              maxLengthEnforced: true,
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              controller: _userNameController,
                              style: _labelStyle,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(10)
                                      .copyWith(top: 20.0, bottom: 10.0),
                                  prefixIcon: Icon(Icons.perm_identity),
                                  hintText: '请输入用户名',
                                  fillColor: Colors.black12,
                                  filled: true),
                              autofocus: true,
                            ),
                          )),
                      new Padding(
                          padding: const EdgeInsets.only(
                              top: 5.0, left: 20.0, right: 20.0),
                          child: new ConstrainedBox(
                              constraints:
                              BoxConstraints(maxHeight:MediaQuery.of(context).size.height/10, maxWidth: 400),
                              child: _loginType == _loginPass
                                  ? new TextField(
                                maxLines: 1,
                                style: _labelStyle,
                                keyboardType: TextInputType.text,
                                controller: _passwordController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(10)
                                        .copyWith(top: 15.0, bottom: 10.0),
                                    prefixIcon: Icon(Icons.lock),
                                    hintText: '请输入密码',
                                    fillColor: Colors.black12,
                                    filled: true),
                                obscureText: true,
                              )
                                  : new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 2,
                                    child: new TextField(
                                      style: _labelStyle,
                                      keyboardType: TextInputType.number,
                                      controller: _checkCodeController,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding:
                                          EdgeInsets.all(10.0).copyWith(
                                              top: 12.0, bottom: 12.0),
                                          prefixIcon: Icon(Icons.lock),
                                          hintText: '请输入验证码',
                                          hintStyle: new TextStyle(
                                            fontFamily: '楷体_GB2312',
                                          ),
                                          fillColor: Colors.black12,
                                          filled: true),
                                      obscureText: true,
                                    ),
                                  ),
                                  new Expanded(
                                      flex: 1,
                                      child: new Padding(
                                        padding:
                                        EdgeInsets.only(left: 10.0),
                                        child: new RaisedButton(
                                          onPressed: () async {
                                            if (_codeBtnflag) {
                                              bool res =
                                              await getCheckCode();
                                              if (res == true) {
                                                _startTimer();
                                              } else {
                                                return null;
                                              }
                                            } else {
                                              return null;
                                            }
                                          },
                                          //通过控制 Text 的边距来控制控件的高度
                                          child: new Padding(
                                            padding:
                                            new EdgeInsets.fromLTRB(
                                                0.0, 12.0, 0.0, 12.0),
                                            child: new Text(
                                              _verifyStr,
                                              style: new TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontFamily: '楷体_GB2312',
                                              ),
                                            ),
                                          ),
                                          color: colorStyle,
                                        ),
                                      )),
                                ],
                              ))),
                      new Padding(
                        padding: new EdgeInsets.only(
                            top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
                        child: new Row(
                          children: <Widget>[
                            new Expanded(
                              child: new RaisedButton(
                                onPressed: _loginAction,
                                /*() {
                    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context){
                      return new MyHomeApp();
                    }));
                  },*/
                                //通过控制 Text 的边距来控制控件的高度
                                child: new Padding(
                                  padding: new EdgeInsets.fromLTRB(
                                      0.0, 15.0, 0.0, 15.0),
                                  child: new Text(
                                    "登录",
                                    style: new TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: '楷体_GB2312',
                                    ),
                                  ),
                                ),
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            new GestureDetector(
                              onTap: () {},
                              child: new Text(
                                '忘记密码',
                                style: _labelStyle,
                              ),
                            )
                          ],
                        ),
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              new Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: _loginType == _loginPass
                                    ? new GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _loginType = _loginCode;
                                    });
                                  },
                                  child: new Text(
                                    '短信登录',
                                    style: _labelStyle,
                                  ),
                                )
                                    : new GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _loginType = _loginPass;
                                    });
                                  },
                                  child: new Text(
                                    '密码登录',
                                    style: _labelStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: new GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, new MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return new GestureLogin();
                                        }));
                                  },
                                  child: new Text(
                                    '手势密码',
                                    style: _labelStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ]),
                  )))),
      onWillPop: (){

      },
    );
  }

  void _regisit() {
    setState(() {
      Navigator.push(context,
          new MaterialPageRoute(builder: (BuildContext context) {
        return new Regisit();
      }));
    });
  }

  // 获取验证码

  Future<bool> getCheckCode() async {
    bool _userNameCheck = checkLoignUser();
    if (_userNameCheck) {
      String url = Constant.sendCodeUrl +
          "/" +
          _userNameController.text.toString() +
          "/1";
      var data = await Http().get(url, queryParameters: {
        "phone": _userNameController.text.toString(),
        "type": "1"
      });
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

  /**
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

  Future _loginAction() async {
    String deviceToken=await UMPush.getToken();
    //密码登录
    bool userNameCheck = checkLoignUser();
    String _passNum;
    String _codeNum;
    var user=Provider.of<UserModel>(context);
    var data;
    if (userNameCheck && _loginType == _loginPass) {
      bool passCheck = checkPass();
      if (passCheck) {
           _passNum = Md5Util().encryptByMD5ByHex(_passwordController.text.toString());
           data = await Http.instance.post(Constant.serverUrl+Constant.loginUrl, queryParameters: {
          "phone": _userNameController.text.toString(),
          "style": "1",
          "sysPwd": _passNum,
             "deviceToken":deviceToken,
             "deviceType":_deviceType,
        });
      }
    } else if (_loginType == _loginCode) {
      //验证码登录
      if (checkCode()) {
        _codeNum = _checkCodeController.text.toString();
        data = await Http.instance.post(Constant.serverUrl+Constant.loginUrl, queryParameters: {
          "phone": _userNameController.text.toString(),
          "style": "1",
          "code": _codeNum,
          "deviceToken":deviceToken,
          "deviceType":_deviceType,
        });
      }
    }

    if (data != null&&data!="") {
      JsonResult result = JsonResult.fromJson(data);
      if (result.sign == 'success') {
        var userMap = result.data['user'];
        print('返回用户信息：$userMap');
        UserInfo userInfo = UserInfo.fromJson(userMap);
        DataUtils.saveLoginInfo(userMap);
        DataUtils.saveUserInfo(userMap);
        SharedPreferenceUtil.saveUser(userInfo);
        user.init(userInfo);
        LocalStorage.save("userInfo",userInfo);
        Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => new MyHomeApp(),), (Route route) => route == null);
        return true;
      } else {
        Fluttertoast.showToast(msg: result.desc);
        return false;
      }
    }else{
      ToastUtil.showShortClearToast("账号异常");
      return false;
    }

  }




}
