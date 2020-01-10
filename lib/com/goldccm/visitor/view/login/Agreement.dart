/*
 * 用户协议
 * create_time:2020/1/9
 */
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/view/homepage/NewsWebView.dart';
import 'package:visitor/com/goldccm/visitor/view/login/VerifyCode.dart';

class UserAgreementDealPage  extends StatefulWidget{
  final String phone;
  UserAgreementDealPage({Key key,this.phone}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return UserAgreementDealPageState();
  }
}
class UserAgreementDealPageState extends State<UserAgreementDealPage>{
  NewsWebPage _newsWebPage = new NewsWebPage(news_url:"http://121.36.45.232:8082/visitor/xieyi2.html",title:"用户协议",news_bar: false,);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child:Container(
          width: ScreenUtil().setWidth(750),
          height: ScreenUtil().setHeight(1334),
          color: Color(0xFFFFFFFF),
          child: Column(
            children: <Widget>[
              Container(
                height: ScreenUtil().setHeight(88),
                width: ScreenUtil().setWidth(750),
                margin: EdgeInsets.only(top: MediaQuery
                    .of(context)
                    .padding
                    .top),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                          right: ScreenUtil().setWidth(235), left: 0),
                      child: IconButton(
                          icon: Image(
                            image: AssetImage("assets/images/login_back.png"),
                            width: ScreenUtil().setWidth(36),
                            height: ScreenUtil().setHeight(36),
                            color: Color(0xFF0073FE),),
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          }),
                    ),
                    Text('注册', style: TextStyle(color: Color(0xFF0073FE),
                      fontSize: ScreenUtil().setSp(36),),),
                  ],
                ),
              ),
              Container(
                child: Divider(
                  color: Color(0x0F000000),
                  height: ScreenUtil().setHeight(2),
                  thickness: ScreenUtil().setHeight(2),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(56),bottom: ScreenUtil().setHeight(24)),
                child: Text('朋悦比邻隐私政策',style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF373737),fontWeight: FontWeight.bold),),
              ),
              Container(
                child: Container(
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(82),right: ScreenUtil().setWidth(82)),
                  height: ScreenUtil().setHeight(374*2),
                  child: _newsWebPage,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(104),right: ScreenUtil().setWidth(104),top: ScreenUtil().setHeight(34)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      width: ScreenUtil().setWidth(230),
                      height: ScreenUtil().setHeight(90),
                      child:  RaisedButton(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),side: BorderSide(
                          color: Color(0xFFE6E6E6),
                        )),
                        child: Text('不同意',style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF656565)),),
                        color: Color(0xFFFFFFFF),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      width: ScreenUtil().setWidth(248),
                      height: ScreenUtil().setHeight(90),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        child: Text('同意并继续',style: TextStyle(color: Color(0xFFFFFFFF),fontSize: ScreenUtil().setSp(36)),),
                        color: Color(0xFF0073FE),
                        onPressed: (){
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> VerifyCodePage(phone: widget.phone,title: '注册',)));
                        },
                      ),
                    ),
                  ],
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}