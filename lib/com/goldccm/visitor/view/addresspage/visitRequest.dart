import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/AddressInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/ChatMessage.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/model/VisitInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/MessageUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/visitAddress.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/*
 * 访问信息详细页
 * author:ody997
 * email:hwk@growingpine.com
 * create_time:2019/10/23
 */

class VisitRequest extends StatefulWidget{
  final int id;
  final int sendId;
  final String startDate;
  final String endDate;
  final String companyName;
  final String visitor;
  final String inviter;
  final int isAccept;
  final String recordType;
  final String answerContent;
  final ChatMessage chatMessage;
  final List<AddressInfo> mineAddress;
  final UserInfo userInfo;
  VisitRequest({Key key,this.id,this.userInfo,this.mineAddress,this.sendId,this.startDate,this.endDate,this.companyName,this.visitor,this.inviter,this.isAccept,this.recordType,this.answerContent,this.chatMessage});
  @override
  State<StatefulWidget> createState() {
    return VisitRequestState();
  }
}
class VisitRequestState extends State<VisitRequest>{
  AddressInfo selectedMineAddress;
  VisitInfo _visitInfo=new VisitInfo();
  List<AddressInfo> _mineAddress=<AddressInfo>[];
  _responseToApply(int select){
    //拒绝访问/邀约请求
    if(select == 0 ){
      _visitInfo.cstatus="applyFail";
      ChatMessage msg=new ChatMessage(
          M_visitId: int.parse(_visitInfo.id),
          M_cStatus: 'applyFail',
        );
      if (MessageUtils.isOpen()) {
        var object = {
          'toUserId': _visitInfo.userId,
          'cstatus':'applyFail',
          'id':_visitInfo.id,
          'answerContent':'回复',
          'type': 3,
        };
        ChatMessage msg=new ChatMessage(
          M_visitId: int.parse(_visitInfo.id),
          M_cStatus: 'applyFail',
        );
        var send = jsonEncode(object);
        WebSocketChannel channel=MessageUtils.getChannel();
        channel.sink.add(send);
        ToastUtil.showShortToast("您已拒绝邀约");
      } else {
        ToastUtil.showShortToast("与服务器断开连接");
      }
    }
    //接收访问/邀约请求
    if(select == 1){
      _visitInfo.cstatus="applySuccess";
      ChatMessage msg=new ChatMessage(
        M_visitId: int.parse(_visitInfo.id),
        M_cStatus: 'applySuccess',
      );
      if (MessageUtils.isOpen()) {
        var object = {
          'toUserId': _visitInfo.userId,
          'cstatus':'applySuccess',
          'id':_visitInfo.id,
          'answerContent':'回复',
          'type':3
        };
        ChatMessage msg=new ChatMessage(
          M_visitId: int.parse(_visitInfo.id),
          M_cStatus: 'applySuccess',
        );
        var send = jsonEncode(object);
        WebSocketChannel channel=MessageUtils.getChannel();
        channel.sink.add(send);
        ToastUtil.showShortToast("您已同意邀约");
      } else {
        ToastUtil.showShortToast("与服务器断开连接");
      }
    }
  }
  @override
  void initState() {
    super.initState();
    requestData();
    initAsync();
  }
  initAsync() async {
    _mineAddress = await getAddressInfo();
  }
  getAddressInfo() async {
    String url = Constant.serverUrl+"companyUser/findVisitComSuc";
    UserInfo userInfo=await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey();
    List<AddressInfo> _list=<AddressInfo>[];
    var res = await Http().post(url,queryParameters: {
      "token": userInfo.token,
      "userId": userInfo.id,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "visitorId":userInfo.id,
    });
    if(res !=null){
      if(res is String){
        Map map = jsonDecode(res);
        if(map['verify']['sign']=="success"){
          if(map['data']!=null&&map['data'].length>0){
            for(var info in map['data']){
              if(info['status']=="applySuc"&&info['currentStatus']=="normal"){
                AddressInfo addressInfo=new AddressInfo(id: info['id'],companyId: info['companyId'],sectionId: info['sectionId'],userId: info['userId'],postId: info['postId'],userName: info['userName'],createDate: info['createDate'],createTime: info['createTime'],companyName: info['companyName'],currentStatus: info['currentStatus'],sectionName: info['sectionName'],status: info['status'],secucode: info['secucode'],sex: info['sex'],roleType: info['roleType']);
                _list.add(addressInfo);
              }
            }
          }
        }
        else{
          ToastUtil.showShortClearToast(map['verify']['desc']);
        }
      }
    }
    return _list;
  }
  requestData() async {
    String url = Constant.serverUrl+"visitorRecord/findRecordFromId";
    String threshold = await CommonUtil.calWorkKey();
    UserInfo userInfo=await LocalStorage.load("userInfo");
    var res = await Http().post(url,queryParameters: ({
      "token": userInfo.token,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "userId": userInfo.id,
      "id":widget.id,
    }),debugMode: true,userCall: false);
    if(res is String){
      Map map = jsonDecode(res);
      VisitInfo visitInfo=new VisitInfo(
        id: map['data']['id'].toString(),
        visitDate: map['data']['visitDate'],
        visitTime: map['data']['visitTime'],
        userId: map['data']['userId'].toString(),
        visitorId: map['data']['visitorId'].toString(),
        reason: map['data']['reason'],
        cstatus: map['data']['cstatus'],
        dateType: map['data']['dateType'],
        startDate: map['data']['startDate'],
        endDate: map['data']['endDate'],
        answerContent: map['data']['answerContent'],
        orgCode: map['data']['orgCode'],
        companyName: map['data']['companyName'],
        recordType: map['data']['recordType'].toString(),
        realName: map['data']['realName'],
      );
      setState(() {
        _visitInfo=visitInfo;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserModel>(context);
    return  switchType(user.info);
  }

  changeVisitCompany(VisitInfo info,{int companyId}) async {
    String url = Constant.serverUrl + "visitorRecord/modifyCompanyFromId";
    UserInfo userInfo=await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
    var res;
    if(companyId!=null){
      res = await Http().post(url,
          queryParameters: ({
            "token": userInfo.token,
            "factor": CommonUtil.getCurrentTime(),
            "threshold": threshold,
            "requestVer": await CommonUtil.getAppVersion(),
            "userId": userInfo.id,
            "id":info.id,
            "cstatus": info.cstatus,
            "answerContent": info.answerContent,
            "dataType": info.dateType,
            "startDate": info.startDate,
            "endDate": info.endDate,
            "companyId":companyId,
          }),debugMode: true);
    }else {
      res = await Http().post(url,
          queryParameters: ({
            "token": userInfo.token,
            "factor": CommonUtil.getCurrentTime(),
            "threshold": threshold,
            "requestVer": await CommonUtil.getAppVersion(),
            "userId": userInfo.id,
            "id": info.id,
            "cstatus": info.cstatus,
            "answerContent": info.answerContent,
            "dataType": info.dateType,
            "startDate": info.startDate,
            "endDate": info.endDate,
          }), debugMode: true);
    }
    if(res is String){
      Map map = jsonDecode(res);
      if(map['verify']['sign']=="success"){
        ToastUtil.showShortClearToast(map['verify']['desc']);
      }else{
        ToastUtil.showShortClearToast(map['verify']['desc']);
        _visitInfo.cstatus="applyConfirm";
      }
    }
  }

  Widget switchType(UserInfo user){
    if(_visitInfo==null||_visitInfo.id==null){
      return Scaffold(
        appBar: AppBar(
          title:Text('访问消息',textScaleFactor: 1.0),
          centerTitle:true,
          backgroundColor: Theme.of(context).appBarTheme.color,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){Navigator.pop(context);}),
        ),
        body: WillPopScope(child:Container(
          child: Center(
            child: Text('努力加载中'),
          ),
        ), onWillPop:(){
          Navigator.pop(context);
        }),
      );
    }
    if(_visitInfo.recordType=="1"){
      return Scaffold(
        appBar: AppBar(
          title:Text('访问消息',textScaleFactor: 1.0),
          centerTitle:true,
          backgroundColor: Theme.of(context).appBarTheme.color,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){Navigator.pop(context);}),
        ),
        body: WillPopScope(child:Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(30),
              child: _visitInfo.userId==user.id.toString()?_visitInfo.cstatus=="applyConfirm"?RichText(text: TextSpan(
                  text: '您',style: TextStyle(color: Colors.black,fontSize: 18.0,letterSpacing: 2),
                  children: <TextSpan>[
                    TextSpan(
                      text: '的访问申请正在等待对方的回复，请耐心等待',
                      style: TextStyle(color: Colors.black54,fontSize: 16.0,letterSpacing: 1),
                    ),
                  ]
              ),textScaleFactor: 1.0):RichText(text: TextSpan(
                  text: '您',style: TextStyle(color: Colors.black,fontSize: 18.0,letterSpacing: 2),
                  children: <TextSpan>[
                    TextSpan(
                      text: '的访问申请已收到回复,请查看下方详细信息',
                      style: TextStyle(color: Colors.black54,fontSize: 16.0,letterSpacing: 1),
                    ),
                  ]
              ),textScaleFactor: 1.0):RichText(text: TextSpan(
                  text: '您的好友',style: TextStyle(color: Colors.black,fontSize: 18.0,letterSpacing: 2),
                  children: <TextSpan>[
                    TextSpan(
                      text: '希望在以下地点以下时间对您进行访问，请您审核',
                      style: TextStyle(color: Colors.black54,fontSize: 16.0,letterSpacing: 1),
                    ),
                  ]
              ),textScaleFactor: 1.0)
            ),
            _visitInfo.userId==user.id.toString()?
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                title: Text('访问地址',style: TextStyle(color: Colors.black,fontSize: 16.0,letterSpacing: 1),textScaleFactor: 1.0,),
                subtitle: Text(_visitInfo.companyName!=null?_visitInfo.companyName:"暂无访问地址",style: TextStyle(color: Colors.black54,fontSize: 16.0,letterSpacing: 1),textScaleFactor: 1.0,),
              ),
            ) : Container(padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                title: Text('访问地址',style: TextStyle(color: Colors.black,fontSize: 16.0,letterSpacing: 1),),
                subtitle: Text(_visitInfo.companyName!=null?_visitInfo.companyName:"请点击选择您希望对方访问的地址",style: TextStyle(color: Colors.black54,fontSize: 16.0,letterSpacing: 1),textScaleFactor: 1.0),
                onTap: (){
                  if(_visitInfo.cstatus=="applyConfirm") {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => VisitAddress(lists: _mineAddress,))).then((
                        value) {
                          if(value!=null){
                            selectedMineAddress =_mineAddress[value];
                            setState(() {
                              _visitInfo.companyName=_mineAddress[value].companyName;
                            });
                          }
                    });
                  }
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                title: Text('访问开始时间',style: TextStyle(color: Colors.black,fontSize: 16.0,letterSpacing: 1),textScaleFactor: 1.0),
                subtitle: Text(_visitInfo.startDate),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                title: Text('访问结束时间',style: TextStyle(color: Colors.black,fontSize: 16.0,letterSpacing: 1),textScaleFactor: 1.0),
                subtitle: Text(_visitInfo.endDate),
              ),
            ),
          ],
        ), onWillPop:(){
          Navigator.pop(context);
        }),
        bottomSheet: _visitInfo.userId==user.id.toString()?Container(height:50,child: Text(_visitInfo.cstatus=="applyConfirm"?"审核中":_visitInfo.cstatus=="applySuccess"?"已通过":"未通过",style: TextStyle(fontSize: 24,color: Colors.green)),alignment: Alignment.center,):_visitInfo.cstatus=="applyConfirm"?Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                child: new SizedBox(
                  width: 170.0,
                  height: 50.0,
                  child: new FlatButton(
                    color: Colors.green,
                    textColor: Colors.white,
                    child: new Text('同意访问',textScaleFactor: 1.0),
                    onPressed: () async {
                      if(selectedMineAddress==null){
                        ToastUtil.showShortClearToast("请先选择一个访问地址，点击上方选择访问地址即可选择");
                      }else{
                        setState(() {
                          _visitInfo.cstatus="applySuccess";
                        });
                        changeVisitCompany(_visitInfo,companyId:selectedMineAddress.companyId);
                      }
                    },
                  ),
                ),
              ),
              Container(
                child: new SizedBox(
                  width: 170.0,
                  height: 50.0,
                  child: new FlatButton(
                    color: Colors.red,
                    textColor: Colors.white,
                    child: new Text('拒绝访问',textScaleFactor: 1.0),
                    onPressed: () async {
                      setState(() {
                        _visitInfo.cstatus = "applyFail";
                      });
                      changeVisitCompany(_visitInfo);
                    },
                  ),
                ),
              )
            ],
          ),
        ):_visitInfo.cstatus=="applySuccess"?Container(height:50,child: Text("通过",style: TextStyle(fontSize: 24,color: Colors.green),textScaleFactor: 1.0),alignment: Alignment.center,):Container(height:50,child: Text("拒绝",style: TextStyle(fontSize: 24,color: Colors.red),),alignment: Alignment.center),
      );
    }
    else{
      return Scaffold(
        appBar: AppBar(
          title:Text('邀约消息',textScaleFactor: 1.0),
          centerTitle:true,
          backgroundColor: Theme.of(context).appBarTheme.color,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){Navigator.pop(context);}),
        ),
        body:WillPopScope(child:Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(30),
              child:_visitInfo.visitorId==user.id.toString()?_visitInfo.cstatus=="applyConfirm"?RichText(text: TextSpan(
                  text: '您',style: TextStyle(color: Colors.black,fontSize: 18.0,letterSpacing: 2),
                  children: <TextSpan>[
                    TextSpan(
                      text: '的邀约申请正在等待对方的回复，请耐心等待',
                      style: TextStyle(color: Colors.black54,fontSize: 16.0,letterSpacing: 1),
                    ),
                  ]
              ),textScaleFactor: 1.0):RichText(text: TextSpan(
                  text: '您',style: TextStyle(color: Colors.black,fontSize: 18.0,letterSpacing: 2),
                  children: <TextSpan>[
                    TextSpan(
                      text: '的邀约申请已收到回复,请查看下方详细信息',
                      style: TextStyle(color: Colors.black54,fontSize: 16.0,letterSpacing: 1),
                    ),
                  ]
              ),textScaleFactor: 1.0):RichText(text: TextSpan(
                  text: '${_visitInfo.realName}',style: TextStyle(color: Colors.black,fontSize: 18.0,letterSpacing: 2),
                  children: <TextSpan>[
                    TextSpan(
                      text: '邀请您在以下地点以下时间进行访问，请您审核',
                      style: TextStyle(color: Colors.black54,fontSize: 16.0,letterSpacing: 1),
                    ),
                  ]
              ),textScaleFactor: 1.0)
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                title: Text('洽谈地址',style: TextStyle(color: Colors.black,fontSize: 16.0,letterSpacing: 1),textScaleFactor: 1.0),
                subtitle: Text(_visitInfo.companyName!=null?_visitInfo.companyName:"",style: TextStyle(color: Colors.black54,fontSize: 16.0,letterSpacing: 1),textScaleFactor: 1.0),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                title: Text('洽谈开始时间',style: TextStyle(color: Colors.black,fontSize: 16.0,letterSpacing: 1),),
                subtitle: Text(_visitInfo.startDate!=null?_visitInfo.startDate:"",style: TextStyle(color: Colors.black54,fontSize: 16.0,letterSpacing: 1),),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                title: Text('洽谈结束时间',style: TextStyle(color: Colors.black,fontSize: 16.0,letterSpacing: 1),textScaleFactor: 1.0),
                subtitle: Text(_visitInfo.endDate!=null?_visitInfo.endDate:"",style: TextStyle(color: Colors.black54,fontSize: 16.0,letterSpacing: 1),textScaleFactor: 1.0),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                title: Text('理由',style: TextStyle(color: Colors.black,fontSize: 16.0,letterSpacing: 1),textScaleFactor: 1.0),
                subtitle: Text("",textScaleFactor: 1.0),
              ),
            ),
          ],
        ), onWillPop: (){
          Navigator.pop(context);
        }),
        bottomSheet:  _visitInfo.visitorId==user.id.toString()?Container(height:50,child: Text(_visitInfo.cstatus=="applyConfirm"?"审核中":_visitInfo.cstatus=="applySuccess"?"已通过":"未通过",style: TextStyle(fontSize: 24,color: Colors.green),textScaleFactor: 1.0),alignment: Alignment.center,):_visitInfo.cstatus=="applyConfirm"?Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                child: new SizedBox(
                  width: 170.0,
                  height: 50.0,
                  child: new FlatButton(
                    color: Colors.green,
                    textColor: Colors.white,
                    child: new Text('同意受邀',textScaleFactor: 1.0),
                    onPressed: () async {
                      setState(() {
                        _visitInfo.cstatus="applySuccess";
                      });
                      _responseToApply(1);
                    },
                  ),
                ),
              ),
              Container(
                child: new SizedBox(
                  width: 170.0,
                  height: 50.0,
                  child: new FlatButton(
                    color: Colors.red,
                    textColor: Colors.white,
                    child: new Text('拒绝受邀',textScaleFactor: 1.0),
                    onPressed: () async {
                      setState(() {
                        _visitInfo.cstatus="applyFail";
                      });
                      _responseToApply(0);
                    },
                  ),
                ),
              )
            ],
          ),
        ):_visitInfo.cstatus=="applySuccess"?Container(height:50,child: Text("通过",style: TextStyle(fontSize: 24,color: Colors.green),textScaleFactor: 1.0),alignment: Alignment.center,):Container(height:50,child: Text("拒绝",style: TextStyle(fontSize: 24,color: Colors.red),textScaleFactor: 1.0,),alignment: Alignment.center),
      );
    }
  }
}