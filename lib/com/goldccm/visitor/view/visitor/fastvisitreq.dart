import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';

class FastVisitReq extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new FastVisitReqState();
  }
}

class FastVisitReqState extends State<FastVisitReq> {
  final TextStyle _labelStyle = new TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  final TextStyle _hintlStyle =
      new TextStyle(fontSize: 16.0, color: Colors.black54);

  TextEditingController _visitNameControl = new TextEditingController();
  TextEditingController _visitPhoneControl = new TextEditingController();
  TextEditingController _visitStartControl = new TextEditingController();
  TextEditingController _visitEndControl = new TextEditingController();
  FocusNode _startNode = new FocusNode();
  FocusNode _endNode = new FocusNode();

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
                              print(
                                  '1111111111${_visitEndControl.text.toString()}');
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
                        textInputAction: TextInputAction.next,
                        // 焦点控制，类似于Android中View的Focus
                        style: _hintlStyle,
                        decoration: InputDecoration(
                          hintText: '请选择拜访开始时间',
                          // 去掉下划线
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
                        // 焦点控制，类似于Android中View的Focus
                        style: _hintlStyle,
                        decoration: InputDecoration(
                          hintText: '请选择拜访结束时间',
                          // 去掉下划线
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
                new Padding(
                  padding: new EdgeInsets.only(
                      top: 80.0, left: 10.0, right: 10.0, bottom: 10.0),
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Expanded(
                        child: new RaisedButton(
                          onPressed: () {},
                          //通过控制 Text 的边距来控制控件的高度
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
        // 右边部分输入，用Expanded限制子控件的大小
        new Expanded(
          child: new TextField(
            controller: controller,
            autofocus: autofocus,
            // 焦点控制，类似于Android中View的Focus
            style: _hintlStyle,
            keyboardType: inputtype,
            decoration: InputDecoration(
              hintText: hintText,
              // 去掉下划线
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: left),
            ),
          ),
        ),
      ],
    );
  }

  _getUserByNameAndPhone() {
    String _name = _visitNameControl.text.toString();
    String phone = _visitPhoneControl.text.toString();
    if (null == _name) {
      ToastUtil.showShortToast('姓名不能为空');
      return;
    }
    if (null == phone) {
      ToastUtil.showShortToast('手机号不能为空');
      return;
    }
    if (phone.length != 11) {
      ToastUtil.showShortToast('手机号格式错误');
      return;
    }
  }
}
