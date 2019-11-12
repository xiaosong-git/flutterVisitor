import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';



class ToastUtil{


  /**
   * 短toast显示
   */
   static void showShortToast(String msg){
    Fluttertoast.showToast(
      msg: msg,
      fontSize: 14.0,
      textColor: Colors.black,
      backgroundColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
    );
  }


  /**
   * 长toast显示
   */
   static void showLongToast(String msg){
    Fluttertoast.showToast(
      msg: msg,
      fontSize: 14.0,
      textColor: Colors.black,
      backgroundColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
    );
  }
   /*
    * 短时间toast显示-黑底白字-居中显示
    */
   static void showShortClearToast(String msg){
     Fluttertoast.showToast(
       msg: msg,
       fontSize: 14.0,
       gravity: ToastGravity.CENTER,
       textColor: Colors.white,
       backgroundColor: Colors.black,
       toastLength: Toast.LENGTH_SHORT,
     );
   }
}