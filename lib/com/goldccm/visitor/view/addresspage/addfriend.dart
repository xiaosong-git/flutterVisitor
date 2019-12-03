import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';

/*
 * 添加好友
 * author:ody997
 * email:hwk@growingpine.com
 * create_time:2019/10/23
 */
class AddFriendPage extends StatefulWidget{
  final UserInfo userInfo;
  AddFriendPage({Key key,this.userInfo}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return AddFriendPageState();
  }
}
class AddFriendPageState extends State<AddFriendPage>{
  UserInfo _userInfo;
  String _phone;
  String _name;
  var textController =  new TextEditingController();
  var formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _userInfo=widget.userInfo;
  }
  addFriend() async {
    String url = Constant.serverUrl+"userFriend/addFriendByPhoneAndUser";
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url, queryParameters: {
      "token": _userInfo.token,
      "factor":CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "userId":_userInfo.id,
      "phone":_phone,
      "realName":_name,
    },userCall: true);
    if(res !=null&&res!=""&&res!="isBlocking"){
      if(res is String){
        Map map = jsonDecode(res);
        if(map['verify']['desc']=="success"){
          ToastUtil.showShortClearToast(map['verify']['desc']);
          Navigator.pop(context);
          Navigator.pop(context);
        }else{
          ToastUtil.showShortClearToast(map['verify']['desc']);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
    }else{
      ToastUtil.showShortToast("请求失败");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加好友',style: TextStyle(fontSize: 17.0),textScaleFactor: 1.0),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.color,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: _addFriend(),
    );
  }
  Widget _addFriend(){
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            color: Colors.white,
            height: 60,
            child: Row(
              children: <Widget>[
                Text(
                  '姓名',
                  style: TextStyle(fontSize:  Constant.normalFontSize),textScaleFactor: 1.0,
                ),
                Container(
                  width: MediaQuery.of(context).size.width-65,
                  padding: EdgeInsets.fromLTRB(60, 0.0, 0.0, 0.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: '请输入好友姓名',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: Constant.normalFontSize),
                    ),
                    onSaved: (value){
                      _name=value;
                    },
                    validator: (value){
                      if(value.isEmpty){
                        return '请不要为空';
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            color: Colors.white,
            height: 60,
            child: Row(
              children: <Widget>[
                Text(
                  '手机号',
                  style: TextStyle(fontSize: Constant.normalFontSize),textScaleFactor: 1.0
                ),
                Container(
                  width: MediaQuery.of(context).size.width-80,
                  padding: EdgeInsets.fromLTRB(45, 0.0, 0.0, 0.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: '请输入他的手机号码',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize:  Constant.normalFontSize),
                    ),
                    onSaved: (value){
                      _phone=value;
                    },
                    validator: (value){
                      if(value.isEmpty){
                        return '请不要为空';
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          new Container(
            padding: EdgeInsets.fromLTRB(20, 100, 20, 0),
            child: new SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              child: new RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                color: Colors.blue,
                textColor: Colors.white,
                child: new Text(
                  '添加好友',
                  style: TextStyle(fontSize:  Constant.normalFontSize),textScaleFactor: 1.0
                ),
                onPressed: () async {
                  if(formKey.currentState.validate()){
                    formKey.currentState.save();
                    addFriend();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      )
    );
  }
}
