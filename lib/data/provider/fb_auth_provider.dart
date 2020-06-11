import 'package:firedart/auth/user_gateway.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guard/guard.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../data/errors/errors.dart';
import '../../data/events/authstatus_event.dart';
import '../../data/events/messages_event.dart';
import '../../data/extension/extensions.dart'; // ignore: unused_import
import '../../data/models/hive_store.dart';
import '../../data/models/login_data.dart';
import '../../services/service_locator.dart';

enum AuthStatus { signIn, signedIn, signedOut, signOut, notVerified, verified }

class FBAuthProvider with ChangeNotifier {
  final log = sl<Logger>();
  final msg = sl<Message>();
  final authStatus = sl<AuthStatusListener>();

  User _user;
  FirebaseAuth auth;
  Document document;
  http.Client client;
  HiveStore hiveStore;
  DocumentReference ref;
  String cacheEmail = "";
  AuthStatus _status = AuthStatus.signedOut;
  bool _processing;
  dynamic handler;

  // @formatter:off
  User get user => _user;
  get status => _status;
  get isLoggedIn => guard(() => auth.isSignedIn, false);
  get isVerified => _status == AuthStatus.verified;
  get notVerified => _status == AuthStatus.notVerified;

  set status(AuthStatus value) {
    _status = value;
    notifyListeners();
  }

  set user(User value) {
    _user = value;
    notifyListeners();
  }

  @override
  void dispose() {
    authStatus.event.unsubscribe(handler);
    ref.stream.listen((event) {}).cancel();
    auth.signInState.listen((event) {}).cancel();
    super.dispose();
  }

  void init() async {
    handler = (args) => this.status = authStatus.status;
    authStatus.event.subscribe(handler);
    client = !kReleaseMode ? VerboseClient() : http.Client();
    hiveStore = await HiveStore.create();

    FirebaseAuth.initialize(data.getString('apiKey'), hiveStore);
    Firestore.initialize(data.getString('projectId'));

    auth = FirebaseAuth.instance;
    auth.httpClient = client;

    // @formatter:off
    (auth.isSignedIn) ? silentLoginEvent() : log.i('Firebase instance created. Not logged in.');

    auth.signInState.listen((state) => statusChange(state));
  }

  void statusChange(bool state) {
    log.i('Login state: ${isLoggedIn}');

    // @formatter:off
    (state)
        ? null /*((user == null) ? loginEvent() : null)*/
        : logoutEvent();
  }

  // -------------------------------------------------------------------------------------- GetData
  // GetData --------------------------------------------------------------------------------------
  Future<User> getUserInfo() async {
    var u;
    try {
      u = await auth.getUser();
    } on Exception catch (e) {
      FBError.exceptionToUiMessage(e);
      return null;
    }
    if (u != null) cacheEmail = u.email;

    // @formatter:off
    (u.emailVerified) ? ((notVerified) ? (await authStatus.setStatus(AuthStatus.verified)) : null) : await authStatus.setStatus(AuthStatus.notVerified);

    log.d('EMAIL VERIFICATION STATUS: ${u.emailVerified} : ${authStatus.status}');
    return u;
  }

  Future<DocumentReference> getDocument() async {
    var docRef;
    if (ref == null) {
      docRef = Firestore.instance.collection(data.getString('collection')).document(auth.userId);
      await docRef.exists
          ? docRef.stream.listen((document) => this.document = document)
          : await docRef.update({
              "first": "",
              "last": "",
              "serialNum": "",
              "contactEmail": user.email,
            }).then(
              (document) => docRef.stream.listen(
                (document) => this.document = document,
              ),
            );
    }
    return docRef;
  }

  // --------------------------------------------------------------------------------------- Events
  // Events ---------------------------------------------------------------------------------------

  authListener() {}

  void loginEvent() async {
    if (!_processing) {
      try {
        user ??= await getUserInfo();
      } on Exception catch (e) {
        FBError.exceptionToUiMessage(e);
        return;
      }
    }

    if (this.status == AuthStatus.notVerified) return;

    try {
      ref ??= await getDocument();
      if (ref == null) return;
      this.document = await ref.get();
    } on Exception catch (e) {
      FBError.exceptionToUiMessage(e);
      return;
    }
  }

