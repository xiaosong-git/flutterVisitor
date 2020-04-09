import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
            child: Text('似乎出了点问题'),       
        ),
      ),
    );
  }
}