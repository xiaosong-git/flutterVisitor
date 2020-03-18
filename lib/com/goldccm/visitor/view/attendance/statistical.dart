import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/CheckRecord.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';

class StatisticalPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return StatisticalPageState();
  }

}
class StatisticalPageState extends State<StatisticalPage>{
  CalendarController _calendarController;
  DateTime _selectDay;
  DateTime _focusDay;
  List<CheckRecord> _list=List();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy年MM月').format(_focusDay)),
      ),
      body: SingleChildScrollView(
        child:Column(
          children: <Widget>[
            TableCalendar(
                calendarController: _calendarController,
                locale: 'zh_CN',
                headerVisible: false,
                onDaySelected: _onDateSelected,
                onVisibleDaysChanged: _onVisibleDaysChanged,
                availableCalendarFormats:const{
                  CalendarFormat.month:'Month',
//              CalendarFormat.week:'Week',
                },
              ),
            Container(
              width: ScreenUtil().setWidth(750),
              height: ScreenUtil().setHeight(80),
              color: Colors.grey[100],
              padding: EdgeInsets.only(left: 20,top: 10,),
              child: Text('当日考勤'),
            ),
            _list.length>0?Container(
              height: ScreenUtil().setHeight(550),
              child: ListView.builder(itemBuilder: (context,index){
                return ListTile(title: Text('${_list[index].time}',style: TextStyle(fontSize: 20),),subtitle: Text('${_list[index].location}'),);
              },itemCount: _list.length,),
            ):Container(
              padding: EdgeInsets.only(top: 50),
              child: Text('无打卡记录'),
            )
          ],
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _selectDay=DateTime.now();
    _focusDay=DateTime.now();
    getDay(DateTime.now());
  }
  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }
  void _onDateSelected(DateTime day, List events){
      setState(() {
        _selectDay=day;
        getDay(day);
      });
  }
  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format){
      setState(() {
        _focusDay=_calendarController.focusedDay;
      });
  }
  Future<void> getDay(DateTime day) async {
      _list.clear();
      UserInfo userInfo = await LocalStorage.load("userInfo");
      String url="work/gainDay";
      String date=DateFormat('yyyy-MM-dd').format(day);
      String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
      var res = await Http().post(url,
          queryParameters: {
            "token": userInfo.token,
            "userId": userInfo.id,
            "factor": CommonUtil.getCurrentTime(),
            "threshold": threshold,
            "requestVer": await CommonUtil.getAppVersion(),
            "companyId":userInfo.companyId,
            "date":date,
          },
          userCall: false);
      if(res is String){
        Map map = jsonDecode(res);
        if(map['verify']['sign']=="success"){
          for(var res in map['data']){
            CheckRecord checkRecord = CheckRecord.fromJson(res);
            setState(() {
              _list.add(checkRecord);
            });
          }
        }
      }
  }
}