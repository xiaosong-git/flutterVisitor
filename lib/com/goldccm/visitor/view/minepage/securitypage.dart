import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:gesture_password/gesture_password.dart';
import 'package:gesture_password/mini_gesture_password.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/Md5Util.dart';
import 'package:visitor/com/goldccm/visitor/util/RegExpUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/common/LoadingDialog.dart';
import 'package:visitor/com/goldccm/visitor/view/minepage/minepage.dart';
import 'package:provider/provider.dart';



UserInfo _userInfo;


///修改手机
class ChangePhonePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ChangePhonePageState();
  }
}

class ChangePhonePageState extends State<ChangePhonePage> {
  var phoneController = new TextEditingController();
  var codeController = new TextEditingController();
  Timer _timer;
  int countDown = 60;
  bool isWork = true;
  void timeCountDown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countDown <= 0) {
        setState(() {
          isWork = true;
        });
      } else {
        setState(() {
          isWork = false;
          countDown = countDown - 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text('更换手机',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF373737)),),
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
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                color: Colors.white,
                height: 60,
                child: Row(
                  children: <Widget>[
                    Text('新手机号',
                        style: TextStyle(fontSize: Constant.normalFontSize),
                        textScaleFactor: 1.0),
                    Container(
                      width: 180,
                      padding: EdgeInsets.fromLTRB(30, 0.0, 0.0, 0.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '请输入手机号',
                          border: InputBorder.none,
                          hintStyle:
                              TextStyle(fontSize: Constant.normalFontSize),
                        ),
                        controller: phoneController,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 0.0,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                color: Colors.white,
                height: 60,
                child: Row(
                  children: <Widget>[
                    Text('验证码',
                        style: TextStyle(fontSize: Constant.normalFontSize),
                        textScaleFactor: 1.0),
                    Container(
                      width: 180,
                      padding: EdgeInsets.fromLTRB(45, 0.0, 0.0, 0.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '请输入验证码',
                          border: InputBorder.none,
                          hintStyle:
                              TextStyle(fontSize: Constant.normalFontSize),
                        ),
                        controller: codeController,
                      ),
                    ),
                    isWork == true
                        ? RaisedButton(
                            color: Colors.white,
                            textColor: Colors.blue,
                            elevation: 0,
                            child: Text('发送验证码',
                                style: TextStyle(
                                    fontSize: Constant.normalFontSize),
                                textScaleFactor: 1.0),
                            onPressed: () {
                              sendCode();
                            })
                        : RaisedButton(
                            color: Colors.white,
                            textColor: Colors.grey,
                            elevation: 0,
                            child: Text('${countDown}s',
                                style: TextStyle(
                                    fontSize: Constant.normalFontSize),
                                textScaleFactor: 1.0),
                            onPressed: () {},
                          )
                  ],
                ),
              ),
              new Container(
                padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
                child: new SizedBox(
                  width: 300.0,
                  height: 50.0,
                  child: new RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: new Text('提交',
                        style: TextStyle(fontSize: Constant.normalFontSize),
                        textScaleFactor: 1.0),
                    onPressed: () async {
                      updatePhone();
                    },
                  ),
                ),
              )
            ],
          ),
        ));
  }

  ///发送验证码
  sendCode() async {
    String url = Constant.sendCodeUrl;
    String phone = phoneController.text;
    String type = "1";
    if (phone == null || phone == "") {
      ToastUtil.showShortClearToast("电话号码不能为空");
    } else if (phone.length != 11) {
      ToastUtil.showShortClearToast("电话号码格式不正确");
    } else {
      url = url + "/" + phone + "/" + type;
      String res = await Http().get(url);
      Map map = jsonDecode(res);
      if (map['verify']['sign'] == "success") {
        ToastUtil.showShortClearToast("发送成功");
        setState(() {
          countDown = 60;
        });
        timeCountDown();
      } else {
        ToastUtil.showShortClearToast(map['verify']['desc']);
      }
    }
  }

  ///提交
  updatePhone() async {
    String url = Constant.updatePhoneUrl;
    String phone = phoneController.text;
    UserInfo userInfo=await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey();
    String code = codeController.text;
    if (phone == null || phone == "") {
      ToastUtil.showShortClearToast("电话号码不能为空");
    } else if (!RegExpUtil.instance.verifyPhone(phone)) {
      ToastUtil.showShortClearToast("电话号码格式不正确");
    } else if (code == null || code == "") {
      ToastUtil.showShortClearToast("验证码不能为空");
    } else {

      var res = await Http().post(url,
          queryParameters: {
            "token": userInfo.token,
            "userId": userInfo.id,
            "factor": CommonUtil.getCurrentTime(),
            "threshold": threshold,
            "requestVer": await CommonUtil.getAppVersion(),
            "phone": phone,
            "code": code,
          },
          userCall: true);
      if (res != null) {
        Map map = jsonDecode(res);
        if (map['verify']['sign'] == "success") {
          ToastUtil.showShortClearToast('手机更换成功');
          userInfo.phone = phone;
          DataUtils.updateUserInfo(userInfo);
          FocusScope.of(context).requestFocus(FocusNode());
          Navigator.pop(context);
        } else {
          ToastUtil.showShortClearToast(map['verify']['desc']);
        }
      }
    }
  }
}

