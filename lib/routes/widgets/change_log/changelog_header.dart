import 'package:dynamic_widget/dynamic_widget/icons_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/models/changelog_data.dart';
import '../../../helpers/custom_color.dart';

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
  final ChangeLogData changeLog;
  final int index;

  ChangelogHeader({Key key, this.changeLog, this.index}) : super(key: key) {}

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: EdgeInsets.fromLTRB(7, 0, 0, 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            flex: 2,
            child: CircleAvatar(
                radius: 14,
                child: (changeLog.icon != "")
                    ? Icon(
                        getIconGuessFavorFA(name: '${changeLog.icon}') ?? backupIconList[index],
                        color: Colors.orange.withOpacity(0.5),
                        size: 14,
                      )
                    : Icon(backupIconList[index], size: 14)),
          ),
//          Flexible(flex: 0, child: NullWidget()),
          Flexible(
            flex: 10,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${changeLog.title}',
                  softWrap: true,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    fontSize: 12,
                    color: Color(0xFF607FAE),
                    shadows: [Shadow(color: AppColors.BG_DARK, blurRadius: 1)],
                  )),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text('v${changeLog.version}',
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                      fontSize: 12,
                      color: Color(0xFF607FAE),
                      shadows: [Shadow(color: AppColors.DARK_DARK, blurRadius: 1)],
                    )),
                Text('${changeLog.dateposted}',
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                      fontSize: 12,
                      color: Color(0xFF607FAE),
                      shadows: [Shadow(color: AppColors.DARK_DARK, blurRadius: 1)],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
