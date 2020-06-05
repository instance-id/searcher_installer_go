import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';

import 'data/enums/enums.dart';
import 'data/events/authstatus_event.dart';
import 'data/provider/fb_auth_provider.dart';
import 'data/provider/theme_data.dart';
import 'routes/dashboard_screen.dart';
import 'routes/login_screen.dart';
import 'widgets/transition_route_observer.dart';

class UpdateHome extends StatefulWidget {
  @override
  _UpdateHomeState createState() => _UpdateHomeState();
}

final sl = GetIt.instance;

class _UpdateHomeState extends State<UpdateHome> with TickerProviderStateMixin {
  final data = GlobalConfiguration();
  final status = sl<AuthStatusListener>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<FBAuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      navigatorObservers: [TransitionRouteObserver()],
      home: (auth.status == AuthStatus.signedIn && auth.user != null) ? DashboardScreen() : LoginScreen(),
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        DashboardScreen.routeName: (context) => DashboardScreen(),
      },
    );
  }
}
