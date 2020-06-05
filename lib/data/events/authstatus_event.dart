import 'package:event/event.dart';
import '../enums/enums.dart';

class AuthStatusListener {
  AuthStatus status = AuthStatus.signedOut;
  var valueChangedEvent = Event();

  void setStatus(AuthStatus value) {
    this.status = value;
    print(this.status);
    valueChangedEvent.broadcast();
  }
}
