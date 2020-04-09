import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/AddressInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/RegExpUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/Add/Visit/fastvisitreq.dart';

/*
 * 实现非好友快速邀约
 * author:ody997<hwk@growingpine.com>
 * create_time:2019/11/29
 */
class FastInviteReq extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new FastInviteReqState();
  }
}
/*
 * TextEditingController and FocusNode 是长时间存在的对象，需要在initState创建，然后在dispose中清除
 */
class FastInviteReqState extends State<FastInviteReq> {

  final TextStyle _labelStyle = new TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  final TextStyle _hintlStyle = new TextStyle(fontSize: 16.0, color: Colors.black54);

  TextEditingController _inviteNameControl;
  TextEditingController _invitePhoneControl;
  TextEditingController _inviteStartControl;
  TextEditingController _inviteAddrControl;
  List<AddressInfo> _mineAddress=<AddressInfo>[];
  TextEditingController _inviteEndControl;
  TextEditingController _inviteReasonControl;
  FocusNode _startNode;
  FocusNode _endNode;
  AddressInfo selectedMineAddress;
  String startDateText;
  DateTime startDate;
  String endDateText;
  DateTime endDate;
  int selectIndex=0;
  var dialog;

  @override
  void initState() {
    super.initState();
    init();
    _startNode = FocusNode();
    _endNode = FocusNode();
    _inviteNameControl = TextEditingController();
    _invitePhoneControl = TextEditingController();
    _inviteAddrControl = TextEditingController();
    _inviteStartControl = TextEditingController();
    _inviteEndControl = TextEditingController();
    _inviteReasonControl = TextEditingController();
  }
  init() async {
    _mineAddress=await getAddressInfo();
  }
  @override
  void dispose() {
    _startNode.dispose();
    _endNode.dispose();
    _inviteNameControl.dispose();
    _inviteReasonControl.dispose();
    _inviteEndControl.dispose();
    _invitePhoneControl.dispose();
    _inviteStartControl.dispose();
    _inviteAddrControl.dispose();
    super.dispose();
  }
  getAddressInfo() async {
    String url = "companyUser/findVisitComSuc";
    String threshold = await CommonUtil.calWorkKey();
    UserInfo userInfo =await LocalStorage.load("userInfo");
    List<AddressInfo> _list=<AddressInfo>[];
    var res = await Http().post(url,queryParameters: {
      "token": userInfo.token,
      "userId": userInfo.id,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "visitorId":userInfo.id,
    },userCall: false );
    if(res !=null){
      if(res is String){
        Map map = jsonDecode(res);
        if(map['verify']['sign']=="success"){
          if(map['data']!=null&&map['data'].length>0){
            for(var info in map['data']){
              if(info['status']=="applySuc"&&info['currentStatus']=="normal"){
                AddressInfo addressInfo=new AddressInfo(id: info['id'],companyId: info['companyId'],sectionId: info['sectionId'],userId: info['userId'],postId: info['postId'],userName: info['userName'],createDate: info['createDate'],createTime: info['createTime'],companyName: info['companyName'],currentStatus: info['currentStatus'],sectionName: info['sectionName'],status: info['status'],secucode: info['secucode'],sex: info['sex'],roleType: info['roleType']);
                _list.add(addressInfo);
              }
            }
          }
        }
        else{
          ToastUtil.showShortClearToast(map['verify']['desc']);
        }
      }
    }
    return _list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF8F8F8),
        appBar: new AppBar(
          centerTitle: true,
          backgroundColor:  Color(0xFFFFFFFF),
          title:  Text('快捷邀约',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF787878)),),
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
                              controller:_inviteNameControl,
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
                              controller: _invitePhoneControl,
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
                              controller: _inviteStartControl,
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
                                      _inviteStartControl.text=startDateText;
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
                              controller: _inviteEndControl,
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
                                      _inviteEndControl.text=endDateText;
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
                                child:Text('来访地址',style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF787878)),),
                                padding: EdgeInsets.only(left: ScreenUtil().setWidth(88)),
                              )
                          ),
                          Expanded(
                            flex:2,
                            child: TextField(
                              controller: _inviteAddrControl,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '请选择来访地址',
                                hintStyle: TextStyle(color: Color(0xFFCFCFCF),fontSize: ScreenUtil().setSp(28)),
                                suffixIcon: Image(
                                  image: AssetImage('assets/images/mine_next.png'),
                                ),
                              ),
                              readOnly: true,
                              onTap: (){
                                if(_mineAddress.length>0){
                                  callAddress();
                                }else{
                                  ToastUtil.showShortClearToast("您没有所属公司");
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                          fastinvite();
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
  Future<bool> fastinvite() async {
    if(_inviteNameControl.text.toString()==null||_inviteNameControl.text.toString()==""){
      ToastUtil.showShortToast('姓名未填写');
      return false;
    }
    if(!RegExpUtil().verifyPhone(_invitePhoneControl.text.toString())){
      ToastUtil.showShortToast('电话格式不正确');
      return false;
    }
    if(_inviteStartControl.text.toString()==""||_inviteStartControl.text.toString()==""){
      ToastUtil.showShortToast('开始时间不正确');
      return false;
    }
    if(_inviteEndControl.text.toString()==""||_inviteEndControl.text.toString()==""){
      ToastUtil.showShortToast('时长不正确');
      return false;
    }
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String httpUrl="visitorRecord/inviteStranger";
    String threshold=await CommonUtil.calWorkKey(userInfo: userInfo);
    String end=  DateFormat('yyyy-MM-dd HH:mm').format(endDate);
    var parameters={
      "userId": userInfo.id,
      "token": userInfo.token,
      "factor":CommonUtil.getCurrentTime(),
      "threshold":threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "phone":_invitePhoneControl.text.toString(),
      "realName":_inviteNameControl.text.toString(),
      "startDate":_inviteStartControl.text.toString(),
      "endDate":end,
      "reason":_inviteReasonControl.text.toString(),
      "companyId":selectedMineAddress.companyId,
    };
    var response=await Http().post(httpUrl,queryParameters: parameters,userCall: true);
    if(response!=null&&response!=""){
      if(response is String){
        Map responseMap = jsonDecode(response);
        if(responseMap['verify']['sign']=="success"){
          ToastUtil.showShortToast('邀约成功，可在个人中心查看');
          Navigator.pop(context);
        }else{
          ToastUtil.showShortToast(responseMap['verify']['desc']);
        }
      }
    }
  }
  callAddress(){
    return dialog=YYDialog().build(context)
      ..gravity = Gravity.bottom
      ..gravityAnimationEnable = true
      ..backgroundColor = Colors.transparent
      ..widget(Container(
        width: 350,
        height: double.parse((45*_mineAddress.length+1*_mineAddress.length-1).toString()),
        margin: EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
        ),
        child: Column(
          children: <Widget>[
            ListView.separated(itemBuilder: (context,index){
              return InkWell(
                child: Container(
                  width: 300,
                  height: 45,
                  child: Center(
                    child: Text(_mineAddress[index].companyName,style: TextStyle(fontSize: ScreenUtil().setSp(32),color:selectIndex==index?Colors.blue:Colors.black),textScaleFactor: 1.0,),
                  ),
                ),
                onTap: (){
                  setState(() {
                    selectIndex=index;
                    _inviteAddrControl.text=_mineAddress[index].companyName;
                    dialog.dismiss();
                    selectedMineAddress=_mineAddress[index];
                  });
                },
              );
            },  separatorBuilder: (context,index){
              return Container(
                child: Divider(
                  height: 1,
                ),
              );
            }, itemCount: _mineAddress.length,shrinkWrap: true,padding: EdgeInsets.all(0),)
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
