import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:searcher_installer/data/models/changelog_data.dart';
import 'package:searcher_installer/data/provider/changelog_provider.dart';
import 'package:searcher_installer/helpers/custom_card.dart';

class ChangeLogItem extends StatelessWidget {
  final String id;
  final String version;
  final String title;
  final String description;
  final String dateposted;
  final String project;

  final IconData iconData;
  final double itemHeight;
  final VoidCallback openContainer;

  ChangeLogItem(
    this.id,
    this.version,
    this.title,
    this.description,
    this.dateposted,
    this.project,
    this.iconData,
    this.itemHeight, {
    this.openContainer,
  });

  @override
  Widget build(BuildContext context) {
    var infoService = Provider.of<ChangeLogDataProvider>(context);

    return Container(
        height: itemHeight,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: EdgeInsets.fromLTRB(0, 1, 2, 1),
        child: CustomCard(
          padding: [2, 0, 0, 0],
          elevation: 0,
          shadowColor: Colors.black,
          color: Color.fromRGBO(35, 47, 52, 0.9),
          child: FutureProvider(
            create: (context) => infoService.fetchchangelog(id, project),
            child: Consumer<ChangeLogData>(
              builder: (context, cLog, widget) {
                return InkWell(
                    onTap: openContainer,
                    highlightColor: Colors.redAccent,
                    splashColor: Colors.orange,
                    child: Container(
                        padding: EdgeInsets.fromLTRB(5, 5, 8, 0),
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                              Row(
                                children: [
                                  Container(
                                    child: Text(title, style: Theme.of(context).textTheme.subhead),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3),
                              Row(
                                children: [
                                  SizedBox(width: 1),
                                  Container(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                          padding: EdgeInsets.fromLTRB(0, 0, 0, 3),
                                          child: Text(
                                            description,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            textScaleFactor: 0.8,
                                            style: Theme.of(context).textTheme.bodyText1,
                                          ))),
                                ],
                              )
                            ]),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Text("v", style: Theme.of(context).textTheme.bodyText1),
                                      Text(version, style: Theme.of(context).textTheme.bodyText1),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  child: Icon(
                                    iconData,
                                    color: Colors.orange.withOpacity(0.6),
                                    size: 22,
                                  ),
                                )
                              ],
                            )
                          ]),
                          Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 2), child: Row(children: <Widget>[]))
                        ])));
              },
            ),
          ),
        ));
  }
}
