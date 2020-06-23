import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../data/models/changelog_data.dart';
import '../../../helpers/custom_color.dart';

class ExpansionChangeLogExpanded extends StatelessWidget {
  const ExpansionChangeLogExpanded({
    Key key,
    @required this.changeLog,
  }) : super(key: key);

  final ChangeLogData changeLog;


  @override
  Widget build(BuildContext context) {
    return Column(
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
                )),
        Divider(
          color: Color.fromRGBO(21, 21, 21, 0.6),
          thickness: 3.0,
          height: 2.0,
          indent: 30,
          endIndent: 30,
        ),
      ],
    );
  }
}
