import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/view/attendance/editruleName.dart';
import 'package:visitor/com/goldccm/visitor/view/attendance/editrulePerson.dart';
import 'package:visitor/com/goldccm/visitor/view/attendance/editruleTime.dart';

/*
 * 编辑规则
 * 主要实现详细规则的更新
 * editor:ody997
 * email:hwk@growingpine.com
 * create_time:2019/10/31
 */
class EditRulePage extends StatefulWidget {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('编辑规则',textScaleFactor: 1.0),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              title: Text('规则类型',textScaleFactor: 1.0),
              trailing: Text('固定上下班',textScaleFactor: 1.0),
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
            ListTile(
              title: Text('加班规则',textScaleFactor: 1.0),
              trailing: Text('日常考勤',textScaleFactor: 1.0),
              onTap: () {
                _changeRuleOvertime();
              },
            ),
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
 //规则类型
  void _changeRuleType() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: new SizedBox(
                  height: 260,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: ShapeDecoration(
                          color: Color(0xffffffff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(0.0),
                            ),
                          ),
                        ),
                        child: new Column(
                          children: <Widget>[
                            Padding(
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 30,
                                  child: Center(
                                    child: Text(
                                      '规则类型',
                                      style: TextStyle(fontSize:  18),textScaleFactor: 1.0
                                    ),
                                  )),
                              padding:EdgeInsets.symmetric(vertical: 10),
                            ),
                            Divider(
                              height: 0,
                            ),
                            FlatButton(
                                onPressed: () async {},
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 30,
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '固定上下班',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                      ),textScaleFactor: 1.0
                                    ),
                                  ),
                                ),
                            ),
                            Divider(
                              height: 0,
                            ),
                           FlatButton(
                                onPressed: () async {},
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 30,
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '按班次上下班',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                      ),textScaleFactor: 1.0
                                    ),
                                  ),
                                ),
                              ),
                            Divider(
                              height: 0,
                            ),
                            FlatButton(
                                onPressed: () async {},
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 30,
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '自由上下班',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                      ),textScaleFactor: 1.0
                                    ),
                                  ),
                                ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
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
}
