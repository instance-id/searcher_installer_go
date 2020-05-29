import 'package:event/event.dart';
import '../enums/enums.dart';

class AuthStatusListener {
  AuthStatus status = AuthStatus.loggedOut;
  var valueChangedEvent = Event();
  var relayEvent = Event();

  void setStatus(AuthStatus value) {
    this.status = value;
    print('From Listener: ${this.status}');
    valueChangedEvent.broadcast();
  }

  void relayStatus(AuthStatus value) {
    this.status = value;
    print('From Relay: ${this.status}');
    relayEvent.broadcast();
  }
}
