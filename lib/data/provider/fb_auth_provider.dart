import 'package:firedart/auth/user_gateway.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guard/guard.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../data/errors/errors.dart';
import '../../data/events/auth_status_event.dart';
import '../../data/events/messages_event.dart';
import '../../data/events/show_dash_event.dart';
import '../../data/models/hive_store.dart';
import '../../data/models/login_data.dart';
import '../../extensions.dart'; // ignore: unused_import
import '../../services/service_locator.dart';
import '../models/dashboard_data.dart';

enum AuthStatus { signIn, signedIn, signedOut, signOut, notVerified, verified }

class FBAuthProvider with ChangeNotifier {
  final log = sl<Logger>();
  final msg = sl<Message>();
  final authStatus = sl<AuthStatusListener>();
  final dashEvent = sl<ShowDashListener>();
  final dashData = sl<DashboardData>();

  bool _processing = false;

  dynamic handler;
  FirebaseAuth auth;
  HiveStore hiveStore;
  http.Client client;
  String cacheEmail = "";

  // @formatter:off
  get document => dashData.document;
  get isLoggedIn => guard(() => auth.isSignedIn, false);
  get isVerified => authStatus.isVerified;
  get notVerified => authStatus.isNotVerified;
  get ref => dashData.ref;
  User get user => dashData.user;

  set document(Document value) {
    dashData.document = value;
    notifyListeners();
  }

  set ref(DocumentReference value) => dashData.ref = value;

  set user(User value) {
    dashData.user = value;
    notifyListeners();
  }

  void initFireBase() async {
    client = !kReleaseMode ? VerboseClient() : http.Client();
    FirebaseAuth.initialize(data.getString('apiKey'), hiveStore);
    Firestore.initialize(data.getString('projectId'));
  }

  void init() async {
    log.d('FBAuthProvider Init');
    dashData.fbAuthProvider = this;
    dashEvent.setStatus(false);
    hiveStore = await HiveStore.create();

    await initFireBase();

    auth = FirebaseAuth.instance;
    auth.httpClient = client;

    (auth.isSignedIn) ? silentLoginEvent() : log.i('Firebase instance created. Not logged in.');

    auth.signInState.listen((state) => statusChange(state));
  }

  @override
  void dispose() {
    log.d('FBAuthProvider Dispose');
    ref.stream.listen((event) {}).cancel();
    auth.signInState.listen((event) {}).cancel();
    super.dispose();
  }

  void statusChange(bool state) {
    log.i('Login state: ${isLoggedIn}');
    (state) ? null /*loginEvent()*/ : logoutEvent();
  }

  // --------------------------------------------------------------------------------------- Events
  // Events ---------------------------------------------------------------------------------------
/*  void loginEvent() {
//    if (!authStatus.isNotVerified) authStatus.setStatus(AuthStatus.signedIn);
  }*/

  void logoutEvent() async {
    authStatus.setStatus(AuthStatus.signOut);
    logOutComplete();
  }

  void logOutComplete() {
    authStatus.setStatus(AuthStatus.signedOut);
    dashEvent.setStatus(false);
    dashData.clearData();
    log.d('SIGNED OUT: ${authStatus.status}');
    msg.sendMessage({
      'type': MsgType.success,
      'message': "Logout Successful",
      'title': "Status:",
      'duration': 3500,
    });
  }

  // -------------------------------------------------------------------------------------- GetData
  // GetData --------------------------------------------------------------------------------------
  Future<User> getUserInfo() async {
    var u;
    u = await auth.getUser();
    if (u != null) cacheEmail = u.email;

    (u.emailVerified) ? ((notVerified) ? (authStatus.setStatus(AuthStatus.verified)) : null) : authStatus.setStatus(AuthStatus.notVerified);

    log.d('EMAIL VERIFICATION STATUS: ${u.emailVerified} : ${authStatus.status}');
    return u;
  }

  Future<DocumentReference> getDocument() async {
    var docRef;
    if (ref == null) {
      log.d('REF NULL: GETTING FOR USER: ${auth.userId}');
      docRef = Firestore.instance.collection(data.getString('collection')).document(auth.userId);
      log.d('REF NULL: GETTING: ${docRef}');

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
        return FBError.exceptionToUiMessage(
          FBError(e.toString(), FBFailures.dependency),
        );
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
        return FBError.exceptionToUiMessage(
          FBError(e.toString(), FBFailures.dependency),
        );
      }
      log.d(user);

      // @formatter:off
      (authStatus.isNotVerified) ? result = "notVerified" : result = await afterAuthorized();
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
      FBError.exceptionToUiMessage(
        FBError(e.toString(), FBFailures.dependency),
      );
      return;
    }

    log.d(user);
    if (authStatus.isNotVerified) {
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
      FBError.exceptionToUiMessage(
        FBError(e.toString(), FBFailures.dependency),
      );
      return;
    }

    authStatus.setStatus(AuthStatus.signedIn);
    msg.sendMessage({
      'type': MsgType.info,
      'message': "Login Successful",
      'title': "Status:",
      'duration': 3500,
    });

    dashEvent.setStatus(true);
  }

  Future<String> signIn(LoginData loginData) async {
    _processing = true;
    var result;

    if (!isLoggedIn) {
       user ??= await auth.signIn(loginData.email, loginData.password)
           .then((u) async => u ?? await getUserInfo()
           .then((v) => user = v));

      (authStatus.isNotVerified) ? result = "notVerified" : await afterAuthorized();
       return Future.delayed(Duration(milliseconds: 2000), () {return result;});

    }
    _processing = false;
//    return result;
  }

  Future<Null> afterAuthorized() async {
    if (user != null) {
      if (user.contactEmail == null || user.contactEmail == "") {
        user.contactEmail = user.email;
      }
      ref ?? getDocument().then((value) => ref = value);
      data.updateValue("updateData", true);
    } else {
      throw Exception('User Null');
    }
    log.d('doLogin After Auth Return');
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
      FBError.exceptionToUiMessage(
        FBError(e.toString(), FBFailures.dependency),
      );
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
