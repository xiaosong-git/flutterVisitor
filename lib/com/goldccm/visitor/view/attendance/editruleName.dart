import 'package:flutter/material.dart';

/*
 * 规则改名
 * editor:ody997
 * email:hwk@growingpine.com
 * create_time:2019/10/31
 */
class EditRuleNamePage extends StatefulWidget{
  final String name;
  EditRuleNamePage({Key key,this.name}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return EditRuleNamePageState();
  }
}
/*
 * _textEditingController 规则名textField控制类
 */
class EditRuleNamePageState extends State<EditRuleNamePage>{
  TextEditingController _textEditingController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('规则名称',textScaleFactor: 1.0),
        actions: <Widget>[
          Container(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
              width: 90,
              child:   FlatButton(
                child: Text('保存',style: TextStyle(color: Colors.blue),textScaleFactor: 1.0),
                color: Colors.white,
                onPressed: (){
                    saveName();
                },
              )
          ),
        ],
      ),
      body: Container(
          child: TextField(
            controller: _textEditingController,
          )
      ),
    );
  }
  //保存名称
  void saveName(){

  }
  @override
  void initState() {
    super.initState();
    _textEditingController=new TextEditingController();
    _textEditingController.text=widget.name;
  }
}