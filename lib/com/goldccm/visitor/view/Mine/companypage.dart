import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';

var _keys = null;

///公司管理
///userInfo接收来自上一级页面传递过来的变量
class CompanyPage extends StatefulWidget{
  CompanyPage({Key key,this.userInfo}):super(key:key);
  final UserInfo userInfo;
  @override
  State<StatefulWidget> createState() {
    return CompanyPageState();
  }
}
class CompanyPageState extends State<CompanyPage>{
  UserInfo userInfo;
  int groupValue=-1;
  @override
  void initState() {
    super.initState();
    getCompanyInfo();
    userInfo=widget.userInfo;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('公司管理',textScaleFactor: 1.0,style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(36)),),
        centerTitle: true,
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 1,
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        leading: IconButton(
            icon: Image(
              image: AssetImage("assets/images/back_white.png"),
              width: ScreenUtil().setWidth(36),
              height: ScreenUtil().setHeight(36),
              fit: BoxFit.fill,
              color: Color(0xFF595959),),
            onPressed: () {
              setState(() {
                Navigator.pop(context);
              });
            }),
      ),
      body:_buildInfo(),
    );
  }
  Widget _buildInfo() {
    if (_keys != null && _keys != "") {
      return ListView.builder(
          itemCount: _keys.length != null ? _keys.length : 0,
          itemBuilder: (BuildContext context, int index) {
            return index==groupValue?
              Container(
                height: ScreenUtil().setHeight(310),
                width: ScreenUtil().setWidth(710),
                margin: EdgeInsets.only(left: ScreenUtil().setWidth(20),top: ScreenUtil().setHeight(40),right:ScreenUtil().setWidth(20)),
                child: Card(
                  elevation: 5.0,
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: Stack(
                    children: <Widget>[
                      Image.asset("assets/images/mine_company_background.png",fit: BoxFit.cover,width: ScreenUtil().setWidth(710),height:ScreenUtil().setHeight(310)),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setHeight(32),vertical: ScreenUtil().setHeight(10)),
                              child: RichText(
                                  text: TextSpan(
                                      text: '公司名称    ',
                                      style: TextStyle(fontSize: ScreenUtil().setSp(30),color:Color(0xFFCFCFCF)),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: _keys[index]['companyName'],
                                          style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(32)),
                                        ),
                                      ]
                                  )
                                  ,textScaleFactor: 1.0),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setHeight(32),vertical: ScreenUtil().setHeight(10)),
                              child:   RichText(
                                  text: TextSpan(
                                      text: '部门名称    ',
                                      style: TextStyle(fontSize: ScreenUtil().setSp(30),color:Color(0xFFCFCFCF)),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: _keys[index]['sectionName'],
                                          style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(32)),
                                        ),
                                      ]
                                  )
                                  ,textScaleFactor: 1.0 ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setHeight(32),vertical: ScreenUtil().setHeight(10)),
                              child:RichText(
                                  text: TextSpan(
                                      text: '用户姓名    ',
                                      style: TextStyle(fontSize: ScreenUtil().setSp(30),color:Color(0xFFCFCFCF)),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: _keys[index]['userName'],
                                          style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(32)),
                                        ),
                                      ]
                                  )
                                  ,textScaleFactor: 1.0),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setHeight(32),vertical: ScreenUtil().setHeight(10)),
                              child: RichText(
                                  text: TextSpan(
                                      text: '入职时间    ',
                                      style: TextStyle(fontSize: ScreenUtil().setSp(30),color:Color(0xFFCFCFCF)),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: _keys[index]['createDate'],
                                          style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(32)),
                                        ),
                                      ]
                                  )
                                  ,textScaleFactor: 1.0),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        child: Radio(value:index, groupValue: groupValue, onChanged: (T){updateGroupValue(T);},activeColor: Colors.blue,),
                        right: 10.0,
                        top:50.0,
                      ),
                    ],
                  ),
                ),
              ):Container(
              height: ScreenUtil().setHeight(310),
              width: ScreenUtil().setWidth(710),
              margin: EdgeInsets.only(left: ScreenUtil().setWidth(20),top: ScreenUtil().setHeight(40),right:ScreenUtil().setWidth(20)),
              child: Card(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
                child:
                Stack(
                  children: <Widget>[
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setHeight(32),vertical: ScreenUtil().setHeight(10)),
                            child: RichText(
                                text: TextSpan(
                                    text: '公司名称    ',
                                    style: TextStyle(fontSize: ScreenUtil().setSp(30),color:Color(0xFFCFCFCF)),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: _keys[index]['companyName'],
                                        style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(32)),
                                      ),
                                    ]
                                )
                                ,textScaleFactor: 1.0),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setHeight(32),vertical: ScreenUtil().setHeight(10)),
                            child:   RichText(
                                text: TextSpan(
                                    text: '部门名称    ',
                                    style: TextStyle(fontSize: ScreenUtil().setSp(30),color:Color(0xFFCFCFCF)),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: _keys[index]['sectionName'],
                                        style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(32)),
                                      ),
                                    ]
                                )
                                ,textScaleFactor: 1.0 ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setHeight(32),vertical: ScreenUtil().setHeight(10)),
                            child:RichText(
                                text: TextSpan(
                                    text: '用户姓名    ',
                                    style: TextStyle(fontSize: ScreenUtil().setSp(30),color:Color(0xFFCFCFCF)),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: _keys[index]['userName'],
                                        style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(32)),
                                      ),
                                    ]
                                )
                                ,textScaleFactor: 1.0),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setHeight(32),vertical: ScreenUtil().setHeight(10)),
                            child: RichText(
                                text: TextSpan(
                                    text: '入职时间    ',
                                    style: TextStyle(fontSize: ScreenUtil().setSp(30),color:Color(0xFFCFCFCF)),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: _keys[index]['createDate'],
                                        style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(32)),
                                      ),
                                    ]
                                )
                                ,textScaleFactor: 1.0),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      child: Radio(value:index, groupValue: groupValue, onChanged: (T){updateGroupValue(T);},activeColor: Colors.blue,),
                      right: 10.0,
                      top:50.0,
                    ),
                  ],
                ),
              ),
            );
          });
    } else {
      return Column(
        children: <Widget>[
          Container(
            child: Center(
                child: Image.asset('assets/images/visitor_icon_nodata.png')),
            padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
          ),
          Center(child: Text('暂无数据，请重新获取',textScaleFactor: 1.0))
        ],
      );
    }
  }
  //获取公司信息
  getCompanyInfo() async {
    print(await RouterUtil.getStatus());
    _keys=null;
    String url = Constant.findApplySucUrl;
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url, queryParameters: {
      "token": userInfo.token,
      "userId": userInfo.id,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
    });
    if (res != null) {
      Map map = jsonDecode(res);
      if (map['verify']['sign'] == "success")
        if(map['data']==null) {
          ToastUtil.showShortClearToast("暂无数据");
        }else{
        setState(() {
          _keys = map['data'];
          int index = 0;
          for (var data in map['data']) {
            if (data['companyId'] == userInfo.companyId) {
              userInfo.companyId=data['companyId'];
              userInfo.companyName=data['companyName'];
              userInfo.role=data['roleType'];
              DataUtils.updateUserInfo(userInfo);
              Provider.of<UserModel>(context).init(userInfo);
              LocalStorage.save("userInfo",userInfo);
              groupValue = index;
              break;
            }
            index++;
          }
        });
      }
    }
  }
  ///更新默认公司
  Future updateGroupValue(int v) async {
    String url = Constant.updateCompanyIdAndRoleUrl;
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url,queryParameters: {
      "token": userInfo.token,
      "userId": userInfo.id,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "companyId":_keys[v]['companyId'],
      "role":_keys[v]['roleType'],
    },debugMode: true,userCall: true);
    Map map = jsonDecode(res);
    if(map['verify']['sign']=="success"){
      ToastUtil.showShortClearToast("修改公司成功");
      print(_keys[v]);
      setState(() {
        groupValue=v;
        userInfo.companyId=_keys[v]['companyId'];
        userInfo.companyName=_keys[v]['companyName'];
        userInfo.role=_keys[v]['roleType'];
        DataUtils.updateUserInfo(userInfo);
        Provider.of<UserModel>(context).init(userInfo);
        LocalStorage.save("userInfo",userInfo);
      });
      Navigator.pop(context);
    }else{
      ToastUtil.showShortClearToast("修改公司失败");
    }
  }
}