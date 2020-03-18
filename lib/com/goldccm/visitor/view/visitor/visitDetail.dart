import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visitor/com/goldccm/visitor/component/Qrcode.dart';
import 'package:visitor/com/goldccm/visitor/model/QrcodeMode.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/VisitInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/QrcodeHandler.dart';

class VisitDetail extends StatelessWidget{
  final VisitInfo visitInfo;
  final UserInfo userInfo;
  VisitDetail({Key key,this.visitInfo,this.userInfo}):super(key:key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("详细信息",textScaleFactor: 1.0),
      ),
      body: Column(
        children: <Widget>[
          Column(
              children: <Widget>[
                ListTile(title: Text('访问人',textScaleFactor: 1.0),subtitle: Text(visitInfo.realName!=null?visitInfo.realName:"",textScaleFactor: 1.0),),
                ListTile(title: Text('访问时间',textScaleFactor: 1.0),subtitle: Text(visitInfo.startDate!=null?visitInfo.startDate:"",textScaleFactor: 1.0),),
                ListTile(title: Text('访问地点',textScaleFactor: 1.0),subtitle: Text(visitInfo.companyName!=null?visitInfo.companyName:"",textScaleFactor: 1.0),),
              ],
            ),
          Container(
            padding: EdgeInsets.all(20.0),
            child: new SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              child: switchPassWay(context),
            ),
          )
        ],
      )
    );
  }
  Widget switchPassWay(BuildContext context){

    if(visitInfo.cstatus=="applySuccess"){
      return FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        color: Colors.green,
        textColor: Colors.white,
        child: new Text('显示二维码',style: TextStyle(fontSize: 18.0),textScaleFactor: 1.0),
        onPressed: () async {
          QrcodeMode model = new QrcodeMode(userInfo: userInfo,totalPages: 1,bitMapType: 2,visitInfo: visitInfo);
          List<String> qrMsg = QrcodeHandler.buildQrcodeData(model);
          print('$qrMsg[0]');
          Navigator.push(context,
              new CupertinoPageRoute(builder: (BuildContext context) {
                return new Qrcode(qrCodecontent:qrMsg);
              }));

        },
      );
    }else if(visitInfo.cstatus=="applyConfirm"){
      return FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        color: Colors.blue,
        textColor: Colors.white,
        child: new Text('访问待审核',style: TextStyle(fontSize: 18.0),),
        onPressed: () async {

        },
      );
    }else{
      return FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        color: Colors.blue,
        textColor: Colors.white,
        child: new Text('访问已被拒绝',style: TextStyle(fontSize: 18.0),),
      );
    }
  }
}