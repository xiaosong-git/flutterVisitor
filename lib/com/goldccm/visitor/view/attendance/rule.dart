import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/view/attendance/editrule.dart';
/*
 * 规则界面
 * email:hwk@growingpine.com
 * create_time:2019/10/28
 */
class RulePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return RulePageState();
  }
}
/*
 * 打卡规则分为上下班和外出两种
 * 点击规则进入详情页
 * 右上角添加新规则
 */
class RulePageState extends State<RulePage> with SingleTickerProviderStateMixin{
  var _tabLists=['上下班','外出'];
  TabController _tabController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('规则'),
        actions: <Widget>[
          IconButton(
              icon: Image.asset(
                "assets/icons/user_addfriend.png",
                scale: 2.0,
              ),
              onPressed: () {
                settingRule();
              }),
        ],
        bottom: TabBar(tabs:_tabLists.map((e)=>Tab(text: e,)).toList(),controller: _tabController,indicatorColor: Colors.blue,labelColor: Colors.white,),
      ),
      body: TabBarView(children: <Widget>[
        Container(
          child: ListTile(title: Text('规则1'),onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>EditRulePage()));
          },),
        ),
        Container(
        ),
      ],controller: _tabController,),
    );
  }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLists.length, vsync: this);
  }
  //添加新打卡规则
  settingRule(){
    //当前类型
    int currentIndex=_tabController.index;
    Navigator.push(context, MaterialPageRoute(builder: (context)=>EditRulePage(type: currentIndex,)));
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}