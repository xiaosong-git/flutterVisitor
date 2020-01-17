import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//好友中心
//author:hwk<wenkun97@126.com>
//create_time:2020/1/17
class FriendList extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return FriendListState();
  }
}
class FriendListState extends State<FriendList>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通讯录'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
    );
  }
}