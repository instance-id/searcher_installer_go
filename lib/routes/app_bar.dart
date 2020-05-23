import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:searcher_installer_go/helpers/animate_route.dart';
import 'package:searcher_installer_go/helpers/custom_color.dart';
import 'package:searcher_installer_go/routes/about.dart';
import 'package:searcher_installer_go/routes/tab_menu.dart';

import 'dashboard_screen.dart';

class MainAppBar extends StatelessWidget {
  MainAppBar(BuildContext context, this.keyNavigator);

  final GlobalKey<TabMenuState> keyNavigator;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            GlobalConfiguration().getString("title"),
            style: TextStyle(color: Color(0xFF2ead51), letterSpacing: 1, fontSize: 18),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: Color(0xFF2ead51),
          ),
          actions: <Widget>[
            PopupMenuButton<int>(
              onSelected: (int result) async {
                switch (result) {
                  case 0:
                    Scaffold.of(context).openDrawer();
                    break;
                }
              },
              icon: Icon(Icons.settings_applications, size: 20,),
              tooltip: "About",
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                PopupMenuItem<int>(
                    height: 45,
                    value: 0,
                    child: Container(
                      alignment: Alignment.center,
                      height: 35,
                      width: 85,
                      child: Row(
                        children: [
                          Text("About"),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.settings_applications),
                        ],
                      ),
                    ))
              ],
            )
          ]),
    );
  }
}

class DraggebleAppBar extends StatelessWidget implements PreferredSizeWidget {
//  static const platform_channel_dragable = MethodChannel('samples.go-flutter.dev/dragable');

  final MainAppBar appBar;

  const DraggebleAppBar({Key key, this.appBar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(child: appBar);
  }

  @override
  Size get preferredSize => new Size.fromHeight(35);
}
