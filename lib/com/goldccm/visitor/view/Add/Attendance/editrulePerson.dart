import 'package:flutter/material.dart';
/*
 * 编辑打卡人员
 * editor:ody997
 * email:hwk@growingpine.com
 * create_time:2019/11/1
 */
class EditRulePersonPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return EditRulePersonPageState();
  }
}
class EditRulePersonPageState extends State<EditRulePersonPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('打卡人员列表',textScaleFactor: 1.0),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.add),
            title: Text('添加',textScaleFactor: 1.0),
            onTap: _addPerson,
          ),
        ],
      )
    );
  }
  void _addPerson(){

  }
}
/*
 * 添加打卡人员
 * editor:ody997
 * email:hwk@growingpine.com
 * create_time:2019/11/1
 */
class EditRulePersonAddPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return EditRulePersonAddPageState();
  }
}
class EditRulePersonAddPageState extends State<EditRulePersonAddPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加',textScaleFactor: 1.0),
      ),
      body: Column(
        children: <Widget>[

        ],
      ),
    );
  }
}