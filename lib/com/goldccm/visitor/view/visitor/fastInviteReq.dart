import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/AddressInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/RegExpUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/visitAddress.dart';

/*
 * 实现非好友快速邀约
 * author:ody997<hwk@growingpine.com>
 * create_time:2019/11/29
 */
class FastInviteReq extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new FastInviteReqState();
  }
}
/*
 * TextEditingController and FocusNode 是长时间存在的对象，需要在initState创建，然后在dispose中清除
 */
class FastInviteReqState extends State<FastInviteReq> {

  final TextStyle _labelStyle = new TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  final TextStyle _hintlStyle = new TextStyle(fontSize: 16.0, color: Colors.black54);

  TextEditingController _inviteNameControl;
  TextEditingController _invitePhoneControl;
  TextEditingController _inviteStartControl;
  TextEditingController _inviteAddrControl;
  List<AddressInfo> _mineAddress=<AddressInfo>[];
  TextEditingController _inviteEndControl;
  TextEditingController _inviteReasonControl;
  FocusNode _startNode;
  FocusNode _endNode;
  AddressInfo selectedMineAddress;

  @override
  void initState() {
    super.initState();
    init();
    _startNode = FocusNode();
    _endNode = FocusNode();
    _inviteNameControl = TextEditingController();
    _invitePhoneControl = TextEditingController();
    _inviteAddrControl = TextEditingController();
    _inviteStartControl = TextEditingController();
    _inviteEndControl = TextEditingController();
    _inviteReasonControl = TextEditingController();
  }
  init() async {
    _mineAddress=await getAddressInfo();
  }
  @override
  void dispose() {
    _startNode.dispose();
    _endNode.dispose();
    _inviteNameControl.dispose();
    _inviteReasonControl.dispose();
    _inviteEndControl.dispose();
    _invitePhoneControl.dispose();
    _inviteStartControl.dispose();
    _inviteAddrControl.dispose();
    super.dispose();
  }
  getAddressInfo() async {
    String url = "companyUser/findVisitComSuc";
    String threshold = await CommonUtil.calWorkKey();
    UserInfo userInfo =await LocalStorage.load("userInfo");
    List<AddressInfo> _list=<AddressInfo>[];
    var res = await Http().post(url,queryParameters: {
      "token": userInfo.token,
      "userId": userInfo.id,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "visitorId":userInfo.id,
    },userCall: false );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.color,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: new Text(
            '便捷邀约',
            textAlign: TextAlign.center,
            style: new TextStyle(fontSize: 18.0, color: Colors.white),
            textScaleFactor: 1.0,
          ),
        ),
        body: SingleChildScrollView(
          child: new Padding(
            padding: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                buildForm('邀约姓名', '请输入真实姓名', true, 25, _inviteNameControl,
                    TextInputType.text),
                new Divider(
                  color: Colors.black54,
                ),
                buildForm('邀约手机号', '请输入拜访人手机号', true, 10, _invitePhoneControl,
                    TextInputType.phone),
                new Divider(
                  color: Colors.black54,
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      padding: EdgeInsets.all(10.0).copyWith(right: 20.0),
                      child: new Text(
                        '邀约地址',
                        style: _labelStyle,
                        textScaleFactor: 1.0,
                      ),
                    ),
                    new Expanded(
                      child: new TextField(
                        onTap: () {
                          Navigator.push(context,MaterialPageRoute(builder: (context)=>VisitAddress(lists: _mineAddress,))).then((value){
                            selectedMineAddress=_mineAddress[value];
                            setState(() {
                              _inviteAddrControl.text=selectedMineAddress.companyName;
                            });
                          });
                        },
                        controller: _inviteAddrControl,
                        autofocus: false,
                        readOnly: true,
                        textInputAction: TextInputAction.next,
                        style: _hintlStyle,
                        decoration: InputDecoration(
                          hintText: '请选择邀约地址',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 30),
                        ),
                      ),
                    ),
                  ],
                ),
                new Divider(
                  color: Colors.black54,
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      padding: EdgeInsets.all(10.0).copyWith(right: 20.0),
                      child: new Text(
                        '邀约开始时间',
                        style: _labelStyle,
                        textScaleFactor: 1.0,
                      ),
                    ),
                    // 右边部分输入，用Expanded限制子控件的大小
                    new Expanded(
                      child: new TextField(
                        onTap: () {
                          DatePicker.showDateTimePicker(
                            context,
                            locale: LocaleType.zh,
                            theme: new DatePickerTheme(),
                            onConfirm: (date) {
                              print('comfirm$date');
                              if (date.isBefore(DateTime.now())) {
                                ToastUtil.showShortToast('开始时间不能小于当前时间');
                                _inviteStartControl.text = '';
                                _startNode.unfocus();
                                return;
                              }
                              if (null != _inviteEndControl.text.toString() &&
                                  _inviteEndControl.text.toString().length ==
                                      16) {
                                if (date.isAfter(DateTime.parse(
                                    _inviteEndControl.text.toString()))) {
                                  ToastUtil.showShortToast('开始时间不能大于结束时间');
                                  _inviteStartControl.text = '';
                                  _startNode.unfocus();
                                  return;
                                }

                                if (date.day !=
                                    (DateTime.parse(
                                        _inviteEndControl.text.toString())
                                        .day)) {
                                  ToastUtil.showShortToast('邀约时间请选择在同一天,请重新选择');
                                  _inviteStartControl.text = '';
                                  _endNode.unfocus();
                                  return;
                                }
                              }
                              _inviteStartControl.text =
                                  date.toString().substring(0, 16);
                              _startNode.unfocus();
                            },
                          );
                        },
                        controller: _inviteStartControl,
                        focusNode: _startNode,
                        autofocus: false,
                        readOnly: true,
                        textInputAction: TextInputAction.next,
                        style: _hintlStyle,
                        decoration: InputDecoration(
                          hintText: '请选择邀约开始时间',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                new Divider(
                  color: Colors.black54,
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      padding: EdgeInsets.all(10.0).copyWith(right: 20.0),
                      child: new Text(
                        '邀约结束时间',
                        style: _labelStyle,
                      ),
                    ),
                    new Expanded(
                      child: new TextField(
                        onTap: () {
                          DatePicker.showDateTimePicker(
                            context,
                            locale: LocaleType.zh,
                            theme: new DatePickerTheme(),
                            onConfirm: (date) {
                              print('comfirm$date');
                              if (date.isBefore(DateTime.parse(
                                  _inviteStartControl.text.toString()))) {
                                ToastUtil.showShortToast('结束时间不能小于开始时间,请重新选择');
                                _endNode.unfocus();
                                return;
                              }

                              if (date.day !=
                                  (DateTime.parse(
                                      _inviteStartControl.text.toString())
                                      .day)) {
                                ToastUtil.showShortToast('邀约时间请选择在同一天,请重新选择');
                                _endNode.unfocus();
                                return;
                              }
                              _inviteEndControl.text =
                                  date.toString().substring(0, 16);
                              _endNode.unfocus();
                            },
                          );
                        },

                        controller: _inviteEndControl,
                        autofocus: false,
                        focusNode: _endNode,
                        readOnly: true,
                        style: _hintlStyle,
                        decoration: InputDecoration(
                          hintText: '请选择邀约结束时间',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                new Divider(
                  color: Colors.black54,
                ),
                Column(
                  children: <Widget>[
                    new Container(
                      padding: EdgeInsets.all(10.0).copyWith(right: 20.0),
                      child: new Text(
                        '邀约理由',
                        style: _labelStyle,
                        textScaleFactor: 1.0,
                      ),
                    ),
                    Container(
                      child:Padding(
                        padding: EdgeInsets.all(5.0),
                        child:  TextField(
                          minLines: 5,
                          maxLines: 5,
                          controller: _inviteReasonControl,
//                          autofocus: true,
                          style: _hintlStyle,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: '请输入邀约理由',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            contentPadding: EdgeInsets.all(10.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                new Padding(
                  padding: new EdgeInsets.only(
                      top: 30.0, left: 10.0, right: 10.0, bottom: 10.0),
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Expanded(
                        child: new RaisedButton(
                          onPressed: () {
                            fastinvite();
                          },
                          child: new Padding(
                            padding:
                            new EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                            child: new Text(
                              "发起邀约",
                              style: new TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              textScaleFactor: 1.0,
                            ),
                          ),
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ));
  }

  Widget buildForm(String labelText, String hintText, bool autofocus,
      double left, TextEditingController controller, TextInputType inputtype) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Container(
          padding: EdgeInsets.all(10.0).copyWith(right: 20.0),
          child: new Text(
            labelText,
            style: _labelStyle,
            textScaleFactor: 1.0,
          ),
        ),
        new Expanded(
          child: new TextField(
            controller: controller,
//            autofocus: autofocus,
            style: _hintlStyle,
            keyboardType: inputtype,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: left),
            ),
          ),
        ),
      ],
    );
  }
  /*
   * 请求快捷访问接口
   */
  Future<bool> fastinvite() async {
    if(_inviteNameControl.text.toString()==null||_inviteNameControl.text.toString()==""){
      ToastUtil.showShortToast('姓名不能为空');
      return false;
    }
    if(!RegExpUtil().verifyPhone(_invitePhoneControl.text.toString())){
      ToastUtil.showShortToast('电话不对哦');
      return false;
    }
    if(_inviteStartControl.text.toString()==""||_inviteStartControl.text.toString()==""){
      ToastUtil.showShortToast('邀约开始时间未选择');
      return false;
    }
    if(_inviteEndControl.text.toString()==""||_inviteEndControl.text.toString()==""){
      ToastUtil.showShortToast('邀约结束时间未选择');
      return false;
    }
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String httpUrl="visitorRecord/inviteStranger";
    String threshold=await CommonUtil.calWorkKey(userInfo: userInfo);
    var parameters={
      "userId": userInfo.id,
      "token": userInfo.token,
      "factor":CommonUtil.getCurrentTime(),
      "threshold":threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "phone":_invitePhoneControl.text.toString(),
      "realName":_inviteNameControl.text.toString(),
      "startDate":_inviteStartControl.text.toString(),
      "endDate":_inviteEndControl.text.toString(),
      "reason":_inviteReasonControl.text.toString(),
      "companyId":selectedMineAddress.companyId,
    };
    var response=await Http().post(httpUrl,queryParameters: parameters,userCall: true);
    if(response!=null&&response!=""){
      if(response is String){
        Map responseMap = jsonDecode(response);
        if(responseMap['verify']['sign']=="success"){
          ToastUtil.showShortToast('邀约成功，可在个人中心查看');
          Navigator.pop(context);
        }else{
          ToastUtil.showShortToast(responseMap['verify']['desc']);
        }
      }
    }
  }
}
