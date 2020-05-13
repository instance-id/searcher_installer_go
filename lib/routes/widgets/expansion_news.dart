import 'package:dynamic_widget/dynamic_widget/icons_helper.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:searcher_installer_go/data/models/news_data.dart';
import 'package:supercharged/supercharged.dart';

var iconList = [
  getIconGuessFavorFA(name: "bug"),
  getIconGuessFavorFA(name: "whatshot"),
  getIconGuessFavorFA(name: "hourglass"),
  Icons.hourglass_empty,
  Icons.threed_rotation,
  Icons.image_aspect_ratio,
  Icons.threesixty,
];

class ExpansionNews extends StatelessWidget {
  ExpansionNews(this.news, this.index);
  final NewsData news;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Card(
          color: Color.fromRGBO(35, 47, 52, 0.7),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              ScrollOnExpand(
                scrollOnExpand: true,
                scrollOnCollapse: false,
                child: ExpandablePanel(
                  theme: ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    tapBodyToCollapse: true,
                    animationDuration: 500.milliseconds,
                  ),
                  header: Container(
                    height: 50,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Row(
                          children: [
                            CircleAvatar(
                                child: (news.icon != "")
                                    ? Icon(
                                        getIconGuessFavorFA(name: news.icon),
                                        color: Colors.orange.withOpacity(0.5),
                                      )
                                    : Icon(iconList[index])),
                            Spacer(flex: 1),
                            Text('${news.title}', style: Theme.of(context).textTheme.bodyText2),
                            Spacer(flex: 19),
                            Text('${news.dateposted}', style: Theme.of(context).textTheme.bodyText2),
                          ],
                        )),
                  ),
                  collapsed: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        color: Color.fromRGBO(210, 160, 12, 0.1),
                        thickness: 3.0,
                        height: 2.0,
                        indent: 0,
                        endIndent: 0,
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text(
                          '${news.description}',
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ),
                    ],
                  ),
                  expanded: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Divider(
                        color: Color.fromRGBO(210, 160, 12, 0.3),
                        thickness: 3.0,
                        height: 2.0,
                        indent: 0,
                        endIndent: 0,
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      for (var _ in Iterable.generate(5))
                        Padding(
                            padding: EdgeInsets.only(bottom: 10, left: 10),
                            child: Text(
                              '${news.details.trimLeft()}',
                              softWrap: true,
                              overflow: TextOverflow.fade,
                              style: Theme.of(context).textTheme.subtitle2,
                            )),
                    ],
                  ),
                  builder: (_, collapsed, expanded) {
                    return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: Expandable(
                        collapsed: collapsed,
                        expanded: expanded,
                        theme: const ExpandableThemeData(crossFadePoint: 0),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
