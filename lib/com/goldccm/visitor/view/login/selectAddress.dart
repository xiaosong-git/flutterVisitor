import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visitor/com/goldccm/visitor/meta/province.dart';

//地址选择
//create_time:2020/1/25
class SelectAddressPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return SelectAddressPageState();
  }
}
class SelectAddressPageState extends State<SelectAddressPage>{
  String selectProvince="";
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(ScreenUtil().setHeight(88)+MediaQuery.of(context).padding.top),
        child: AppBar(
          title: Text('1111'),
          flexibleSpace: Image(
            image: AssetImage('assets/images/login_navigation.png'),
            fit: BoxFit.cover,
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          buildListView(),
        ],
      ),
    );
  }
  buildListView(){
    print(provincesData.keys);
   return SliverList(
     delegate: SliverChildBuilderDelegate(
         (BuildContext context,int index){
           return ListTile(title: Text(provincesData.entries.elementAt(index).value),);
         },childCount: provincesData.keys.length,
     ));
  }
}