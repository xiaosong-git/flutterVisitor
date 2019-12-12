import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gesture_password/gesture_password.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/Md5Util.dart';
import 'package:visitor/com/goldccm/visitor/util/SharedPreferenceUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/NPushUtils.dart';
import 'package:visitor/home.dart';

/*
 * 手势登录
 */
class GestureLogin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new GestureLoginState();
  }
}

class GestureLoginState extends State<GestureLogin> {
  @override
  void initState() {
    super.initState();
  }

//  GlobalKey<GesturePasswordState> miniGesturePassword =
//      new GlobalKey<GesturePasswordState>();
  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.lightBlue,
          leading: IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              }),
          centerTitle: true,
          title: new Text(
            "手势密码登录",
            textAlign: TextAlign.center,
            style: new TextStyle(
              fontSize: 18.0,
              color: Colors.white,
            ),
            textScaleFactor: 1.0,
          ),
        ),
        body: new Column(children: <Widget>[
          new Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Image.asset(
                  "assets/icons/手势密码用户@2x.png",
                  scale: 1.7,
                ),
              ],
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Text(""),
              ],
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: new Center(
                child: new Container(
              //    color: Colors.red,
              margin: const EdgeInsets.only(top: 10.0),
              child: new GesturePassword(
                //width: 200.0,
                attribute: ItemAttribute.normalAttribute,
                successCallback: (s) {
                  print("successCallback$s");
                  verifyGesturePwd(s);
                  scaffoldState.currentState?.showSnackBar(
                      new SnackBar(content: new Text('successCallback:$s')));
                },
                failCallback: () {
                  print('failCallback');
                  scaffoldState.currentState?.showSnackBar(
                      new SnackBar(content: new Text('failCallback')));
                },
                selectedCallback: (str) {
                  print("selectedCallback$str");
                  scaffoldState.currentState
                      ?.showSnackBar(new SnackBar(content: new Text(str)));
                },
              ),
            )),
          )
        ]));
  }

  getPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.getString("PHONE");
    print(phone);
    return phone;
  }

  verifyGesturePwd(String s) async {
    String phone = await getPhone();
    String url = Constant.serverUrl + Constant.loginUrl;
    String _passNum = Md5Util().encryptByMD5ByHex(s);
    var res = await Http().post(url, queryParameters: {
      "phone": phone,
      "style": "2",
      "sysPwd": _passNum,
      "deviceToken": await NPush().getClientId(),
      "deviceType": Platform.isAndroid ? 1 : Platform.isIOS ? 2 : 3,
    });
    if (res != null) {
      Map result = jsonDecode(res);
      print('$result');
      if (result['verify']['sign'] == 'success') {
        var userMap = result['data']['user'];
        print('返回用户信息：$userMap');
        UserInfo userInfo = UserInfo.fromJson(userMap);
        DataUtils.saveLoginInfo(userMap);
        DataUtils.saveUserInfo(userMap);
        SharedPreferenceUtil.saveUser(userInfo);
        Provider.of<UserModel>(context).init(userInfo);
        LocalStorage.save("userInfo",userInfo);
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(
                builder: (BuildContext context) => new MyHomeApp()),
            (Route route) => route == null);
        ToastUtil.showShortToast('登录成功');
        return true;
      } else {
        ToastUtil.showShortToast(result['verify']['desc']);
        return false;
      }
    }
  }
}
