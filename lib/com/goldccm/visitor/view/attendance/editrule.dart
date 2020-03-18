import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/RuleInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/RuleInfoDetail.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/view/attendance/editruleName.dart';
import 'package:visitor/com/goldccm/visitor/view/attendance/editrulePerson.dart';
import 'package:visitor/com/goldccm/visitor/view/attendance/editruleTime.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';

/*
 * 编辑规则
 * 主要实现详细规则的更新
 * email:hwk@growingpine.com
 * create_time:2019/10/31
 */
class EditRulePage extends StatefulWidget {
  final int type;
  final RuleInfo ruleInfo;
  EditRulePage({Key key,this.type,this.ruleInfo}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return EditRulePageState();
  }
}

/*
 * selectedType 规则类型 0 固定上下班，1 按班次上线，2 自由上下班
 */
class EditRulePageState extends State<EditRulePage> {
  int _selectedType = 0 ;
  RuleInfo info=RuleInfo();
  RuleInfoDetail _infoDetail=RuleInfoDetail();
  UserInfo userInfo=UserInfo();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('编辑规则',textScaleFactor: 1.0),
          actions: <Widget>[
            FlatButton(
              child: Text('保存'),
            )
          ],
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              title: Text('规则类型',textScaleFactor: 1.0),
              trailing: Text('固定时间上下班',textScaleFactor: 1.0),
              onTap: () {
                _changeRuleType();
              },
            ),
            ListTile(
              title: Text('规则名称',textScaleFactor: 1.0),
              trailing: Text(info.groupName!=null?'${info.groupName}':"",textScaleFactor: 1.0),
              onTap: () {
                _changeRuleName();
              },
            ),
            ListTile(
              title: Text('打卡人员',textScaleFactor: 1.0),
              trailing: Text(userInfo.companyName!=null?'${userInfo.companyName}':"",textScaleFactor: 1.0),
              onTap: () {
                _changeRulePerson();
              },
            ),
            ListTile(
              title: Text('打卡时间',textScaleFactor: 1.0),
              trailing: Text('${info.timeStr}'??"",textScaleFactor: 1.0),
              onTap: () {
                _changeRuleTime();
              },
            ),
            ListTile(
              title: Text('打卡位置',textScaleFactor: 1.0),
              trailing: Text('${info.locTitle}'??"",textScaleFactor: 1.0),
              onTap: () {
                _changeRulePosition();
              },
            ),
//            ListTile(
//              title: Text('汇报对象',textScaleFactor: 1.0),
//              trailing: Text('潘仰知等2人',textScaleFactor: 1.0),
//              onTap: () {
//                _changeRuleReportPerson();
//              },
//            ),
//            ListTile(
//              title: Text('加班规则',textScaleFactor: 1.0),
//              trailing: Text('日常考勤',textScaleFactor: 1.0),
//              onTap: () {
//                _changeRuleOvertime();
//              },
//            ),
//            ListTile(
//              title: Text('更多设置',textScaleFactor: 1.0),
//              trailing: Text(''),
//              onTap: () {
//                _moreSetting();
//              },
//            ),
          ],
        ));
  }
  @override
  void initState() {
    super.initState();
    info=widget.ruleInfo;
    getRuleDetail();
    getUser();
  }
 //规则类型
  void _changeRuleType() {

  }
  //规则名称
  void _changeRuleName() {
      Navigator.push(context,CupertinoPageRoute(builder: (context)=>EditRuleNamePage())).then((value){
        if(value!=null&&value!=""){
        setState(() {
            info.groupName=value;
        });
        }
      });
  }
  //打卡人员
  void _changeRulePerson() {
    Navigator.push(context,CupertinoPageRoute(builder: (context)=>EditRulePersonPage()));
  }
  void _changeRuleTime() {
    Navigator.push(context, CupertinoPageRoute(builder: (context)=>EditRuleTimePage(cList: _infoDetail.checkInDate,)));
  }
  void _changeRuleReportPerson() {

  }
  void _changeRulePosition(){

  }
  void _changeRuleOvertime() {}
  void _moreSetting() {}
  //保存打卡规则
  void saveRule(){
    String url = Constant.attendanceSaveRuleUrl;
    Http().post(url);
  }
  //获取详细打卡规则
  getRuleDetail() async {
    if(widget.ruleInfo.groupId!=null){
      UserInfo userInfo = await LocalStorage.load("userInfo");
      String url="work/gainGroupDetail";
      String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
      var res = await Http().post(url,
          queryParameters: {
            "token": userInfo.token,
            "userId": userInfo.id,
            "factor": CommonUtil.getCurrentTime(),
            "threshold": threshold,
            "requestVer": await CommonUtil.getAppVersion(),
            "groupId": widget.ruleInfo.groupId,
          },
          userCall: false);
      if(res is String){
        Map map = jsonDecode(res);
        if(map['verify']['sign']=="success"){
          for(var res in map['data']){
            List<CheckInDate> check;
            for(var ckd in res['checkInDate']){
              check.add(CheckInDate.fromJson(ckd));
            }
            List<LocInfo> loc;
            for(var loi in res['locInfo']){
              loc.add(LocInfo.fromJson(loi));
            }
            RuleInfoDetail ruleInfoDetail=new RuleInfoDetail(userList: res['userList'],whiteList: res['whiteList'],checkInDate: check,locInfo: loc,companyId: res['group']['companyId'],groupType: res['group']['groupType'],groupName: res['group']['groupName']);
            setState(() {
              _infoDetail=ruleInfoDetail;
            });
          }
        }
      }
    }
  }
  getUser() async {
    userInfo=await LocalStorage.load("userInfo");
  }
}
