import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/RoomInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/RoomOrderInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'RoomCheckOut.dart';
/*
 * 共享 - 详细订单
 * email:hwk@growingpine.com
 * create_time:2019/10/22
 */
class RoomDetail extends StatefulWidget {
  final RoomInfo roomInfo;
  RoomDetail({Key key, this.roomInfo}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return RoomDetailState();
  }
}
/*
 * 时间条
 * 点击两次选中他们之间的时间块
 * firstCount是第一块选中的时间
 * lastCount是最后一块选中的时间
 */
class ListState {
  int selectFlag = 0;
  int firstCount = -1;
  int lastCount = 10000;
  List<TimeSquare> _list = <TimeSquare>[
    TimeSquare(0, "9:00", 9),
    TimeSquare(0, "9:30", 9.5),
    TimeSquare(0, "10:00", 10),
    TimeSquare(0, "10:30", 10.5),
    TimeSquare(0, "11:00", 11),
    TimeSquare(0, "11:30", 11.5),
    TimeSquare(0, "12:00", 12),
    TimeSquare(0, "12:30", 12.5),
    TimeSquare(0, "13:00", 13),
    TimeSquare(0, "13:30", 13.5),
    TimeSquare(0, "14:00", 14),
    TimeSquare(0, "14:30", 14.5),
    TimeSquare(0, "15:00", 15),
    TimeSquare(0, "15:30", 15.5),
    TimeSquare(0, "16:00", 16),
    TimeSquare(0, "16:30", 16.5),
    TimeSquare(0, "17:00", 17),
    TimeSquare(0, "17:30", 17.5),
    TimeSquare(0, "18:00", 18),
    TimeSquare(0, "18:30", 18.5),
    TimeSquare(0, "19:00", 19),
    TimeSquare(0, "19:30", 19.5),
    TimeSquare(0, "20:00", 20),
    TimeSquare(0, "20:30", 20.5),
    TimeSquare(0, "21:00", 21),
    TimeSquare(0, "21:30", 21.5),
    TimeSquare(0, "22:00", 22),
    TimeSquare(0, "22:30", 22.5),
    TimeSquare(0, "23:00", 23)
  ];
  setList(list) {
    _list = list;
  }

  getList() {
    return _list;
  }
  targetPosition(int count, int status) {
    if (_list[count].status != -1) {
      if (selectFlag == 0) {
          firstCount = count;
          selectFlag += 1;
          changeStatus(count, 1);
      } else if (selectFlag == 1) {
        lastCount = count;
        if (firstCount == count) {
            selectFlag = 0;
            changeStatus(firstCount, 0);
        } else {
          bool allowed = true;
          if(firstCount>count){
            int mid=firstCount;
            firstCount=lastCount;
            lastCount=mid;
          }
          for (int i = firstCount ; i <= lastCount; i++) {
            if (_list[i].status == -1) {
              allowed = false;
            }
          }
          if (allowed == true) {
              selectFlag += 1;
            for (int i = firstCount ; i <= lastCount; i++) {
              changeStatus(i, 1);
            }
          } else {
            selectFlag = 0;
            changeStatus(firstCount, 0);
            ToastUtil.showShortClearToast("选择时间段已被预订");
          }
        }
      } else {
        changeALot(firstCount, lastCount, 0);
        selectFlag = 0;
      }
    }
  }
  changeALot(int first, int last, int status) {
    for (int i = first; i <= last; i++) {
      changeStatus(i, status);
    }
  }

  changeStatus(count, status) {
    _list[count].status = status;
  }
}

class RoomDetailState extends State<RoomDetail> {
  ListState _listState1 = new ListState();
  ListState _listState2 = new ListState();
  ListState _listState3 = new ListState();
  ListState _listState4 = new ListState();
  ListState _listState5 = new ListState();
  List<ListState> _stateList = new List<ListState>();
  UserInfo _userInfo = new UserInfo();
  ScrollController _scrollController = new ScrollController();
  final double expandedHeight = 70.0;
  int _index = 0;
  DateTime bookDate = DateTime.now();

