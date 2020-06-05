import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:searcher_installer_go/helpers/custom_color.dart';

Size getWidgetSize(GlobalKey key) {
  final RenderBox renderBox = key.currentContext?.findRenderObject();
  return renderBox?.size;
}

Flushbar showSuccessToast(BuildContext context, String message, String title, int duration) {
  return Flushbar(
    margin: EdgeInsets.fromLTRB(0, 0, 0, 40),
    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
    maxHeight: 35,
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.FLOATING,
    messageText: Row(
      children: <Widget> [
        Text(title, style: TextStyle(color: AppColors.M_DYELLOW, fontWeight: FontWeight.w600)),
        SizedBox(width: 5),
        Text(message, style: TextStyle(color: Colors.green, fontWeight: FontWeight.w400)),
      ],
    ),
    icon: Icon(Icons.check_circle, color: Colors.green[300]),
    leftBarIndicatorColor: Colors.green[300],
    duration: Duration(milliseconds: duration),
    backgroundColor: AppColors.BG_DARK,
    onTap: (flushbar) => flushbar.dismiss(),
  )..show(context);
}

Flushbar showErrorToast(BuildContext context, String message, String title, int duration) {
  return Flushbar(
    margin: EdgeInsets.fromLTRB(0, 0,0, 40),
    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
    maxHeight: 35,
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.FLOATING,
    borderRadius: 0,
    messageText: Row(
      children: <Widget> [
        Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        SizedBox(width: 5),
        Text(message, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400)),
      ],
    ),
    icon: Icon(Icons.error, size: 28.0, color: Colors.white),
    leftBarIndicatorColor: Colors.black26,
    duration: Duration(milliseconds: duration),
    backgroundGradient: LinearGradient(
      colors: [
        Colors.red[800],
        Colors.red[600],
        Colors.red[500],
//        Color.fromRGBO(255, 20, 20, 0.5),
      ],
    ),
    onTap: (flushbar) => flushbar.dismiss(),
  )..show(context);
}
