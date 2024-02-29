import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
class StaticMethod{
  
  //==================================SHOW TOAST MESSAGE
  static void showToastMsg(String msg, Color textColor,context){
    print('show toast called');
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.white,
      textColor: textColor,
    );
  }
}