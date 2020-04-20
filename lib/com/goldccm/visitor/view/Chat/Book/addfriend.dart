import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/RegExpUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/Chat/Book/contacts.dart';
import 'package:visitor/com/goldccm/visitor/view/Chat/Book/searchDetail.dart';
import 'package:visitor/com/goldccm/visitor/view/Chat/Message/frienddetail.dart';

//
// 添加好友
// 通过手机号添加和通过通讯录添加
class AddFriendPage extends StatefulWidget{
  final UserInfo userInfo;
  AddFriendPage({Key key,this.userInfo}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return AddFriendPageState();
  }
}
class AddFriendPageState extends State<AddFriendPage>{
  bool isSeen=false;
  var textController =  new TextEditingController();
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加好友',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF373737)),),
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
      body: ListView(
        children: <Widget>[
          ListTile(
              title:Text('手机号查找'),
            leading: Image(
              image: AssetImage('assets/images/book_add_phone.png'),
            ),
            trailing:
            Image(
              width:20,
              height: 20,
              image: AssetImage('assets/images/mine_next.png'),
              fit: BoxFit.fill,
            ),
            onTap: (){
              Navigator.push(context,CupertinoPageRoute(builder: (context) => AddByPhone()));
            },
          ),
          ListTile(
              title:Text('手机联系人'),
            leading: Image(
              image: AssetImage('assets/images/book_add_contacts.png'),
            ),
            trailing:
            Image(
              width:20,
              height: 20,
              image: AssetImage('assets/images/mine_next.png'),
              fit: BoxFit.fill,
            ),
            onTap: (){
              Navigator.push(context,CupertinoPageRoute(builder: (context) => ContactsPage()));
            },
          ),
        ],
      ),
    );
  }
}
class AddByPhone extends StatefulWidget{
  final UserInfo userInfo;
  AddByPhone({Key key,this.userInfo}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return AddByPhoneState();
  }
}
class AddByPhoneState extends State<AddByPhone>{
  bool isSeen=false;
  var textController =  new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child:IconButton(
                  icon: Image(
                    image: AssetImage("assets/images/login_back.png"),
                    width:20,
                    height:20,
                    fit: BoxFit.fill,
                    color: Color(0xFF373737),),
                  onPressed: () {
                    setState(() {
                      FocusScope.of(context).requestFocus(FocusNode());
                      Navigator.pop(context);
                    });
                  }),
            ),
            Expanded(
              flex: 9,
              child: Container(
                height:40,
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child:  TextField(
                        decoration: new InputDecoration(
                          hintText: '搜索',
                          hintStyle: TextStyle(fontSize:16),
                          contentPadding: const EdgeInsets.only(bottom: 5),
                          border: InputBorder.none,),
                        controller: textController,style: TextStyle(height: 1,fontSize: 16),
                        onChanged: searchPhone,
                        onSubmitted:submit,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    IconButton(
                      icon: new Icon(Icons.cancel),
                      color: Colors.grey,
                      iconSize: 18.0,
                      onPressed: () {
                        textController.text="";
                      },
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:Color(0xFFF6F6F6),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 1,
        brightness: Brightness.light,
        automaticallyImplyLeading: false,
      ),
      body: isSeen?ListView(
        children: <Widget>[
          InkWell(
            child:Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Image(
                    width: 18,
                    height: 18,
                    image:AssetImage('assets/images/book_add_search.png'),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  height: 50,
                  child:  RichText(
                    text: TextSpan(
                      text: '添加:',
                      style: TextStyle(fontSize: 16.0,color: Color(0xFF373737)),
                      children: <TextSpan>[
                        TextSpan(
                          text: textController.text.toString(),
                          style: TextStyle(fontSize: 16.0,color:Color(0xFF0073FE)),
                        )
                      ],
                    ),
                    textScaleFactor: 1.0,
                  ),
                ),
              ],
            ),
            onTap: (){
              submit(textController.text.toString());
            },
          ),
        ],
      ):Container(),
    );
  }
  void searchPhone(String value) async {
    if(value!=""){
      setState(() {
        isSeen=true;
      });
    }else{
      setState(() {
        isSeen=false;
      });
    }
  }
  Future<void> submit(String value) async {
    if(!RegExpUtil().verifyPhone(value)){
      ToastUtil.showShortClearToast("查无此人");
      return;
    }
    String url="userFriend/findPhone";
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url, queryParameters: {
      "token": userInfo.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "userId": userInfo.id,
      "phone":value,
    });
    if(res is String){
      Map map = jsonDecode(res);
      if(map['verify']['sign']=="success"){
        FriendInfo info = FriendInfo.fromJson(map['data'][0],userInfo.id);
        Navigator.push(context,CupertinoPageRoute(builder: (context)=>SearchDetailPage(user: info)));
      }else{
        ToastUtil.showShortClearToast(map['verify']['desc']);
      }
    }
  }
}
