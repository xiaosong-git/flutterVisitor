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
//                appbarMore();
              }),
        ],
        bottom: TabBar(tabs:_tabLists.map((e)=>Tab(text: e,)).toList(),controller: _tabController,indicatorColor: Colors.blue,),
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
  settingNormal(){

  }
  settingOut(){

  }
}