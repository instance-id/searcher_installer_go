import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:searcher_installer_go/animations/anim_FadeInVT.dart';
import 'package:searcher_installer_go/data/models/changelog_data.dart';
import 'package:searcher_installer_go/data/provider/changelog_provider.dart';
import 'package:searcher_installer_go/helpers/custom_card.dart';
import 'package:searcher_installer_go/helpers/icons_helper.dart';
import 'package:sized_context/sized_context.dart';

import 'expansion_changelog.dart';

class ChangeLogList extends StatefulWidget {
  ChangeLogList();

  @override
  _ChangeLogListState createState() => _ChangeLogListState();
}

class _ChangeLogListState extends State<ChangeLogList> with SingleTickerProviderStateMixin {
  final Logger log = new Logger();
  List<ChangeLogData> changeLog;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    changeLog = Provider.of<ChangeLogDataProvider>(context).changeLog;

    var iconList = [
      getIconGuessFavorFA(name: "bug"),
      Icons.hotel,
      Icons.hourglass_empty,
      Icons.threed_rotation,
      Icons.image_aspect_ratio,
      Icons.threesixty,
    ];

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
          children: [
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
              horizontalPadding: FluidValue((_) => 0),
              child: Fluid(
                  child: (changeLog == null)
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            Container(
                              height: context.heightPx - 165,
                              child: ListView.separated(
                                itemCount: changeLog.length,
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                scrollDirection: Axis.vertical,
                                separatorBuilder: (context, __) => SizedBox(height: 5),
                                itemBuilder: (context, index) => FadeInVertical(
                                  delay: (index.toDouble() * 0.3) + 0.3,
                                  distance: -75,
                                  duratin: 500,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
                                    child: ExpansionChangeLog(changeLog[index], index),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
