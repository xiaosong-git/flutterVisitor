import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/RuleInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';

import 'editrule.dart';
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
  List<RuleInfo> ruleLists=List();
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
          color: Colors.grey[200],
          padding: EdgeInsets.only(top: 10),
          child: ListView.separated(itemBuilder: (context,index){
            return Container(
              child: ListTile(
                title: Text(ruleLists[index].groupName??""),
                onTap: (){
                  Navigator.push(context,CupertinoPageRoute(builder: (context)=>EditRulePage(ruleInfo: ruleLists[index],)));
                },
              ),
              color: Colors.white,
            );
          },itemCount:ruleLists.length,separatorBuilder: (context,index){
            return Divider(height: 10,);
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
    getRules();
  }
  //添加新打卡规则
  settingRule(){
    //当前类型
    int currentIndex=_tabController.index;
    Navigator.push(context, CupertinoPageRoute(builder: (context)=>EditRulePage(type: currentIndex,ruleInfo: RuleInfo(),)));
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  //获取现有打卡规则
  getRules() async {
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String url="work/gainGroupIndex";
    String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
    var res = await Http().post(url,
        queryParameters: {
          "token": userInfo.token,
          "userId": userInfo.id,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "companyId": userInfo.companyId,
        },
        userCall: false);
    if(res is String){
      Map map = jsonDecode(res);
      if(map['verify']['sign']=="success"){
        for(var res in map['data']){
          RuleInfo _rule=RuleInfo.fromJson(res);
          setState(() {
            ruleLists.add(_rule);
          });
        }
      }
    }
  }
}