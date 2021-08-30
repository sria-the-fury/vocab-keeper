import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class FlutterToaster {

  static successToaster(hasMessage, message) {
    Fluttertoast.showToast(
        msg: hasMessage ? message : "Success",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      textColor: Colors.white,
      backgroundColor: Colors.green[500]
    );

  }

  static errorToaster(hasMessage, message) {
    Fluttertoast.showToast(
        msg: hasMessage ? message : "Error",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        backgroundColor: Colors.red
    );

  }

  static defaultToaster(hasMessage, message) {
    Fluttertoast.showToast(
        msg: hasMessage ? message : "default",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        textColor: Colors.white,
        backgroundColor: Colors.blue[500]
    );

  }

  static warningToaster(hasMessage, message) {
    Fluttertoast.showToast(
        msg: hasMessage ? message : "warning",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        backgroundColor: Colors.orange[500]
    );

  }
}