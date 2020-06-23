import 'package:event/event.dart';

import '../../routes/home.dart';

class ExpansionListener {
  bool value = false;
  String type;
  final valueChangedEvent = Event();
  final resetEvent = Event();

  void sendMessage(bool value, String type) {
    this.value = value;
    this.type = type;
    valueChangedEvent.broadcast();
  }

  void reset() {
    resetEvent.broadcast();
  }
}

class ExpansionController {
  ExpandTarget target = ExpandTarget.NONE;
  var _numOpen = 0;

  get isNone => target == ExpandTarget.NONE;
  get isNews => target == ExpandTarget.NEWS;
  get isChangeLog => target == ExpandTarget.CLOG;
  get numOpen => _numOpen;

  final valueChangedEvent = Event();
  final numOpenEvent = Event();

  void setNumOpen(int value) {
    this._numOpen = value;
    numOpenEvent.broadcast();
  }

  void expandTarget(ExpandTarget value) {
    this.target = value;
    valueChangedEvent.broadcast();
  }
}
