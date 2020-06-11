import 'package:event/event.dart';

import '../../data/provider/fb_auth_provider.dart';

class AuthStatusListener {
  AuthStatus status = AuthStatus.signedOut;
  get isVerified => status == AuthStatus.verified;
  get notVerified => status == AuthStatus.notVerified;
  get isSignedIn => status == AuthStatus.signedIn;
  get isSignIn => status == AuthStatus.signIn;
  get isSignOut => status == AuthStatus.signOut;
  var event = Event();

  void setStatus(AuthStatus value) {
    this.status = value;
    event.broadcast();
  }
}
