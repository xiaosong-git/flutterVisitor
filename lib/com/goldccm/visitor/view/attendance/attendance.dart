import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/view/attendance/check.dart';
import 'package:visitor/com/goldccm/visitor/view/attendance/rule.dart';
import 'package:visitor/com/goldccm/visitor/view/attendance/statistical.dart';

/*
 * 打卡主界面
 * 包括三个子界面 打卡 统计 规则
 * email:hwk@growingpine.com
 * create_time:2019/10/28
 */
class AttendancePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return AttendancePageState();
  }
}

class AttendancePageState extends State<AttendancePage>{
  List _tabLists=['打卡','统计','规则'];
  var _tabIcons = [['assets/icons/attendance_check.png','assets/icons/attendance_check_verify.png'],['assets/icons/attendance_statis.png','assets/icons/attendance_statis_verify.png'],['assets/icons/attendance_rule.png','assets/icons/attendance_rule_verify.png']];
  int _tabIndex = 0;
  List<Widget> _pages;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: _pages[_tabIndex],
      bottomNavigationBar:
      BottomNavigationBar(
        items:<BottomNavigationBarItem>[
          BottomNavigationBarItem(title: Text(_tabLists[0]),icon: Image.asset(reverseIcon(0),scale: 6.0,)),
          BottomNavigationBarItem(title: Text(_tabLists[1]),icon: Image.asset(reverseIcon(1),scale: 6.0,)),
          BottomNavigationBarItem(title: Text(_tabLists[2]),icon: Image.asset(reverseIcon(2),scale: 6.0,)),
        ],
          currentIndex: _tabIndex,
        onTap: (index){
          setState(() {
            _tabIndex=index;
          });
        },
      ),
    );
  }
  @override
  void initState() {
    //初始化子界面列表
    super.initState();
    _pages = [
      CheckPointPage(),
      StatisticalPage(),
      RulePage(),
    ];
  }
  //切换当前页面的图标从未选择到选择
  reverseIcon(int currentIndex){
    print(_tabIndex);
    if(currentIndex==_tabIndex){
      return _tabIcons[currentIndex][1];
    }else{
      return _tabIcons[currentIndex][0];
    }
  }
}