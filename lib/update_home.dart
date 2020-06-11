import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/events/authstatus_event.dart';
import 'data/provider/fb_auth_provider.dart';
import 'data/provider/theme_data.dart';
import 'routes/dashboard_screen.dart';
import 'routes/login_screen.dart';
import 'services/service_locator.dart';
import 'widgets/transition_route_observer.dart';

class UpdateHome extends StatelessWidget {
  final status = sl<AuthStatusListener>();
  final loginScreen = sl<LoginScreen>();
  final dashboardScreen = sl<DashboardScreen>();
  static const routeName = '/update';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<FBAuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      navigatorObservers: [TransitionRouteObserver()],
      home: (auth.status == AuthStatus.signedIn && auth.user != null) ? dashboardScreen : loginScreen,
      routes: {
        LoginScreen.routeName: (context) => loginScreen,
        DashboardScreen.routeName: (context) => dashboardScreen,
      },
    );
  }
}
