import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy年MM月').format(_focusDay)),
      ),
      body: Column(
        children: <Widget>[
          TableCalendar(
            calendarController: _calendarController,
            locale: 'zh_CN',
            headerVisible: false,
            onDaySelected: _onDateSelected,
            onVisibleDaysChanged: _onVisibleDaysChanged,
            availableCalendarFormats:const{
              CalendarFormat.month:'Month',
              CalendarFormat.week:'Week',
            },
          ),
          Column(
            children: <Widget>[
              Card(
                child: Column(
                  children: <Widget>[
                    Text('上下班统计'),
                    Container(
                      color: Colors.white,
                      child: Row(
                          children: <Widget>[
                            Material(
                              color: Colors.white,
                              child: InkWell(
                                child: Container(
                                  width: 80,
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    children: <Widget>[
                                      Text('迟到'),
                                    ],
                                  ),
                                ),
                                onTap: () {

                                },
                                splashColor: Colors.black12,
                                borderRadius: BorderRadius.circular(18.0),
                                radius: 30,
                              ),
                            ),
                            Material(
                              color: Colors.white,
                              child: InkWell(
                                child: Container(
                                  width: 80,
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    children: <Widget>[
                                      Text('早退'),
                                    ],
                                  ),
                                ),
                                onTap: () {

                                },
                                splashColor: Colors.black12,
                                borderRadius: BorderRadius.circular(18.0),
                                radius: 30,
                              ),
                            ),
                            Material(
                              color: Colors.white,
                              child: InkWell(
                                child: Container(
                                  width: 80,
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    children: <Widget>[
                                      Text('缺卡'),
                                    ],
                                  ),
                                ),
                                onTap: () {

                                },
                                splashColor: Colors.black12,
                                borderRadius: BorderRadius.circular(18.0),
                                radius: 30,
                              ),
                            ),
                          ],
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      )
    );
  }
  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _selectDay=DateTime.now();
    _focusDay=DateTime.now();
  }
  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }
  void _onDateSelected(DateTime day, List events){
      setState(() {
        _selectDay=day;
      });
  }
  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format){
      setState(() {
        _focusDay=_calendarController.focusedDay;
      });
  }
}