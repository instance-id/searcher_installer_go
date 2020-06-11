import 'package:event/event.dart';
import 'package:searcher_installer_go/routes/home.dart';

class ExpansionListener {
  bool value = false;
  String type;
  var valueChangedEvent = Event();

  void sendMessage(bool value, String type) {
    this.value = value;
    this.type = type;
    valueChangedEvent.broadcast();
  }
}

class ExpansionController {
  ExpandTarget target = ExpandTarget.NONE;
  var valueChangedEvent = Event();

  void expandTarget(ExpandTarget value) {
    this.target = value;
    valueChangedEvent.broadcast();
  }
}
