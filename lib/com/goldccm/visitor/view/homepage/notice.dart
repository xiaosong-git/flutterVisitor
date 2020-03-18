import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';

class NoticePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoticePageState();
  }
}

class NoticePageState extends State<NoticePage> {
  var _noticeBuilderFuture;
  List<Notice> _lists = <Notice>[];
  bool notEmpty=true;
  @override
  void initState() {
    super.initState();
    _noticeBuilderFuture = getNotice();
  }

  getNotice() async {
    String url = "notice/allList/1/20";
    UserInfo userInfo = await DataUtils.getUserInfo();
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url, queryParameters: {
      "token": userInfo.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "userId": userInfo.id,
    },userCall: false );
    if (res is String) {
      Map map = jsonDecode(res);
      if(map['verify']['sign']=="success") {
        for (int i=map['data']['rows'].length-1;i>=0;i--) {
          Notice notice;
          if(i==map['data']['rows'].length-1){
            notice = new Notice(
              noticeTitle: map['data']['rows'][i]['noticeTitle'],
              content: map['data']['rows'][i]['content'],
              createDate: map['data']['rows'][i]['createDate'],
              createTime: map['data']['rows'][i]['createTime'],
              orgType: map['data']['rows'][i]['orgType'],
              isDayFirst: true,
              isYearFirst: true,
            );
          }else{
            String date = map['data']['rows'][i]['createDate'];
            String preDate = map['data']['rows'][i+1]['createDate'];
            if(int.parse(date.substring(0,4))!=int.parse(preDate.substring(0,4))){
                notice = new Notice(
                  noticeTitle: map['data']['rows'][i]['noticeTitle'],
                  content: map['data']['rows'][i]['content'],
                  createDate: map['data']['rows'][i]['createDate'],
                  createTime: map['data']['rows'][i]['createTime'],
                  orgType: map['data']['rows'][i]['orgType'],
                  isDayFirst: true,
                  isYearFirst: true,
                );
            }
            if(int.parse(date.substring(8,10))!=int.parse(preDate.substring(8,10))){
              notice = new Notice(
                noticeTitle: map['data']['rows'][i]['noticeTitle'],
                content: map['data']['rows'][i]['content'],
                createDate: map['data']['rows'][i]['createDate'],
                createTime: map['data']['rows'][i]['createTime'],
                orgType: map['data']['rows'][i]['orgType'],
                isDayFirst: true,
              );
            }else{
               notice = new Notice(
                noticeTitle: map['data']['rows'][i]['noticeTitle'],
                content: map['data']['rows'][i]['content'],
                createDate: map['data']['rows'][i]['createDate'],
                createTime: map['data']['rows'][i]['createTime'],
                orgType: map['data']['rows'][i]['orgType'],
              );
            }
          }
          _lists.add(notice);
        }
      }else{
        setState(() {
          notEmpty=false;
        });
        ToastUtil.showShortToast(map['verify']['desc']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160),
        child: AppBar(
          title: Text('公告',style: new TextStyle(
              fontSize: ScreenUtil().setSp(70), color: Colors.white),textScaleFactor: 1.0),
          flexibleSpace: Image(
            image: AssetImage('assets/images/login_background.png'),
            fit: BoxFit.fill,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
              icon: Image(
                image: AssetImage("assets/images/login_back.png"),
                width: ScreenUtil().setWidth(36),
                height: ScreenUtil().setHeight(36),
                color: Color(0xFFFFFFFF),),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              }),
        ),
      ),
      body: notEmpty==true?FutureBuilder(
        builder: noticeFuture,
        future: _noticeBuilderFuture,
      ):Column(
        children: <Widget>[
          Container(
            child: Center(
                child: Image.asset('assets/images/visitor_icon_nodata.png')),
            padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
          ),
          Center(child: Text('暂无公告',textScaleFactor: 1.0))
        ],
      ),
    );
  }

  Widget noticeFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('无连接',textScaleFactor: 1.0);
        break;
      case ConnectionState.waiting:
        return Stack(
          children: <Widget>[
            Opacity(
                opacity: 0.1,
                child: ModalBarrier(
                  color: Colors.black,
                )
            ),
            Center(
              child:Container(
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  //黑色背景
                    color: Colors.black87,
                    //圆角边框
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  //控件里面内容主轴负轴剧中显示
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  //主轴高度最小
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                  child: CircularProgressIndicator(backgroundColor: Colors.black,),
                  width: 10,
                  height: 10,
                  alignment: Alignment.center,
                ),
                    Text(
                      '加载中',
                      style: TextStyle(color: Colors.white),textScaleFactor: 1.0
                    )
                  ],
                ),
              ),
            ),
          ],
        );
        break;
      case ConnectionState.active:
        return Text('active',textScaleFactor: 1.0);
        break;
      case ConnectionState.done:
        if (snapshot.hasError) return Text('Error',textScaleFactor: 1.0);
        return _buildNoticeList();
        break;
      default:
        return null;
    }
  }

  Widget _buildNoticeList() {
    return ListView.builder(
      itemBuilder: (_, int index) => _lists[index],
      itemCount: _lists.length,
    );
  }
}

