import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:logger/logger.dart';
import 'package:simple_animations/simple_animations.dart';

import 'data/events/messages_event.dart';
import 'data/events/requestlogin_event.dart';
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

class _AppHomeState extends State<AppHome> with AnimationMixin {
  final GlobalKey<TabMenuState> _keyNavigator = GlobalKey<TabMenuState>();
  final log = sl<Logger>();
  final msg = sl<Message>();
  final login = sl<RequestLogin>();

  GlobalConfiguration data = GlobalConfiguration();
  List<String> title = ["Searcher : News", "Searcher : Installer", "Searcher : Account", "Searcher : Change Log"];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    msg.valueChangedEvent + (args) => Future.microtask(() => _showMessage(msg));
    login.event + (args) =>  _loginMenu();

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
    TabMenu navigator = TabMenu(
      key: _keyNavigator,
      onChanged: onChanged,
    );

    return Scaffold(
        primary: true,
        appBar: DraggebleAppBar(appBar: MainAppBar(context)),
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
