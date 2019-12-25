import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/AddressInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/VisitInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/visitAddress.dart';
import 'package:visitor/com/goldccm/visitor/view/common/LoadingDialog.dart';
import 'package:visitor/com/goldccm/visitor/view/common/error.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/visitDetail.dart';

/*
 * 个人中心-审核界面
 * 审核访问我的人和帮助公司员工审核
 * author:hwk<hwk@growingpine.com>
 * create_time:2019/11/22
 */
class VisitList extends StatefulWidget {
  int currentRole;
  VisitList({Key key,this.currentRole}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return VisitListState();
  }
}

class VisitListState extends State<VisitList> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List tabs = ['我的访问', '访问我的人', '帮助审核'];
  List activeTabs = ['我的访问'];
  List<AddressInfo> _addressLists = <AddressInfo>[];
  List<VisitInfo> _visitLists = <VisitInfo>[];
  List _visitMyPeopleLists = [];
  List _visitMyCompanyLists = [];
  int selectedCompanyId;
  int _visitMineCount = 1;
  String currentRole="staff";
  var _visitBuilderFuture;
  var _visitMineBuilderFuture;
  var _visitCompanyBuilderFuture;
  ScrollController _scrollPeopleController = new ScrollController();
  ScrollController _scrollCompanyController = new ScrollController();
  ScrollController _scrollMineController = new ScrollController();
  bool visitMyPeopleNotEmpty = true;
  bool visitMyCompanyNotEmpty = true;
  bool visitMyMineNotEmpty = true;
  UserInfo _userInfo=new UserInfo();
  @override
  void initState() {
    super.initState();
    initAsync();
    _visitBuilderFuture = visitMyPeople();
    _visitCompanyBuilderFuture = visitMyCompany();
    _visitMineBuilderFuture = visitMine();
    if(widget.currentRole==1){
      _tabController = TabController(length: tabs.length, vsync: this);
    }else{
      _tabController = TabController(length: activeTabs.length, vsync: this);
    }
    _tabController.addListener(() {});
  }
  initAsync() async {
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

  visitMyPeople() async {
    UserInfo userInfo=await LocalStorage.load("userInfo");
      String url = "visitorRecord/visitMyPeople/1/100";
      String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
      var res = await Http().post(url,
          queryParameters: ({
            "token":userInfo.token,
            "factor": CommonUtil.getCurrentTime(),
            "threshold": threshold,
            "requestVer": await CommonUtil.getAppVersion(),
            "userId": userInfo.id,
          }),userCall: false);
      if(res !=""&&res!=null){
        if (res is String) {
          Map map = jsonDecode(res);
          if (map['verify']['sign'] == "success") {
              for (var data in map['data']['rows']) {
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
                  visitorRealName: data['realName'],
                  phone: data['phone'],
                  companyName: data['companyName'],
                  id: data['id'].toString(),
                  companyId: data['companyId'],
                );
                _visitMyPeopleLists.add(visitInfo);
              }
          }
        }
      }
  }

  visitMyCompany() async {
    UserInfo userInfo=await LocalStorage.load("userInfo");
      String url =
          "visitorRecord/visitMyCompany/1/100";
      String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
      var res = await Http().post(url,
          queryParameters: ({
            "token": userInfo.token,
            "factor": CommonUtil.getCurrentTime(),
            "threshold": threshold,
            "requestVer": await CommonUtil.getAppVersion(),
            "userId": userInfo.id,
          }),userCall: false);
      if(res!=""&&res!=null){
        if (res is String) {
          Map map = jsonDecode(res);
          if (map['verify']['sign'] == "success") {
              for (var data in map['data']['rows']) {
                VisitInfo visitInfo = new VisitInfo(
                  realName: data['userRealName'],
                  visitDate: data['visitDate'],
                  visitTime: data['visitTime'],
                  userId: data['userId'].toString(),
                  visitorId: data['visitorId'].toString(),
                  reason: data['reason'],
                  cstatus: data['cstatus'],
                  dateType: data['dateType'],
                  endDate: data['endDate'],
                  startDate: data['startDate'],
                  visitorRealName: data['userRealName'],
                  phone: data['phone'],
                  companyName: data['companyName'],
                  id: data['id'].toString(),
                );
                _visitMyCompanyLists.add(visitInfo);
              }
          }
        }
      }

  }

  visitMine() async {
    UserInfo userInfo=await LocalStorage.load("userInfo");
      String url =
         "visitorRecord/visitRecord/$_visitMineCount/100";
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
      if(res !=""&&res!=null){
        if (res is String) {
          Map map = jsonDecode(res);
          if (map['verify']['sign'] == "success") {
            for (var data in map['data']['rows']) {
              if (data['recordType'] == 1 && data['userId'] == userInfo.id){
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
  }

  adoptAndReject(VisitInfo info, int index, int type) async {
    UserInfo userInfo=await LocalStorage.load("userInfo");
    String url = "visitorRecord/adoptionAndRejection";
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url,
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
        }),userCall: false );
    if (res is String) {
      Map map = jsonDecode(res);
      if (map['verify']['sign'] == "success") {
        ToastUtil.showShortClearToast(map['verify']['desc']);
      } else {
        ToastUtil.showShortClearToast(map['verify']['desc']);
        setState(() {
          if (type == 1) {
            _visitMyPeopleLists[index].cstatus = "applyConfirm";
          }
          if (type == 2) {
            _visitMyCompanyLists[index].cstatus = "applyConfirm";
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.currentRole==1?Scaffold(
      appBar: AppBar(
        title: Text('访问与审核',textScaleFactor: 1.0,),
        centerTitle: true,
        bottom: TabBar(
            indicatorColor: Colors.blue,
            controller: _tabController,
            tabs: tabs
                .map((e) => Tab(
                      child: Text(e,textScaleFactor: 1.0,),
                    ))
                .toList()),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          FutureBuilder(
            builder: _visitMineFuture,
            future: _visitMineBuilderFuture,
          ),
            FutureBuilder(
              builder: _visitFuture,
              future: _visitBuilderFuture,
            ),
            FutureBuilder(
              builder: _visitCompanyFuture,
              future: _visitCompanyBuilderFuture,
            ),
        ],
      )
    ):Scaffold(
        appBar: AppBar(
          title: Text('访问与审核',textScaleFactor: 1.0,),
          centerTitle: true,
          bottom: TabBar(
              indicatorColor: Colors.blue,
              controller: _tabController,
              tabs: activeTabs
                  .map((e) => Tab(
                child: Text(e,textScaleFactor: 1.0,),
              ))
                  .toList()),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            FutureBuilder(
              builder: _visitMineFuture,
              future: _visitMineBuilderFuture,
            ),
          ],
        )
    );
  }

  Widget _visitFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('无连接',textScaleFactor: 1.0,);
        break;
      case ConnectionState.waiting:
        return LoadingDialog(text:'加载中');
        break;
      case ConnectionState.active:
        return Text('active',textScaleFactor: 1.0,);
        break;
      case ConnectionState.done:
        if (snapshot.hasError)
          return ErrorPage();
        return _buildList();
        break;
      default:
        return null;
    }
  }

  Widget _visitMineFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('无连接',textScaleFactor: 1.0,);
        break;
      case ConnectionState.waiting:
        return LoadingDialog(text:'加载中');
        break;
      case ConnectionState.active:
        return Text('active',textScaleFactor: 1.0,);
        break;
      case ConnectionState.done:
        if (snapshot.hasError)
          return ErrorPage();
        return _buildMineList();
        break;
      default:
        return null;
    }
  }

  _buildList() {
    return ListView.separated(
      itemCount: _visitMyPeopleLists.length,
      itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: RichText(text: TextSpan(
              text: '来访人员  ',
              style: TextStyle(fontSize: 16,color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: _visitMyPeopleLists[index].realName != null
                      ? _visitMyPeopleLists[index].realName
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
                        text:_visitMyPeopleLists[index].startDate != null ? _visitMyPeopleLists[index].startDate : "",
                        style: TextStyle(fontSize: 16,color: Colors.grey),
                      ),
                    ],
                  ),textScaleFactor: 1.0,),
                  RichText(text: TextSpan(
                    text: '结束时间  ',
                    style: TextStyle(fontSize: 16,color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text:_visitMyPeopleLists[index].endDate != null ? "${_visitMyPeopleLists[index].endDate}" : "",
                        style: TextStyle(fontSize: 16,color: Colors.grey),
                      ),
                    ],
                  ),textScaleFactor: 1.0,),
                ]),
            trailing:  _visitMyPeopleLists[index].cstatus != null ?_visitMyPeopleLists[index].cstatus == "applyConfirm"?DateTime.parse(_visitMyPeopleLists[index].endDate).isBefore(DateTime.now())?Text("过期",style: TextStyle(color: Colors.red),):Text("审核",style: TextStyle(),):_visitMyPeopleLists[index].cstatus == "applySuccess" ?Text("通过",style: TextStyle(color: Colors.green,),):Text("拒绝",style: TextStyle( color: Colors.red),):Text(""),
            onTap: () {
              if(DateTime.parse(_visitMyPeopleLists[index].endDate).isBefore(DateTime.now())){
                ToastUtil.showShortClearToast("访问记录已过期");
              }
              else if (_visitMyPeopleLists[index].cstatus == "applyConfirm") {
                selectedCompanyId=null;
                _visitMyPeopleLists[index].companyName = null;
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
                                      subtitle: Text(_visitMyPeopleLists[index].companyId == null ? "点击选择访问地址" : _visitMyPeopleLists[index].companyName!=null?_visitMyPeopleLists[index].companyName:"",textScaleFactor: 1.0,),
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>VisitAddress(lists: _addressLists,))).then((value){
                                          selectedCompanyId=_addressLists[value].companyId;
                                          setState(() {
                                            _visitMyPeopleLists[index].companyId = _addressLists[value].companyId;
                                            _visitMyPeopleLists[index].companyName = _addressLists[value].companyName;
                                          });
                                        });
                                      },
                                    ),
                                    ListTile(
                                      title: Text('访问理由',textScaleFactor: 1.0,),
                                      subtitle: Text(_visitMyPeopleLists[index].reason != null ? _visitMyPeopleLists[index].reason : "",textScaleFactor: 1.0,),
                                    )
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
                                  _visitMyPeopleLists[index].cstatus =
                                      "applyFail";
                                });
                                changeVisitCompany(_visitMyPeopleLists[index], selectedCompanyId,index);
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
                                    _visitMyPeopleLists[index].cstatus =
                                    "applySuccess";
                                  });
                                  changeVisitCompany(_visitMyPeopleLists[index], selectedCompanyId,index);
                                }
                              },
                            ),
                          ],
                        ));
              } else {
                ToastUtil.showShortClearToast("访问记录已回复");
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
      controller: _scrollPeopleController,
    );
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
      controller: _scrollMineController,
    );
  }

  Widget _visitCompanyFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('无连接',textScaleFactor: 1.0,);
        break;
      case ConnectionState.waiting:
        return  LoadingDialog(text:'加载中');
        break;
      case ConnectionState.active:
        return Text('active',textScaleFactor: 1.0,);
        break;
      case ConnectionState.done:
        if (snapshot.hasError)
          return ErrorPage();
        return _buildCompanyList();
        break;
      default:
        return null;
    }
  }

  _buildCompanyList() {
    return ListView.separated(
      itemCount:  _visitMyCompanyLists.length,
      itemBuilder: (BuildContext context, int index) {

          return ListTile(
            title: RichText(text: TextSpan(
              text: '来访人员  ',
              style: TextStyle(fontSize: 16,color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: _visitMyCompanyLists[index].realName != null
                      ? _visitMyCompanyLists[index].realName
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
                        text:_visitMyCompanyLists[index].startDate != null ? _visitMyCompanyLists[index].startDate : "",
                        style: TextStyle(fontSize: 16,color: Colors.grey),
                      ),
                    ],
                  ),textScaleFactor: 1.0,),
                  RichText(text: TextSpan(
                    text: '结束时间  ',
                    style: TextStyle(fontSize: 16,color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text:_visitMyCompanyLists[index].endDate != null ? "${_visitMyCompanyLists[index].endDate}" : "",
                        style: TextStyle(fontSize: 16,color: Colors.grey),
                      ),
                    ],
                  ),textScaleFactor: 1.0,),
                ]),
            trailing: _visitMyCompanyLists[index].cstatus != null ?_visitMyCompanyLists[index].cstatus == "applyConfirm"?DateTime.parse(_visitMyCompanyLists[index].endDate).isBefore(DateTime.now())?Text("过期",style: TextStyle( color: Colors.red),):Text("审核",style: TextStyle(),textScaleFactor: 1.0,): _visitMyCompanyLists[index].cstatus == "applySuccess" ?Text("通过",style: TextStyle(color: Colors.green,),textScaleFactor: 1.0,):Text("拒绝",style: TextStyle( color: Colors.red),textScaleFactor: 1.0,):Text(""),
            onTap: () {
              if(DateTime.parse(_visitMyCompanyLists[index].endDate).isBefore(DateTime.now())){
                ToastUtil.showShortClearToast("访问记录已过期");
              }
              else if (_visitMyCompanyLists[index].cstatus == "applyConfirm") {
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
                                      subtitle: Text(_visitMyCompanyLists[index].companyName != null ? _visitMyCompanyLists[index].companyName : "",textScaleFactor: 1.0,),
                                    ),
                                    ListTile(
                                      title: Text('访问理由',textScaleFactor: 1.0,),
                                      subtitle: Text(_visitMyCompanyLists[index].reason != null ? _visitMyCompanyLists[index].reason : "",textScaleFactor: 1.0,),
                                    )
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
                                  _visitMyCompanyLists[index].cstatus =
                                      "applyFail";
                                });
                                adoptAndReject(
                                    _visitMyCompanyLists[index], index, 2);
                              },
                            ),
                            new FlatButton(
                              child: new Text("通过",
                                  style: TextStyle(color: Colors.blue),textScaleFactor: 1.0,),
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  _visitMyCompanyLists[index].cstatus =
                                      "applySuccess";
                                });
                                adoptAndReject(
                                    _visitMyCompanyLists[index], index, 2);
                              },
                            ),
                          ],
                        ));
              } else {
                ToastUtil.showShortClearToast("访问记录已回复");
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
      controller: _scrollCompanyController,
    );
  }
  changeVisitCompany(VisitInfo info,int companyId,int index) async {
      String url = "visitorRecord/modifyCompanyFromId";
      String threshold = await CommonUtil.calWorkKey(userInfo: _userInfo);
      var res = await Http().post(url,
          queryParameters: ({
            "token": _userInfo.token,
            "factor": CommonUtil.getCurrentTime(),
            "threshold": threshold,
            "requestVer": await CommonUtil.getAppVersion(),
            "userId": _userInfo.id,
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
          _visitMyPeopleLists[index].cstatus = "applyConfirm";
        }
      }
  }
  @override
  void dispose() {
    _tabController?.dispose();
    _scrollPeopleController.dispose();
    _scrollCompanyController.dispose();
    _scrollMineController.dispose();
    super.dispose();
  }
}
