import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

import '../data/events/messages_event.dart';
import '../data/events/request_login_event.dart';
import '../data/provider/fb_auth_provider.dart';
import '../helpers/custom_color.dart';
import '../services/service_locator.dart';
import '../widgets//drop_down.dart' as p;

class MainAppBar extends StatelessWidget {
  final msg = sl<Message>();
  final login = sl<RequestLogin>();

  MainAppBar();

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<FBAuthProvider>().isLoggedIn;
    final auth = Provider.of<FBAuthProvider>(context, listen: false);

    return Container(
      alignment: Alignment.center,
      child: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            '${data.getString("title")}',
            style: TextStyle(color: AppColors.M_DYELLOW, fontWeight: FontWeight.w500, letterSpacing: 1, fontSize: 18),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: AppColors.M_DYELLOW,
          ),
          actions: <Widget>[
            p.PopupMenuButton<int>(
              onSelected: (int result) async {
                switch (result) {
                  case 0:
                    Scaffold.of(context).openDrawer();
                    break;
                  case 1:
                    if (isLoggedIn) {
                      login.sendEvent();
                      Future.microtask(() => auth.signOut());
                    }
                    break;
                  case 2:
                    if ((!isLoggedIn)) {
                      login.sendEvent();
                    }
                    break;
                }
              },
              icon: Icon(Icons.settings_applications, size: 21),
              tooltip: "About",
              padding: EdgeInsets.all(0),
              itemBuilder: (BuildContext context) => <p.PopupMenuEntry<int>>[
                p.PopupMenuItem<int>(
                    height: 35,
                    value: 0,
                    child: Container(
                      padding: EdgeInsets.all(0),
                      alignment: Alignment.center,
                      height: 35,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("About"),
                          Spacer(),
                          Icon(Icons.settings_applications, size: 21),
                          SizedBox(width: 1),
                        ],
                      ),
                    )),
                (isLoggedIn)
                    ? p.PopupMenuItem<int>(
                        height: 35,
                        value: 1,
                        child: Container(
                          alignment: Alignment.center,
                          height: 35,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Logout"),
                              Spacer(),
                              Icon(Ionicons.md_log_out, size: 21),
                            ],
                          ),
                        ))
                    : p.PopupMenuItem<int>(
                        height: 35,
                        value: 2,
                        child: Container(
                          alignment: Alignment.center,
                          height: 35,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Login"),
                              Spacer(),
                              Icon(Ionicons.md_log_in, size: 21),
                            ],
                          ),
                        )),
              ],
            )
          ]),
    );
  }
}

class DraggebleAppBar extends StatelessWidget implements PreferredSizeWidget {
//  static const platform_channel_dragable = MethodChannel('samples.go-flutter.dev/dragable');

  MainAppBar appBar = MainAppBar();

  DraggebleAppBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(child: appBar);
  }

  @override
  Size get preferredSize => new Size.fromHeight(35);
}
