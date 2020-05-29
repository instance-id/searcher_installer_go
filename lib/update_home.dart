import 'package:faui/src/10_auth/auth_state_user.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'data/enums/enums.dart';
import 'data/provider/auth_provider.dart';
import 'data/provider/theme_data.dart';
import 'routes/dashboard_screen.dart';
import 'routes/login_screen.dart';
import 'widgets/transition_route_observer.dart';

class UpdateHome extends StatefulWidget {
  @override
  _UpdateHomeState createState() => _UpdateHomeState();
}

GetIt sl = GetIt.instance;

class _UpdateHomeState extends State<UpdateHome> with TickerProviderStateMixin {
  final data = GlobalConfiguration();
  final log = sl<Logger>();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      navigatorObservers: [TransitionRouteObserver()],
      home: FauiAuthState.user != null && authProvider.currentStatus == AuthStatus.signedIn ? DashboardScreen() : LoginScreen(),
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        DashboardScreen.routeName: (context) => DashboardScreen(),
      },
    );
  }
}
