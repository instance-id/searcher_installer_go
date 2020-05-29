import 'package:flushbar/flushbar_helper.dart';

class FlushBarDisplayHelper {
  final Map<String, dynamic> content;

  FlushBarDisplayHelper(this.content);

  void show() {
    FlushbarHelper.createSuccess(
      message: content['message'],
      title: content['title'],
      duration: Duration(seconds: 3),
    )
      ..show(content['context']);
  }
}