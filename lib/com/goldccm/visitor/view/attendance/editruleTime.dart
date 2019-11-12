import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

/*
 * 规则打卡时间设置
 * editor:ody997
 * create_time:2019/11/4
 * email:hwk@growingpine.com
 */
class EditRuleTimePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EditRuleTimePageState();
  }
}

/*
 *
 */
class EditRuleTimePageState extends State<EditRuleTimePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('打卡时间',textScaleFactor: 1.0),
        ),
        body: Column(
          children: <Widget>[
            ListTile(
              title: Text('添加打卡时间',textScaleFactor: 1.0),
              onTap: _callAddTime,
            )
          ],
        ));
  }

  void _callAddTime() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => EditRuleTimeAddPage()));
  }

  @override
  void initState() {
    super.initState();
    getAllTime();
  }

  //初始化打卡时间列表
  void getAllTime() {}
}

/*
 * 规则添加打卡时间
 */
class EditRuleTimeAddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EditRuleTimeAddPageState();
  }
}

class EditRuleTimeAddPageState extends State<EditRuleTimeAddPage> {
  var _time = [
    [DateTime.now(), DateTime.now()],
    [DateTime.now(), DateTime.now()],
    [DateTime.now(), DateTime.now()]
  ];
  var _timeLength = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加打卡时间',textScaleFactor: 1.0,),
        actions: <Widget>[
          FlatButton(
            onPressed: _addTime,
            child: Text('确定',textScaleFactor: 1.0),
            color: Colors.transparent,
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('工作日',textScaleFactor: 1.0),
            onTap: _workingDay,
          ),
          _getTime(),
          ListTile(
            title: Text('更多设置',textScaleFactor: 1.0),
          )
        ],
      ),
    );
  }

  Widget _getTime() {
    if (_timeLength == 1) {
      return Column(
        children: <Widget>[
          ListTile(
            title: Text('上下班时段',textScaleFactor: 1.0),
          ),
          ListTile(
            title: Text('上班',textScaleFactor: 1.0),
            trailing: FlatButton(
                onPressed: null,
                child: Text('${_time[0][0].toString().substring(11, 16)}',textScaleFactor: 1.0)),
            onTap: () {
              DatePicker.showTimePicker(context, showTitleActions: true,
                  onConfirm: (date) {
                setState(() {
                  print(date);
                  _time[0][0] = date;
                });
              },
                  currentTime: _time[0][0] ?? DateTime.now(),
                  locale: LocaleType.zh);
            },
          ),
          ListTile(
            title: Text('下班',textScaleFactor: 1.0),
            trailing: FlatButton(
                onPressed: null,
                child: Text('${_time[0][1].toString().substring(11, 16)}',textScaleFactor: 1.0)),
            onTap: () {
              DatePicker.showTimePicker(context, showTitleActions: true,
                  onConfirm: (date) {
                setState(() {
                  _time[0][1] = date;
                });
              },
                  currentTime: _time[0][1] ?? DateTime.now(),
                  locale: LocaleType.zh);
            },
          ),
          ListTile(
            title: Text('添加时段',textScaleFactor: 1.0),
            onTap: () {
              setState(() {
                _time[1][0] = DateTime.now();
                _time[1][1] = DateTime.now();
                _timeLength++;
              });
            },
          )
        ],
      );
    }
    if (_timeLength == 2) {
      return Column(
        children: <Widget>[
          ListTile(title: Text('上下班时段1',textScaleFactor: 1.0)),
          ListTile(
            title: Text('上班',textScaleFactor: 1.0),
            trailing: FlatButton(
                onPressed: null,
                child: Text('${_time[0][0].toString().substring(11, 16)}',textScaleFactor: 1.0)),
            onTap: () {
              DatePicker.showTimePicker(context, showTitleActions: true,
                  onConfirm: (date) {
                setState(() {
                  _time[0][0] = date;
                });
              },
                  currentTime: _time[0][0] ?? DateTime.now(),
                  locale: LocaleType.zh);
            },
          ),
          ListTile(
            title: Text('下班',textScaleFactor: 1.0),
            trailing: FlatButton(
                onPressed: null,
                child: Text('${_time[0][1].toString().substring(11, 16)}',textScaleFactor: 1.0)),
            onTap: () {
              DatePicker.showTimePicker(context, showTitleActions: true,
                  onConfirm: (date) {
                setState(() {
                  _time[0][1] = date;
                });
              },
                  currentTime: _time[0][1] ?? DateTime.now(),
                  locale: LocaleType.zh);
            },
          ),
          ListTile(
            title: Text('上下班时段2',textScaleFactor: 1.0),
            trailing: FlatButton(
                onPressed: () {
                  setState(() {
                    _time[1][0] = null;
                    _time[1][1] = null;
                    _timeLength--;
                  });
                },
                child: Text('删除',textScaleFactor: 1.0)),
          ),
          ListTile(
            title: Text('上班',textScaleFactor: 1.0),
            trailing: FlatButton(
                onPressed: null,
                child: Text('${_time[1][0].toString().substring(11, 16)}',textScaleFactor: 1.0)),
            onTap: () {
              DatePicker.showTimePicker(context, showTitleActions: true,
                  onConfirm: (date) {
                setState(() {
                  _time[1][0] = date;
                });
              },
                  currentTime: _time[1][0] ?? DateTime.now(),
                  locale: LocaleType.zh);
            },
          ),
          ListTile(
            title: Text('下班',textScaleFactor: 1.0),
            trailing: FlatButton(
                onPressed: null,
                child: Text('${_time[1][1].toString().substring(11, 16)}',textScaleFactor: 1.0)),
            onTap: () {
              DatePicker.showTimePicker(context, showTitleActions: true,
                  onConfirm: (date) {
                setState(() {
                  _time[1][1] = date;
                });
              },
                  currentTime: _time[1][1] ?? DateTime.now(),
                  locale: LocaleType.zh);
            },
          ),
          ListTile(
            title: Text('添加时段',textScaleFactor: 1.0),
            onTap: () {
              setState(() {
                _time[2][0] = DateTime.now();
                _time[2][1] = DateTime.now();
                _timeLength++;
              });
            },
          )
        ],
      );
    }
    if (_timeLength == 3) {
      return Column(
        children: <Widget>[
          Text('上下班时段1',textScaleFactor: 1.0),
          ListTile(
            title: Text('上班',textScaleFactor: 1.0),
            trailing: FlatButton(
                onPressed: null,
                child: Text('${_time[0][0].toString().substring(11, 16)}',textScaleFactor: 1.0)),
            onTap: () {
              DatePicker.showTimePicker(context, showTitleActions: true,
                  onConfirm: (date) {
                setState(() {
                  _time[0][0] = date;
                });
              },
                  currentTime: _time[0][0] ?? DateTime.now(),
                  locale: LocaleType.zh);
            },
          ),
          ListTile(
            title: Text('下班',textScaleFactor: 1.0),
            trailing: FlatButton(
                onPressed: null,
                child: Text('${_time[0][1].toString().substring(11, 16)}',textScaleFactor: 1.0)),
            onTap: () {
              DatePicker.showTimePicker(context, showTitleActions: true,
                  onConfirm: (date) {
                setState(() {
                  _time[0][1] = date;
                });
              },
                  currentTime: _time[0][1] ?? DateTime.now(),
                  locale: LocaleType.zh);
            },
          ),
          ListTile(title: Text('上下班时段2',textScaleFactor: 1.0)),
          ListTile(
            title: Text('上班',textScaleFactor: 1.0),
            trailing: FlatButton(
                onPressed: null,
                child: Text('${_time[1][0].toString().substring(11, 16)}',textScaleFactor: 1.0)),
            onTap: () {
              DatePicker.showTimePicker(context, showTitleActions: true,
                  onConfirm: (date) {
                setState(() {
                  _time[1][0] = date;
                });
              },
                  currentTime: _time[1][0] ?? DateTime.now(),
                  locale: LocaleType.zh);
            },
          ),
          ListTile(
            title: Text('下班',textScaleFactor: 1.0),
            trailing: FlatButton(
                onPressed: null,
                child: Text('${_time[1][1].toString().substring(11, 16)}',textScaleFactor: 1.0)),
            onTap: () {
              DatePicker.showTimePicker(context, showTitleActions: true,
                  onConfirm: (date) {
                setState(() {
                  _time[1][1] = date;
                });
              },
                  currentTime: _time[1][1] ?? DateTime.now(),
                  locale: LocaleType.zh);
            },
          ),
          ListTile(
            title: Text('上下班时段3',textScaleFactor: 1.0),
            trailing: FlatButton(
                onPressed: () {
                  setState(() {
                    _time[2][0] = null;
                    _time[2][1] = null;
                    _timeLength--;
                  });
                },
                child: Text('删除',textScaleFactor: 1.0)),
          ),
          ListTile(
            title: Text('上班',textScaleFactor: 1.0),
            trailing: FlatButton(
                onPressed: null,
                child: Text('${_time[2][0].toString().substring(11, 16)}',textScaleFactor: 1.0)),
            onTap: () {
              DatePicker.showTimePicker(context, showTitleActions: true,
                  onConfirm: (date) {
                setState(() {
                  _time[2][0] = date;
                });
              },
                  currentTime: _time[2][0] ?? DateTime.now(),
                  locale: LocaleType.zh);
            },
          ),
          ListTile(
            title: Text('下班',textScaleFactor: 1.0),
            trailing: FlatButton(
                onPressed: null,
                child: Text('${_time[2][1].toString().substring(11, 16)}',textScaleFactor: 1.0)),
            onTap: () {
              DatePicker.showTimePicker(context, showTitleActions: true,
                  onConfirm: (date) {
                setState(() {
                  _time[2][1] = date;
                });
              },
                  currentTime: _time[2][1] ?? DateTime.now(),
                  locale: LocaleType.zh);
            },
          ),
        ],
      );
    }
  }

  void _addTime() {}
  void _workingDay() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditRuleTimeChooseWorkingDayPage()));
  }
}

