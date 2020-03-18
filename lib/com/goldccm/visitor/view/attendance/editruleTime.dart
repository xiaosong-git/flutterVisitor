import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:visitor/com/goldccm/visitor/model/RuleInfoDetail.dart';

/*
 * 规则打卡时间设置
 * editor:ody997
 * create_time:2019/11/4
 * email:hwk@growingpine.com
 */
class EditRuleTimePage extends StatefulWidget {
  final List<CheckInDate> cList;
  EditRuleTimePage({Key key,this.cList}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return EditRuleTimePageState();
  }
}

/*
 *
 */
class EditRuleTimePageState extends State<EditRuleTimePage> {
  List<CheckInDate> _list;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('打卡时间',textScaleFactor: 1.0),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text('添加打卡时间',textScaleFactor: 1.0),
                onTap: _callAddTime,
              ),
              _list.length>0?Divider():Container(),
              ListView.separated(itemBuilder: (context,index){
                return ListTile(title:Text('时段'),subtitle: Text('${_list[index].timeInterval}'),);
              }, separatorBuilder: (context,index){
                return Divider();
              }, itemCount: _list.length,shrinkWrap: true,)
            ],
          )
        )
    );
  }

  void _callAddTime() {
    Navigator.push(context,
        CupertinoPageRoute(builder: (context) => EditRuleTimeAddPage())).then((value){
          if(value!=null&&value!=""){
            int num=value[3][0];
            CheckInDate _check=CheckInDate();
          }
    });
  }

  @override
  void initState() {
    super.initState();
    getAllTime();
  }

  //初始化打卡时间列表
  void getAllTime() {
    if(widget.cList!=null){
      setState(() {
        _list=widget.cList;
      });
    }else{
      _list=new List();
    }
  }
}

/*
 * 规则添加打卡时间
 */
class EditRuleTimeAddPage extends StatefulWidget {
  final CheckInDate checkInDate;
  EditRuleTimeAddPage({Key key,this.checkInDate}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return EditRuleTimeAddPageState();
  }
}

class EditRuleTimeAddPageState extends State<EditRuleTimeAddPage> {
  CheckInDate _checkInDate=CheckInDate();
  var _time = [
    [DateTime.now(), DateTime.now()],
    [DateTime.now(), DateTime.now()],
    [DateTime.now(), DateTime.now()],
    [0,0]
  ];
  @override
  void initState() {
    super.initState();
    initDate();
  }
  initDate(){
    if(widget.checkInDate!=null){
      _checkInDate=widget.checkInDate;
      if(_checkInDate.timeInterval!=null){
        var timeInterval=_checkInDate.timeInterval.split(",");
        if(timeInterval.length==2) {
          _timeLength=1;
          _time[0][0]=DateTime.parse(timeInterval[0]);
          _time[0][1]=DateTime.parse(timeInterval[1]);
        }
        if(timeInterval.length==4){
          _timeLength=2;
          _time[0][0]=DateTime.parse(timeInterval[0]);
          _time[0][1]=DateTime.parse(timeInterval[1]);
          _time[1][0]=DateTime.parse(timeInterval[2]);
          _time[1][1]=DateTime.parse(timeInterval[3]);
        }
        if(timeInterval.length==6){
          _timeLength=3;
          _time[0][0]=DateTime.parse(timeInterval[0]);
          _time[0][1]=DateTime.parse(timeInterval[1]);
          _time[1][0]=DateTime.parse(timeInterval[2]);
          _time[1][1]=DateTime.parse(timeInterval[3]);
          _time[2][0]=DateTime.parse(timeInterval[4]);
          _time[2][1]=DateTime.parse(timeInterval[5]);
        }
      }
    }
  }
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
                child: Text('${DateFormat('HH:mm').format(_time[0][0])}',textScaleFactor: 1.0)),
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
                child: Text('${DateFormat('HH:mm').format(_time[0][1])}',textScaleFactor: 1.0)),
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
                child: Text('${DateFormat('HH:mm').format(_time[0][0])}',textScaleFactor: 1.0)),
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
                child: Text('${DateFormat('HH:mm').format(_time[0][1])}',textScaleFactor: 1.0)),
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
                child: Text('${DateFormat('HH:mm').format(_time[1][0])}',textScaleFactor: 1.0)),
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
                child: Text('${DateFormat('HH:mm').format(_time[1][1])}',textScaleFactor: 1.0)),
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
                child: Text('${DateFormat('HH:mm').format(_time[0][0])}',textScaleFactor: 1.0)),
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
                child: Text('${DateFormat('HH:mm').format(_time[0][1])}',textScaleFactor: 1.0)),
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
                child: Text('${DateFormat('HH:mm').format(_time[1][0])}',textScaleFactor: 1.0)),
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
                child: Text('${DateFormat('HH:mm').format(_time[1][1])}',textScaleFactor: 1.0)),
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
                child: Text('${DateFormat('HH:mm').format(_time[2][0])}',textScaleFactor: 1.0)),
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
                child: Text('${DateFormat('HH:mm').format(_time[2][1])}',textScaleFactor: 1.0)),
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

  void _addTime() {
    _time[3][0]=_timeLength;
    Navigator.pop(context,_time,);
  }
  void _workingDay() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => EditRuleTimeChooseWorkingDayPage(workDays: _checkInDate.workDays,))).then((value){
              if(value!=null){
                setState(() {
                  _checkInDate.workDays=value;
                });}
    });
  }
}

/*
 * 打卡时间选择工作日
 * create_time:2019/11/4
 * editor:ody997
 * email:hwk@growingpine.com
 */
class EditRuleTimeChooseWorkingDayPage extends StatefulWidget {
  final String workDays;
  EditRuleTimeChooseWorkingDayPage({Key key,this.workDays}):super(key:key);
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
    [false, false],
    [false, false],
    [false, false],
    [false, false],
    [false, false],
    [false, false],
    [false, false]
  ];

  @override
  void initState() {
    super.initState();
    initDays();
  }
  initDays(){
    if(widget.workDays!=""&&widget.workDays!=null){
      var day=widget.workDays.split(",");
      setState(() {
        for(var num in day){
          dayLines[int.parse(num)-1][0]=true;
        }
      });
    }
  }
  checkDays(){
    String days="";
    for(int i=0;i<7;i++){
      if(dayLines[i][1]){
        int index=i+1;
        days=days+"$index,";
      }
    }
    if(days.length>0){
      days=days.substring(0,days.length-1);
    }
    Navigator.pop(context,days);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('工作日',textScaleFactor: 1.0),
        automaticallyImplyLeading: false,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){checkDays();}),
      ),
      body: WillPopScope(
        child: Column(
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
        onWillPop: (){
          checkDays();
          return Future.value(false);
        },
      )
    );
  }
}
