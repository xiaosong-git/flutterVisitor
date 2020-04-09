import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:visitor/com/goldccm/visitor/component/Qrcode.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/QrcodeMode.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/VisitInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/QrcodeHandler.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/common/LoadingDialog.dart';
import 'package:visitor/com/goldccm/visitor/view/common/emptyPage.dart';
import 'package:visitor/com/goldccm/visitor/view/Add/Visit/visitDetail.dart';
import 'package:visitor/com/goldccm/visitor/view/Mine/visitRecordDetail.dart';
/*
 * 访问记录
 * 展示可用于访问的访问二维码
 */
class VisitRecord extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return VisitRecordState();
  }
}

class VisitRecordState extends State<VisitRecord>{
  int count = 1;
  List<VisitInfo> _visitLists = <VisitInfo>[];
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
            contentPadding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(24),horizontal: ScreenUtil().setWidth(24)),
            title: RichText(
              text: TextSpan(
                text: _visitLists[index].realName != null ? _visitLists[index].realName : "",
                style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF212121)),
              ),
              textScaleFactor: 1.0,
            ),
            subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(text: TextSpan(
                    text:"访问时间  ",
                    style: TextStyle(fontSize: ScreenUtil().setSp(26),color: Color(0xFFA8A8A8)),
                    children: <TextSpan>[
                      TextSpan(
                      text:_visitLists[index].startDate != null ? DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(_visitLists[index].startDate)):"",
                        style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF595959)),
                      ),
                      TextSpan(
                        text:_visitLists[index].endDate != null ? "-${DateFormat('HH:mm').format(DateTime.parse(_visitLists[index].endDate))}" : "",
                        style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF595959)),
                      ),
                    ],
                  ),textScaleFactor: 1.0,maxLines: 1,overflow: TextOverflow.ellipsis,),
                  RichText(text: TextSpan(
                    text:"访问地址  ",
                    style: TextStyle(fontSize: ScreenUtil().setSp(26),color: Color(0xFFA8A8A8)),
                    children: <TextSpan>[
                      TextSpan(
                        text:_visitLists[index].address != null ? "${_visitLists[index].address}" :"暂无访问地址",
                        style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Color(0xFF595959)),
                      ),
                    ],
                  ),textScaleFactor: 1.0,maxLines: 1,overflow: TextOverflow.ellipsis,),
                ]
            ),
            leading: Container(
              width: ScreenUtil().setWidth(112),
              height: ScreenUtil().setHeight(112),
              child: _visitLists[index].headUrl!=null?CachedNetworkImage(
                imageUrl: RouterUtil.imageServerUrl +
                    _visitLists[index].headUrl,
                placeholder: (context, url) =>
                    Container(
                      child: CircularProgressIndicator(backgroundColor: Colors.black,),
                      width: ScreenUtil().setWidth(20),
                      height: ScreenUtil().setHeight(20),
                      alignment: Alignment.center,
                    ),
                errorWidget: (context, url, error) =>
                    Image(
                      width: ScreenUtil().setWidth(112),
                      height: ScreenUtil().setHeight(112),
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/mine_visitRecord_headDefault.png'),
                    ),
                imageBuilder: (context,imageProvider)=>CircleAvatar(
                  backgroundImage: imageProvider,
                  radius: 100,
                ),
                width: ScreenUtil().setWidth(112),
                height: ScreenUtil().setHeight(112),
                fit: BoxFit.cover,
              ):Image(
                width: ScreenUtil().setWidth(112),
                height: ScreenUtil().setHeight(112),
                fit: BoxFit.cover,
                image: AssetImage('assets/images/mine_visitRecord_headDefault.png'),
              ),
            ),
            trailing: Image.asset("assets/images/mine_next.png",),
            onTap: () {
                Navigator.push(context, CupertinoPageRoute(builder: (context) => VisitRecordDetail(visitInfo: _visitLists[index],)));
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
        _refresh();
      },
      onLoad: ()async{
        _getMoreData();
      },
      controller: _easyRefreshController,
      enableControlFinishLoad: true,
      enableControlFinishRefresh: true,
      firstRefresh: false,
      firstRefreshWidget: LoadingDialog(text: '加载中',),
      emptyWidget: notEmpty!=true?EmptyPage():null,
    );
  }
  _refresh() async {
    _visitLists.clear();
    count=1;
    String url = "visitorRecord/findRecordUser";
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey(userInfo:userInfo);
    var res = await Http().post(url,
        queryParameters: ({
          "pageNum":count,
          "pageSize":10,
          "token": userInfo.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "userId": userInfo.id,
          "condition":"userId",
          "recordType":1,
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
            _visitLists.add(VisitInfo.fromJson(data));
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
    String url = "visitorRecord/findRecordUser";
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey(userInfo:userInfo);
    var res = await Http().post(url,
        queryParameters: ({
          "pageNum":count,
          "pageSize":10,
          "token": userInfo.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "userId": userInfo.id,
          "condition":"userId",
          "recordType":1,
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
            _visitLists.add(VisitInfo.fromJson(data));
          }
          setState(() {
            count++;
          });
          if (map['data']['rows'].length < 10) {
            _easyRefreshController.finishLoad(success: true,noMore: true);
          }else{
            _easyRefreshController.finishLoad(success: true);
          }
        }
      }
    }
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
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text('访问邀约记录',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF373737)),),
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
      body: notEmpty==true?
         FutureBuilder(
            builder: _visitFuture,
            future: _visitBuilderFuture,
         )
          :Column(
        children: <Widget>[
          Container(
            child: Image(
              image: AssetImage('assets/images/mine_visitRecord_empty.png'),
              width: ScreenUtil().setWidth(600),
              fit: BoxFit.cover,
            ),
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(160),bottom: ScreenUtil().setHeight(50)),
          ),
          Center(child: Text('暂无记录',textScaleFactor: 1.0,style: TextStyle(color: Color(0xFF373737),fontSize: ScreenUtil().setSp(34)),))
        ],
      ),
    );
  }
}