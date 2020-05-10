import 'package:global_configuration/global_configuration.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:searcher_installer/routes/home.dart';
import 'package:searcher_installer/routes/news.dart';
import 'package:searcher_installer/update_home.dart';
import 'package:searcher_installer/routes/about.dart';
import 'package:searcher_installer/routes/app_bar.dart';
import 'package:searcher_installer/routes/tab_menu.dart';

import 'helpers/background.dart';

class AppHome extends StatefulWidget {
  @override
  _AppHomeState createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> with TickerProviderStateMixin {
  final GlobalKey<TabMenuState> _keyNavigator = GlobalKey<TabMenuState>();
  var log = Logger();
  List<String> title = ["Searcher : News", "Searcher : Installer", "Searcher : Account", "Searcher : Change Log"];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    TabMenu navigator = TabMenu(
      key: _keyNavigator,
      onChanged: onChanged,
    );

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
