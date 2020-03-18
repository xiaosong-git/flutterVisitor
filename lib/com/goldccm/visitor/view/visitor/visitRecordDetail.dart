import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/VisitDetailInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/VisitInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/common/LoadingDialog.dart';
import 'package:visitor/com/goldccm/visitor/view/common/emptyPage.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/visitDetail.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/visitRecordDetailExt.dart';

//
// 详细访问
//
class VisitRecordDetail extends StatefulWidget {
  final VisitInfo visitInfo;
  VisitRecordDetail({Key key, this.visitInfo}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return VisitRecordDetailState();
  }
}

class VisitRecordDetailState extends State<VisitRecordDetail> {
  int count = 1;
  List<VisitDetailInfo> _visitDetailLists = <VisitDetailInfo>[];
  bool notEmpty = true;
  var _visitDetailBuilderFuture;
  EasyRefreshController _easyRefreshController;
  int sortType = 0;
  int total = 0;
  var dialog;
  var sortTypes=['全部','访问','邀约'];

  @override
  void initState() {
    super.initState();
    _easyRefreshController = EasyRefreshController();
    _visitDetailBuilderFuture = _getMoreData();
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(
          '访问邀约记录',
          textScaleFactor: 1.0,
          style: TextStyle(
              fontSize: ScreenUtil().setSp(36), color: Color(0xFF373737)),
        ),
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
              color: Color(0xFF373737),
            ),
            onPressed: () {
              setState(() {
                Navigator.pop(context);
              });
            }),
      ),
      body: FutureBuilder(
          builder: _visitDetailFuture, future: _visitDetailBuilderFuture),
    );
  }

  Widget _visitDetailFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text(
          '无连接',
          textScaleFactor: 1.0,
        );
        break;
      case ConnectionState.waiting:
        return LoadingDialog(
          text: '加载中',
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
        return _buildDetailList();
        break;
      default:
        return null;
    }
  }

  //构建列表
  _buildDetailList() {
    return EasyRefresh.custom(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            child: Row(
              children: <Widget>[
                Container(
                  child: widget.visitInfo.headUrl != null?CachedNetworkImage(
                    imageUrl: widget.visitInfo.headUrl != null
                        ? RouterUtil.imageServerUrl + widget.visitInfo.headUrl
                        : "",
                    placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.black,
                      ),
                      width: 10,
                      height: 10,
                      alignment: Alignment.center,
                    ),
                    errorWidget:  (context, url, error) =>
                        Image(
                          width: ScreenUtil().setWidth(112),
                          height: ScreenUtil().setHeight(112),
                          fit: BoxFit.cover,
                          image: AssetImage('assets/images/mine_visitRecord_headDefault.png'),
                        ),
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundImage: imageProvider,
                      radius: 100,
                    ),
                  ):Image(
                    width: ScreenUtil().setWidth(112),
                    height: ScreenUtil().setHeight(112),
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/mine_visitRecord_headDefault.png'),
                  ),
                  width: ScreenUtil().setWidth(120),
                  margin: EdgeInsets.all(ScreenUtil().setWidth(28)),
                  height: ScreenUtil().setWidth(120),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          child: Text(
                              widget.visitInfo.realName != null
                                  ? widget.visitInfo.realName
                                  : '未实名认证',
                              style: TextStyle(
                                color: Color(0xFF373737),
                                fontSize: ScreenUtil().setSp(30),
                              ),
                              softWrap: true,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textScaleFactor: 1.0),
                          width: ScreenUtil().setWidth(110),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(10),
                              right: ScreenUtil().setWidth(16)),
                          child: Text(
                            '|',
                            style: TextStyle(
                              color: Color(0xFFCFCFCF),
                              fontSize: ScreenUtil().setSp(30),
                            ),
                            softWrap: true,
                            textScaleFactor: 1.0,
                          ),
                        ),
                        Container(
                          child: Text(
                              widget.visitInfo.city != null
                                  ? widget.visitInfo.city
                                  : '无',
                              style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: ScreenUtil().setSp(30),
                              ),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textScaleFactor: 1.0),
                          width: ScreenUtil().setWidth(200),
                        )
                      ],
                    ),
                    Container(
                      width: ScreenUtil().setWidth(500),
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(16)),
                      child: Text(
                          widget.visitInfo.companyName != null
                              ? widget.visitInfo.companyName
                              : '',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: ScreenUtil().setSp(30),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaleFactor: 1.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(16)),
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(32)),
            height: ScreenUtil().setHeight(80),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 8,
                  child: RichText(
                    text: TextSpan(
                      text: "Ta和我有",
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(28),
                          color: Color(0xFFCFCFCF)),
                      children: <TextSpan>[
                        TextSpan(
                          text: total < 99 ? total.toString() : "99+",
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(28),
                              color: Color(0xFF0073FE)),
                        ),
                        TextSpan(
                          text: "条往来记录",
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(28),
                              color: Color(0xFFCFCFCF)),
                        ),
                      ],
                    ),
                    textScaleFactor: 1.0,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    child: FlatButton(
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            child: Text(
                              sortType == 1
                                  ? '访问'
                                  : sortType == 2 ? '邀约' : '全部',
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(28),
                                  color: Color(0xFF595959)),
                            ),
                            right: ScreenUtil().setWidth(30),
                            top: ScreenUtil().setHeight(15),
                          ),
                          Positioned(
                            right: ScreenUtil().setWidth(0),
                            top: ScreenUtil().setHeight(30),
                            child: Image(
                              image: AssetImage(
                                  'assets/images/login_triangle.png'),
                              width: ScreenUtil().setWidth(24),
                              height: ScreenUtil().setHeight(18),
                              color: Color(0xFF595959),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        callType();
                      },
                    ),
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFF8F8F8),
                  width: ScreenUtil().setHeight(2),
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              int itemIndex = index ~/ 2;
              if (index.isOdd) {
                return Divider(
                  height: 1,
                  color: Color(0xFFF8F8F8),
                );
              } else {
                if(_visitDetailLists[itemIndex]
                    .startDate.length<16||_visitDetailLists[itemIndex]
                    .endDate.length<16){
                  return Container();
                }
                if (index == 0) {
                  return Column(
                    children: <Widget>[
                      Container(
                        child: Text('${DateFormat('yyyy').format(DateTime.parse(
                            _visitDetailLists[itemIndex].startDate))}年',style: TextStyle(fontSize: ScreenUtil().setSp(38),color: Color(0xFF373737)),),
                        height: ScreenUtil().setHeight(90),
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: ScreenUtil().setWidth(32)),
                        color: Colors.white,
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            top: ScreenUtil().setHeight(16),
                            bottom: ScreenUtil().setHeight(16),
                            left: ScreenUtil().setWidth(32),
                            right: ScreenUtil().setWidth(32)),
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setHeight(0),
                              horizontal: ScreenUtil().setWidth(0)),
                          title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                RichText(
                                  text: TextSpan(
                                    text: "时间  ",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(26),
                                        color: Color(0xFFA8A8A8)),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: _visitDetailLists[itemIndex]
                                                    .startDate !=
                                                null
                                            ? DateFormat('HH:mm').format(
                                                DateTime.parse(
                                                    _visitDetailLists[itemIndex]
                                                        .startDate))
                                            : "",
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(30),
                                            color: Color(0xFF595959)),
                                      ),
                                      TextSpan(
                                        text: _visitDetailLists[itemIndex]
                                                    .endDate !=
                                                null
                                            ? "-${_visitDetailLists[itemIndex].endDate.substring(11, 16)}"
                                            : "",
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(30),
                                            color: Color(0xFF595959)),
                                      ),
                                    ],
                                  ),
                                  textScaleFactor: 1.0,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: "地址  ",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(26),
                                        color: Color(0xFFA8A8A8)),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: _visitDetailLists[itemIndex]
                                                    .address !=
                                                null
                                            ? "${_visitDetailLists[itemIndex].address}"
                                            : "暂无访问地址",
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(30),
                                            color: Color(0xFF595959)),
                                      ),
                                    ],
                                  ),
                                  textScaleFactor: 1.0,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ]),
                          leading: Container(
                            alignment: Alignment.topCenter,
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(20)),
                            width: ScreenUtil().setWidth(112),
                            child: Text(
                              DateFormat('MM/dd').format(DateTime.parse(
                                  _visitDetailLists[itemIndex].startDate)),
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(34),
                                  color: Color(0xFF595959)),
                            ),
                          ),
                          trailing: Container(
                            alignment: Alignment.topRight,
                            width: ScreenUtil().setWidth(100),
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(20)),
                            child: DateTime.parse(
                                        _visitDetailLists[itemIndex].endDate)
                                    .isBefore(DateTime.now())
                                ? Text(
                                    '过期',
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(30),
                                        color: Color(0xFFC2E8FF)),
                                  )
                                : _visitDetailLists[itemIndex].cStatus ==
                                        "applyConfirm"
                                    ? Text(
                                        '待审核',
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(30),
                                            color: Color(0xFF066FFD)),
                                      )
                                    : _visitDetailLists[itemIndex].cStatus ==
                                            "applySuccess"
                                        ? Text(
                                            '通过',
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(30),
                                                color: Color(0xFF0FAA0F)),
                                          )
                                        : Text(
                                            '拒绝',
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(30),
                                                color: Color(0xFFFD0637)),
                                          ),
                          ),
                          onTap: () {
                            print(_visitDetailLists[itemIndex]);
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => VisitRecordDetailExt(info: _visitDetailLists[itemIndex],))).then((value){
                              _refresh();
                            });
                          },
                        ),
                      ),
                    ],
                  );
                } else if (DateFormat('yyyy').format(DateTime.parse(
                        _visitDetailLists[itemIndex].startDate)) !=
                    DateFormat('yyyy').format(DateTime.parse(
                        _visitDetailLists[itemIndex - 1].startDate))) {
                  return Column(
                    children: <Widget>[
                      Container(
                        child: Text('${DateFormat('yyyy').format(DateTime.parse(
                      _visitDetailLists[itemIndex].startDate))}年',style: TextStyle(fontSize: ScreenUtil().setSp(38),color: Color(0xFF373737)),),
                          height: ScreenUtil().setHeight(90),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: ScreenUtil().setWidth(32)),
                          color: Colors.white,
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            top: ScreenUtil().setHeight(16),
                            bottom: ScreenUtil().setHeight(16),
                            left: ScreenUtil().setWidth(32),
                            right: ScreenUtil().setWidth(32)),
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setHeight(0),
                              horizontal: ScreenUtil().setWidth(0)),
                          title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                RichText(
                                  text: TextSpan(
                                    text: "时间  ",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(26),
                                        color: Color(0xFFA8A8A8)),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: _visitDetailLists[itemIndex]
                                                    .startDate !=
                                                null
                                            ? DateFormat('HH:mm').format(
                                                DateTime.parse(
                                                    _visitDetailLists[itemIndex]
                                                        .startDate))
                                            : "",
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(30),
                                            color: Color(0xFF595959)),
                                      ),
                                      TextSpan(
                                        text: _visitDetailLists[itemIndex]
                                                    .endDate !=
                                                null
                                            ? "-${_visitDetailLists[itemIndex].endDate.substring(11, 16)}"
                                            : "",
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(30),
                                            color: Color(0xFF595959)),
                                      ),
                                    ],
                                  ),
                                  textScaleFactor: 1.0,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: "地址  ",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(26),
                                        color: Color(0xFFA8A8A8)),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: _visitDetailLists[itemIndex]
                                            .address !=
                                                null
                                            ? "${_visitDetailLists[itemIndex].address}"
                                            : "暂无访问地址",
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(30),
                                            color: Color(0xFF595959)),
                                      ),
                                    ],
                                  ),
                                  textScaleFactor: 1.0,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ]),
                          leading: Container(
                            alignment: Alignment.topCenter,
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(20)),
                            width: ScreenUtil().setWidth(112),
                            child: Text(
                              DateFormat('MM/dd').format(DateTime.parse(
                                  _visitDetailLists[itemIndex].startDate)),
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(34),
                                  color: Color(0xFF595959)),
                            ),
                          ),
                          trailing: Container(
                            alignment: Alignment.topRight,
                            width: ScreenUtil().setWidth(100),
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(20)),
                            child: DateTime.parse(
                                        _visitDetailLists[itemIndex].endDate)
                                    .isBefore(DateTime.now())
                                ? Text(
                                    '过期',
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(30),
                                        color: Color(0xFFC2E8FF)),
                                  )
                                : _visitDetailLists[itemIndex].cStatus ==
                                        "applyConfirm"
                                    ? Text(
                                        '待审核',
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(30),
                                            color: Color(0xFF066FFD)),
                                      )
                                    : _visitDetailLists[itemIndex].cStatus ==
                                            "applySuccess"
                                        ? Text(
                                            '通过',
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(30),
                                                color: Color(0xFF0FAA0F)),
                                          )
                                        : Text(
                                            '拒绝',
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(30),
                                                color: Color(0xFFFD0637)),
                                          ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => VisitRecordDetailExt(info: _visitDetailLists[itemIndex]))).then((value){
                                      _refresh();
                            });
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return Container(
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setHeight(16),
                        bottom: ScreenUtil().setHeight(16),
                        left: ScreenUtil().setWidth(32),
                        right: ScreenUtil().setWidth(32)),
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setHeight(0),
                          horizontal: ScreenUtil().setWidth(0)),
                      title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            RichText(
                              text: TextSpan(
                                text: "时间  ",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(26),
                                    color: Color(0xFFA8A8A8)),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: _visitDetailLists[itemIndex]
                                                .startDate !=
                                            null
                                        ? DateFormat('HH:mm').format(
                                            DateTime.parse(
                                                _visitDetailLists[itemIndex]
                                                    .startDate))
                                        : "",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(30),
                                        color: Color(0xFF595959)),
                                  ),
                                  TextSpan(
                                    text: _visitDetailLists[itemIndex]
                                                .endDate !=
                                            null && _visitDetailLists[itemIndex]
                                        .endDate.length>=16
                                        ? "-${_visitDetailLists[itemIndex].endDate.substring(11, 16)}"
                                        : "",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(30),
                                        color: Color(0xFF595959)),
                                  ),
                                ],
                              ),
                              textScaleFactor: 1.0,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            RichText(
                              text: TextSpan(
                                text: "地址  ",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(26),
                                    color: Color(0xFFA8A8A8)),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: _visitDetailLists[itemIndex]
                                        .address !=
                                            null
                                        ? "${_visitDetailLists[itemIndex].address}"
        : "暂无访问地址",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(30),
                                        color: Color(0xFF595959)),
                                  ),
                                ],
                              ),
                              textScaleFactor: 1.0,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ]),
                      leading: Container(
                        alignment: Alignment.topCenter,
                        padding:
                            EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                        width: ScreenUtil().setWidth(112),
                        child: Text(
                          DateFormat('MM/dd').format(DateTime.parse(
                              _visitDetailLists[itemIndex].startDate)),
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(34),
                              color: Color(0xFF595959)),
                        ),
                      ),
                      trailing: Container(
                        alignment: Alignment.topRight,
                        width: ScreenUtil().setWidth(100),
                        padding:
                            EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                        child: DateTime.parse(
                                    _visitDetailLists[itemIndex].endDate)
                                .isBefore(DateTime.now())
                            ? Text(
                                '过期',
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(30),
                                    color: Color(0xFFC2E8FF)),
                              )
                            : _visitDetailLists[itemIndex].cStatus ==
                                    "applyConfirm"
                                ? Text(
                                    '待审核',
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(30),
                                        color: Color(0xFF066FFD)),
                                  )
                                : _visitDetailLists[itemIndex].cStatus ==
                                        "applySuccess"
                                    ? Text(
                                        '通过',
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(30),
                                            color: Color(0xFF0FAA0F)),
                                      )
                                    : Text(
                                        '拒绝',
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(30),
                                            color: Color(0xFFFD0637)),
                                      ),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => VisitRecordDetailExt(info: _visitDetailLists[itemIndex]))).then((value){
                          _refresh();
                        });
                      },
                    ),
                  );
                }
              }
            },
            childCount: _visitDetailLists.length * 2 - 1,
          ),
        )
      ],
      onRefresh: () async {
        _refresh();
      },
      onLoad: () async {
        _getMoreData();
      },
      controller: _easyRefreshController,
      enableControlFinishLoad: true,
      enableControlFinishRefresh: true,
      firstRefresh: false,
      firstRefreshWidget: LoadingDialog(
        text: '加载中',
      ),
