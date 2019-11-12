import 'dart:convert';
import 'package:flutter/material.dart';
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
    String url = Constant.serverUrl+"notice/allList/1/20";
    UserInfo userInfo = await DataUtils.getUserInfo();
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url, queryParameters: {
      "token": userInfo.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": CommonUtil.getAppVersion(),
      "userId": userInfo.id,
    });
    if (res is String) {
      Map map = jsonDecode(res);
      if(map['verify']['sign']=="success") {
        for (var info in map['data']['rows']) {
          Notice notice = new Notice(
            noticeTitle: info['noticeTitle'],
            content: info['content'],
            createDate: info['createDate'],
            createTime: info['createTime'],
            orgType: info['orgType'],
          );
          _lists.insert(0, notice);
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
      appBar: AppBar(
        title: Text('公告栏',style: new TextStyle(
            fontSize: 17.0, color: Colors.white),textScaleFactor: 1.0),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.color,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){Navigator.pop(context);}),
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
                    CircularProgressIndicator(),
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
    return ListView.separated(
      itemBuilder: (_, int index) => _lists[index],
      padding: EdgeInsets.all(8),
      itemCount: _lists.length,
      separatorBuilder: (context,index){
        return Divider(height: 0.0,);
      },
    );
  }
}

class Notice extends StatelessWidget {
  final String noticeTitle;
  final String content;
  final String createDate;
  final String createTime;
  final String orgType;
  Notice(
      {this.noticeTitle,
      this.content,
      this.createTime,
      this.createDate,
      this.orgType});
  @override
  Widget build(BuildContext context) {
    return  Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        height: 67,
          child:InkWell(
            child:Container(
              padding: EdgeInsets.all(10),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Image.asset("assets/icons/大楼.png"),
                    ),
                    width: 40,
                    height: 40,
                  ),
                  Positioned(
                    child: Text('$noticeTitle',overflow: TextOverflow.ellipsis,maxLines: 1,style: TextStyle(fontSize: 16.0),textScaleFactor: 1.0),
                    left: 60,
                    width: 220,
                  ),
                  Positioned(
                    child: Text('${content}',overflow: TextOverflow.ellipsis,maxLines: 1,style: TextStyle(fontSize: 15.0,color: Colors.black45),textScaleFactor: 1.0),
                    left: 60,
                    width: 270,
                    top: 20,
                  ),
                  Positioned(
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: Text('${createDate}',style: TextStyle(fontSize: 14.0,color: Colors.black45),textScaleFactor: 1.0),
                    ),
                    right: 0,
                  ),
                ],
              ),
            ),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>NoticeDetail (noticeTitle: noticeTitle,content: content,createDate: createDate,createTime: createTime,orgType: orgType,)));
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