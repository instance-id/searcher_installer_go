import 'package:event/event.dart';
import 'package:logger/logger.dart';

import '../../data/provider/fb_auth_provider.dart';
import '../../services/service_locator.dart';

class AuthStatusListener {
  final log = sl<Logger>();
  AuthStatus status = AuthStatus.signedOut;

  final event = Event();

  get isSignedOut => status == AuthStatus.signedOut;
  get isSignedIn => status == AuthStatus.signedIn;
  get isSignIn => status == AuthStatus.signIn;
  get isSignOut => status == AuthStatus.signOut;
  get isVerified => status == AuthStatus.verified;
  get isNotVerified => status == AuthStatus.notVerified;

  void setStatus(AuthStatus value) {
    this.status = value;
    event.broadcast();
    print('Current Status: ${this.status}');
  }
}
