import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/model/AddressInfo.dart';

/*
 * 访问/邀约地址选择
 * Author:ody997
 * Email:hwk@growingpine.com
 * 2019/10/16
 */
class VisitAddress extends StatelessWidget{
  final List<AddressInfo> lists;
  const VisitAddress({Key key, this.lists}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('选择地址',textScaleFactor: 1.0),
        centerTitle: true,
      ),
      body: ListView.builder(itemBuilder: (context,index){
        return ListTile(
          title: Text(lists[index].companyName!=null?lists[index].companyName:"",textScaleFactor: 1.0,),
          subtitle: Text(lists[index].userName!=null?lists[index].userName:"",textScaleFactor: 1.0,),
          onTap: (){
            Navigator.pop(context,index);
          },
        );
      },itemCount: lists.length,
      ),
    );
  }
}