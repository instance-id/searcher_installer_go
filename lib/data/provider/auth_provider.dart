import 'package:faui/faui.dart';
import 'package:faui/faui_api.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';

import 'package:logger/logger.dart';
import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:searcher_installer/data/models/fbapp.dart';

class AuthProvider with ChangeNotifier {
  FbApp fbApp;
  FauiDb fauiDb;

  AuthProvider(this.fbApp) {
    fauiDb = getFauiDb();
  }

  var log = Logger();
  GlobalConfiguration api = new GlobalConfiguration();
  FauiUser authUser;

  // ----------------------------------------------------------- Variables
  // SECTION Variables ---------------------------------------------------
  bool stayLoggedIn = true;
  bool _onExitInvoked = false;
  final Map<FauiPhrases, String> phrases = Map<FauiPhrases, String>();

  LocalStorageInterface _storage;
  LocalStorageInterface get storage => _storage;

  void init() async {
    _storage = await LocalStorage.getInstance();
    print('From Init: ${fbApp.apiKey}');
  }

  FbApp getFbApp() {
    fbApp = FbApp(
      apiKey: api.getString('apiKey'),
      authDomain: api.getString('authDomain'),
      databaseURL: api.getString('databaseURL'),
      projectId: api.getString('projectId'),
      storageBucket: api.getString('storageBucket'),
      messagingSenderId: api.getString('messagingSenderId'),
      appId: api.getString('appId'),
    );
    return fbApp;
  }

  FauiDb getFauiDb() {
    return FauiDb(
      api.getString('apiKey'),
      api.getString('database'),
      api.getString('projectId'),
    );
  }
}
