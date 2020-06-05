import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'app_home.dart';
import 'data/events/requestlogin_event.dart';
import 'data/models/fbapp.dart';
import 'data/provider/changelog_provider.dart';
import 'data/events/authstatus_event.dart';
import 'data/events/expansion_event.dart';
import 'data/events/messages_event.dart';
import 'data/provider/navigation_provider.dart';
import 'data/provider/news_provider.dart';
import 'data/provider/settings_provider.dart';
import 'services/data_storage.dart';
import 'package:stack_trace/stack_trace.dart';

import '.secret/secret.config.dart';
import 'data/provider/fb_auth_provider.dart';
import 'helpers/exceptions.dart';

GetIt sl = GetIt.instance;

FbApp getFbApp() {
  var api = GlobalConfiguration();
  return FbApp(
    apiKey: api.getString('apiKey'),
    authDomain: api.getString('authDomain'),
    databaseURL: api.getString('databaseURL'),
    projectId: api.getString('projectId'),
    storageBucket: api.getString('storageBucket'),
    messagingSenderId: api.getString('messagingSenderId'),
    appId: api.getString('appId'),
  );
}

Future<void> main() async {
  sl.registerSingleton<Logger>(
      Logger(level: kDebugMode ? Level.debug : Level.info,
          printer: PrettyPrinter(
            methodCount: 2,
            errorMethodCount: 10,
            lineLength: 100,
            colors: io.stdout.supportsAnsiEscapes,
            printEmojis: false,
              printTime: false,
          )
      )
  );
  sl.registerSingleton<Message>(Message());
  sl.registerSingleton<RequestLogin>(RequestLogin());
  sl.registerSingleton<AuthStatusListener>(AuthStatusListener());
  sl.registerSingleton<ExpansionListener>(ExpansionListener());
  sl.registerSingleton<ExpansionController>(ExpansionController());

  var log = sl<Logger>();
  await Chain.capture(() async {
    await runMain();
  }, onError: (error, chain) {
    if (error is ApplicationFailedException) {
      log.w(error.message);
      io.exitCode = error.exitCode;
      return;
    } else {
      var logMsg = ('Something went wrong! You may have discovered a bug in `Searcher_Installer`.\n'
          'Please file an issue at '
          'https://github.com/instance-id/searcher_installer_go/issues/new?labels=package%3Asearcher_installer');
      log.w(logMsg, error, chain.terse);
      io.exitCode = 1;
    }
  });
}

void runMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalConfiguration().loadFromMap({
    "debug": false,
    "title": "Searcher : Installer",
    "address": "https://instance.id",
    "collection": "users",
    "database": "(default)",
    "verified": "Not Verified",
    "updateData": true,
    "loginOk": false,
    "showLogin": true,
    "playAppAnim": true,
    "playDataAnim": true,
  }).loadFromMap(api);
  var app = getFbApp();
  await DataStorage.loadAppSettings();

  // enable network traffic logging
  io.HttpClient.enableTimelineLogging = GlobalConfiguration().getBool("debug");

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider<ChangeLogDataProvider>(create: (_) => ChangeLogDataProvider()..init()),
      ChangeNotifierProvider<SettingsDataProvider>(create: (_) => SettingsDataProvider()..init()),
      ChangeNotifierProvider<NewsDataProvider>(create: (_) => NewsDataProvider()..init()),
      ChangeNotifierProvider<NavigationProvider>(create: (_) => NavigationProvider()),
      ChangeNotifierProvider<FBAuthProvider>(create: (_) => FBAuthProvider()..init()),
    ], child: MyApp(app)),
  );
}

class MyApp extends StatelessWidget {
  final app;

  MyApp(this.app);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsDataProvider>(context);

    return MaterialApp(
      title: 'Searcher : Installer',
      theme: settings.theme,
      home: AppHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}
