import 'package:eventsubscriber/eventsubscriber.dart';
import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/material.dart';

import 'data/events/auth_status_event.dart';
import 'data/events/show_dash_event.dart';
import 'routes/dashboard_screen.dart';
import 'routes/login_screen.dart';
import 'services/service_locator.dart';

class UpdateHome extends StatefulWidget {
  static const routeName = '/update';

  @override
  _UpdateHomeState createState() => _UpdateHomeState();
}

class _UpdateHomeState extends State<UpdateHome> {
  final status = sl<AuthStatusListener>();
  final loginScreen = sl<LoginScreen>();
  final dashboardScreen = sl<DashboardScreen>();
  final dashEvent = sl<ShowDashListener>();

  bool userExists = false;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> subNavKey = GlobalKey<NavigatorState>();

    return FluidLayout(
      horizontalPadding: FluidValue((_) => 0),
      child: Fluid(
        child: EventSubscriber(
          event: dashEvent.event,
          handler: (context, args) => (dashEvent.showDash) ? dashboardScreen : loginScreen,
//              MaterialApp(
//                key: subNavKey,
//                debugShowCheckedModeBanner: false,
//                theme: themeData,
//                navigatorObservers: [TransitionRouteObserver()],
//                home: (dashEvent.showDash) ? dashboardScreen : loginScreen,
//                routes: {
//                  LoginScreen.routeName: (context) => loginScreen,
//                  DashboardScreen.routeName: (context) => dashboardScreen,
//                },
//              ),


        ),
      ),
    );
  }
}
