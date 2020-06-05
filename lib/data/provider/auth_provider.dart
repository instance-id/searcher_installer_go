//import 'package:cross_local_storage/cross_local_storage.dart';
//import 'package:faui/faui.dart';
//import 'package:faui/faui_api.dart';
//import 'package:flutter/material.dart';
//import 'package:get_it/get_it.dart';
//import 'package:global_configuration/global_configuration.dart';
//import 'package:logger/logger.dart';
//
//import '../../data/events/authstatus_event.dart';
//import '../../data/models/fbapp.dart';
//import '../enums/enums.dart';
//
//GetIt sl = GetIt.instance;
//
//class AuthProvider with ChangeNotifier {
//  final log = sl.get<Logger>();
//  final authListener = sl.get<AuthStatusListener>();
//
//  AuthProvider(this.fbApp) {
//    fauiDb = getFauiDb();
//    authListener.valueChangedEvent + (args) => receiveAuthChange(authListener.status);
//  }
//
//  GlobalConfiguration data = new GlobalConfiguration();
//  FbApp fbApp;
//  FauiDb fauiDb;
//  FauiUser authUser;
//  bool _loginStatus = false;
//  AuthStatus _currentStatus = AuthStatus.signedOut;
//
//  bool get loginStatus => _loginStatus;
//
//  AuthStatus get currentStatus => _currentStatus;
//
//  set loginStatus(bool value) {
//    _loginStatus = value;
//  }
//
//  Future<bool> _setAuth(AuthStatus status) async {
//    try {
//      switch (status) {
//        case AuthStatus.signIn:
//          loginStatus = false;
//          _currentStatus = AuthStatus.signIn;
//          break;
//        case AuthStatus.signedIn:
//          loginStatus = true;
//          _currentStatus = AuthStatus.signedIn;
//          break;
//        case AuthStatus.signOut:
//          loginStatus = true;
//          _currentStatus = AuthStatus.signOut;
//          break;
//        case AuthStatus.signedOut:
//          loginStatus = false;
//          _currentStatus = AuthStatus.signedOut;
//          break;
//      }
//    } catch (e) {
//      if (data.getBool("debug")) log.d("Problem settings auth status: $e");
//    }
//    if (data.getBool("debug")) log.d('Login Status: ${currentStatus} Login Bool: ${loginStatus}');
//    return loginStatus;
//  }
//
//  Future<bool> receiveAuthChange(AuthStatus status) async {
//    _setAuth(status);
//    notifyListeners();
//    return loginStatus;
//  }
//
//  Future<bool> doAuthChange(AuthStatus status) async {
//    _setAuth(status);
//    notifyListeners();
//    authListener.relayStatus(currentStatus);
//    return loginStatus;
//  }
//
//  // ----------------------------------------------------------- Variables
//  // SECTION Variables ---------------------------------------------------
//
//  LocalStorageInterface _storage;
//
//  LocalStorageInterface get storage => _storage;
//
//  void init() async {
//    _storage = await LocalStorage.getInstance();
//  }
//
//  FauiDb getFauiDb() {
//    return FauiDb(
//      data.getString('apiKey'),
//      data.getString('database'),
//      data.getString('projectId'),
//    );
//  }
//}