  void logoutEvent() {
    user = null;
    ref = null;
    authStatus.setStatus(AuthStatus.signOut);
    log.d('SIGNED OUT: ${authStatus.status}');
    msg.sendMessage({
      'type': MsgType.success,
      'message': "Logout Successful",
      'title': "Status:",
      'duration': 3500,
    });
  }

  // --------------------------------------------------------------------------------------- Signup
  // Signup ---------------------------------------------------------------------------------------
  Future<String> signUp(LoginData loginData) async {
    _processing = true;

    if (!isLoggedIn) {
      try {
        await auth.signUp(loginData.email, loginData.password).then((u) {
          cacheEmail = u.email;
          auth.requestEmailVerification();
          authStatus.setStatus(AuthStatus.notVerified);
        });
      } on Exception catch (e) {
        return FBError.exceptionToUiMessage(e);
      }
    }
    _processing = false;
    return null;
  }

  Future<String> checkEmailVerification() async {
    var result = null;
    if (isLoggedIn) {
      try {
        user = await getUserInfo();
      } on Exception catch (e) {
        return FBError.exceptionToUiMessage(e);
      }
      log.d(user);

      // @formatter:off
      (this.status == AuthStatus.notVerified) ? result = "notVerified" : null;
    } else {
      result = "notSignedIn";
    }
    return result;
  }

  // --------------------------------------------------------------------------------------- SignIn
  // SignIn ---------------------------------------------------------------------------------------
  void silentLoginEvent() async {
    try {
      user ??= await getUserInfo();
    } on Exception catch (e) {
      FBError.exceptionToUiMessage(e);
      return;
    }

    log.d(user);
    if (this.status == AuthStatus.notVerified) {
      msg.sendMessage({
        'type': MsgType.info,
        'message': "Please verify email address to continue",
        'title': "Status:",
        'duration': 3500,
      });
      return;
    }
    log.d('AUTO LOGIN ${user.email}');

    try {
      ref ??= await getDocument();
      this.document = await ref.get();
    } on Exception catch (e) {
      FBError.exceptionToUiMessage(e);
      return;
    }

    authStatus.setStatus(AuthStatus.signedIn);
    msg.sendMessage({
      'type': MsgType.info,
      'message': "Login Successful",
      'title': "Status:",
      'duration': 3500,
    });
  }

  Future<String> signIn(LoginData loginData) async {
    _processing = true;
    var result = null;

    if (!isLoggedIn) {
      try {
        await auth.signIn(loginData.email, loginData.password);
      } on Exception catch (e) {
        return FBError.exceptionToUiMessage(e);
      }

      try {
        user ??= await getUserInfo();
      } on Exception catch (e) {
        return FBError.exceptionToUiMessage(e);
      }

      // @formatter:off
      (this.status == AuthStatus.notVerified) ? result = "notVerified" : result = null;
    }
    _processing = false;
    return result;
  }

  // -------------------------------------------------------------------------------------- SignOut
  // SignOut --------------------------------------------------------------------------------------
  void signOut() async {
    auth.signOut();
  }

  // ------------------------------------------------------------------------------------- Recovery
  // Recovery -------------------------------------------------------------------------------------
  void recoverPassword(String email) async {
    log.d('PASSWORD RECOVERY INITIATED');

    try {
      auth.resetPassword(email);
    } on Exception catch (e) {
      FBError.exceptionToUiMessage(e);
      return;
    }

    msg.sendMessage({
      'type': MsgType.success,
      'message': "Password reset request sent",
      'title': "Status:",
      'duration': 3500,
    });
  }

  Future<Document> getData() async {
    document = await ref.get();
    return document;
  }

  void updateDoc(Map<String, dynamic> doc) async {
    await ref.update(doc);
    log.d('snapshot: ${document['verified']}');
  }
}
