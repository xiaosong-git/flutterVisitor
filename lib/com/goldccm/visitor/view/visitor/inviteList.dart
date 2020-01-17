import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/VisitInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/visitDetail.dart';

/*
 * 个人中心 邀约界面
 * 查看邀约我的人和我要邀约的人
 * create_time:2019/10/23
    */
class InviteList extends StatefulWidget {
  final UserInfo userInfo;
  InviteList({Key key, this.userInfo}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return InviteListState();
  }
}

/*
 *  _mineInviteLists,_whoInviteMeLists 邀约我和收到的邀约
 */
class InviteListState extends State<InviteList>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List tabs = ['我的邀约', '邀约我的人'];
  List _mineInviteLists = [];
  List _whoInviteMeLists = [];
  var _inviteBuilderFuture;
  var _whoInviteBuilderFuture;
  ScrollController _scrollMineController = new ScrollController();
  ScrollController _scrollWhoController = new ScrollController();
  bool isPerformingRequest = false;
  bool isPerformingWhoInviteRequest = false;
  bool mineInviteNotEmpty = true;
  bool whoInviteMeNotEmpty = true;
  @override
  void initState() {
    super.initState();
    _inviteBuilderFuture = getSentInviteLists();
    _whoInviteBuilderFuture = getReceivedInviteLists();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {});
  }

  //获取我的邀约列表
  getSentInviteLists() async {
    String url =  "visitorRecord/visitorList";
    String threshold = await CommonUtil.calWorkKey(userInfo: widget.userInfo);
    var res = await Http().post(url,
        queryParameters: ({
          "pageNum":1,
          "pageSize":100,
          "token": widget.userInfo.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "userId": widget.userInfo.id,
          "condition":"visitorId",
          "recordType":2,
        }),
        userCall: false);
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
          );
          if (data['visitorId'] == widget.userInfo.id) {
            _mineInviteLists.add(visitInfo);
          }
        }
        setState(() {});
      } else {
        ToastUtil.showShortClearToast(map['verify']['desc']);
      }
    }
  }

  //获取审核邀约列表
  getReceivedInviteLists() async {
    String url = "visitorRecord/visitorList";
    String threshold = await CommonUtil.calWorkKey(userInfo: widget.userInfo);
    var res = await Http().post(url,
        queryParameters: ({
          "pageNum":1,
          "pageSize":100,
          "token": widget.userInfo.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "userId": widget.userInfo.id,
          "condition":"userId",
          "recordType":2,
        }),
        userCall: false);
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
            visitorRealName: widget.userInfo.realName,
            phone: data['phone'],
            companyName: data['companyName'],
            id: data['id'].toString(),
          );
            _whoInviteMeLists.add(visitInfo);
        }
        setState(() {});
      } else {
        ToastUtil.showShortClearToast(map['verify']['desc']);
      }
    }
  }

  //审核邀约
  adoptAndReject(VisitInfo info, int index) async {
    String url ="visitorRecord/visitReply";
    String threshold = await CommonUtil.calWorkKey();
    var res = await Http().post(url,
        queryParameters: ({
          "token": widget.userInfo.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "userId": widget.userInfo.id,
          "id": info.id,
          "cstatus": info.cstatus,
          "answerContent": info.answerContent,
          "dataType": info.dateType,
          "startDate": info.startDate,
          "endDate": info.endDate,
        }));
    if (res is String) {
      Map map = jsonDecode(res);
      if (map['verify']['sign'] == "success") {
        ToastUtil.showShortClearToast(map['verify']['desc']);
      } else {
        ToastUtil.showShortClearToast(map['verify']['desc']);
        setState(() {
          _whoInviteMeLists[index].cstatus = "applyConfirm";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '邀约记录',
          textScaleFactor: 1.0,
        ),
        centerTitle: true,
        bottom: TabBar(
            indicatorColor: Colors.blue,
            controller: _tabController,
            tabs: tabs
                .map((e) => Tab(
                      child: Text(
                        e,
                        textScaleFactor: 1.0,
                      ),
                    ))
                .toList()),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          FutureBuilder(
            builder: _inviteFuture,
            future: _inviteBuilderFuture,
          ),
          FutureBuilder(
            builder: _inviteWhoFuture,
            future: _whoInviteBuilderFuture,
          ),
        ],
      ),
    );
  }

  Widget _inviteFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text(
          '无连接',
          textScaleFactor: 1.0,
        );
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
                      style: TextStyle(color: Colors.white),
                      textScaleFactor: 1.0,
                    )
                  ],
                ),
              ),
            ),
          ],
        );
        break;
      case ConnectionState.active:
        return Text(
          'active',
          textScaleFactor: 1.0,
        );
        break;
      case ConnectionState.done:
        if (snapshot.hasError)
          return Text(
            snapshot.error.toString(),
            textScaleFactor: 1.0,
          );
        return _buildList();
        break;
      default:
        return null;
    }
  }

  _buildList() {
    return ListView.separated(
      itemCount: _mineInviteLists.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: RichText(
            text: TextSpan(
              text: '受邀人员  ',
              style: TextStyle(fontSize: 16, color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: _mineInviteLists[index].realName != null
                      ? _mineInviteLists[index].realName
                      : "",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            textScaleFactor: 1.0,
          ),
          subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: '开始时间  ',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: _mineInviteLists[index].startDate != null
                            ? _mineInviteLists[index].startDate
                            : "",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  textScaleFactor: 1.0,
                ),
                RichText(
                  text: TextSpan(
                    text: '结束时间  ',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: _mineInviteLists[index].endDate != null
                            ? "${_mineInviteLists[index].endDate}"
                            : "",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  textScaleFactor: 1.0,
                ),
              ]),
          trailing: _mineInviteLists[index].cstatus != null
              ? _mineInviteLists[index].cstatus == "applyConfirm"
                  ? DateTime.parse(_mineInviteLists[index].endDate)
                          .isBefore(DateTime.now())
                      ? Text(
                          "过期",
                          style: TextStyle(color: Colors.red),
                        )
                      : Text(
                          "审核",
                          style: TextStyle(),
                        )
                  : _mineInviteLists[index].cstatus == "applySuccess"
                      ? Text(
                          "通过",
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        )
                      : Text(
                          "拒绝",
                          style: TextStyle(color: Colors.red),
                        )
              : Text(""),
          onTap: () {
            if (DateTime.parse(_mineInviteLists[index].endDate)
                .isBefore(DateTime.now())) {
              ToastUtil.showShortClearToast("访问记录已过期");
            }else{
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VisitDetail(
                        visitInfo: _mineInviteLists[index],
                      )));
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

  Widget _inviteWhoFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text(
          '无连接',
          textScaleFactor: 1.0,
        );
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
                      style: TextStyle(color: Colors.white),
                      textScaleFactor: 1.0,
                    )
                  ],
                ),
              ),
            ),
          ],
        );
        break;
      case ConnectionState.active:
        return Text(
          'active',
          textScaleFactor: 1.0,
        );
        break;
      case ConnectionState.done:
        if (snapshot.hasError)
          return Text(
            snapshot.error.toString(),
            textScaleFactor: 1.0,
          );
        return _buildWhoList();
        break;
      default:
        return null;
    }
  }

  _buildWhoList() {
    return ListView.separated(
      itemCount: _whoInviteMeLists.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: RichText(text: TextSpan(
            text: '邀约人员  ',
            style: TextStyle(fontSize: 16,color: Colors.black),
            children: <TextSpan>[
              TextSpan(
                text: _whoInviteMeLists[index].realName!=null?_whoInviteMeLists[index].realName:"",
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
                      text:_whoInviteMeLists[index].startDate!=null?_whoInviteMeLists[index].startDate: "",
                      style: TextStyle(fontSize: 16,color: Colors.grey),
                    ),
                  ],
                ),textScaleFactor: 1.0,),
                RichText(text: TextSpan(
                  text: '结束时间  ',
                  style: TextStyle(fontSize: 16,color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                      text: _whoInviteMeLists[index].endDate!=null?"${_whoInviteMeLists[index].endDate}":"",
                      style: TextStyle(fontSize: 16,color: Colors.grey),
                    ),
                  ],
                ),textScaleFactor: 1.0,),
              ]),
          trailing: _whoInviteMeLists[index].cstatus != null ?_whoInviteMeLists[index].cstatus == "applyConfirm"?DateTime.parse(_whoInviteMeLists[index].endDate).isBefore(DateTime.now())?Text("过期",style: TextStyle(color: Colors.red),):Text("审核",style: TextStyle(),):_whoInviteMeLists[index].cstatus == "applySuccess" ?Text("通过",style: TextStyle(color: Colors.green,),):Text("拒绝",style: TextStyle( color: Colors.red),):Text(""),
          onTap: () {
            if (DateTime.parse(_whoInviteMeLists[index].endDate)
                .isBefore(DateTime.now())) {
              ToastUtil.showShortClearToast("邀约记录已过期");
            } else if (_whoInviteMeLists[index].cstatus == "applyConfirm") {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text(
                          '邀约审核',
                          textScaleFactor: 1.0,
                        ),
                        content: StatefulBuilder(
                            builder: (context, StateSetter setState) {
                          return Container(
                              height: 150,
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    title: Text(
                                      '邀约地址',
                                      textScaleFactor: 1.0,
                                    ),
                                    subtitle: Text(
                                      _whoInviteMeLists[index].companyName !=
                                              null
                                          ? _whoInviteMeLists[index].companyName
                                          : "",
                                      textScaleFactor: 1.0,
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      '邀约理由',
                                      textScaleFactor: 1.0,
                                    ),
                                    subtitle: Text(
                                      _whoInviteMeLists[index].reason != null
                                          ? _whoInviteMeLists[index].reason
                                          : "",
                                      textScaleFactor: 1.0,
                                    ),
                                  )
                                ],
                              ));
                        }),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text(
                              "拒绝",
                              style: TextStyle(color: Colors.red),
                              textScaleFactor: 1.0,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                _whoInviteMeLists[index].cstatus = "applyFail";
                              });
                              adoptAndReject(_whoInviteMeLists[index], index);
                            },
                          ),
                          new FlatButton(
                            child: new Text(
                              "通过",
                              style: TextStyle(color: Colors.blue),
                              textScaleFactor: 1.0,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                _whoInviteMeLists[index].cstatus =
                                    "applySuccess";
                              });
                              adoptAndReject(_whoInviteMeLists[index], index);
                            },
                          ),
                        ],
                      ));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VisitDetail(
                            visitInfo: _whoInviteMeLists[index],
                          )));
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
      controller: _scrollWhoController,
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollMineController.dispose();
    _scrollWhoController.dispose();
    super.dispose();
  }
}
