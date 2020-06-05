import 'package:event/event.dart';

class RequestLogin {
  var event = Event();

  void sendEvent() {
    event.broadcast();
  }
}