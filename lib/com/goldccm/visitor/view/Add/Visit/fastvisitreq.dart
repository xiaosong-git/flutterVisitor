import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/RegExpUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';

/*
 * 实现非好友快速访问
 * author:ody997<hwk@growingpine.com>
 * create_time:2019/11/29
 */
class FastVisitReq extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new FastVisitReqState();
  }
}
/*
 * TextEditingController and FocusNode 是长时间存在的对象，需要在initState创建，然后在dispose中清除
 */
class FastVisitReqState extends State<FastVisitReq> {

  final TextStyle _labelStyle = new TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  final TextStyle _hintlStyle = new TextStyle(fontSize: 16.0, color: Colors.black54);
  bool isCompleted=false;
  TextEditingController _visitNameControl;
  TextEditingController _visitPhoneControl;
  TextEditingController _visitStartControl;
  TextEditingController _visitEndControl;
  TextEditingController _visitReasonControl;
  TextEditingController _visitReasonDetailControl;
  FocusNode _startNode;
  FocusNode _endNode;
  String startDateText;
  DateTime startDate;
  String endDateText;
  DateTime endDate;
  int reasonType=1;
  var dialog;
  String reasonText="";
  bool addReason=false;

  @override
  void initState() {
    super.initState();
    _startNode = FocusNode();
    _endNode = FocusNode();
    _visitNameControl = TextEditingController();
    _visitPhoneControl = TextEditingController();
    _visitStartControl = TextEditingController();
    _visitEndControl = TextEditingController();
    _visitReasonControl = TextEditingController();
    _visitReasonDetailControl = TextEditingController();
  }

