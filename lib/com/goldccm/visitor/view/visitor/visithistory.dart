import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:visitor/com/goldccm/visitor/component/Qrcode.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/QrcodeMode.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/VisitInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/QrcodeHandler.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/common/LoadingDialog.dart';
import 'package:visitor/com/goldccm/visitor/view/common/emptyPage.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/visitDetail.dart';
/*
 * 访问记录
 * 展示可用于访问的访问二维码
 */
class VisitHistory extends StatefulWidget{
  final UserInfo userInfo;
  VisitHistory({Key key,this.userInfo}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return VisitHistoryState();
  }
}

class VisitHistoryState extends State<VisitHistory>{
  int count = 1;
  List<VisitInfo> _visitLists = <VisitInfo>[];
  bool isPerformingRequest = false;
  bool notEmpty=true;
  var _visitBuilderFuture;
  EasyRefreshController _easyRefreshController;

  @override
  void initState() {
    super.initState();
    _easyRefreshController = EasyRefreshController();
    _visitBuilderFuture=_getMoreData();
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    super.dispose();
  }
  //构建列表
  _buildInviteList(){
    return EasyRefresh(
      child:ListView.separated(
        itemCount: _visitLists.length,
        itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: RichText(text: TextSpan(
                text: '访问对象  ',
                style: TextStyle(fontSize: 16,color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: _visitLists[index].realName != null
                        ? _visitLists[index].realName
                        : "",
                    style: TextStyle(fontSize: 16,color: Colors.grey),
                  ),
                ],
              ),textScaleFactor: 1.0,),
              subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RichText(text: TextSpan(
                      text: '开始时间  ',
                      style: TextStyle(fontSize: 16,color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text:_visitLists[index].startDate != null ? _visitLists[index].startDate : "",
                          style: TextStyle(fontSize: 16,color: Colors.grey),
                        ),
                      ],
                    ),textScaleFactor: 1.0,),
                    RichText(text: TextSpan(
                      text: '结束时间  ',
                      style: TextStyle(fontSize: 16,color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text:_visitLists[index].endDate != null ? "${_visitLists[index].endDate}" : "",
                          style: TextStyle(fontSize: 16,color: Colors.grey),
                        ),
                      ],
                    ),textScaleFactor: 1.0,),
                  ]),
              trailing: _visitLists[index].cstatus != null ?_visitLists[index].cstatus == "applyConfirm"?DateTime.parse(_visitLists[index].endDate).isBefore(DateTime.now())?Text("过期",style: TextStyle( color: Colors.red),):Text("审核",style: TextStyle(),): _visitLists[index].cstatus == "applySuccess" ?Text("通过",style: TextStyle(color: Colors.green,),):Text("拒绝",style: TextStyle( color: Colors.red),):Text(""),
              onTap: () {
                if(DateTime.parse(_visitLists[index].endDate).isBefore(DateTime.now())){
                  ToastUtil.showShortClearToast("访问已过期");
                }else{
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => VisitDetail(visitInfo: _visitLists[index],)));
                }
              },
            );
          },
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            child: Divider(
              height: 0,
            ),
          );
        },
        padding: EdgeInsets.all(8),
      ),
      onRefresh: ()async{
        _refresh();
      },
      onLoad: ()async{
        _getMoreData();
      },
      controller: _easyRefreshController,
      enableControlFinishLoad: true,
      enableControlFinishRefresh: true,
      firstRefresh: false,
      firstRefreshWidget: LoadingDialog(text: '加载中',),
      emptyWidget: notEmpty!=true?EmptyPage():null,
    );
  }
  _refresh() async {
    _visitLists.clear();
    count=1;
    String url = "visitorRecord/visitorList";
    String threshold = await CommonUtil.calWorkKey(userInfo:widget.userInfo);
    var res = await Http().post(url,
        queryParameters: ({
          "pageNum":count,
          "pageSize":10,
          "token": widget.userInfo.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "userId": widget.userInfo.id,
          "condition":"userId",
          "recordType":1,
        }),debugMode: true,userCall: false);
    if (res is String) {
      Map map = jsonDecode(res);
      if(map['verify']['sign']=="success"){
        if(map['data']['total']==0){
          setState(() {
            notEmpty = false;
          });
        }else{
          for (var data in map['data']['rows']) {
            VisitInfo visitInfo = new VisitInfo(
              realName:data['realName'],
              visitDate: data['visitDate'],
              visitTime: data['visitTime'],
              userId: data['userId'].toString(),
              visitorId: data['visitorId'].toString(),
              reason: data['reason'],
              cstatus: data['cstatus'],
              dateType: data['dateType'],
              endDate: data['endDate'],
              startDate: data['startDate'],
              id: data['id'].toString(),
              visitorRealName: widget.userInfo.realName,
              phone: widget.userInfo.phone,
            );
            _visitLists.add(visitInfo);
          }
          setState(() {
            count++;
          });
          _easyRefreshController.finishRefresh(success: true);
        }
      }
    }
  }
  //加载更多数据
  _getMoreData() async {
        String url = "visitorRecord/visitorList";
        String threshold = await CommonUtil.calWorkKey(userInfo:widget.userInfo);
        var res = await Http().post(url,
            queryParameters: ({
              "pageNum":count,
              "pageSize":10,
              "token": widget.userInfo.token,
              "factor": CommonUtil.getCurrentTime(),
              "threshold": threshold,
              "requestVer": await CommonUtil.getAppVersion(),
              "userId": widget.userInfo.id,
              "condition":"userId",
              "recordType":1,
            }),debugMode: true,userCall: false);
        if (res is String) {
          Map map = jsonDecode(res);
          if(map['verify']['sign']=="success"){
            if(map['data']['total']==0){
              setState(() {
                notEmpty = false;
              });
            }else{
              for (var data in map['data']['rows']) {
                VisitInfo visitInfo = new VisitInfo(
                  realName:data['realName'],
                  visitDate: data['visitDate'],
                  visitTime: data['visitTime'],
                  userId: data['userId'].toString(),
                  visitorId: data['visitorId'].toString(),
                  reason: data['reason'],
                  cstatus: data['cstatus'],
                  dateType: data['dateType'],
                  endDate: data['endDate'],
                  startDate: data['startDate'],
                  id: data['id'].toString(),
                  visitorRealName: widget.userInfo.realName,
                  phone: widget.userInfo.phone,
                );
                _visitLists.add(visitInfo);
              }
              setState(() {
                count++;
              });
              if (map['data']['rows'].length < 10) {
                setState(() {
                  count--;
                });
                _easyRefreshController.finishLoad(success: true,noMore: true);
              }else{
                _easyRefreshController.finishLoad(success: true);
              }
            }
          }
        }
  }

  Widget _visitFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('无连接',textScaleFactor: 1.0,);
        break;
      case ConnectionState.waiting:
        return LoadingDialog(text: '加载中',);
        break;
      case ConnectionState.active:
        return Text('active',textScaleFactor: 1.0,);
        break;
      case ConnectionState.done:
        if (snapshot.hasError) return Text(snapshot.error.toString(),textScaleFactor: 1.0,);
        return _buildInviteList();
        break;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('访问记录',textScaleFactor: 1.0,),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.color,
      ),
      body: notEmpty==true?
      FutureBuilder(
              builder: _visitFuture,
              future: _visitBuilderFuture,
            )
      :Column(
        children: <Widget>[
          Container(
            child: Center(
                child: Image.asset('assets/images/visitor_icon_nodata.png')),
            padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
          ),
          Center(child: Text('您还没有访问记录',textScaleFactor: 1.0,))
        ],
      ),
    );
  }
}