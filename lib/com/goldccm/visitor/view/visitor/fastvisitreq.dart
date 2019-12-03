import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/RegExpUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';

/*
 * 实现非好友快速访问
 * author:ody997<hwk@growingpine.com>
 * create_time:2019/11/29
 */
class FastVisitReq extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new FastVisitReqState();
  }
}
/*
 * TextEditingController and FocusNode 是长时间存在的对象，需要在initState创建，然后在dispose中清除
 */
class FastVisitReqState extends State<FastVisitReq> {

  final TextStyle _labelStyle = new TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  final TextStyle _hintlStyle = new TextStyle(fontSize: 16.0, color: Colors.black54);

  TextEditingController _visitNameControl;
  TextEditingController _visitPhoneControl;
  TextEditingController _visitStartControl;
  TextEditingController _visitEndControl;
  TextEditingController _visitReasonControl;
  FocusNode _startNode;
  FocusNode _endNode;

  @override
  void initState() {
    super.initState();
    _startNode = FocusNode();
    _endNode = FocusNode();
    _visitNameControl = TextEditingController();
    _visitPhoneControl = TextEditingController();
    _visitStartControl = TextEditingController();
    _visitEndControl = TextEditingController();
    _visitReasonControl = TextEditingController();
  }

  @override
  void dispose() {
    _startNode.dispose();
    _endNode.dispose();
    _visitNameControl.dispose();
    _visitReasonControl.dispose();
    _visitEndControl.dispose();
    _visitPhoneControl.dispose();
    _visitStartControl.dispose();
    super.dispose();
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
            '便捷访问',
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
                buildForm('拜访人姓名', '请输入真实姓名', true, 25, _visitNameControl,
                    TextInputType.text),
                new Divider(
                  color: Colors.black54,
                ),
                buildForm('拜访人手机号', '请输入拜访人手机号', true, 10, _visitPhoneControl,
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
                        '访问开始时间',
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
                                _visitStartControl.text = '';
                                _startNode.unfocus();
                                return;
                              }
                              if (null != _visitEndControl.text.toString() &&
                                  _visitEndControl.text.toString().length ==
                                      16) {
                                if (date.isAfter(DateTime.parse(
                                    _visitEndControl.text.toString()))) {
                                  ToastUtil.showShortToast('开始时间不能大于结束时间');
                                  _visitStartControl.text = '';
                                  _startNode.unfocus();
                                  return;
                                }

                                if (date.day !=
                                    (DateTime.parse(
                                            _visitEndControl.text.toString())
                                        .day)) {
                                  ToastUtil.showShortToast('访问时间请选择在同一天,请重新选择');
                                  _visitStartControl.text = '';
                                  _endNode.unfocus();
                                  return;
                                }
                              }
                              _visitStartControl.text =
                                  date.toString().substring(0, 16);
                              _startNode.unfocus();
                            },
                          );
                        },
                        controller: _visitStartControl,
                        focusNode: _startNode,
                        autofocus: false,
                        readOnly: true,
                        textInputAction: TextInputAction.next,
                        style: _hintlStyle,
                        decoration: InputDecoration(
                          hintText: '请选择拜访开始时间',
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
                        '访问结束时间',
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
                                  _visitStartControl.text.toString()))) {
                                ToastUtil.showShortToast('结束时间不能小于开始时间,请重新选择');
                                _endNode.unfocus();
                                return;
                              }

                              if (date.day !=
                                  (DateTime.parse(
                                          _visitStartControl.text.toString())
                                      .day)) {
                                ToastUtil.showShortToast('访问时间请选择在同一天,请重新选择');
                                _endNode.unfocus();
                                return;
                              }
                              _visitEndControl.text =
                                  date.toString().substring(0, 16);
                              _endNode.unfocus();
                            },
                          );
                        },

                        controller: _visitEndControl,
                        autofocus: false,
                        focusNode: _endNode,
                        readOnly: true,
                        style: _hintlStyle,
                        decoration: InputDecoration(
                          hintText: '请选择拜访结束时间',
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
                        '访问理由',
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
                          controller: _visitReasonControl,
//                          autofocus: true,
                          style: _hintlStyle,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: '请输入访问理由',
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
                            fastVisit();
                          },
                          child: new Padding(
                            padding:
                                new EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                            child: new Text(
                              "发起访问",
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
  Future<bool> fastVisit() async {
    if(_visitNameControl.text.toString()==null||_visitNameControl.text.toString()==""){
      ToastUtil.showShortToast('姓名不能为空');
      return false;
    }
    if(!RegExpUtil().verifyPhone(_visitPhoneControl.text.toString())){
      ToastUtil.showShortToast('电话不对哦');
      return false;
    }
    if(_visitStartControl.text.toString()==""||_visitStartControl.text.toString()==""){
      ToastUtil.showShortToast('访问开始时间未选择');
      return false;
    }
    if(_visitEndControl.text.toString()==""||_visitEndControl.text.toString()==""){
      ToastUtil.showShortToast('访问结束时间未选择');
      return false;
    }
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String httpUrl=Constant.fastVisitUrl;
    String threshold=await CommonUtil.calWorkKey(userInfo: userInfo);
    var parameters={
      "userId": userInfo.id,
      "token": userInfo.token,
      "factor":CommonUtil.getCurrentTime(),
      "threshold":threshold,
      "requestVer": await CommonUtil.getAppVersion(),
      "phone":_visitPhoneControl.text.toString(),
      "realName":_visitNameControl.text.toString(),
      "startDate":_visitStartControl.text.toString(),
      "endDate":_visitEndControl.text.toString(),
      "reason":_visitReasonControl.text.toString(),
      "recordType":1,
    };
    var response=await Http().post(httpUrl,queryParameters: parameters,userCall: true);
    if(response!=null&&response!=""){
      if(response is String){
        Map responseMap = jsonDecode(response);
        if(responseMap['verify']['sign']=="success"){
          ToastUtil.showShortToast('访问成功，可在个人中心查看哦');
          Navigator.pop(context);
        }else{
          ToastUtil.showShortToast(responseMap['verify']['desc']);
        }
      }
    }
  }
}