  @override
  void dispose() {
    _startNode.dispose();
    _endNode.dispose();
    _visitNameControl.dispose();
    _visitReasonControl.dispose();
    _visitEndControl.dispose();
    _visitPhoneControl.dispose();
    _visitStartControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF8F8F8),
        appBar: new AppBar(
          centerTitle: true,
          backgroundColor:  Color(0xFFFFFFFF),
          title:  Text('快捷访问',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF787878)),),
          elevation: 1,
          automaticallyImplyLeading: false,
          leading: IconButton(
              icon: Image(
                image: AssetImage("assets/images/login_back.png"),
                width: ScreenUtil().setWidth(36),
                height: ScreenUtil().setHeight(36),
                color: Color(0xFF787878),),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              }),
          brightness: Brightness.light,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                height: ScreenUtil().setHeight(214),
                margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(16)),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            child:Text('受访人姓名',style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF787878)),),
                            padding: EdgeInsets.only(left: ScreenUtil().setWidth(60)),
                          )
                        ),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller:_visitNameControl,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '请输入姓名',
                              hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: ScreenUtil().setWidth(236)),
                      child: Divider(height: 1,),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            child:Text('受访人手机号',style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF787878)),),
                            padding: EdgeInsets.only(left: ScreenUtil().setWidth(32)),
                          )
                        ),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _visitPhoneControl,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '请输入手机号',
                              hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                height: ScreenUtil().setHeight(310),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child:  Container(
                            child:Text('开始时间',style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF787878)),),
                            padding: EdgeInsets.only(left: ScreenUtil().setWidth(88)),
                          )
                        ),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _visitStartControl,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '请选择开始时间',
                              hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                              suffixIcon: Image(
                                image: AssetImage('assets/images/mine_next.png'),
                              ),
                            ),
                            readOnly: true,
                            onTap: (){
                              DatePicker.showDateTimePicker(context, showTitleActions: true,minTime: DateTime.now(),maxTime: DateTime.now().add(Duration(days: 14)), onConfirm: (date) {
                                DateTime currentDate=DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day);
                                if (date.compareTo(currentDate)>=0) {
                                  setState(() {
                                    startDate = date;
                                    startDateText = DateFormat('yyyy-MM-dd HH:mm').format(date);
                                    _visitStartControl.text=startDateText;
                                  });
                                }else{
                                  ToastUtil.showShortClearToast("时间选择错误");
                                }
                              }, currentTime: DateTime.now(), locale: LocaleType.zh,

                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: ScreenUtil().setWidth(236)),
                      child: Divider(height: 1,),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex:1,
                          child:  Container(
                            child:Text('时长(小时)',style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF787878)),),
                            padding: EdgeInsets.only(left: ScreenUtil().setWidth(68)),
                          )
                        ),
                        Expanded(
                          flex:2,
                          child: TextField(
                            controller: _visitEndControl,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '请选择时长',
                              hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                              suffixIcon: Image(
                                image: AssetImage('assets/images/mine_next.png'),
                              ),
                            ),
                            readOnly: true,
                            onTap: (){
                              if(startDate==null){
                                ToastUtil.showShortClearToast("开始时间未选择");
                              }else{
                                DatePicker.showPicker(context,pickerModel:CustomPicker(currentTime: startDate),locale: LocaleType.zh,onConfirm: (date){
                                  setState(() {
                                    endDate=date;
                                    endDateText=(date.hour-startDate.hour).toString()+".0";
                                    _visitEndControl.text=endDateText;
                                  });
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: ScreenUtil().setWidth(236)),
                      child: Divider(height: 1,),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex:1,
                          child:  Container(
                            child:Text('访问是由',style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF787878)),),
                            padding: EdgeInsets.only(left: ScreenUtil().setWidth(88)),
                          )
                        ),
                        Expanded(
                          flex:2,
                          child: TextField(
                            controller: _visitReasonControl,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '请选择访问是由',
                              hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                              suffixIcon: Image(
                                image: AssetImage('assets/images/mine_next.png'),
                              ),
                            ),
                            readOnly: true,
                            onTap: (){
                              callReason(reasonType);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              reasonType==5?Container(
                color: Colors.white,
                height: ScreenUtil().setHeight(250),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        flex:1,
                        child:  Container(
                          padding: EdgeInsets.only(left: ScreenUtil().setWidth(88)),
                        )
                    ),
                    Expanded(
                      flex:2,
                      child: TextField(
                        controller: _visitReasonDetailControl,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '请输入访问是由',
                          hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                        ),
                        maxLength: 80,
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
              ):Container(),
              Container(
                margin: EdgeInsets.only(top: ScreenUtil().setHeight(82)),
                color: Colors.white,
                child: SizedBox(
                  width: ScreenUtil().setWidth(458),
                  height: ScreenUtil().setHeight(90),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Text('提交',style: TextStyle(color: Color(0xFFFFFFFF),fontSize: ScreenUtil().setSp(32)),),
                    color: Color(0xFF0073FE),
                    onPressed: (){
                      fastVisit();
                    },
                  ),
                )
              ),
            ],
          )
        ));
  }

  Widget buildForm(String labelText, String hintText, bool autofocus,
      double left, TextEditingController controller, TextInputType inputtype) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Container(
          padding: EdgeInsets.all(10.0).copyWith(right: 20.0),
          child: new Text(
            labelText,
            style: _labelStyle,
            textScaleFactor: 1.0,
          ),
        ),
        new Expanded(
          child: new TextField(
            controller: controller,
//            autofocus: autofocus,
            style: _hintlStyle,
            keyboardType: inputtype,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: left),
            ),
          ),
        ),
      ],
    );
  }
  /*
   * 请求快捷访问接口
   */
  Future<bool> fastVisit() async {
    if(_visitNameControl.text.toString()==null||_visitNameControl.text.toString()==""){
      ToastUtil.showShortToast('姓名未填写');
      return false;
    }
    if(!RegExpUtil().verifyPhone(_visitPhoneControl.text.toString())){
      ToastUtil.showShortToast('电话格式不正确');
      return false;
    }
    if(_visitStartControl.text.toString()==""||_visitStartControl.text.toString()==""){
      ToastUtil.showShortToast('开始时间不正确');
      return false;
    }
    if(_visitEndControl.text.toString()==""||_visitEndControl.text.toString()==""){
      ToastUtil.showShortToast('时长不正确');
      return false;
    }
    if(_visitReasonControl.text.toString()==""||_visitReasonControl.text.toString()==""){
      ToastUtil.showShortToast('访问是由未填写');
      return false;
    }
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String httpUrl=Constant.fastVisitUrl;
    String threshold=await CommonUtil.calWorkKey(userInfo: userInfo);
    String end=  DateFormat('yyyy-MM-dd HH:mm').format(endDate);
    var parameters={
      "userId": userInfo.id,
      "token": userInfo.token,
      "factor":CommonUtil.getCurrentTime(),
      "threshold":threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "phone":_visitPhoneControl.text.toString(),
      "realName":_visitNameControl.text.toString(),
      "startDate":_visitStartControl.text.toString(),
      "endDate":end,
      "reason":reasonType==5?_visitReasonDetailControl.text.toString():_visitReasonControl.text.toString(),
      "recordType":1,
    };
    var response=await Http().post(httpUrl,queryParameters: parameters,userCall: true);
    if(response!=null&&response!=""){
      if(response is String){
        Map responseMap = jsonDecode(response);
        if(responseMap['verify']['sign']=="success"){
          ToastUtil.showShortToast('访问成功，可在个人中心查看哦');
          Navigator.pop(context);
        }else{
          ToastUtil.showShortToast(responseMap['verify']['desc']);
        }
      }
    }
  }
  callReason(int type){
    return dialog=YYDialog().build(context)
      ..gravity = Gravity.bottom
      ..gravityAnimationEnable = true
      ..backgroundColor = Colors.transparent
      ..widget(Container(
        width: 350,
        height: 227,
        margin: EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
        ),
        child: Column(
          children: <Widget>[
            InkWell(
              child: Container(
                width: 350,
                height: 45,
                child: Center(
                  child: Text('商务拜访',style: TextStyle(fontSize: ScreenUtil().setSp(32),color:type==1?Colors.blue:Colors.black),textScaleFactor: 1.0,),
                ),
              ),
              onTap: (){
                setState(() {
                  reasonType=1;
                  reasonText="商务拜访";
                  _visitReasonControl.text=reasonText;
                  dialog.dismiss();
                });
              },
            ),
            Divider(height: 1,),
            InkWell(
              child:   Container(
                width: 350,
                height: 45,
                child: Center(
                  child: Text('配送服务',style: TextStyle(fontSize: ScreenUtil().setSp(32),color:type==2?Colors.blue:Colors.black),textScaleFactor: 1.0,),
                ),
              ),
              onTap: (){
                setState(() {
                  reasonType=2;
                  reasonText="配送服务";
                  _visitReasonControl.text=reasonText;
                  dialog.dismiss();
                });
              },
            ),
            InkWell(
              child: Container(
                width: 350,
                height: 45,
                child: Center(
                  child: Text('面试',style: TextStyle(fontSize: ScreenUtil().setSp(32),color:type==3?Colors.blue:Colors.black),textScaleFactor: 1.0,),
                ),
              ),
              onTap: (){
                setState(() {
                  reasonType=3;
                  reasonText="面试";
                  _visitReasonControl.text=reasonText;
                  dialog.dismiss();
                });
              },
            ),
            InkWell(
              child:   Container(
                width: 350,
                height: 45,
                child: Center(
                  child: Text('找人',style: TextStyle(fontSize: ScreenUtil().setSp(32),color:type==4?Colors.blue:Colors.black),textScaleFactor: 1.0,),
                ),
              ),
              onTap: (){
                setState(() {
                  reasonType=4;
                  reasonText="找人";
                  _visitReasonControl.text=reasonText;
                  dialog.dismiss();
                });
              },
            ),
            Divider(height: 1,),
            InkWell(
              child:   Container(
                width: 350,
                height: 45,
                child: Center(
                  child: Text('其他',style: TextStyle(fontSize: ScreenUtil().setSp(32),color:type==5?Colors.blue:Colors.black),textScaleFactor: 1.0,),
                ),
              ),
              onTap: (){
                setState(() {
                  reasonType=5;
                  reasonText="其他";
                  _visitReasonControl.text=reasonText;
                });
                dialog.dismiss();
              },
            ),
          ],
        ),
      ))
      ..widget(InkWell(
        child: Container(
          width: 350,
          height: 45,
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              "取消",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),onTap: (){
            dialog.dismiss();
        },
      ))
      ..show();
  }
}
class CustomPicker extends CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }

  CustomPicker({DateTime currentTime, LocaleType locale}) : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();
    this.setLeftIndex(this.currentTime.hour);
    this.setMiddleIndex(1);
    this.setRightIndex(this.currentTime.second);
  }

  @override
  String leftStringAtIndex(int index) {
//    if (index >= 0 && index < 24) {
//      return this.digits(index, 2);
//    } else {
//      return null;
//    }
    return null;
  }

  @override
  String middleStringAtIndex(int index) {
    if (index >= 1 && index < 24-currentTime.hour) {
      return index.toString();
    } else {
      return null;
    }
  }

  @override
  String rightStringAtIndex(int index) {
//    if (index >= 0 && index < 60) {
//      return this.digits(index, 2);
//    } else {
//      return null;
//    }
    return null;
  }

//  @override
//  String leftDivider() {
//    return "|";
//  }
//
//  @override
//  String rightDivider() {
//    return "|";
//  }

  @override
  List<int> layoutProportions() {
    return [0, 2, 0];
  }

  @override
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(currentTime.year, currentTime.month, currentTime.day,
        currentTime.hour+this.currentMiddleIndex(), currentTime.minute, currentTime.second)
        : DateTime(currentTime.year, currentTime.month, currentTime.day, currentTime.hour+this.currentMiddleIndex(),
        currentTime.minute, currentTime.second);
  }
}
