import 'package:event/event.dart';

enum MsgType {error, success, info}

class Message {
  Map<String, dynamic> payload = Map<String, dynamic>();
  var valueChangedEvent = Event();

  void sendMessage(Map<String, dynamic> message) {
    this.payload = message;
    valueChangedEvent.broadcast();
  }
}