//更新密码
class ChangePwdPage extends StatefulWidget {
  ChangePwdPage({Key key, this.userInfo}) : super(key: key);
  final UserInfo userInfo;
  @override
  State<StatefulWidget> createState() {
    return ChangePwdPageState();
  }
}

class ChangePwdPageState extends State<ChangePwdPage> {
  var _phone;
  final _formKey = GlobalKey<FormState>();
  String _oldPassword;
  String _newPassword;
  String _confirmPassword;
  @override
  void initState() {
    super.initState();
    _phone = widget.userInfo.phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('更换登录密码', textScaleFactor: 1.0),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.color,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: SingleChildScrollView(
          child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(30),
                child: Container(
                  height: 20,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('为你的账号',
                          style: TextStyle(fontSize: 14.0),
                          textScaleFactor: 1.0),
                      _phone != null
                          ? Text(
                              _phone,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 14.0),
                              textScaleFactor: 1.0,
                            )
                          : Text(
                              "",
                              textScaleFactor: 1.0,
                            ),
                      Text('设定新的登录密码',
                          style: TextStyle(fontSize: 14.0),
                          textScaleFactor: 1.0),
                    ],
                  ),
                )),
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              color: Colors.white,
              height: 60,
              child: Row(
                children: <Widget>[
                  Text('旧密码',
                      style: TextStyle(
                          fontSize: Constant.normalFontSize,
                          fontWeight: FontWeight.w600),
                      textScaleFactor: 1.0),
                  Container(
                    width: 180,
                    padding: EdgeInsets.fromLTRB(45, 0.0, 0.0, 0.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: '请输入旧密码',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: Constant.normalFontSize,
                        ),
                      ),
                      onSaved: (value) {
                        _oldPassword = value;
                      },
                      keyboardType: TextInputType.text,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 0.0,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              color: Colors.white,
              height: 60,
              child: Row(
                children: <Widget>[
                  Text(
                    '新密码',
                    style: TextStyle(
                        fontSize: Constant.normalFontSize,
                        fontWeight: FontWeight.w600),
                    textScaleFactor: 1.0,
                  ),
                  Container(
                    width: 180,
                    padding: EdgeInsets.fromLTRB(45, 0.0, 0.0, 0.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: '请输入8至16位由字母数字组合',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: Constant.normalFontSize),
                      ),
                      onSaved: (value) {
                        _newPassword = value;
                      },
                      keyboardType: TextInputType.text,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 0.0,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              color: Colors.white,
              height: 60,
              child: Row(
                children: <Widget>[
                  Text('确认密码',
                      style: TextStyle(
                          fontSize: Constant.normalFontSize,
                          fontWeight: FontWeight.w600),
                      textScaleFactor: 1.0),
                  Container(
                    width: 180,
                    padding: EdgeInsets.fromLTRB(30, 0.0, 0.0, 0.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: '请确认新密码',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: Constant.normalFontSize),
                      ),
                      onSaved: (value) {
                        _confirmPassword = value;
                      },
                      keyboardType: TextInputType.text,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ),
            new Container(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: new SizedBox(
                width: 300.0,
                height: 50.0,
                child: new RaisedButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: new Text(
                    '提交',
                    style: TextStyle(
                      fontSize: Constant.normalFontSize,
                    ),
                    textScaleFactor: 1.0,
                  ),
                  onPressed: () async {
                      _formKey.currentState.save();
                      _updatePwd();
                  },
                ),
              ),
            )
          ],
        ),
      )),
    );
  }

  _updatePwd() async {
    if(_oldPassword==""&&_oldPassword==null){
      ToastUtil.showShortToast("旧密码不正确");
      return;
    }
    if(!RegExpUtil().verifyPassWord(_newPassword)){
      ToastUtil.showShortToast("新密码不符合格式");
      return;
    }
    if(_newPassword!=_confirmPassword){
      ToastUtil.showShortToast("两次密码不一致");
      return;
    }
    String url =  Constant.updatePwdUrl;
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url,
        queryParameters: {
          "userId": _userInfo.id,
          "token": _userInfo.token,
          "threshold": threshold,
          "factor": CommonUtil.getCurrentTime(),
          "newPassword": Md5Util().encryptByMD5ByHex(_newPassword),
          "oldPassword": Md5Util().encryptByMD5ByHex(_oldPassword),
        },
        userCall: true);
    if (res != null) {
      Map map = jsonDecode(res);
      if (map['verify']['sign'] == 'success') {
        ToastUtil.showShortClearToast(map['verify']['desc']);
        Navigator.pop(context);
      } else {
        ToastUtil.showShortClearToast(map['verify']['desc']);
        _formKey.currentState.reset();
      }
    }
  }
}

