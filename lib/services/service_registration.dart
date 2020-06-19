import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../.secret/secret.config.dart';
import '../data/events/auth_status_event.dart';
import '../data/events/expansion_event.dart';
import '../data/events/messages_event.dart';
import '../data/events/request_login_event.dart';
import '../data/events/show_dash_event.dart';
import '../data/models/dashboard_data.dart';
import '../data/models/fbapp.dart';
import '../data/provider/message_text.dart';
import '../helpers/background.dart';
import '../routes/app_bar.dart';
import '../routes/dashboard_screen.dart';
import '../routes/login_screen.dart';
import 'service_locator.dart';

class ServiceRegistration {
  FbApp getFbApp() {
    return FbApp(
      apiKey: data.getString('apiKey'),
      authDomain: data.getString('authDomain'),
      databaseURL: data.getString('databaseURL'),
      projectId: data.getString('projectId'),
      storageBucket: data.getString('storageBucket'),
      messagingSenderId: data.getString('messagingSenderId'),
      appId: data.getString('appId'),
    );
  }

  RegisterServices() {
    data.loadFromMap({
      "debug": false,
      "title": "Searcher : Installer",
      "address": "https://instance.id",
      "collection": "users",
      "database": "(default)",
      "verified": "Not Verified",
      "updateData": true,
    }).loadFromMap(api);

    sl.registerSingleton<Logger>(Logger(
        level: kDebugMode ? Level.debug : Level.info,
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 55,
          lineLength: 100,
          colors: io.stdout.supportsAnsiEscapes,
          printEmojis: false,
          printTime: true,
        )));
    sl.registerSingleton<Message>(Message());
    sl.registerSingleton<RequestLogin>(RequestLogin());
    sl.registerSingleton<ExpansionListener>(ExpansionListener());
    sl.registerSingleton<AuthStatusListener>(AuthStatusListener());
    sl.registerSingleton<ExpansionController>(ExpansionController());

    sl.registerLazySingleton<MessageText>(() => MessageText());
    sl.registerLazySingleton<LoginScreen>(() => LoginScreen());
    sl.registerLazySingleton<DraggebleAppBar>(() => DraggebleAppBar());
    sl.registerLazySingleton<ShowDashListener>(() => ShowDashListener());
    sl.registerLazySingleton<DashboardScreen>(() => DashboardScreen());
    sl.registerLazySingleton<DashboardData>(() => DashboardData()..init());
    sl.registerLazySingleton<Background>(() => Background(assetName: 'assets/images/main0.png'));
  }
}