class Notice extends StatelessWidget {
  final String noticeTitle;
  final String content;
  final String createDate;
  final String createTime;
  final String orgType;
  final bool isDayFirst;
  final bool isYearFirst;
  Notice(
      {this.noticeTitle,
      this.content,
      this.createTime,
      this.createDate,
      this.orgType,
      this.isDayFirst,
      this.isYearFirst});
  @override
  Widget build(BuildContext context) {
    return  isYearFirst==true?Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: ScreenUtil().setWidth(750),
          child: Text('${createDate.substring(0,4)}年',style: TextStyle(fontSize: ScreenUtil().setSp(40),color: Colors.black),),
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(32),bottom: ScreenUtil().setHeight(24),top: 0),
          color: Colors.white,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(32)),
          color: Colors.white,
          height: ScreenUtil().setHeight(140),
          child:InkWell(
            child:Container(
              child: Stack(
                children: <Widget>[
                  isDayFirst==true? Positioned(
                    child: Column(
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            text: createDate.substring(8,10),
                            style: TextStyle(fontSize: ScreenUtil().setSp(40),color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                text: int.parse(createDate.substring(5,7))<10?'${createDate.substring(6,7)}月':'${createDate.substring(5,7)}月',
                                style: TextStyle(fontSize: ScreenUtil().setSp(24),color:Color(0xFF787878)),
                              ),
                            ],
                          ),
                          textScaleFactor: 1.0,
                        ),
                        DateTime.parse(createDate).weekday==1?Text('星期一',style: TextStyle(color: Color(0xFF6C6C6C),fontSize: ScreenUtil().setSp(28)),):DateTime.parse(createDate).weekday==2?Text('星期二',style: TextStyle(color: Color(0xFF6C6C6C),fontSize: ScreenUtil().setSp(28)),):DateTime.parse(createDate).weekday==3?Text('星期三',style: TextStyle(color: Color(0xFF6C6C6C),fontSize: ScreenUtil().setSp(28)),):DateTime.parse(createDate).weekday==4?Text('星期四',style: TextStyle(color: Color(0xFF6C6C6C),fontSize: ScreenUtil().setSp(28)),):DateTime.parse(createDate).weekday==5?Text('星期五',style: TextStyle(color: Color(0xFF6C6C6C),fontSize: ScreenUtil().setSp(28)),):DateTime.parse(createDate).weekday==6?Text('星期六',style: TextStyle(color: Color(0xFF6C6C6C),fontSize: ScreenUtil().setSp(28)),):DateTime.parse(createDate).weekday==7?Text('星期天',style: TextStyle(color: Color(0xFF6C6C6C),fontSize: ScreenUtil().setSp(28)),):Text(''),
                      ],
                    ),
                  ): Positioned(
                    child: Container(),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      width: ScreenUtil().setWidth(594),
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(16),top: ScreenUtil().setHeight(16),bottom: ScreenUtil().setHeight(16)),
//                      margin: EdgeInsets.only(left: ScreenUtil().setWidth(46)),
                      color: Color(0xFFF9F9F9),
                      child: Text('$noticeTitle',style: TextStyle(fontSize: ScreenUtil().setSp(32),color: Color(0xFF373737)),maxLines: 2,overflow: TextOverflow.ellipsis,),
                    ),
                  ),
                ],
              ),
            ),
            onTap: (){
              Navigator.push(context, CupertinoPageRoute(builder: (context)=>NoticeDetail (noticeTitle: noticeTitle,content: content,createDate: createDate,createTime: createTime,orgType: orgType,)));
            },
          ),
        )
      ],
    ):Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(32)),
        height: ScreenUtil().setHeight(140),
          child:InkWell(
            child:Container(
              child: Stack(
                children: <Widget>[
                  isDayFirst==true? Positioned(
                    child: Column(
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            text: createDate.substring(8,10),
                            style: TextStyle(fontSize: ScreenUtil().setSp(40),color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                text: int.parse(createDate.substring(5,7))<10?'${createDate.substring(6,7)}月':'${createDate.substring(5,7)}月',
                                style: TextStyle(fontSize: ScreenUtil().setSp(24),color:Color(0xFF787878)),
                              ),
                            ],
                          ),
                          textScaleFactor: 1.0,
                        ),
                        DateTime.parse(createDate).weekday==1?Text('星期一',style: TextStyle(color: Color(0xFF6C6C6C),fontSize: ScreenUtil().setSp(28)),):DateTime.parse(createDate).weekday==2?Text('星期二',style: TextStyle(color: Color(0xFF6C6C6C),fontSize: ScreenUtil().setSp(28)),):DateTime.parse(createDate).weekday==3?Text('星期三',style: TextStyle(color: Color(0xFF6C6C6C),fontSize: ScreenUtil().setSp(28)),):DateTime.parse(createDate).weekday==4?Text('星期四',style: TextStyle(color: Color(0xFF6C6C6C),fontSize: ScreenUtil().setSp(28)),):DateTime.parse(createDate).weekday==5?Text('星期五',style: TextStyle(color: Color(0xFF6C6C6C),fontSize: ScreenUtil().setSp(28)),):DateTime.parse(createDate).weekday==6?Text('星期六',style: TextStyle(color: Color(0xFF6C6C6C),fontSize: ScreenUtil().setSp(28)),):DateTime.parse(createDate).weekday==7?Text('星期天',style: TextStyle(color: Color(0xFF6C6C6C),fontSize: ScreenUtil().setSp(28)),):Text(''),
                      ],
                    ),
                  ): Positioned(
                    child: Container(),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      width: ScreenUtil().setWidth(594),
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(16),top: ScreenUtil().setHeight(16),bottom: ScreenUtil().setHeight(16)),
//                      margin: EdgeInsets.only(left: ScreenUtil().setWidth(46)),
                      color: Color(0xFFF9F9F9),
                      child: Text('$noticeTitle',style: TextStyle(fontSize: ScreenUtil().setSp(32),color: Color(0xFF373737)),maxLines: 2,overflow: TextOverflow.ellipsis,),
                    ),
                  ),
                ],
              ),
            ),
            onTap: (){
              Navigator.push(context, CupertinoPageRoute(builder: (context)=>NoticeDetail (noticeTitle: noticeTitle,content: content,createDate: createDate,createTime: createTime,orgType: orgType,)));
            },
          ),
    );
  }
}
class NoticeDetail extends StatelessWidget{
  final String noticeTitle;
  final String content;
  final String createDate;
  final String createTime;
  final String orgType;
  NoticeDetail({Key key,this.noticeTitle,this.content,this.createDate,this.createTime,this.orgType}):super(key:key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: orgType=="company"?Text('公司公告',textScaleFactor: 1.0,style: new TextStyle(
            fontSize: 17.0, color: Colors.white),):Text('大楼公告',textScaleFactor: 1.0,style: new TextStyle(
            fontSize: 17.0, color: Colors.white),),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.color,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){Navigator.pop(context);}),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Container(
              child:  Text(noticeTitle,textScaleFactor: 1.0,style: TextStyle(fontSize: 18.0),),
              padding: EdgeInsets.only(bottom: 10.0),
            ),
            Text('$createDate $createTime',textScaleFactor: 1.0,style: TextStyle(color: Colors.black45),),
            Divider(),
            Text('$content',textScaleFactor: 1.0),
          ],
        ),
      ),
    );
  }
}