///手势密码
class ChangeGesturePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ChangeGesturePageState();
  }
}

bool _value = false;

class ChangeGesturePageState extends State<ChangeGesturePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设定手势密码', textScaleFactor: 1.0),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.color,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('手势密码',
                style: TextStyle(fontSize: Constant.normalFontSize),
                textScaleFactor: 1.0),
            trailing: Switch(
              value: _value,
              onChanged: (newValue) {
                setState(() {
                  _value = newValue;
                  if (newValue == true) {
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (context) => GesturePage()));
                  }
                });
              },
              activeColor: Colors.blue,
            ),
          ),
          showUpdateGesture(context)
        ],
      ),
    );
  }
}

Widget showUpdateGesture(BuildContext context) {
  if (_value == true) {
    return ListTile(
      title: Text('修改手势密码',
          style: TextStyle(fontSize: Constant.normalFontSize),
          textScaleFactor: 1.0),
      onTap: () {
        Navigator.push(context,
            CupertinoPageRoute(builder: (context) => UpdateGesturePage()));
      },
    );
  } else {
    return ListTile();
  }
}

///更新手势密码
class UpdateGesturePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UpdateGesturePageState();
  }
}

class UpdateGesturePageState extends State<UpdateGesturePage> {
  var pastStr;
  var firstStr;
  var num = 0;
  var repeatStr;
  var _noticeStr = "请绘制解锁图案";
  var _color = Colors.blue;
  Timer _timer;
  int _countdownTime = 0;
  @override
  void initState() {
    super.initState();
    _noticeStr = '请绘制旧解锁图案';
  }

