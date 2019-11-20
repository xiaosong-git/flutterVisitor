import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

class Qrcode extends StatefulWidget {
  final List<String> qrCodecontent;
  Qrcode({Key key, this.qrCodecontent}) : super(key: key);

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
    return new Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.color,
      appBar: new AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: new Text(
          '二维码',
          textAlign: TextAlign.center,
          style: new TextStyle(
            fontSize: 18.0,
            color: Colors.white,
          ),
          textScaleFactor: 1.0,
        ),
      ),
      body: new Center(
        child: Container(
          margin: EdgeInsets.all(20.0),
          child:Card(
            elevation: 10.0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 350,
              color: Colors.white,
              alignment: Alignment.center,
              child: new QrImage(
                data: data,
                size: 300,
                version: 10,
                padding: EdgeInsets.all(20),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
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
          print('$data');
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
