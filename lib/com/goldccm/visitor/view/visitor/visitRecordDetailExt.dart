import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/AddressInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/VisitDetailInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/VisitInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/visitAddress.dart';

//
// 单个访问详情
//
class VisitRecordDetailExt extends StatefulWidget{
  final VisitDetailInfo info;
  VisitRecordDetailExt({Key key,this.info}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return VisitRecordDetailExtState();
  }
}
class VisitRecordDetailExtState extends State<VisitRecordDetailExt>{

  VisitInfo _visitInfo;
  UserInfo _userInfo=new UserInfo();
  String visitor="";
  String inviter="";
  int selectedCompanyId;
  List<AddressInfo> _addressLists = <AddressInfo>[];

  @override
  void initState() {
    super.initState();
    initInfo();
    requestData();
  }
  initInfo() async {
    _userInfo=await LocalStorage.load("userInfo");
    _addressLists= await getAddressInfo(_userInfo.id);
  }
  getAddressInfo(int visitorId) async {
    UserInfo userInfo=await LocalStorage.load("userInfo");
    String url ="companyUser/findVisitComSuc";
    String threshold = await CommonUtil.calWorkKey();
    List<AddressInfo> _list=<AddressInfo>[];
    var res = await Http().post(url,queryParameters: {
      "token": userInfo.token,
      "userId": userInfo.id,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "visitorId":visitorId,
    },userCall: false);
    if(res !=null&&res !=""){
      if(res is String){
        Map map = jsonDecode(res);
        if(map['verify']['sign']=="success"){
          if(map['data']!=null&&map['data'].length>0){
            for(var info in map['data']){
              print(info);
              if(info['status']=="applySuc"&&info['currentStatus']=="normal"){
                AddressInfo addressInfo=new AddressInfo(id: info['id'],companyId: info['companyId'],sectionId: info['sectionId'],userId: info['userId'],postId: info['postId'],userName: info['userName'],createDate: info['createDate'],createTime: info['createTime'],companyName: info['companyName'],currentStatus: info['currentStatus'],sectionName: info['sectionName'],status: info['status'],secucode: info['secucode'],sex: info['sex'],roleType: info['roleType'],address: info['addr']);
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
    String url = "visitorRecord/findRecordFromId";
    String threshold = await CommonUtil.calWorkKey();
    UserInfo userInfo = await LocalStorage.load("userInfo");
    var res = await Http().post(url,
        queryParameters: ({
          "token": userInfo.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "userId": userInfo.id,
          "id": widget.info.id,
        }),
        debugMode: true,
        userCall: false);
    if (res is String) {
      Map map = jsonDecode(res);
      VisitInfo visitInfo = new VisitInfo(
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
        address:  map['data']['addr'],
      );
      setState(() {
        _visitInfo = visitInfo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text('访问详情',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF373737)),),
        centerTitle: true,
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 1,
        brightness: Brightness.light,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Image(
              image: AssetImage("assets/images/login_back.png"),
              width: ScreenUtil().setWidth(36),
              height: ScreenUtil().setHeight(36),
              color: Color(0xFF373737),),
            onPressed: () {
              setState(() {
                Navigator.pop(context);
              });
            }),
      ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      height: ScreenUtil().setHeight(60),
                      alignment:Alignment.center,
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(62)),
                      margin: EdgeInsets.only(top: ScreenUtil().setHeight(40)),
                      child: Text('发起人',style: TextStyle(fontSize:ScreenUtil().setSp(34),color: Color(0xFFA8A8A8)),),
                    ),
                    Container(
                      alignment:Alignment.center,
                      height: ScreenUtil().setHeight(60),
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(32)),
                      margin: EdgeInsets.only(top: ScreenUtil().setHeight(40)),
                      child: Text(widget.info.sender!=null?widget.info.sender:"",style: TextStyle(fontSize:ScreenUtil().setSp(34),color: Color(0xFF373737)),),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      alignment:Alignment.center,
                      height: ScreenUtil().setHeight(60),
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(62)),
                      child: Text('接收人',style: TextStyle(fontSize:ScreenUtil().setSp(34),color: Color(0xFFA8A8A8)),),
                    ),
                    Container(
                      alignment:Alignment.center,
                      height: ScreenUtil().setHeight(60),
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(32)),
                      child: Text(widget.info.receiver!=null?widget.info.receiver:"",style: TextStyle(fontSize:ScreenUtil().setSp(34),color: Color(0xFF373737)),),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      alignment:Alignment.center,
                      height: ScreenUtil().setHeight(60),
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(32)),
                      child: Text('申请时间',style: TextStyle(fontSize:ScreenUtil().setSp(34),color: Color(0xFFA8A8A8)),),
                    ),
                    Container(
                      alignment:Alignment.center,
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(32),top: ScreenUtil().setHeight(8)),
                      height: ScreenUtil().setHeight(60),
                      child: Text(widget.info.visitDate!=null&&widget.info.visitDate!=""?"${DateFormat('yyyy/MM/dd').format(DateTime.parse(widget.info.visitDate))}    ${widget.info.visitTime}":"",style: TextStyle(fontSize:ScreenUtil().setSp(34),color: Color(0xFF373737)),),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      alignment:Alignment.center,
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(32)),
                      height: ScreenUtil().setHeight(60),
                      child: Text('受理时间',style: TextStyle(fontSize:ScreenUtil().setSp(34),color: Color(0xFFA8A8A8)),),
                    ),
                    Container(
                      alignment:Alignment.center,
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(32),top: ScreenUtil().setHeight(8)),
                      height: ScreenUtil().setHeight(60),
                      child: Text(widget.info.replyDate!=null&&widget.info.replyDate!=""?"${DateFormat('yyyy/MM/dd').format(DateTime.parse(widget.info.replyDate))}    ${widget.info.replyTime}":"",style: TextStyle(fontSize:ScreenUtil().setSp(34),color: Color(0xFF373737)),),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      alignment:Alignment.center,
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(32)),
                      height: ScreenUtil().setHeight(60),
                      child: Text('受理状态',style: TextStyle(fontSize:ScreenUtil().setSp(34),color: Color(0xFFA8A8A8)),),
                    ),
                    Container(
                      alignment:Alignment.center,
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(32)),
                      height: ScreenUtil().setHeight(60),
                      child:  widget.info.cStatus ==
                          "applyConfirm"
                          ? Text(
                        '待审核',
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(34),
                            color: Color(0xFF066FFD)),
                      )
                          : widget.info.cStatus ==
                          "applySuccess"
                          ? Text(
                        '通过',
                        style: TextStyle(
                            fontSize:
                            ScreenUtil().setSp(34),
                            color: Color(0xFF0FAA0F)),
                      )
                          : Text(
                        '拒绝',
                        style: TextStyle(
                            fontSize:
                            ScreenUtil().setSp(34),
                            color: Color(0xFFFD0637)),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      alignment:Alignment.center,
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(32)),
                      height: ScreenUtil().setHeight(60),
                      child: Text('访问时间',style: TextStyle(fontSize:ScreenUtil().setSp(34),color: Color(0xFFA8A8A8)),),
                    ),
                    Container(
                      alignment:Alignment.center,
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(32),top: ScreenUtil().setHeight(8)),
                      height: ScreenUtil().setHeight(60),
                      child:      RichText(
                        text: TextSpan(
                          text: widget.info
                              .startDate !=
                              null
                              ? DateFormat('yyyy/MM/dd    HH:mm').format(
                              DateTime.parse(
                                  widget.info
                                      .startDate))
                              : "",
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(34),
                              color: Color(0xFF373737)),
                          children: <TextSpan>[
                            TextSpan(
                              text:  widget.info
                                  .endDate !=
                                  null
                                  ? "-${ widget.info.endDate.substring(11, 16)}"
                                  : "",
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(34),
                                  color: Color(0xFF373737)),
                            ),
                          ],
                        ),
                        textScaleFactor: 1.0,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(32),top: ScreenUtil().setHeight(10)),
                      height: ScreenUtil().setHeight(60),
                      child: Text('访问地址',style: TextStyle(fontSize:ScreenUtil().setSp(34),color: Color(0xFFA8A8A8)),),
                    ),
                    Container(
                      width: ScreenUtil().setWidth(500),
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(32),top: ScreenUtil().setHeight(10)),
                      height: ScreenUtil().setHeight(180),
                      child: Text(widget.info.address!=null?widget.info.address:"",style: TextStyle(fontSize:ScreenUtil().setSp(34),color: Color(0xFF373737)),overflow: TextOverflow.ellipsis,maxLines: 3,),
                    ),
                  ],
                ),
              ],
            ),
            DateTime.parse(widget.info.endDate).isBefore(DateTime.now())?
            Positioned(
              right: 0,
              top: 0,
              child: Image(
                image: AssetImage('assets/images/mine_visitRecord_expired.png'),
                width: ScreenUtil().setWidth(256),
                fit: BoxFit.cover,
              ),
            ):_userInfo.id.toString()==widget.info.visitorId&&widget.info.recordType=="1"&&widget.info.cStatus=="applyConfirm"?
                Positioned(
                  bottom: ScreenUtil().setHeight(300),
                  width: ScreenUtil().setWidth(750),
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: ScreenUtil().setHeight(100),left: ScreenUtil().setWidth(112),right: ScreenUtil().setWidth(112)),
                          child: new SizedBox(
                            width: 300.0,
                            height: 50.0,
                            child: new RaisedButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                              color: Color(0xFF0073FE),
                              textColor: Color(0xFFFFFFFF),
                              child: new Text('通过',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36)),),
                              onPressed: () async {
                                selectedCompanyId=null;
                                  //访问
                                  if(widget.info.recordType=="1"){
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('访问审核',textScaleFactor: 1.0,),
                                          content: StatefulBuilder(
                                              builder: (context, StateSetter setState) {
                                                return Container(
                                                    height: 150,
                                                    child: Column(
                                                      children: <Widget>[
                                                        ListTile(
                                                          title: Text('访问地址',textScaleFactor: 1.0,),
                                                          subtitle: Text(_visitInfo.companyId == null ? "点击选择访问地址" :_visitInfo.companyId!=null?_visitInfo.companyName:"",textScaleFactor: 1.0,),
                                                          onTap: () {
                                                            Navigator.push(context, CupertinoPageRoute(builder: (context)=>VisitAddress(lists: _addressLists,))).then((value){
                                                              selectedCompanyId=_addressLists[value].companyId;
                                                              setState(() {
                                                                _visitInfo.companyId = _addressLists[value].companyId;
                                                                _visitInfo.companyName = _addressLists[value].companyName;
                                                                widget.info.companyName = _addressLists[value].companyName;
                                                                _visitInfo.address = _addressLists[value].address;
                                                                widget.info.address = _addressLists[value].address;
                                                                widget.info.visitDate = DateTime.now().toString();
                                                                widget.info.visitTime = DateFormat('HH-mm').format(DateTime.now());
                                                              });
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ));
                                              }),
                                          actions: <Widget>[
                                            new FlatButton(
                                              child: new Text("拒绝",
                                                style: TextStyle(color: Colors.red),textScaleFactor: 1.0,),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  _visitInfo.cstatus =
                                                  "applyFail";
                                                  widget.info.cStatus = "applyFail";
                                                  widget.info.visitDate = DateTime.now().toString();
                                                  widget.info.visitTime = DateFormat('HH-mm').format(DateTime.now());
                                                });
                                                changeVisitCompany(_visitInfo, selectedCompanyId);
                                              },
                                            ),
                                            new FlatButton(
                                              child: new Text("通过",
                                                style: TextStyle(color: Colors.blue),textScaleFactor: 1.0,),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                if(selectedCompanyId==null){
                                                  ToastUtil.showShortClearToast("请先选择一个地址");
                                                }else{
                                                  setState(() {
                                                    _visitInfo.cstatus =
                                                    "applySuccess";
                                                    widget.info.cStatus = "applySuccess";
                                                    widget.info.visitDate = DateTime.now().toString();
                                                    widget.info.visitTime = DateFormat('HH-mm').format(DateTime.now());
                                                  });
                                                  changeVisitCompany(_visitInfo, selectedCompanyId);
                                                }
                                              },
                                            ),
                                          ],
                                        ));
                                  }
                              },
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: ScreenUtil().setHeight(30),left: ScreenUtil().setWidth(112),right: ScreenUtil().setWidth(112)),
                          child: new SizedBox(
                            width: 300.0,
                            height: 50.0,
                            child: new RaisedButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                              color: Color(0xFFE0E0E0),
                              textColor: Color(0xFFFFFFFF),
                              child: new Text('拒绝',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36)),),
                              onPressed: () async {
                                //访问
                                if(widget.info.recordType=="1"){
                                    setState(() {
                                      _visitInfo.cstatus="applyFail";
                                      widget.info.cStatus="applyFail";
                                      widget.info.visitDate = DateTime.now().toString();
                                      widget.info.visitTime = DateFormat('HH-mm').format(DateTime.now());
                                      changeVisitCompany(_visitInfo, selectedCompanyId);
                                    });
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ):_userInfo.id.toString()==widget.info.userId&&widget.info.recordType=="2"&&widget.info.cStatus=="applyConfirm"? Positioned(
              bottom: ScreenUtil().setHeight(300),
              width: ScreenUtil().setWidth(750),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(100),left: ScreenUtil().setWidth(112),right: ScreenUtil().setWidth(112)),
                      child: new SizedBox(
                        width: 300.0,
                        height: 50.0,
                        child: new RaisedButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                          color: Color(0xFF0073FE),
                          textColor: Color(0xFFFFFFFF),
                          child: new Text('通过',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36)),),
                          onPressed: () async {
                            //邀约
                            if(widget.info.recordType=="2"){
                              setState(() {
                                _visitInfo.cstatus="applySuccess";
                                widget.info.cStatus="applySuccess";
                                adoptAndReject(_visitInfo);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(30),left: ScreenUtil().setWidth(112),right: ScreenUtil().setWidth(112)),
                      child: new SizedBox(
                        width: 300.0,
                        height: 50.0,
                        child: new RaisedButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                          color: Color(0xFFE0E0E0),
                          textColor: Color(0xFFFFFFFF),
                          child: new Text('拒绝',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36)),),
                          onPressed: () async {
                            //邀约
                            if(widget.info.recordType=="2"){
                              setState(() {
                                _visitInfo.cstatus="applyFail";
                                widget.info.cStatus="applyFail";
                                adoptAndReject(_visitInfo);
                              });
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ):Container()
          ],
        )
      )
    );
  }
  //邀约
  adoptAndReject(VisitInfo info) async {
    UserInfo user=await LocalStorage.load("userInfo");
    String url = "visitorRecord/visitReply";
    String threshold = await CommonUtil.calWorkKey(userInfo:user);
    var res = await Http().post(url,
        queryParameters: ({
          "token": user.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "userId": user.id,
          "id": info.id,
          "cstatus": info.cstatus,
          "answerContent": info.answerContent,
          "dataType": info.dateType,
          "startDate": info.startDate,
          "endDate": info.endDate,
        }),userCall: false );
    if (res is String) {
      Map map = jsonDecode(res);
      if (map['verify']['sign'] == "success") {
        ToastUtil.showShortClearToast(map['verify']['desc']);
      } else {
        ToastUtil.showShortClearToast(map['verify']['desc']);
        setState(() {
            widget.info.cStatus = "applyConfirm";
            _visitInfo.cstatus ="applyConfirm";
            widget.info.visitDate = DateTime.now().toString();
            widget.info.visitTime = DateFormat('HH-mm').format(DateTime.now());
        });
      }
    }
  }
  //访问
  changeVisitCompany(VisitInfo info,int companyId) async {
    String url = "visitorRecord/modifyCompanyFromId";
    UserInfo user=await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey(userInfo:user);
    var res = await Http().post(url,
        queryParameters: ({
          "token": user.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "userId": user.id,
          "id":info.id,
          "cstatus": info.cstatus,
          "answerContent": info.answerContent,
          "dataType": info.dateType,
          "startDate": info.startDate,
          "endDate": info.endDate,
          "companyId":companyId,
        }),debugMode: true );
    if(res is String) {
      Map map = jsonDecode(res);
      if (map['verify']['sign'] == "success") {
        ToastUtil.showShortClearToast(map['verify']['desc']);
      } else {
        ToastUtil.showShortClearToast(map['verify']['desc']);
        widget.info.cStatus = "applyConfirm";
      }
    }
  }
}