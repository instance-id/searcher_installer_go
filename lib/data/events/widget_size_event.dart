import 'package:event/event.dart';

class SizeListener {
  dynamic value;
  final event = Event();

  void setSize(bool value, String type) {
    this.value = value;
    event.broadcast();
  }
}