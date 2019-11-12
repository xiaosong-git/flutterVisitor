import 'dart:async';
import 'package:flutter/material.dart';

class EditRulePositionPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return EditRulePositionPageState();
  }
}
class EditRulePositionPageState extends State<EditRulePositionPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('打卡位置',textScaleFactor: 1.0),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('添加位置',textScaleFactor: 1.0),
            onTap: _addPosition,
          )
        ],
      ),
    );
  }
  void _addPosition(){

  }
}
