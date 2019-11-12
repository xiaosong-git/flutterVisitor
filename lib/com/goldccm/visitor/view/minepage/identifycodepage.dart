import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/component/Qrcode.dart';
import 'package:visitor/com/goldccm/visitor/model/QrcodeMode.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/QrcodeHandler.dart';


//个人识别码
class IdentifyCodePage extends StatefulWidget {
  IdentifyCodePage({Key key, this.userInfo}) : super(key: key);
  final UserInfo userInfo;
  @override
  State<StatefulWidget> createState() {
    return IdentifyCodePageState();
  }
}

class IdentifyCodePageState extends State<IdentifyCodePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('身份识别码',textScaleFactor: 1.0),
        centerTitle: true,
      ),
    );
  }


}
