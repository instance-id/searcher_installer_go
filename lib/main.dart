import 'dart:io';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';
import 'package:searcher_installer/services/auth_storage.dart';
import 'app_home.dart';
import 'data/models/fbapp.dart';
import 'data/provider/auth_provider.dart';
import 'data/provider/changelog_provider.dart';
import 'data/provider/news_provider.dart';
import 'data/provider/navigation_provider.dart';
import 'data/provider/theme_data.dart';

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
  WidgetsFlutterBinding.ensureInitialized();

  GlobalConfiguration().loadFromMap({
    "title":"Searcher : Installer",
    "address":"https://instance.id",
    "collection": "access-data-demo-user",
    "database": "(default)",
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
