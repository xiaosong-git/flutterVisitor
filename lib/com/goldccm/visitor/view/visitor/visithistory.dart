import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/component/Qrcode.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/QrcodeMode.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/VisitInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/QrcodeHandler.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';

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
  ScrollController _scrollController = new ScrollController();
  bool isPerformingRequest = false;
  bool notEmpty=true;
  var _visitBuilderFuture;
  @override
  void initState() {
    super.initState();
    _visitBuilderFuture=_getMoreData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  _buildInviteList(){
    return ListView.separated(
      itemCount: isPerformingRequest == true
          ? _visitLists.length
          : _visitLists.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == _visitLists.length) {
          return ListTile(
            title: Text('加载中'),
          );
        } else {
          return ListTile(
            title: Text(_visitLists[index].realName!=null?_visitLists[index].realName:""),
            subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_visitLists[index].startDate!=null?_visitLists[index].startDate:""),
                  Text(_visitLists[index].endDate!=null?"至 ${_visitLists[index].endDate}":""),
                ]
            ),
            trailing: Text(_visitLists[index].cstatus!=null?(_visitLists[index].cstatus=="applyConfirm"?"审核中":_visitLists[index].cstatus=="applySuccess"?"已通过":"未通过"):""),
            onTap: () {
              if(_visitLists[index].cstatus=="applySuccess") {
                QrcodeMode model = new QrcodeMode(userInfo: widget.userInfo,
                    totalPages: 1,
                    bitMapType: 2,
                    visitInfo: _visitLists[index]);
                List<String> qrMsg = QrcodeHandler.buildQrcodeData(model);
                Navigator.push(context,
                    new MaterialPageRoute(builder: (BuildContext context) {
                      return new Qrcode(qrCodecontent: qrMsg);
                    }));
              }else{
                ToastUtil.showShortClearToast("您的访问还没有通过申请哦");
              }
            },
          );
        }
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          child: Divider(
            height: 0,
          ),
        );
      },
      padding: EdgeInsets.all(8),
      controller: _scrollController,
    );
  }
  _getMoreData() async {
    if (!isPerformingRequest) {
      Future.delayed(Duration(seconds: 1), () async {
        setState(() => isPerformingRequest = true);
        String url = Constant.serverUrl + "visitorRecord/visitRecord/$count/10";
        String threshold = await CommonUtil.calWorkKey(userInfo:widget.userInfo);
        var res = await Http().post(url,
            queryParameters: ({
              "token": widget.userInfo.token,
              "factor": CommonUtil.getCurrentTime(),
              "threshold": threshold,
              "requestVer": CommonUtil.getAppVersion(),
              "userId": widget.userInfo.id,
            }),debugMode: true);
        print(res);
        if (res is String) {
          Map map = jsonDecode(res);
          if(map['verify']['sign']=="success"){
            if(map['data']['total']==0){
              setState(() {
                isPerformingRequest = true;
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
                isPerformingRequest = false;
              });
              if (map['data']['rows'].length < 10) {
                setState(() {
                  count--;
                  isPerformingRequest = true;
                });
              }
            }
          }
        }
      });
    } else {
      ToastUtil.showShortToast("已加载到底哦！");
    }
  }
  Widget _visitFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('无连接');
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
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
        break;
      case ConnectionState.active:
        return Text('active');
        break;
      case ConnectionState.done:
        if (snapshot.hasError) return Text(snapshot.error.toString());
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
        title: Text('访问记录'),
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
          Center(child: Text('您还没有访问记录'))
        ],
      ),
    );
  }
}