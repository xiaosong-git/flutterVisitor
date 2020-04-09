import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/component/Qrcode.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/QrcodeMode.dart';
import 'package:visitor/com/goldccm/visitor/model/RoomInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/RoomOrderInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/QrcodeHandler.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';

import 'RoomCheckOut.dart';

/*
 * 共享 - 取消预定与通行二维码
 * email:hwk@growingpine.com
 * create_time:2019/10/22
 */
class RoomBook extends StatefulWidget {
  final UserInfo userInfo;
  final RoomOrderInfo order;
  RoomBook({Key key,this.order,this.userInfo}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return RoomBookState();
  }
}

class RoomBookState extends State<RoomBook> {
  RoomInfo _roomInfo = new RoomInfo();
  cancelOrder(RoomOrderInfo room) async {
    String url = "meeting/cancle";
    String threshold = await CommonUtil.calWorkKey();
    print(widget.userInfo.id);
    var res = await Http().post(url,queryParameters:({
      'record_id':room.id,
      'user_name':widget.userInfo.realName,
      'phone':widget.userInfo.phone,
      'room_id':room.roomID,
      "token": widget.userInfo.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "userId": widget.userInfo.id,
    }),userCall: false );
    if(res is String){
      Map map = jsonDecode(res);
      if(map['verify']['sign']=="success"){
        ToastUtil.showShortClearToast("取消预约成功");
        Navigator.pop(context);
      }else{
        ToastUtil.showShortClearToast(map['verify']['desc']);
      }
    }
  }
  @override
  void initState() {
    super.initState();
    print(widget.order);
    int length=widget.order.timeInterval.split(",").length;
    RoomInfo roomInfo =new RoomInfo(id: widget.order.roomID,roomAddress: widget.order.roomAddress,roomName: widget.order.roomName,roomPrice: (double.parse(widget.order.price)/length).toString(),roomImage: widget.order.roomImage.split(","));
    setState(() {
      _roomInfo=roomInfo;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('您的预定',textScaleFactor: 1.0,),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.color,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){Navigator.pop(context);}),
      ),
      body: SingleChildScrollView(
        child:  Column(
          children: <Widget>[
            Divider(height: 0,),
            ListTile(title: Text('名称',textScaleFactor: 1.0,),trailing: widget.order.roomName!=null?Text(widget.order.roomName,textScaleFactor: 1.0,):Text(""),),
            Divider(height: 0,),
            ListTile(title: Text('时间',textScaleFactor: 1.0,),trailing: widget.order.applyStartTime!=null?Text(widget.order.applyStartTime.replaceAll("\.5", ":30").replaceAll("\.0", ":00")+"-"+widget.order.applyEndTime.replaceAll("\.5", ":30").replaceAll("\.0", ":00"),textScaleFactor: 1.0,):Text("")),
            Divider(height: 0,),
            ListTile(title: Text('地点',textScaleFactor: 1.0,),trailing: widget.order.roomAddress!=null?Text(widget.order.roomAddress,textScaleFactor: 1.0,):Text(""),),
            Divider(height: 0,),
            Container(
              padding: EdgeInsets.only(top: 50,left: 10,right: 10),
              child: new SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50.0,
                child: (widget.order.tradeStatus=="1"||widget.order.tradeNO==null)?new FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: new Text('前往支付',style: TextStyle(fontSize: 18.0),textScaleFactor: 1.0,),
                  onPressed: () async {
                    String applyDate=widget.order.applyDate;
                    print(applyDate);
                    var diff= DateTime.parse(applyDate).difference(DateTime.now());
                    if(diff.inDays<=6&&diff.inDays>=0){
                      Navigator.push(context, CupertinoPageRoute(builder: (context)=>RoomCheckOut(userInfo: widget.userInfo,timeLines: widget.order.timeInterval,startTime: widget.order.applyStartTime,endTime: widget.order.applyEndTime,count: widget.order.timeInterval.split(",").length,roomInfo: _roomInfo,day: diff.inDays,roomOrderInfo: widget.order,)));
                    }else{
                      ToastUtil.showShortClearToast("超过支付时间");
                    }
                  },
                ):switchPassWay(widget.order.gate),
              ),
            ),
            widget.order.tradeStatus=="2"?widget.order.gate==1?Text('现场扫描人脸即可进出',textScaleFactor: 1.0,):widget.order.gate==0?Text('通过扫描二维码进出',textScaleFactor: 1.0,):Text('通过其他方式进出，请现场查询工作人员',textScaleFactor: 1.0,):Container(
              padding: EdgeInsets.all(10.0),
              child: new SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50.0,
                child: new FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  color: Colors.grey,
                  textColor: Colors.white,
                  child: new Text('取消预定',style: TextStyle(fontSize: 18.0),textScaleFactor: 1.0,),
                  onPressed: () async {
                    cancelOrder(widget.order);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget switchPassWay(int status){
    if(status==1){
      return new FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        color: Colors.blue,
        textColor: Colors.white,
        child: new Text('人脸扫描进出',style: TextStyle(fontSize: 18.0),textScaleFactor: 1.0,),
        onPressed: () async {

        },
      );
    }
    else if(status==0){
      return new FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        color: Colors.blue,
        textColor: Colors.white,
        child: new Text('显示二维码',style: TextStyle(fontSize: 18.0),textScaleFactor: 1.0,),
        onPressed: () async {
          QrcodeMode model = new QrcodeMode(userInfo: widget.userInfo,totalPages: 1,bitMapType: 4,roomOrderInfo: widget.order);
          List<String> qrMsg = QrcodeHandler.buildQrcodeData(model);
          print('$qrMsg[0]');
          Navigator.push(context,
              new CupertinoPageRoute(builder: (BuildContext context) {
                return new Qrcode(qrCodecontent:qrMsg);
              }));

        },
      );
    }else{
      return new FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        color: Colors.blue,
        textColor: Colors.white,
        child: new Text('其他方式',style: TextStyle(fontSize: 18.0),textScaleFactor: 1.0,),
        onPressed: () async {

        },
      );
    }
  }
}
