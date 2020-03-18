import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

class Qrcode extends StatefulWidget {
  final List<String> qrCodecontent;
  final String title;
  Qrcode({Key key, this.qrCodecontent,this.title}) : super(key: key);

  @override
  QrcodeState createState() => QrcodeState();
}

class QrcodeState extends State<Qrcode> with SingleTickerProviderStateMixin {
  int currentContent = 0;
  String data;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    _timer();
//    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return new Scaffold(
      backgroundColor:Color(0xFFFFFFFF),
      body: Container(
        width: ScreenUtil().setWidth(750),
        height: ScreenUtil().setHeight(1334),
        child:  Stack(
          children: <Widget>[
            Positioned(
              top:ScreenUtil().setHeight(94),
              left: ScreenUtil().setWidth(66),
              child:IconButton(
                  icon: Image(
                    image: AssetImage("assets/images/login_back.png"),
                    width: ScreenUtil().setWidth(36),
                    height: ScreenUtil().setHeight(36),
                    color: Colors.white,),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  }
                  ),
            ),
            Positioned(
              top:ScreenUtil().setHeight(114),
              left: ScreenUtil().setWidth(322),
              child: Text(widget.title!=null?widget.title:'门禁卡',style: TextStyle(color: Colors.white,fontSize: ScreenUtil().setSp(36),fontWeight: FontWeight.w600),),
            ),
            Positioned(
              child: Container(
                width: ScreenUtil().setWidth(584),
                height: ScreenUtil().setHeight(666),
                child: Card(
                  elevation: 10.0,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(42),vertical: ScreenUtil().setHeight(84)),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                    child: QrImage(
                      data: data,
                      size: 500,
                      version: 10,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                    ),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                ),
              ),
              left: ScreenUtil().setWidth(84),
              top: ScreenUtil().setHeight(248),
            ),
          ],
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/home_card_background.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Timer timer;
  _timer() async {
    if (timer == null && widget.qrCodecontent.length > 1) {
      timer = Timer.periodic(Duration(milliseconds: 200), (as) {
        setState(() {
          data = widget.qrCodecontent[currentContent];
          currentContent++;
          if (currentContent == widget.qrCodecontent.length) {
            currentContent = 0;
          }
        });
      });
    } else {
      data = widget.qrCodecontent[currentContent];
      print('$data');
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer.cancel();
    }
  }
}
