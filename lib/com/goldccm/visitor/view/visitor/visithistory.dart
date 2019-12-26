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
  int _totalNum=-1;
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
              title: Text(_visitLists[index].realName!=null?_visitLists[index].realName:"",textScaleFactor: 1.0,),
              subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_visitLists[index].startDate!=null?_visitLists[index].startDate:"",textScaleFactor: 1.0,),
                    Text(_visitLists[index].endDate!=null?"至 ${_visitLists[index].endDate}":"",textScaleFactor: 1.0,),
                  ]
              ),
              trailing: Text(_visitLists[index].cstatus!=null?(_visitLists[index].cstatus=="applyConfirm"?"审核中":_visitLists[index].cstatus=="applySuccess"?"已通过":"未通过"):"",textScaleFactor: 1.0,),
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
      },
      onLoad: ()async{
        _getMoreData();
      },
      controller: _easyRefreshController,
      enableControlFinishLoad: true,
//      enableControlFinishRefresh: true,
      firstRefresh: true,
      firstRefreshWidget: LoadingDialog(text: '加载中',),
      emptyWidget: notEmpty!=true?EmptyPage():null,
    );
  }
  //加载更多数据
  _getMoreData() async {
      Future.delayed(Duration(seconds: 1), () async {
        String url = "visitorRecord/visitRecord/$count/10";
        String threshold = await CommonUtil.calWorkKey(userInfo:widget.userInfo);
        var res = await Http().post(url,
            queryParameters: ({
              "token": widget.userInfo.token,
              "factor": CommonUtil.getCurrentTime(),
              "threshold": threshold,
              "requestVer": await CommonUtil.getAppVersion(),
              "userId": widget.userInfo.id,
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
                _totalNum+=10;
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
      });
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