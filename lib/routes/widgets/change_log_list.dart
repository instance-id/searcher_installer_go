import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:searcher_installer/animations/slide_in.dart';
import 'package:searcher_installer/data/models/changelog_data.dart';
import 'package:searcher_installer/data/provider/changelog_provider.dart';
import 'package:searcher_installer/helpers/custom_card.dart';
import 'package:searcher_installer/helpers/icons_helper.dart';
import 'package:searcher_installer/helpers/open_container.dart';
import 'package:sized_context/sized_context.dart';
import 'package:supercharged/supercharged.dart';

import '../changelog_details.dart';
import '../changelog_item.dart';

class ChangeLogList extends StatefulWidget {
  ChangeLogList();

  @override
  _ChangeLogListState createState() => _ChangeLogListState();
}

class _ChangeLogListState extends State<ChangeLogList> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final Logger log = new Logger();
  List<ChangeLogData> changeLog;

  @override
  void initState() {
    _controller = new AnimationController(
      duration: 1000.milliseconds,
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
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
            SizedBox(
              height: 4,
            ),
            FluidLayout(
              horizontalPadding: FluidValue((_) => 0),
              child: Fluid(
                  horizontalPadding: 10,
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
                                itemBuilder: (context, index) => SlideFadeIn(
                                  key: Key(index.toString()),
                                  begin: 130.0,
                                  end: 0,
                                  direction: "translateX",
                                  delay: (index.toDouble() * 0.2) + 0.3,
                                  child: OpenContainer(
                                    transitionType: ContainerTransitionType.fadeThrough,
                                    closedShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                      Radius.circular(12.0),
                                    )),
                                    closedColor: Colors.transparent,
                                    closedElevation: 3.0,
                                    closedBuilder: (BuildContext _, VoidCallback openContainer) {
                                      return (changeLog[index] == null)
                                          ? Center(child: CircularProgressIndicator())
                                          : ChangeLogItem(
                                              changeLog[index].id,
                                              changeLog[index].version,
                                              changeLog[index].title,
                                              changeLog[index].description,
                                              changeLog[index].dateposted,
                                              changeLog[index].project,
                                              iconList[index],
                                              75,
                                              openContainer: openContainer,
                                            );
                                    },
                                    openColor: Colors.transparent,
                                    openBuilder: (context, action) => ChangeLogDetails(
                                      changeLog[index].id,
                                      changeLog[index].project,
                                      iconList[index],
                                      80,
                                    ),
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
