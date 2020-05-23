import 'package:dynamic_widget/dynamic_widget/icons_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:searcher_installer_go/data/models/changelog_data.dart';
import 'package:searcher_installer_go/data/provider/changelog_provider.dart';
import 'package:searcher_installer_go/helpers/custom_color.dart';
import 'package:searcher_installer_go/packages/expandable_news/expandable.dart';

var backupIconList = [
  getIconGuessFavorFA(name: "bug"),
  getIconGuessFavorFA(name: "whatshot"),
  getIconGuessFavorFA(name: "hourglass"),
  Icons.hourglass_empty,
  Icons.threed_rotation,
  Icons.image_aspect_ratio,
  Icons.threesixty,
];

class ChangelogHeader extends StatelessWidget {
  ChangelogHeader(this.changeLog, this.index);

  final ChangeLogData changeLog;
  final int index;

  @override
  Widget build(BuildContext context) {
    final changeLogData = Provider.of<ChangeLogDataProvider>(context);
    final _expandableController = ExpandableController.of(context);

    return GestureDetector(
      onTap: () {
        _expandableController.toggle();
        changeLogData.setWidth(_expandableController.expanded);
        changeLogData.setNeedsExpand(true);
        print(_expandableController.expanded);
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.fromLTRB(7, 0, 0, 3),
        child: Row(
          children: [
            CircleAvatar(
                radius: 14,
                child: (changeLog.icon != "")
                    ? Icon(
                        getIconGuessFavorFA(name: '${changeLog.icon}') ?? backupIconList[index],
                        color: Colors.orange.withOpacity(0.5),
                        size: 14,
                      )
                    : Icon(
                        backupIconList[index],
                        size: 14,
                      )),
            SizedBox(width: 7),
            Text('${changeLog.title}',
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontSize: 12,
                  color: Color(0xFF607FAE),
                  shadows: [Shadow(color: AppColors.BG_DARK, blurRadius: 1)],
                )),
            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('v${changeLog.version}',
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                      fontSize: 12,
                      color: Color(0xFF607FAE),
                      shadows: [Shadow(color: AppColors.DARK_DARK, blurRadius: 1)],
                    )),
                Text('${changeLog.dateposted}',
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                      fontSize: 12,
                      color: Color(0xFF607FAE),
                      shadows: [Shadow(color: AppColors.DARK_DARK, blurRadius: 1)],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
