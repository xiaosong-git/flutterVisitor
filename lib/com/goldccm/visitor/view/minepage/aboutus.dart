import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info/package_info.dart';

//
// 关于我们
//
class AboutUs extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return AboutUsState();
  }
}
class AboutUsState extends State<AboutUs>{
  String version;
  @override
  void initState() {
    super.initState();
    getVersion();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Column(
        children: <Widget>[
          Container(
            color: Color(0xFFFFFFFF),
            height: ScreenUtil().setHeight(88)+MediaQuery.of(context).padding.top,
            width: ScreenUtil().setWidth(750),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                      right: ScreenUtil().setWidth(205), left: 0),
                  child: IconButton(
                      icon: Image(
                        image: AssetImage("assets/images/back_white.png"),
                        width: ScreenUtil().setWidth(36),
                        height: ScreenUtil().setHeight(36),
                        color: Color(0xFF595959),),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                        });
                      }),
                ),
                Text('关于我们', style: TextStyle(color: Color(0xFF373737),
                  fontSize: ScreenUtil().setSp(36),),),
              ],
            ),
          ),
          Divider(height: 1,),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(200)),
            child: Image(
              image: AssetImage('assets/images/login_logo.png'),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(8)),
            child: Text('V$version',textScaleFactor: 1.0,style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(30)),),
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(70)),
            child: Text('南京朋悦比邻信息科技有限公司',textScaleFactor: 1.0,style: TextStyle(color: Color(0xFF6C6C6C),fontSize: ScreenUtil().setSp(30)),),
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(16)),
            child: Text('版权所有@2018-2020',textScaleFactor: 1.0,style: TextStyle(color: Color(0xFF6C6C6C),fontSize: ScreenUtil().setSp(30)),),
          ),
        ],
      ),
    );
  }
  Future getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version=packageInfo.version;
    });
  }
}