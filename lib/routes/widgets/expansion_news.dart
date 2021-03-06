import 'package:dynamic_widget/dynamic_widget/icons_helper.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

import '../../data/models/news_data.dart';
import '../../helpers/custom_card.dart';
import '../../helpers/custom_color.dart';
import '../../packages/expandable_news/expandable.dart';

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
  ExpansionNews({Key key, this.news, this.index}) : super(key: key) {}
  final NewsData news;
  final int index;

  final themeData = ExpandableThemeData(
    headerAlignment: ExpandablePanelHeaderAlignment.center,
    useInkWell: false,
    tapBodyToCollapse: false,
    crossFadePoint: 0.8,
    tapBodyToExpand: false,
    animationDuration: 300.milliseconds,
    fadeCurve: Curves.easeIn,
    sizeCurve: Curves.easeInOutQuart,
  );

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: CustomCard(
          color: Color.fromRGBO(33, 33, 33, 0.9),
          elevation: 2,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              ScrollOnExpand(
                scrollOnExpand: true,
                scrollOnCollapse: true,
                child: ExpandablePanel(
                  theme: themeData,
                  header: Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(7, 3, 5, 3),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                            child: (news.icon != "")
                                ? Icon(
                                    getIconGuessFavorFA(name: news.icon),
                                    color: Colors.orange.withOpacity(0.5),
                                  )
                                : Icon(iconList[index])),
                        Spacer(flex: 5),
                        Text('${news.title}',
                            style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                              fontSize: 16,
                              color: Color(0xFF607FAE),
                              shadows: [
                                Shadow(color: AppColors.BG_DARK, blurRadius: 1)
                              ],
                            )),
                        Spacer(flex: 95),
                        Text('${news.dateposted}',
                            style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                              fontSize: 16,
                              color: Color(0xFF607FAE),
                              shadows: [
                                Shadow(
                                    color: AppColors.DARK_DARK, blurRadius: 1)
                              ],
                            )),
                      ],
                    ),
                  ),
                  collapsed: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Divider(
                        color: Color.fromRGBO(210, 160, 12, 0.1),
                        thickness: 3.0,
                        height: 2.0,
                        indent: 0,
                        endIndent: 0,
                      ),
                      SizedBox(height: 6),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text(
                          '${news.description}',
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.subtitle2.copyWith(
                            fontSize: 13,
                            shadows: [
                              Shadow(color: AppColors.DARK_DARK, blurRadius: 1)
                            ],
                          ),
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
                      SizedBox(height: 6),
                      for (var _ in Iterable.generate(5))
                        Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
                            child: Text(
                              '${news.details.trimLeft()}',
                              softWrap: true,
                              overflow: TextOverflow.fade,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                fontSize: 13,
                                shadows: [
                                  Shadow(
                                      color: AppColors.DARK_DARK, blurRadius: 1)
                                ],
                              ),
                            )),
                    ],
                  ),
                  builder: (_, collapsed, expanded) {
                    return Padding(
                      padding: EdgeInsets.only(left: 0, right: 0, bottom: 10),
                      child: Expandable(
                        collapsed: collapsed,
                        expanded: expanded,
                        theme: themeData,
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
