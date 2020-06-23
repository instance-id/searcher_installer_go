import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:supercharged/supercharged.dart';

import '../../data/events/expansion_event.dart';
import '../../data/models/changelog_data.dart';
import '../../helpers/custom_card.dart';
import '../../helpers/custom_color.dart';
import '../../packages/expandable_news/expandable.dart';
import '../../routes/widgets/change_log/expansion_change_log_expanded.dart';
import '../../services/service_locator.dart';
import 'change_log/changelog_header.dart';

class ExpansionChangeLog extends StatelessWidget {
  final exp = ExpansionListener();
  final ChangeLogData changeLog;
  final log = sl<Logger>();
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
      key: ValueKey(changeLog.id),
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
                scrollOnExpand: true,
                scrollOnCollapse: true,
                child: ExpandablePanel(
                  key: ValueKey(changeLog.id),
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
                  expanded: ExpansionChangeLogExpanded(key: ValueKey(changeLog.id), changeLog: changeLog),
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
