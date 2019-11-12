import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_umpush/flutter_umpush.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _pushData = 'Unknown';
  TextEditingController tokenController = TextEditingController();
  final FlutterUmpush _flutterUmpush = new FlutterUmpush();
  @override
  void initState() {
    super.initState();
    initPushState();
  }

  Future<void> initPushState() async {
    _flutterUmpush.configure(
      onMessage: (String message) async {
        print("main onMessage: $message");
        setState(() {
          _pushData = message;
        });
        return true;
      },
      onLaunch: (String message) async {
        print("main onLaunch: $message");
        setState(() {
          _pushData = message;
        });
        return true;
      },
      onResume: (String message) async {
        print("main onResume: $message");
        setState(() {
          _pushData = message;
        });
        return true;
      },
      onToken: (String token) async {
        print("main onToken: $token");
        setState(() {
          tokenController.text = token;
        });
        return true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextField(
                controller: tokenController,
              ),
              Text('PushData: $_pushData\n')
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Text("GEt"),
          onPressed: () {},
        ),
      ),
    );
  }
}
