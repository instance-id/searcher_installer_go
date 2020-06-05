import 'package:firedart/auth/user_gateway.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../data/enums/enums.dart';
import '../../data/events/authstatus_event.dart';
import '../../data/events/messages_event.dart';
import '../../data/models/hive_store.dart';
import '../../data/models/login_data.dart';

final sl = GetIt.instance;

class FBAuthProvider with ChangeNotifier {
  final data = GlobalConfiguration();
  final log = sl<Logger>();
  final msg = sl<Message>();
  final authStatus = sl<AuthStatusListener>();
  DocumentReference ref;
  HiveStore hiveStore;
  http.Client client;
  FirebaseAuth auth;
  Document document;
  User _user;
  AuthStatus _status = AuthStatus.signedOut;
  bool _showLogin = true;
  bool _isLoggedIn = false;

  // @formatter:off
  User get user => _user;
  get status => _status;
  get isLoggedIn => _isLoggedIn;
  get showLogin => _showLogin;

  set status(AuthStatus value) {
    _status = value;
    notifyListeners();
  }

  set user(User value) {
    _user = value;
    notifyListeners();
  }

  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  set showLogin(bool value) {
    _showLogin = value;
    notifyListeners();
  }

  @override
  void dispose() {
    ref.stream.listen((event) {}).cancel();
    auth.signInState.listen((event) {}).cancel();
    authStatus.valueChangedEvent.unsubscribeAll();
    super.dispose();
  }

  void init() async {
    authStatus.valueChangedEvent + (args) => this.status = authStatus.status;
    client = !kReleaseMode ? VerboseClient() : http.Client();
    hiveStore = await HiveStore.create();

    FirebaseAuth.initialize(data.getString('apiKey'), hiveStore);
    Firestore.initialize(data.getString('projectId'));

    auth = FirebaseAuth.instance;
    auth.httpClient = client;

    (auth.isSignedIn) ? silentLoginEvent() : log.i('Firebase instance created. Not logged in.');
    auth.signInState.listen((state) => statusChange(state));
  }

  void statusChange(bool state) {
    isLoggedIn = state;
    log.i('Login state: ${isLoggedIn}');
    (state) ? loginEvent() : logoutEvent();
  }

  void getDocument() async {
    if (ref == null) {
      ref = Firestore.instance.collection(data.getString('collection')).document(this.user.id);
      await ref.exists
          ? ref.stream.listen(
              (document) => this.document = document,
            )
          : ref.create({
              "first": "",
              "last": "",
              "serialNum": "",
              "contactEmail": user.email,
            }).then(
              (document) => ref.stream.listen(
                (document) => this.document = document,
              ),
            );
    }
  }

  getUserInfo() async {
    await auth.getUser().then((u) {
      (u.emailVerified)
          ? user = u
          : () {
              msg.sendMessage({
                'type': MsgType.error,
                'message': "Please verify email address to continue",
                'title': "Status:",
                'duration': 3500,
              });
              log.d('EMAIL VERIFICATION STATUS: ${u.emailVerified}');
              return null;
            }();
    });
  }

  void loginEvent() async {
    ref ?? await getDocument();
    if (ref == null) return;
    this.document = await ref.get();
    authStatus.setStatus(AuthStatus.signedIn);
  }

  void silentLoginEvent() async {
    this.isLoggedIn = auth.isSignedIn;
    (this.user) ?? await getUserInfo();
    if (user == null) return;
    log.i('AUTO LOGIN ${user.email}');

    ref ?? await getDocument();
    this.document = await ref.get();
    (this.document) ??
        await ref.create({
          "first": "",
          "last": "",
          "serialNum": "",
          "contactEmail": user.email,
        });

    authStatus.setStatus(AuthStatus.signedIn);
    msg.sendMessage({
      'type': MsgType.info,
      'message': "Login Successful",
      'title': "Status:",
      'duration': 3500,
    });
  }

  Future<String> signIn(LoginData loginData) async {
    var result = null;
    if (!auth.isSignedIn) {
      this.user ?? await auth.signIn(loginData.email, loginData.password);
      (auth.isSignedIn) ? result = null : result = "Error: Could not login";
    }
    return result;
  }

  void signUp(LoginData loginData) async {
    var result = null;

    if (!auth.isSignedIn) {
      await auth.signUp(loginData.email, loginData.password).then((u) {
        user = u;
        auth.requestEmailVerification();
      });
      (auth.isSignedIn) ? result = null : result = "Error: Could not login";
    } else {
      msg.sendMessage({
        'type': MsgType.error,
        'message': "Already logged in",
        'title': "Error:",
        'duration': 3500,
      });
    }
    return result;
  }

  void signOut() async {
    auth.signOut();
  }

  void logoutEvent() {
    user = null;
    data.updateValue('showLogin', true);
    isLoggedIn = false;
    showLogin = true;
    authStatus.setStatus(AuthStatus.signedOut);
    log.i('SIGNED OUT');
    msg.sendMessage({
      'type': MsgType.info,
      'message': "Logout Successful",
      'title': "Status:",
      'duration': 3500,
    });
  }

  void recoverPassword(String email) async {
    log.i('PASSWORD RECOVERY INITIATED');
    auth.resetPassword(email);
  }

  Future<Document> getData() async {
    document = await ref.get();
    return document;
  }

  void updateDoc(Map<String, dynamic> doc) async {
    await ref.update(doc);
    log.i('snapshot: ${document['verified']}');
  }
}