  void startCountdownTimer() {
    const oneSec = const Duration(seconds: 1);

    var callback = (timer) => {
          setState(() {
            if (_countdownTime < 1) {
              _timer.cancel();
              _noticeStr = "请绘制旧解锁图案";
              _color = Colors.blue;
            } else {
              _countdownTime = _countdownTime - 1;
            }
          })
        };

    _timer = Timer.periodic(oneSec, callback);
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
      _noticeStr = "请绘制旧解锁图案";
      _color = Colors.blue;
    }
  }

  GlobalKey<MiniGesturePasswordState> miniGesturePassword =
      new GlobalKey<MiniGesturePasswordState>();
  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('更新手势密码', textScaleFactor: 1.0),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.color,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Center(
              child: Image.asset(
                "assets/icons/user_gesture.png",
                scale: 1.7,
              ),
            ),
            padding: EdgeInsets.all(30),
          ),
          Center(
            child: Text(
              '$_noticeStr',
              style: TextStyle(color: _color, fontSize: 16),
              textScaleFactor: 1.0,
            ),
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                margin: EdgeInsets.only(top: 30.0),
                child: GesturePassword(
                  successCallback: (s) {
                    print("successCallback$s");
                    if (num == 0) {
                      num++;
                      pastStr = s;
                      setState(() {
                        _noticeStr = "请绘制新解锁图案";
                      });
                    } else if (num == 1) {
                      num++;
                      firstStr = s;
                      setState(() {
                        _noticeStr = "请重新绘制新解锁图案";
                      });
                    } else {
                      num = 0;
                      repeatStr = s;
                      if (firstStr == repeatStr) {
                        _updateGesPwd().then((value) {
                          Navigator.pop(context);
                        });
                      }
                      setState(() {
                        _countdownTime = 1;
                        _color = Colors.red;
                      });
                      startCountdownTimer();
                    }
                    scaffoldState.currentState?.showSnackBar(SnackBar(
                        content: Text(
                      'successCallback:$s',
                      textScaleFactor: 1.0,
                    )));
                    miniGesturePassword.currentState?.setSelected('');
                  },
                  failCallback: () {
                    print('failCallback');
                    if (_countdownTime == 0) {
                      setState(() {
                        _countdownTime = 1;
                        _noticeStr = "绘制失败，请重新绘制解锁图案";
                        _color = Colors.red;
                      });
                      startCountdownTimer();
                    }
                    scaffoldState.currentState?.showSnackBar(SnackBar(
                        content: Text(
                      'failCallback',
                      textScaleFactor: 1.0,
                    )));
                    miniGesturePassword.currentState?.setSelected('');
                  },
                  selectedCallback: (str) {
                    miniGesturePassword.currentState?.setSelected(str);
                  },
                  attribute: ItemAttribute(
                      lineStrokeWidth: 2.0,
                      circleStrokeWidth: 2.0,
                      smallCircleR: 10.0,
                      bigCircleR: 30.0,
                      focusDistance: 25.0,
                      normalColor: const Color(0xFFBBDEFB),
                      selectedColor: const Color(0xFF1565C0)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future _updateGesPwd() async {
    LoadingDialog().show(context, '请等待');
    String url =  Constant.updateGesturePwdUrl;
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url,
        queryParameters: {
          "userId": _userInfo.id,
          "token": _userInfo.token,
          "threshold": threshold,
          "factor": CommonUtil.getCurrentTime(),
          "requestVer": await CommonUtil.getAppVersion(),
          "newPassword": Md5Util().encryptByMD5ByHex(repeatStr),
          "oldPassword": Md5Util().encryptByMD5ByHex(pastStr),
        },
        userCall: true);
    if (res != null) {
      Map map = jsonDecode(res);
      ToastUtil.showShortClearToast(map['verify']['desc']);
      Navigator.pop(context);
    }
  }
}

///设定手势密码
class GesturePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GesturePageState();
  }
}

