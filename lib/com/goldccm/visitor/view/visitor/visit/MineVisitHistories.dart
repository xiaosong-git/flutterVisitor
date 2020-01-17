import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/VisitInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/visitDetail.dart';
/*
 * 我的访问（我访问别人的全部记录）
 * author:ody997<hwk@growingpine.com>
 * create_time:2019/12/1
 */
class MineVisitHistories extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return MineVisitHistoriesState();
  }
}
class MineVisitHistoriesState extends State<MineVisitHistories> {

  ScrollController _scrollMineController;
  var _visitMineBuilderFuture;
  List<VisitInfo> _visitLists = <VisitInfo>[];


  @override
  void initState() {
    _scrollMineController=ScrollController();
  }

  @override
  void dispose() {

  }

  visitMine() async {
    UserInfo userInfo=await LocalStorage.load("userInfo");
    String url = "visitorRecord/visitRecord/1/100";
    String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
    var res = await Http().post(url,
        queryParameters: ({
          "token": userInfo.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "userId": userInfo.id,
        }),
        debugMode: true,userCall: false);
    if (res!=null&&res!=""&&res is String) {
      Map map = jsonDecode(res);
      if (map['verify']['sign'] == "success") {
        for (var data in map['data']['rows']) {
          if (data['recordType'] == 1 && data['userId'] == userInfo.id ){
            VisitInfo visitInfo = new VisitInfo(
              realName: data['realName'],
              visitDate: data['visitDate'],
              visitTime: data['visitTime'],
              userId: data['userId'].toString(),
              visitorId: data['visitorId'].toString(),
              reason: data['reason'],
              cstatus: data['cstatus'],
              dateType: data['dateType'],
              endDate: data['endDate'],
              startDate: data['startDate'],
              visitorRealName: userInfo.realName,
              phone: data['phone'],
              companyName: data['companyName'],
              id: data['id'].toString(),
            );
            _visitLists.add(visitInfo);
          }
        }
      }
    }
  }


  Widget _visitMineFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('无连接',textScaleFactor: 1.0,);
        break;
      case ConnectionState.waiting:
        return Stack(
          children: <Widget>[
            Opacity(
                opacity: 0.1,
                child: ModalBarrier(
                  color: Colors.black,
                )),
            Center(
              child: Container(
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                      style: TextStyle(color: Colors.white),textScaleFactor: 1.0,
                    )
                  ],
                ),
              ),
            ),
          ],
        );
        break;
      case ConnectionState.active:
        return Text('active',textScaleFactor: 1.0,);
        break;
      case ConnectionState.done:
        if (snapshot.hasError) return Text(snapshot.error.toString(),textScaleFactor: 1.0,);
        return _buildMineList();
        break;
      default:
        return null;
    }
  }

  _buildMineList() {
    return ListView.separated(
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
          trailing: _visitLists[index].cstatus != null ?_visitLists[index].cstatus == "applyConfirm"?Text("审核",style: TextStyle(),): _visitLists[index].cstatus == "applySuccess" ?Text("通过",style: TextStyle(color: Colors.green,),):Text("拒绝",style: TextStyle( color: Colors.red),):Text(""),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => VisitDetail(visitInfo: _visitLists[index],)));
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
      controller: _scrollMineController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: _visitMineFuture,
      future: _visitMineBuilderFuture,
    );
  }

}

