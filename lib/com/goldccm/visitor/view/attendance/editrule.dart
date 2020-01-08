import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/RuleInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
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
              trailing: Text(info.groupType==1?'固定时间上下班':info.groupType==2?'按班次上下班':'自由上下班',textScaleFactor: 1.0),
              onTap: () {
                _changeRuleType();
              },
            ),
            ListTile(
              title: Text('规则名称',textScaleFactor: 1.0),
              trailing: Text('日常考勤',textScaleFactor: 1.0),
              onTap: () {
                _changeRuleName();
              },
            ),
            ListTile(
              title: Text('打卡人员',textScaleFactor: 1.0),
              trailing: Text('福建小松安信信息科技有限公司',textScaleFactor: 1.0),
              onTap: () {
                _changeRulePerson();
              },
            ),
            ListTile(
              title: Text('打卡时间',textScaleFactor: 1.0),
              trailing: Text('周一到周五',textScaleFactor: 1.0),
              onTap: () {
                _changeRuleTime();
              },
            ),
            ListTile(
              title: Text('打卡位置',textScaleFactor: 1.0),
              trailing: Text('福州软件园G区1#楼',textScaleFactor: 1.0),
              onTap: () {
                _changeRulePosition();
              },
            ),
            ListTile(
              title: Text('汇报对象',textScaleFactor: 1.0),
              trailing: Text('潘仰知等2人',textScaleFactor: 1.0),
              onTap: () {
                _changeRuleReportPerson();
              },
            ),
//            ListTile(
//              title: Text('加班规则',textScaleFactor: 1.0),
//              trailing: Text('日常考勤',textScaleFactor: 1.0),
//              onTap: () {
//                _changeRuleOvertime();
//              },
//            ),
            ListTile(
              title: Text('更多设置',textScaleFactor: 1.0),
              trailing: Text(''),
              onTap: () {
                _moreSetting();
              },
            ),
          ],
        ));
  }
  @override
  void initState() {
    info=widget.ruleInfo;
  }
 //规则类型
  void _changeRuleType() {
     YYDialog().build()
        ..width = 120
        ..height = 110
        ..backgroundColor = Colors.black.withOpacity(0.8)
        ..borderRadius = 10.0
        ..showCallBack = () {
          print("showCallBack invoke");
        }
        ..dismissCallBack = () {
          print("dismissCallBack invoke");
        }
        ..widget(Padding(
          padding: EdgeInsets.only(top: 21),
          child: Image.asset(
            'images/success.png',
            width: 38,
            height: 38,
          ),
        ))
        ..widget(Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            "Success",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ))
        ..animatedFunc = (child, animation) {
          return ScaleTransition(
            child: child,
            scale: Tween(begin: 0.0, end: 1.0).animate(animation),
          );
        }
        ..show();
  }
  //规则名称
  void _changeRuleName() {
      Navigator.push(context,MaterialPageRoute(builder: (context)=>EditRuleNamePage()));
  }
  //打卡人员
  void _changeRulePerson() {
    Navigator.push(context,MaterialPageRoute(builder: (context)=>EditRulePersonPage()));
  }
  void _changeRuleTime() {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>EditRuleTimePage()));
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
}
