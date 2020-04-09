import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tobias/tobias.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/RoomInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/RoomOrderInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/Add/Share/roomHistory.dart';

import 'RoomAfterOrder.dart';
/*
 * 收银台
 * 显示订单信息和支付渠道
 * email:hwk@growingpine.com
 * create_time:2019/10/22
 */
class RoomCheckOut extends StatefulWidget{
  final RoomInfo roomInfo;
  final String timeLines;
  final int day;
  final UserInfo userInfo;
  final String startTime;
  final String endTime;
  final int count;
  final RoomOrderInfo roomOrderInfo;
  RoomCheckOut({Key key,this.roomInfo,this.userInfo,this.day,this.timeLines,this.startTime,this.endTime,this.count,this.roomOrderInfo}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return RoomCheckoutState();
  }
}
class RoomCheckoutState extends State<RoomCheckOut>{
  //订单金额
  String amount="0.01";
  //详细描述
  String description="共享会议室";
  //订单标题，显示在调用的支付渠道里
  String title="会议室";
  bool _alipay=false;
  @override
  void dispose() {
    super.dispose();
  }
  @override
  void initState() {
    calculate();
    super.initState();
  }
  calculate(){
    RoomInfo roomInfo=widget.roomInfo;
    print(roomInfo.toString());
    setState(() {
      amount=(double.parse(roomInfo.roomPrice)*widget.count).toString();
      description=roomInfo.roomName+roomInfo.roomAddress;
      title=roomInfo.roomName;
    });
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child:Scaffold(
        appBar: AppBar(
          title: Text('支付订单',  style: new TextStyle(
              fontSize: 18.0, color: Colors.white),textScaleFactor: 1.0),
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.color,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                showDisposeDialog();
              }),
        ),
        body:  Column(
          children: <Widget>[
            _buildOrder(),
            _buildCashier(),
          ],
        ),

      ),
      onWillPop: (){
        showDisposeDialog();
        return null;
      },
    );
  }
  showDisposeDialog(){
    showDialog(context:context,barrierDismissible: false,builder: (context){
      return new Material( //创建透明层
        type: MaterialType.transparency, //透明类型
        child: new Center( //保证控件居中效果
          child: new SizedBox(
            width: MediaQuery.of(context).size.width/1.5,
            height: MediaQuery.of(context).size.width/3,
            child: new Container(
              decoration: ShapeDecoration(
                color: Color(0xffffffff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
              ),
              child: new Stack(
                children: <Widget>[
                  Positioned(
                    child: new Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0,
                          bottom: 20.0
                      ),
                      child: new Text(
                          '您的订单尚未支付，确认离开？',
                          style: new TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),textScaleFactor: 1.0
                      ),
                    ),
                    left: 10,
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: FlatButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>RoomHistory(userInfo: widget.userInfo,)));
                    }, child: Text('确认',textAlign: TextAlign.center,style: TextStyle(fontSize: 16.0,color: Colors.blue),textScaleFactor: 1.0)),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: FlatButton(onPressed:(){
                      Navigator.pop(context);
                    }, child: Text('我再想想',textAlign: TextAlign.center,style: TextStyle(fontSize: 16.0),textScaleFactor: 1.0)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
  Widget _buildOrder(){
    return Column(
      children: <Widget>[
        Container(
          color: Colors.grey[200],
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 10.0,bottom: 10.0,left: 20.0),
          child:   Text('订单详情',style: TextStyle(color: Colors.black45),textScaleFactor: 1.0,),
        ),
        Divider(height: 0,),
        ListTile(title: Text('名称'),trailing: Text(widget.roomInfo.roomName,textScaleFactor: 1.0,),),
        Divider(height: 0,),
        ListTile(title: Text('时间'),trailing: Text(widget.startTime.replaceAll("\.5", ":30").replaceAll("\.0", ":00")+"-"+widget.endTime.replaceAll("\.5", ":30").replaceAll("\.0", ":00"),textScaleFactor: 1.0,),),
        Divider(height: 0,),
        ListTile(title: Text('费用'),trailing: Text(amount,textScaleFactor: 1.0,),),
        Divider(height: 0,),
      ],
    );
  }
  Widget _buildCashier(){
    return Column(
      children: <Widget>[
        Container(
          color: Colors.grey[200],
          padding: EdgeInsets.only(top: 10.0,bottom: 10.0,left: 20.0),
          width: MediaQuery.of(context).size.width,
          child:   Text('选择支付方式',style: TextStyle(color: Colors.black45),textScaleFactor: 1.0,),
        ),
        Divider(height: 0,),
        CheckboxListTile(
          secondary: Container(
            width: 50,
            child: Image.asset("assets/icons/app_alipay_logo.png"),
          ),
          title: Text('支付宝',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),textScaleFactor: 1.0,),
          subtitle: Text('数亿用户都在用，安全可托付',textScaleFactor: 1.0,),
          value: _alipay,
          activeColor: Colors.orange,
          onChanged: (value){
            setState(() {
              _alipay=value;
            });
          },
        ),
        Divider(height: 0,),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 30.0),
          child:  SizedBox(
              height: 50.0,
              width: MediaQuery.of(context).size.width,
              child: RaisedButton(
                color: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                child: Text('确认支付',style: TextStyle(color: Colors.white),textScaleFactor: 1.0,),
                onPressed: (){
                  if(_alipay==true){
                    createOrder();
                  }else{
                    ToastUtil.showShortClearToast("请选择一种支付方式");
                  }
                },
              )
          ),
        ),
      ],
    );
  }
  createOrder() async {
    String url = "pay/createOrder";
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url,queryParameters:({
      "token": widget.userInfo.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "userId": widget.userInfo.id,
      "subject": widget.roomInfo.roomName,
      "body": widget.roomInfo.roomName+","+widget.roomInfo.roomAddress+","+widget.startTime+"-"+widget.endTime,
      "total_amount":(double.parse(widget.roomInfo.roomPrice)*widget.count).toString(),
//        "total_amount":"0.01",
      "user_id":widget.userInfo.id,
      "apply_id":widget.roomOrderInfo.id,
    }));
    if(res is String){
      if(res !=null){
        print(res);
        Map map = jsonDecode(res);
        if(map['verify']['sign']=="success"){
          print(map['data']);
          var result=await aliPay(map['data']);
          print(result);
          if(result['resultStatus']=="9000") {
            ToastUtil.showShortClearToast("支付成功");
            Navigator.push(context, MaterialPageRoute(builder: (context)=>RoomAfterOrder(roomInfo: widget.roomInfo,userInfo: widget.userInfo,timeLines: widget.timeLines,day: widget.day,)));
          }else if(result['resultStatus']=="6001"){
            ToastUtil.showShortClearToast("您取消了支付");
          } else{
            ToastUtil.showShortClearToast("支付遇到了点问题");
          }
        ToastUtil.showShortClearToast("暂时不能支付");
        }
      }else{
        ToastUtil.showShortClearToast("支付失败");
      }
    }
  }
}