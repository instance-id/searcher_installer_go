import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sized_context/sized_context.dart';
import 'data/events/expansion_event.dart';
import 'package:simple_animations/simple_animations.dart';

import 'data/events/messages_event.dart';
import 'data/events/request_login_event.dart';
import 'helpers/background.dart';
import 'routes/about.dart';
import 'routes/app_bar.dart';
import 'routes/home.dart';
import 'routes/news.dart';
import 'routes/tab_menu.dart';
import 'services/service_locator.dart';
import 'update_home.dart';
import 'widgets/login/src/widget_helper.dart';

class AppHome extends StatefulWidget {
  static const routeName = '/appHome';

  @override
  _AppHomeState createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> with AnimationMixin {
  final GlobalKey<TabMenuState> _keyNavigator = GlobalKey<TabMenuState>();
  final log = sl<Logger>();
  final msg = sl<Message>();
  final login = sl<RequestLogin>();
  final background = sl<Background>();
  final draggebleAppBar = sl<DraggebleAppBar>();
  final expController = sl<ExpansionController>();
  final expListener = sl<ExpansionListener>();

  dynamic msgHandler;
  dynamic loginPageHandler;

  List<String> title = [
    "Searcher : News",
    "Searcher : Installer",
    "Searcher : Account",
    "Searcher : Change Log",
  ];

  @override
  void dispose() {
    msg.valueChangedEvent.unsubscribe(msgHandler);
    login.event.unsubscribe(loginPageHandler);
    pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    msgHandler = (args) => Future.microtask(() => _showMessage(msg));
    loginPageHandler = (args) => _loginMenu();

    msg.valueChangedEvent.subscribe(msgHandler);
    login.event.subscribe(loginPageHandler);

    super.initState();
  }

  // @formatter:off
  Future<bool> _showMessage(Message msg) async {
    if (data.getBool("debug")) log.d('MESSAGE: ${msg.payload['message']}');
    switch (msg.payload['type']) {
      case MsgType.success:
        showSuccessToast(context, msg.payload['message'], msg.payload['title'], msg.payload['duration']);
        break;
      case MsgType.error:
        showErrorToast(context, msg.payload['message'], msg.payload['title'], msg.payload['duration']);
        break;
      case MsgType.info:
        showInfoToast(context, msg.payload['message'], msg.payload['title'], msg.payload['duration']);
        break;
    }

    return true;
  }

  final List<Widget> pages = [];
  int pageIx = 1;
  final PageController pageController = PageController(initialPage: 1);
  bool _propagateAnimations = true;

  _AppHomeState() {
    pages.add(News());
    pages.add(Home());
    pages.add(UpdateHome());
    pages.add(Container());
  }

  void onChanged(int idx) {
    _propagateAnimations = false;
    pageController.animateToPage(
      idx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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

    return Scaffold(resizeToAvoidBottomInset: false,
        primary: true,
        appBar: (draggebleAppBar),
        drawer: Drawer(child: AboutRoute(context)),
          body: Container(
          height: context.heightPx,
          width: context.widthPx,
          child: Stack(overflow: Overflow.clip,
            children: <Widget>[
              background,
              PageView(
                onPageChanged: (i) {
                  if (i >= 3) {
                    i = 2;
                    _loginMenu();
                  } else if (i != 1) {
                    expListener.reset();
                    expController.expandTarget(ExpandTarget.NONE);
                    expController.setNumOpen(0);
                  }
                  setState(() {
                    pageIx = i;
                    data.updateValue("title", title[pageIx]);
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
