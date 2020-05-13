import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:searcher_installer_go/routes/dashboard_screen.dart';
import 'package:searcher_installer_go/routes/login_screen.dart';
import 'package:faui/src/10_auth/auth_state_user.dart';

import 'package:searcher_installer_go/widgets/transition_route_observer.dart';
import 'package:searcher_installer_go/data/provider/theme_data.dart';

class UpdateHome extends StatefulWidget {
  @override
  _UpdateHomeState createState() => _UpdateHomeState();
}

class _UpdateHomeState extends State<UpdateHome> with TickerProviderStateMixin {
  final data = GlobalConfiguration();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      navigatorObservers: [TransitionRouteObserver()],
      home: FauiAuthState.user != null && !data.getBool("showLogin")
          ? DashboardScreen()
          : LoginScreen(),
      // auth.ClientCheck(mounted) ? LoginScreen() : DashboardScreen(),
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        DashboardScreen.routeName: (context) => DashboardScreen(),
      },
    );
  }
}
