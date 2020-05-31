import 'package:faui/faui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'data/enums/enums.dart';
import 'data/events/authstatus_event.dart';
import 'data/events/messages_event.dart';
import 'data/provider/auth_provider.dart';
import 'helpers/background.dart';
import 'routes/about.dart';
import 'routes/app_bar.dart';
import 'routes/home.dart';
import 'routes/news.dart';
import 'routes/tab_menu.dart';
import 'update_home.dart';
import 'widgets/login/src/widget_helper.dart';

class AppHome extends StatefulWidget {
  @override
  _AppHomeState createState() => _AppHomeState();
}

GetIt sl = GetIt.instance;

class _AppHomeState extends State<AppHome> with TickerProviderStateMixin {
  final GlobalKey<TabMenuState> _keyNavigator = GlobalKey<TabMenuState>();
  final log = sl<Logger>();
  final msg = sl<Message>();
  final auth = sl<AuthStatusListener>();

  GlobalConfiguration data = GlobalConfiguration();
  List<String> title = ["Searcher : News", "Searcher : Installer", "Searcher : Account", "Searcher : Change Log"];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    msg.valueChangedEvent + (args) => Future.microtask(() => _showMessage(msg));
    auth.valueChangedEvent + (args) => (auth.status == AuthStatus.signIn) ? _loginMenu().then((value) => auth.setStatus(AuthStatus.loggedOut)) : null;

    if (data.getBool('loginOk') && fauiUser != null && authProvider.currentStatus == AuthStatus.loggedOut) {
      Future.microtask(() => authProvider.doAuthChange(AuthStatus.signedIn));
      msg.sendMessage({'type': MsgType.info, 'message': "Login Successful", 'title': "Status:", 'duration': 4500});
    }
    super.initState();
  }

  final List<Widget> pages = [];
  int pageIx = 1;
  final PageController pageController = PageController(initialPage: 1);
  bool _propagateAnimations = true;

  _AppHomeState() {
    pages.add(News());
    pages.add(Home());
    pages.add(UpdateHome());
  }

  void onChanged(int idx) {
    _propagateAnimations = false;
    pageController.animateToPage(
      idx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // @formatter:off
  Future<bool> _showMessage(Message msg) async {
    if (data.getBool("debug")) log.i('MESSAGE: ${msg.payload['message']}');
    (msg.payload['type'] == MsgType.info)
        ? showSuccessToast(context, msg.payload['message'], msg.payload['title'], msg.payload['duration'])
        : showErrorToast(context, msg.payload['message'], msg.payload['title'], msg.payload['duration']);
    return true;
  }

  Future<bool> _loginMenu() async {
    onChanged(2);
    _keyNavigator.currentState.move(2);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    TabMenu navigator = TabMenu(
      key: _keyNavigator,
      onChanged: onChanged,
    );

    if ( authProvider.currentStatus == AuthStatus.logOut) {
      Future.microtask(() =>authProvider.doAuthChange(AuthStatus.loggedOut));
      Future.microtask(() => msg.sendMessage({'type': MsgType.info, 'message': "Logged out successfully", 'title': "Logout:", 'duration': 4500}));
    }

    return Scaffold(
        primary: true,
        appBar: DraggebleAppBar(appBar: MainAppBar(context, _keyNavigator)),
        drawer: Drawer(child: AboutRoute(context)),
        body: Container(
          child: Stack(
            children: <Widget>[
              Background(assetName: 'assets/images/main0.png'),
              PageView(
                onPageChanged: (i) {
                  setState(() {
                    pageIx = i;
                    GlobalConfiguration().updateValue("title", title[pageIx]);
                  });

                  if (_propagateAnimations == true) {
                    _keyNavigator.currentState.move(i);
                  }
                  _propagateAnimations = true;
                },
                controller: pageController,
                children: pages,
                physics: BouncingScrollPhysics(),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Theme(
                    data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
                    child: navigator,
                  )),
            ],
          ),
        ));
  }
}
