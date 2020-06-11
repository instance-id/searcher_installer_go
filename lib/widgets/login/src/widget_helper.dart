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
        Text(title, style: TextStyle(color: AppColors.LIGHT_TEXT, fontWeight: FontWeight.w600)),
        SizedBox(width: 5),
        Text(message, style: TextStyle(color: AppColors.LIGHT_TEXT, fontWeight: FontWeight.w400)),
      ],
    ),
    icon: Icon(Icons.check_circle, color: Colors.white),
    leftBarIndicatorColor: Colors.green[300],
    duration: Duration(milliseconds: duration),
    backgroundGradient: LinearGradient(
      colors: [
        Colors.green[800],
        Colors.green[600],
        Colors.green[500],
      ],
    ),
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
      ],
    ),
    onTap: (flushbar) => flushbar.dismiss(),
  )..show(context);
}

Flushbar showInfoToast(BuildContext context, String message, String title, int duration) {
  return Flushbar(
    margin: EdgeInsets.fromLTRB(0, 0, 0, 40),
    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
    maxHeight: 35,
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.FLOATING,
    borderRadius: 0,
    messageText: Row(
      children: <Widget>[
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
        Colors.blue[800],
        Colors.blue[600],
        Colors.blue[500],
      ],
    ),
    onTap: (flushbar) => flushbar.dismiss(),
  )
    ..show(context);
}