class GesturePageState extends State<GesturePage> {
  var firstStr;
  var repeatStr;
  var _noticeStr = "请绘制解锁图案";
  var _color = Colors.black;
  Timer _timer;
  int _countdownTime = 0;
  void startCountdownTimer() {
    const oneSec = const Duration(seconds: 1);

    var callback = (timer) => {
          setState(() {
            if (_countdownTime < 1) {
              _timer.cancel();
              _noticeStr = "请绘制解锁图案";
              _color = Colors.black;
            } else {
              _countdownTime = _countdownTime - 1;
            }
          })
        };

    _timer = Timer.periodic(oneSec, callback);
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
      _noticeStr = "请绘制解锁图案";
      _color = Colors.black;
    }
  }

  GlobalKey<MiniGesturePasswordState> miniGesturePassword =
      new GlobalKey<MiniGesturePasswordState>();
  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设定手势密码', textScaleFactor: 1.0),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              _value = false;
              Navigator.pop(context);
            }),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Center(
              child: Image.asset(
                "assets/icons/user_gesture.png",
                scale: 1.7,
              ),
            ),
            padding: EdgeInsets.all(30),
          ),
          Center(
            child: Text(
              '$_noticeStr',
              style: TextStyle(color: _color, fontSize: 16),
              textScaleFactor: 1.0,
            ),
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                margin: EdgeInsets.only(top: 30.0),
                child: GesturePassword(
                  successCallback: (s) {
                    print("successCallback$s");
                    if (firstStr == null) {
                      firstStr = s;
                      setState(() {
                        _noticeStr = "请重复解锁图案";
                        _color = Colors.red;
                      });
                    } else {
                      repeatStr = s;
                      if (firstStr == repeatStr) {
                        _setGesPwd().then((value) {
                          Navigator.pop(context);
                        });
                      }
                      firstStr = null;
                      setState(() {
                        _countdownTime = 1;
                        _color = Colors.red;
                      });
                      startCountdownTimer();
                    }
                    scaffoldState.currentState?.showSnackBar(SnackBar(
                        content: Text(
                      'successCallback:$s',
                      textScaleFactor: 1.0,
                    )));
                    miniGesturePassword.currentState?.setSelected('');
                  },
                  failCallback: () {
                    print('failCallback');
                    if (_countdownTime == 0) {
                      setState(() {
                        _countdownTime = 1;
                        _color = Colors.red;
                      });
                      startCountdownTimer();
                    }
                    scaffoldState.currentState?.showSnackBar(SnackBar(
                        content: Text(
                      'failCallback',
                      textScaleFactor: 1.0,
                    )));
                    miniGesturePassword.currentState?.setSelected('');
                  },
                  selectedCallback: (str) {
                    miniGesturePassword.currentState?.setSelected(str);
                  },
                  attribute: ItemAttribute(
                      lineStrokeWidth: 2.0,
                      circleStrokeWidth: 2.0,
                      smallCircleR: 10.0,
                      bigCircleR: 30.0,
                      focusDistance: 25.0,
                      normalColor: const Color(0xFFBBDEFB),
                      selectedColor: const Color(0xFF1565C0)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future _setGesPwd() async {
    LoadingDialog().show(context, '请等待');
    String url = Constant.setGesturePwdUrl;
    String threshold = await CommonUtil.calWorkKey();
    String pwd = Md5Util().encryptByMD5ByHex(repeatStr);
    var res = await Http().post(url,
        queryParameters: {
          "token": _userInfo.token,
          "userId": _userInfo.id,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "gesturePwd": pwd,
        },
        userCall: true);
    if (res != null) {
      Map map = jsonDecode(res);
      Navigator.pop(context);
      ToastUtil.showShortClearToast(map['verify']['desc']);
      Navigator.pop(context);
      ToastUtil.showShortClearToast(map['verify']['desc']);
    }
  }
}
