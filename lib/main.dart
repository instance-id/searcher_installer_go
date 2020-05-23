import 'dart:io';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:searcher_installer_go/app_home.dart';
import 'package:searcher_installer_go/data/models/fbapp.dart';
import 'package:searcher_installer_go/data/models/settings_data.dart';
import 'package:searcher_installer_go/data/provider/auth_provider.dart';
import 'package:searcher_installer_go/data/provider/changelog_provider.dart';
import 'package:searcher_installer_go/data/provider/navigation_provider.dart';
import 'package:searcher_installer_go/data/provider/news_provider.dart';
import 'package:searcher_installer_go/data/provider/settings_provider.dart';
import 'package:searcher_installer_go/data/provider/theme_data.dart';
import 'package:searcher_installer_go/services/auth_storage.dart';

import '.secret/secret.config.dart';

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
  Logger log = Logger();
  WidgetsFlutterBinding.ensureInitialized();
  SettingsDataProvider settingProvider = SettingsDataProvider();
  List<SettingsData> settings;
  String bgImage;

  settings = await settingProvider.getChanges();

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
  await AuthStorage.trySignInSilently(app.apiKey);
  // enable network traffic logging
  HttpClient.enableTimelineLogging = true;
  runApp(MyApp(app));
}

class MyApp extends StatelessWidget {
  final app;
  MyApp(this.app);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsDataProvider>(create: (_) => SettingsDataProvider()..init()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider(app)..init()),
        ChangeNotifierProvider<NavigationProvider>(create: (_) => NavigationProvider()),
        ChangeNotifierProvider<NewsDataProvider>(create: (_) => NewsDataProvider()..init()),
        ChangeNotifierProvider<ChangeLogDataProvider>(create: (_) => ChangeLogDataProvider()..init()),
      ],
      child: MaterialApp(
        title: 'Searcher : Installer',
        theme: themeData,
        home: AppHome(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