/*
 * 打卡时间选择工作日
 * create_time:2019/11/4
 * editor:ody997
 * email:hwk@growingpine.com
 */
class EditRuleTimeChooseWorkingDayPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EditRuleTimeChooseWorkingDayPageState();
  }
}

/*
 * dayLines 工作日列表 [bool,bool] 第一个bool 是否可选，第二个bool是否生效
 */
class EditRuleTimeChooseWorkingDayPageState
    extends State<EditRuleTimeChooseWorkingDayPage> {
  var dayLines = [
    [false, true],
    [false, true],
    [false, true],
    [false, true],
    [false, true],
    [false, true],
    [false, true]
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('工作日',textScaleFactor: 1.0),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('周一',textScaleFactor: 1.0),
            onTap: () {
              setState(() {
                dayLines[0][1] == true
                    ? dayLines[0][1] = false
                    : dayLines[0][1] = true;
              });
            },
            trailing: dayLines[0][1] == true ? Icon(Icons.check) : null,
          ),
          ListTile(
            title: Text('周二',textScaleFactor: 1.0),
            onTap: () {
              setState(() {
                dayLines[1][1] == true
                    ? dayLines[1][1] = false
                    : dayLines[1][1] = true;
              });
            },
            trailing: dayLines[1][1] == true ? Icon(Icons.check) : null,
          ),
          ListTile(
            title: Text('周三',textScaleFactor: 1.0),
            onTap: () {
              setState(() {
                dayLines[2][1] == true
                    ? dayLines[2][1] = false
                    : dayLines[2][1] = true;
              });
            },
            trailing: dayLines[2][1] == true ? Icon(Icons.check) : null,
          ),
          ListTile(
            title: Text('周四',textScaleFactor: 1.0),
            onTap: () {
              setState(() {
                dayLines[3][1] == true
                    ? dayLines[3][1] = false
                    : dayLines[3][1] = true;
              });
            },
            trailing: dayLines[3][1] == true ? Icon(Icons.check) : null,
          ),
          ListTile(
            title: Text('周五',textScaleFactor: 1.0),
            onTap: () {
              setState(() {
                dayLines[4][1] == true
                    ? dayLines[4][1] = false
                    : dayLines[4][1] = true;
              });
            },
            trailing: dayLines[4][1] == true ? Icon(Icons.check) : null,
          ),
          ListTile(
            title: Text('周六',textScaleFactor: 1.0),
            onTap: () {
              setState(() {
                dayLines[5][1] == true
                    ? dayLines[5][1] = false
                    : dayLines[5][1] = true;
              });
            },
            trailing: dayLines[5][1] == true ? Icon(Icons.check) : null,
          ),
          ListTile(
            title: Text('周日',textScaleFactor: 1.0),
            onTap: () {
              setState(() {
                dayLines[6][1] == true
                    ? dayLines[6][1] = false
                    : dayLines[6][1] = true;
              });
            },
            trailing: dayLines[6][1] == true ? Icon(Icons.check) : null,
          ),
        ],
      ),
    );
  }
}
