import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';

  class MsgSettingPage extends StatefulWidget{
    final FriendInfo user;
    MsgSettingPage({Key key,this.user}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return MsgSettingState();
  }
}
class MsgSettingState extends State<MsgSettingPage>{
    bool _isTop=false;
    bool _isIngore=false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('消息设置',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF373737)),),
        centerTitle: true,
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 1,
        brightness: Brightness.light,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Image(
              image: AssetImage("assets/images/login_back.png"),
              width: ScreenUtil().setWidth(36),
              height: ScreenUtil().setHeight(36),
              color: Color(0xFF373737),),
            onPressed: () {
              setState(() {
                FocusScope.of(context).requestFocus(FocusNode());
                Navigator.pop(context);
              });
            }),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.all(10),
            title: Text(widget.user.name,
                style: TextStyle(fontSize: 15),
                textScaleFactor: 1.0),
            trailing: IconButton(
                icon: Image(
                  width: ScreenUtil().setWidth(50),
                  height: ScreenUtil().setHeight(50),
                  image: AssetImage('assets/images/mine_next.png'),
                  color: Color(0xFFB0B0B0),
                  fit: BoxFit.fill,
                ),
            ),
            leading: Container(
              width: ScreenUtil().setWidth(112),
              height: ScreenUtil().setHeight(112),
              child: widget.user.virtualImageUrl!=null?CachedNetworkImage(
                imageUrl: RouterUtil.imageServerUrl +
                    widget.user.virtualImageUrl,
                placeholder: (context, url) =>
                    Container(
                      child: CircularProgressIndicator(backgroundColor: Colors.black,),
                      width: ScreenUtil().setWidth(20),
                      height: ScreenUtil().setHeight(20),
                      alignment: Alignment.center,
                    ),
                errorWidget: (context, url, error) =>
                    Image(
                      width: ScreenUtil().setWidth(112),
                      height: ScreenUtil().setHeight(112),
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/mine_visitRecord_headDefault.png'),
                    ),
                imageBuilder: (context,imageProvider)=>CircleAvatar(
                  backgroundImage: imageProvider,
                  radius: 100,
                ),
                width: ScreenUtil().setWidth(112),
                height: ScreenUtil().setHeight(112),
                fit: BoxFit.cover,
              ):Image(
                width: ScreenUtil().setWidth(112),
                height: ScreenUtil().setHeight(112),
                fit: BoxFit.cover,
                image: AssetImage('assets/images/mine_visitRecord_headDefault.png'),
              ),
            ),
          ),
          Container(
            child: Divider(height: 1,),
            margin: EdgeInsets.symmetric(horizontal: 10),
          ),
          ListTile(
            title: Text('消息置顶',
                style: TextStyle(fontSize: 15),
                textScaleFactor: 1.0),
            trailing: Switch(
              value: _isTop,
              onChanged: (newValue) {
                setState(() {
                  _isTop = newValue;
                });
              },
              activeTrackColor: Colors.blue,
              activeColor: Colors.white,
            ),
          ),
          Container(
            child: Divider(height: 1,),
            margin: EdgeInsets.symmetric(horizontal: 10),
          ),
          ListTile(
            title: Text('消息免打扰',
                style: TextStyle(fontSize: 15),
                textScaleFactor: 1.0),
            trailing: Switch(
              value: _isIngore,
              onChanged: (newValue) {
                setState(() {
                  _isIngore = newValue;
                });
              },
              activeTrackColor: Colors.blue,
              activeColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}