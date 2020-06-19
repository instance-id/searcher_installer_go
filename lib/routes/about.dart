import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_data.dart';

class AboutRoute extends StatefulWidget {
  AboutRoute(BuildContext context);

  @override
  _AboutRouteState createState() => _AboutRouteState();
}

class _AboutRouteState extends State<AboutRoute> {
  Logger log = new Logger();

  get title => 'About';

  Future<void> _makeCall(String url) async {
    await launch(url).catchError((e) => log.e("Cannot get news data: $e"));
  }

  List<Widget> aboutListTiles(BuildContext context) {
    return <Widget>[
      ListTile(
        title: Text(APP_DESCRIPTION),
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.code),
        title: Text('Source code on GitHub'),
//        onTap: () => _makeCall(GITHUB_URL),
        onTap: () => setState(() {
          var _launched = _makeCall(GITHUB_URL);
        }),
      ),
      ListTile(
        leading: Icon(Icons.bug_report),
        title: Text('Report issue on GitHub'),
        onTap: () => _makeCall('$GITHUB_URL/issues'),
      ),
      ListTile(
        leading: Icon(Icons.open_in_new),
        title: Text('Visit my website'),
        onTap: () => _makeCall(AUTHOR_SITE),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final header = ListTile(
      leading: AppIcon,
      title: Text(APP_NAME),
      subtitle: Text(APP_VERSION),
      trailing: IconButton(
        icon: Icon(Icons.info),
        onPressed: () {
          showAboutDialog(
            context: context,
            applicationName: APP_NAME,
            applicationVersion: APP_VERSION,
            applicationIcon: AppIcon,
            children: <Widget>[
              Text(APP_DESCRIPTION),
            ],
          );
        },
      ),
    );
    return Container(
      color: Color(0xf0303030),
      child: ListView(
        children: <Widget>[header]..addAll(aboutListTiles(context)),
      ),
    );
  }
}
