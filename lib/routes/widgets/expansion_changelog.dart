import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logger/logger.dart';
import 'package:supercharged/supercharged.dart';

import '../../data/events/expansion_event.dart';
import '../../data/models/changelog_data.dart';
import '../../helpers/custom_card.dart';
import '../../helpers/custom_color.dart';
import '../../packages/expandable_news/expandable.dart';
import '../../services/service_locator.dart';
import 'changelog_header.dart';


class ExpansionChangeLog extends StatelessWidget {
  final log = sl<Logger>();
  final exp = ExpansionListener();

  final ChangeLogData changeLog;
  final int index;

  ExpansionChangeLog({Key key, this.changeLog, this.index}) : super(key: key) {}

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
      type: "changelog",
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: CustomCard(
          color: Color.fromRGBO(33, 33, 33, 0.9),
          elevation: 2,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              ScrollOnExpand(
                key: ValueKey(changeLog.id),
                scrollOnExpand: true,
                scrollOnCollapse: true,
                child: ExpandablePanel(
                  theme: themeData,
                  header: ChangelogHeader(key: ValueKey(changeLog.id), changeLog: changeLog, index: index),
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
                          '${changeLog.description}',
                          softWrap: true,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.subtitle2.copyWith(
                            fontSize: 12,
                            shadows: [Shadow(color: AppColors.DARK_DARK, blurRadius: 1)],
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
                      (changeLog.useMarkdown)
                          ? Container(
                              child: Markdown(
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                shrinkWrap: true,
                                selectable: true,
                                data: '${changeLog.details}',
                                imageDirectory: 'https://raw.githubusercontent.com',
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 0, 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      for (var item in changeLog.itemList)
                                        Row(
                                          children: <Widget>[
                                            Divider(
                                              color: Color.fromRGBO(210, 160, 12, 0.3),
                                              thickness: 3.0,
                                              height: 2.0,
                                              indent: 0,
                                              endIndent: 0,
                                            ),
                                            Text(
                                              '${item}',
                                              textAlign: TextAlign.left,
                                              softWrap: true,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.subtitle2.copyWith(
                                                fontSize: 12,
                                                shadows: [Shadow(color: AppColors.DARK_DARK, blurRadius: 1)],
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  Markdown(
                                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    shrinkWrap: true,
                                    selectable: true,
                                    data: '${changeLog.details}',
                                    imageDirectory: 'https://raw.githubusercontent.com',
                                  ),
                                ],
                              )), Divider(
                        color: Color.fromRGBO(21, 21, 21, 0.6),
                        thickness: 3.0,
                        height: 2.0,
                        indent: 30,
                        endIndent: 30,
                      ),
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
