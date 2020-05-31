import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:sized_context/sized_context.dart';

import '../../data/events/expansion_event.dart';
import '../../animations/anim_FadeInVT.dart';
import '../../data/models/changelog_data.dart';
import '../../data/provider/changelog_provider.dart';
import '../../helpers/custom_card.dart';

import 'expansion_changelog.dart';

class ChangeLogList extends StatefulWidget {
  ChangeLogList({Key key}) : super(key: key);

  @override
  _ChangeLogListState createState() => _ChangeLogListState();
}

final sl = GetIt.instance;

class _ChangeLogListState extends State<ChangeLogList> {
  final log = sl<Logger>();
  final exp = sl<ExpansionListener>();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    List<ChangeLogData> changeLog = Provider.of<ChangeLogDataProvider>(context).changeLog;

    return CustomCard(
      borderRadius: [10, 10, 5, 5],
      padding: [0, 0, 0, 0],
      elevation: 6,
      shadowColor: Colors.black,
      color: Color.fromRGBO(35, 47, 52, 0.8),
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            CustomCard(
              borderRadius: [10, 10, 0, 0],
              color: Colors.black54,
              elevation: 3,
              child: Container(
                  height: 25,
                  width: context.widthPx,
                  child: Text(
                    "Change Log",
                    textAlign: TextAlign.center,
                  )),
            ),
            SizedBox(height: 8),
            FluidLayout(
              child: Fluid(
                  horizontalPadding: 0,
                  child: (changeLog == null)
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                          children: <Widget>[
                            Container(
                              height: context.heightPx - 165,
                              child: ListView.separated(
                                controller: _scrollController,
                                itemCount: changeLog.length,
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                scrollDirection: Axis.vertical,
                                separatorBuilder: (context, __) => SizedBox(height: 5),
                                itemBuilder: (context, index) => FadeInVertical(
                                  delay: (index.toDouble() * 0.3) + 0.3,
                                  distance: -75,
                                  duration: 500,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
                                    child: ExpansionChangeLog(
                                      key: ValueKey('${changeLog[index].id}'),
                                      changeLog: changeLog[index],
                                      index: index,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
