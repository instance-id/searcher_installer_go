import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:searcher_installer_go/data/models/changelog_data.dart';
import 'package:searcher_installer_go/data/provider/changelog_provider.dart';
import 'package:searcher_installer_go/helpers/custom_card.dart';
import 'package:searcher_installer_go/helpers/custom_color.dart';
import 'package:searcher_installer_go/helpers/icons_helper.dart';
import 'package:searcher_installer_go/packages/expandable_news/expandable.dart';
import 'package:supercharged/supercharged.dart';

import 'changelog_header.dart';

var backupIconList = [
  getIconGuessFavorFA(name: "bug"),
  getIconGuessFavorFA(name: "whatshot"),
  getIconGuessFavorFA(name: "hourglass"),
  Icons.hourglass_empty,
  Icons.threed_rotation,
  Icons.image_aspect_ratio,
  Icons.threesixty,
];

class ExpansionChangeLog extends StatelessWidget {
  Logger log = Logger();
  final ChangeLogData changeLog;
  final int index;
  ExpansionChangeLog(this.changeLog, this.index);

  @override
  Widget build(BuildContext context) {
    final changeLogData = Provider.of<ChangeLogDataProvider>(context);
//    final _expandableController = ExpandableController.of(context);

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
                  theme: ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    useInkWell: false,
                    tapBodyToCollapse: true,
                    crossFadePoint: 0.8,
                    tapBodyToExpand: true,
                    animationDuration: 600.milliseconds,
                    fadeCurve: Curves.easeIn,
                    sizeCurve: Curves.easeInOutQuart,
                  ),
                  header: ChangelogHeader(changeLog, index),
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
                      SizedBox(height: 6),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text(
                          '${changeLog.description}',
                          softWrap: true,
                          maxLines: 2,
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
//                      for (var _ in Iterable.generate(5))
                      (changeLog.useMarkdown)
                          ? Container(
                              child: Markdown(
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                shrinkWrap: true,
                                selectable: true,
                                data: '${changeLog.details}',
                                imageDirectory: 'https://raw.githubusercontent.com',
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (var item in changeLog.itemList)
                                        Row(
                                          children: [
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
                                              overflow: TextOverflow.fade,
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
                              ))
                    ],
                  ),
                  builder: (context, collapsed, expanded) {
                    return Padding(
                      padding: EdgeInsets.only(left: 0, right: 0, bottom: 10),
                      child: Expandable(
                        collapsed: collapsed,
                        expanded: expanded,
                        theme: ExpandableThemeData(
                          useInkWell: false,
                          crossFadePoint: 0.8,
                          tapBodyToCollapse: true,
                          tapBodyToExpand: true,
                          fadeCurve: Curves.easeIn,
                          sizeCurve: Curves.easeInOutQuart,
                        ),
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
