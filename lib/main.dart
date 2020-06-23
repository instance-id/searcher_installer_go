import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_wrapper.dart';
import 'package:stack_trace/stack_trace.dart';

import 'app_home.dart';
import 'data/models/fbapp.dart';
import 'data/provider/changelog_provider.dart';
import 'data/provider/fb_auth_provider.dart';
import 'data/provider/news_provider.dart';
import 'data/provider/settings_provider.dart';
import 'helpers/exceptions.dart';
import 'services/data_storage.dart';
import 'services/service_locator.dart';
import 'services/service_registration.dart';

Future<void> main() async {
  ServiceRegistration().RegisterServices();
  var app = ServiceRegistration().getFbApp();
  io.HttpClient.enableTimelineLogging = data.getBool("debug");

  var log = sl<Logger>();
  await Chain.capture(() async {
    await runMain(app);
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
      // io.exitCode = 1;
    }
  });
}

void runMain(FbApp app) async {
  await DataStorage.loadAppSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ChangeLogDataProvider>(create: (_) => ChangeLogDataProvider()..init()),
        ChangeNotifierProvider<SettingsDataProvider>(create: (_) => SettingsDataProvider()..init()),
        ChangeNotifierProvider<NewsDataProvider>(create: (_) => NewsDataProvider()..init()),
        ChangeNotifierProvider<FBAuthProvider>(create: (_) => FBAuthProvider()..init()),
      ],
      child: MyApp(app),
    ),
  );
}

class MyApp extends StatelessWidget {
  final app;

  MyApp(this.app);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsDataProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: settings.theme,
      title: 'Searcher : Installer',
      home: AppHome(),
      builder: (context, widget) => ResponsiveWrapper.builder(widget,
          debugLog: true,
          maxWidth: 3840,
          minWidth: 300,
          defaultScale: true,
          breakpoints: [
            ResponsiveBreakpoint.resize(300, name: MOBILE),
            ResponsiveBreakpoint.resize(1000, name: DESKTOP),
          ],
          background: Container(
            color: Colors.transparent,
          )),
    );
  }
}