//      emptyWidget: notEmpty != true ? EmptyPage() : null,
    );
  }

  //刷新
  _refresh() async {
    _visitDetailLists.clear();
    count = 1;
    String url = "visitorRecord/findRecordUserDetail";
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
    var res = await Http().post(url,
        queryParameters: ({
          "pageNum": count,
          "pageSize": 10,
          "token": userInfo.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "userId": userInfo.id,
          "visitorId": widget.visitInfo.visitorId,
          "recordType":sortType!=0?sortType==1?"1":"2":"",
        }),
        debugMode: true,
        userCall: false);
    if (res is String) {
      Map map = jsonDecode(res);
      if (map['verify']['sign'] == "success") {
        if (map['data']['total'] == 0) {
          setState(() {
            notEmpty = false;
            total = map['data']['total'];
          });
        } else {
          setState(() {
            total = map['data']['total'];
          });
          for (var data in map['data']['rows']) {
            _visitDetailLists.add(VisitDetailInfo.fromJson(data));
          }
          setState(() {
            count++;
          });
        }

      }
    }
    _easyRefreshController.finishRefresh(success: true);
    _easyRefreshController.finishLoad(success: true);
  }

  //加载更多数据
  _getMoreData() async {
    String url = "visitorRecord/findRecordUserDetail";
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
    var res = await Http().post(url,
        queryParameters: ({
          "pageNum": count,
          "pageSize": 10,
          "token": userInfo.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "userId": userInfo.id,
          "visitorId": widget.visitInfo.visitorId,
          "recordType":sortType!=0?sortType==1?"1":"2":"",
        }),
        debugMode: true,
        userCall: false);
    if (res is String) {
      Map map = jsonDecode(res);
      if (map['verify']['sign'] == "success") {
        if (map['data']['total'] == 0) {
          setState(() {
            notEmpty = false;
            total = map['data']['total'];
          });
          _easyRefreshController.finishLoad(success: true, noMore: true);
        } else {
          setState(() {
            total = map['data']['total'];
          });
          for (var data in map['data']['rows']) {
            _visitDetailLists.add(VisitDetailInfo.fromJson(data));
          }
          setState(() {
            count++;
          });
          if (map['data']['rows'].length < 10) {
            _easyRefreshController.finishLoad(success: true, noMore: true);
          } else {
            _easyRefreshController.finishLoad(success: true);
          }
        }
      }
    }
  }
  callType(){
      return dialog=YYDialog().build(context)
        ..gravity = Gravity.bottom
        ..gravityAnimationEnable = true
        ..backgroundColor = Colors.transparent
        ..widget(Container(
          width: 350,
          height: double.parse((45*sortTypes.length+1*sortTypes.length-1).toString()),
          margin: EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
          ),
          child: Column(
            children: <Widget>[
              ListView.separated(itemBuilder: (context,index){
                return InkWell(
                  child: Container(
                    width: 300,
                    height: 45,
                    child: Center(
                      child: Text(sortTypes[index],style: TextStyle(fontSize: ScreenUtil().setSp(32),color:sortType==index?Colors.blue:Colors.black),textScaleFactor: 1.0,),
                    ),
                  ),
                  onTap: (){
                    setState(() {
                      sortType=index;
                      _refresh();
                      dialog.dismiss();
                    });
                  },
                );
              },  separatorBuilder: (context,index){
                return Container(
                  child: Divider(
                    height: 1,
                  ),
                );
              }, itemCount: sortTypes.length,shrinkWrap: true,padding: EdgeInsets.all(0),)
            ],
          ),
        ))
        ..widget(InkWell(
          child: Container(
            width: 350,
            height: 45,
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                "取消",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),onTap: (){
          dialog.dismiss();
        },
        ))
        ..show();
  }
}