  ///获取用户信息
  getUserInfo() async {
    UserInfo userInfo = await DataUtils.getUserInfo();
    if (userInfo != null) {
      setState(() {
        _userInfo = userInfo;
      });
    }
  }
  removeUnused() async {
    RoomInfo roomInfo = widget.roomInfo;
    for(int j = 0;j<_stateList.length;j++){
      for (int i = 0; i < _stateList[j].getList().length; i++) {
        if (_stateList[j].getList()[i].value < double.parse(roomInfo.roomOpenTime.replaceAll(":30", ".5").replaceAll(":00",".0"))) {
          setState(() {
            _stateList[j].changeStatus(i, -1);
          });
        }
        if(_stateList[j].getList()[i].value > double.parse(roomInfo.roomCloseTime.replaceAll(":30", ".5").replaceAll(":00",".0"))){
          setState(() {
            _stateList[j].changeStatus(i, -1);
          });
        }
      }
    }
  }

  removePast() async{
      for (int i = 0; i < _stateList[0].getList().length; i++) {
        if (_stateList[0].getList()[i].value <= double.parse(DateTime.now().hour.toString())) {
          setState(() {
            _stateList[0].changeStatus(i, -1);
          });
        }
      }
  }

  getRoomStatus() async {
    String url ="meeting/roomStatus";
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url, queryParameters: {
      'room_id': widget.roomInfo.id,
      "token": _userInfo.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "userId": _userInfo.id,
    },debugMode: true);
    if (res is String) {
      Map map = jsonDecode(res);
      if (map['data'].length > 0) {
        for (int j = 0; j < map['data'].length; j++) {
          String timeInterval = map['data'][j]['time_interval'];
          var result = timeInterval.split(",");
          for (String value in result) {
            for (int i = 0; i < _stateList[j].getList().length; i++) {
              if (_stateList[j].getList()[i].value == double.parse(value)) {
                setState(() {
                  _stateList[j].changeStatus(i, -1);
                });
              }
            }
          }
        }
      }
    }
  }

  double get top {
    double res = expandedHeight;
    if (_scrollController.hasClients) {
      double offset = _scrollController.offset;
      res -= offset;
    }
    return res;
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    getRoomStatus();
    _stateList.add(_listState1);
    _stateList.add(_listState2);
    _stateList.add(_listState3);
    _stateList.add(_listState4);
    _stateList.add(_listState5);
    removeUnused();
    removePast();
    _scrollController.addListener(() {
      var maxScroll = _scrollController.position.maxScrollExtent;
      var pixel = _scrollController.position.pixels;
      if (maxScroll == pixel) {
        setState(() {});
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Stack(
          children: <Widget>[
            CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                SliverAppBar(
                  title: Text(
                    "共享会议室",
                    textAlign: TextAlign.center,
                    style: new TextStyle(fontSize: 17.0, color: Colors.white),textScaleFactor: 1.0,
                  ),
                  leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  expandedHeight: 100.0,
                  backgroundColor: Theme.of(context).appBarTheme.color,
                  centerTitle: true,
                ),
                SliverPadding(
                    padding: const EdgeInsets.fromLTRB(10, 280, 10, 0),
                    sliver: SliverToBoxAdapter(
                      child: IndexedStack(
                        index: _index,
                        children: <Widget>[
                          Container(
                            child: Card(
                              child: timeTable(_listState1, 0),
                              elevation: 10.0,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                new BoxShadow(
                                  color: Colors.white12,
                                  blurRadius: 3.0,
                                  offset: new Offset(0.0, 3.0),
                                ),
                              ],
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            child: Card(
                              child: timeTable(_listState2, 1),
                              elevation: 10.0,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                new BoxShadow(
                                  color: Colors.white12,
                                  blurRadius: 3.0,
                                  offset: new Offset(0.0, 3.0),
                                ),
                              ],
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            child: Card(
                              child: timeTable(_listState3, 2),
                              elevation: 10.0,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                new BoxShadow(
                                  color: Colors.white12,
                                  blurRadius: 3.0,
                                  offset: new Offset(0.0, 3.0),
                                ),
                              ],
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            child: Card(
                              child: timeTable(_listState4, 3),
                              elevation: 10.0,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                new BoxShadow(
                                  color: Colors.white12,
                                  blurRadius: 3.0,
                                  offset: new Offset(0.0, 3.0),
                                ),
                              ],
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            child: Card(
                              child: timeTable(_listState5, 4),
                              elevation: 10.0,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                new BoxShadow(
                                  color: Colors.white12,
                                  blurRadius: 3.0,
                                  offset: new Offset(0.0, 3.0),
                                ),
                              ],
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            Positioned(
              left: 10,
              right: 10,
              top: top,
              child: Container(
                child: Card(
                  child: roomListWidget(widget.roomInfo),
                  elevation: 10.0,
                ),
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    new BoxShadow(
                      color: Colors.white12,
                      blurRadius: 3.0,
                      offset: new Offset(0.0, 3.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget roomListWidget(RoomInfo room) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 328,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Stack(
              children: <Widget>[
                Positioned(
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child:
                    (room.roomImage[0]!=null&&room.roomImage[0]!="")?Image.network(RouterUtil.imageServerUrl+room.roomImage[0]) :
                    Image.asset("assets/images/visitor_icon_nodata.png"),
                  ),
                  height: 180,
                  left: 8,
                  right: 8,
                  bottom: 18,
                ),
                Positioned(
                  child: Text(
                    '${room.roomName}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  left: 8,
                  width: 250,
                  top: 8,
                ),
                Positioned(
                  child: Text(
                    '${room.roomAddress}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  left: 8,
                  width: 250,
                  top: 42,
                ),
                Positioned(
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.blue[200],
                    ),
                    child: Text(
                      '开放时间：${room.roomOpenTime}-${room.roomCloseTime}',
                      style: TextStyle(fontSize: 10.0, color: Colors.blue[700]),textScaleFactor: 1.0,
                    ),
                  ),
                  top: 68,
                  left: 8,
                ),
                Positioned(
                  child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        color: Colors.orange[200],
                      ),
                      child: room.roomType == 1
                          ? Text(
                              '容纳约1-10人',
                              style: TextStyle(
                                  fontSize: 10.0, color: Colors.orange[700]),textScaleFactor: 1.0,
                            )
                          : room.roomType == 2
                              ? Text(
                                  '容纳约10-20人',
                                  style: TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.orange[700]),textScaleFactor: 1.0,
                                )
                              : Text(
                                  '容纳约30人以上',
                                  style: TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.orange[700]),textScaleFactor: 1.0,
                                )),
                  top: 68,
                  left: 120,
                ),
              ],
            ),
          ),
    );
  }

  switchWeekDay(int weekDay) {
    if (weekDay == 1) {
      return '周一';
    } else if (weekDay == 2) {
      return '周二';
    } else if (weekDay == 3) {
      return '周三';
    } else if (weekDay == 4) {
      return '周四';
    } else if (weekDay == 5) {
      return '周五';
    } else if (weekDay == 6) {
      return '周六';
    } else if (weekDay == 7) {
      return '周日';
    } else {
      return '';
    }
  }

  bookRoom(int userID, int roomID, String timeLines, int day) async {
    var splits = timeLines.split(",");
    String url =  "meeting/reserve";
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url,
        queryParameters: ({
          "userId": userID,
          'room_id': roomID,
          'apply_date': DateFormat('yyyy-MM-dd')
              .format(DateTime.now().add(Duration(days: day))),
          'time_interval': timeLines,
          'apply_start_time': splits[0],
          'apply_end_time':
              (double.parse(splits[splits.length - 1]) + 0.5).toString(),
          "token": _userInfo.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
        }),userCall: true);
    if(res!=""&&res!=null&&res!="isBlocking"){
      if (res is String) {
        Map map = jsonDecode(res);
        if (map['verify']['sign'] == "success") {
          RoomOrderInfo roomOrderInfo=new RoomOrderInfo(id: int.parse(map['verify']['code']));
          RoomInfo roomInfo=widget.roomInfo;
          roomInfo.roomPrice=(double.parse(roomInfo.roomPrice)/2).toString();
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => RoomCheckOut(
                    userInfo: _userInfo,
                    roomInfo: widget.roomInfo,
                    timeLines: timeLines,
                    startTime: splits[0],
                    endTime: (double.parse(splits[splits.length - 1]) + 0.5)
                        .toString(),
                    day: day,
                    count: splits.length,
                    roomOrderInfo: roomOrderInfo,
                  )));
//      Navigator.push(context, CupertinoPageRoute(builder: (context)=>RoomHistory(userInfo:_userInfo,)));
        } else {
          ToastUtil.showShortToast(map['verify']['desc']);
        }
      }
    }else{
      ToastUtil.showShortToast("预定失败");
      Navigator.pop(context);
    }
  }

  Widget timeTable(ListState listState, int day) {

    Widget TimeTableRow(ListState lists, int index) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width / 5,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(150),
            ),
            margin: EdgeInsets.only(top: 10, bottom: 5),
            child: FlatButton(
              child: Text(
                lists.getList()[0 + index * 4].time.toString(),
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),textScaleFactor: 1.0,
              ),
              color: lists.getList()[0 + index * 4].status == 0
                  ? Colors.white
                  : lists.getList()[0 + index * 4].status == 1
                      ? Colors.green
                      : Colors.red,
              onPressed: () {
                setState(() {
                  if (lists.getList()[0 + index * 4].status == 0)
                    lists.targetPosition(0 + index * 4, 1);
                  else if (lists.getList()[0 + index * 4].status == 1)
                    lists.targetPosition(0 + index * 4, 0);
                });
              },
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                  side: BorderSide(color: Colors.black12)),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 5,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(150),
            ),
            margin: EdgeInsets.only(top: 10, bottom: 5),
            child: FlatButton(
              child: Text(
                lists.getList()[1 + index * 4].time.toString(),
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),textScaleFactor: 1.0,
              ),
              color: lists.getList()[1 + index * 4].status == 0
                  ? Colors.white
                  : lists.getList()[1 + index * 4].status == 1
                      ? Colors.green
                      : Colors.red,
              onPressed: () {
                setState(() {
                  if (lists.getList()[1 + index * 4].status == 0)
                    lists.targetPosition(1 + index * 4, 1);
                  else if (lists.getList()[1 + index * 4].status == 1)
                    lists.targetPosition(1 + index * 4, 0);
                });
              },
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                  side: BorderSide(color: Colors.black12)),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 5,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(150),
            ),
            margin: EdgeInsets.only(top: 10, bottom: 5),
            child: FlatButton(
              child: Text(
                lists.getList()[2 + index * 4].time.toString(),
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),textScaleFactor: 1.0,
              ),
              color: lists.getList()[2 + index * 4].status == 0
                  ? Colors.white
                  : lists.getList()[2 + index * 4].status == 1
                      ? Colors.green
                      : Colors.red,
              onPressed: () {
                setState(() {
                  if (lists.getList()[2 + index * 4].status == 0)
                    lists.targetPosition(2 + index * 4, 1);
                  else if (lists.getList()[2 + index * 4].status == 1)
                    lists.targetPosition(2 + index * 4, 0);
                });
              },
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                  side: BorderSide(color: Colors.black12)),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 5,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(150),
            ),
            margin: EdgeInsets.only(top: 10, bottom: 5),
            child: FlatButton(
              child: Text(
                lists.getList()[3 + index * 4].time.toString(),
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),textScaleFactor: 1.0,
              ),
              color: lists.getList()[3 + index * 4].status == 0
                  ? Colors.white
                  : lists.getList()[3 + index * 4].status == 1
                      ? Colors.green
                      : Colors.red,
              onPressed: () {
                setState(() {
                  if (lists.getList()[3+ index * 4].status == 0)
                    lists.targetPosition(3 + index * 4, 1);
                  else if (lists.getList()[3 + index * 4].status == 1)
                    lists.targetPosition(3 + index * 4, 0);
                });
              },
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                  side: BorderSide(color: Colors.black12)),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              '预定日期',
              style: TextStyle(fontSize: 14.0),textScaleFactor: 1.0,
            ),
            subtitle: Text(
              '${bookDate.month}月${bookDate.day}日 ${switchWeekDay(bookDate.weekday)}',
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),textScaleFactor: 1.0,
            ),
            onTap: () {
              DateTime maxDate=DateTime.now().add(Duration(days: 4));
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(DateTime.now().year, DateTime.now().month,
                      DateTime.now().day),
                  maxTime: DateTime(maxDate.year,maxDate.month,maxDate.day),
                  onConfirm: (date) {
                setState(() {
                  bookDate = date;
                  _index = date.difference(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day)).inDays;
                });
              }, currentTime: DateTime.now(), locale: LocaleType.zh);
            },
          ),
          Divider(
            height: 0,
          ),
          ListTile(
            title: Text(
              '预定时间',
              style: TextStyle(fontSize: 14.0),textScaleFactor: 1.0,
            ),
          ),
          TimeTableRow(
            listState,
            0,
          ),
          TimeTableRow(
            listState,
            1,
          ),
          TimeTableRow(
            listState,
            2,
          ),
          TimeTableRow(
            listState,
            3,
          ),
          TimeTableRow(
            listState,
            4,
          ),
          TimeTableRow(
            listState,
            5,
          ),
          TimeTableRow(
            listState,
            6,
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            child: new SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              child: RaisedButton(
                  color: Colors.blue,
                  child: Text(
                    '确认',
                    style: TextStyle(color: Colors.white),textScaleFactor: 1.0,
                  ),
                  onPressed: () {
                    String timeLines = "";
                    int count = 0;
                    for (int i = 0; i < listState.getList().length; i++) {
                      if (i + 1 < listState.getList().length &&
                          listState.getList()[i].status != 1 &&
                          listState.getList()[i + 1].status == 1) {
                        count++;
                      }
                      if (listState.getList()[i].status == 1) {
                        timeLines +=
                            listState.getList()[i].value.toString() + ",";
                      }
                    }
                    timeLines = timeLines.substring(0, timeLines.length - 1);
                    if (count > 1) {
                      ToastUtil.showShortToast("请选取连续的时间段");
                    } else {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return new Material(
                              //创建透明层
                              type: MaterialType.transparency, //透明类型
                              child: new Center(
                                //保证控件居中效果
                                child: new SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
                                  height: MediaQuery.of(context).size.width / 3,
                                  child: new Container(
                                    decoration: ShapeDecoration(
                                      color: Color(0xffffffff),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                    child: new Stack(
                                      children: <Widget>[
                                        Positioned(
                                          child: new Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20.0, bottom: 20.0),
                                            child: new Text(
                                              '确认预定？',
                                              style: new TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),textScaleFactor: 1.0,
                                            ),
                                          ),
                                          left: 85,
                                        ),
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          child: FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                bookRoom(
                                                    _userInfo.id,
                                                    widget.roomInfo.id,
                                                    timeLines,
                                                    day);
                                              },
                                              child: Text(
                                                '预定',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Colors.blue),textScaleFactor: 1.0,
                                              )),
                                        ),
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                '我再想想',
                                                textAlign: TextAlign.center,
                                                style:
                                                    TextStyle(fontSize: 16.0),textScaleFactor: 1.0,
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                    }
                  }),
            ),
          )
        ],
      ),
    );
  }
}

class TimeSquare {
  int status;
  String time;
  double value;
  TimeSquare(this.status, this.time, this.value);
}
