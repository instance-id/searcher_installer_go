import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:searcher_installer/data/models/changelog_data.dart';
import 'package:supercharged/supercharged.dart';

class OpenContainerWrapper extends StatelessWidget {
  const OpenContainerWrapper( {
    this.changeLog,
    this.detailsPage,
    this.closedBuilder,
    this.transitionType,
  });

  final ChangeLogData changeLog;
  final Widget detailsPage;
  final OpenContainerBuilder closedBuilder;
  final ContainerTransitionType transitionType;

  @override
  Widget build(BuildContext context) {
    List<double> borderRadius = const [10, 10, 10, 10];

    return OpenContainer(
      openShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius[0]),
            topRight: Radius.circular(borderRadius[1]),
            bottomRight: Radius.circular(borderRadius[2]),
            bottomLeft: Radius.circular(borderRadius[3]),
          )),
      transitionDuration: 700.milliseconds,
      closedColor: Colors.transparent,
      openColor: Colors.transparent,
      transitionType: transitionType,
      // ignore: missing_return
      openBuilder: (BuildContext context, VoidCallback _) {

//        return Navigator.of(context).push(PageRouteBuilder(
//            opaque: false,
//            pageBuilder: (BuildContext context, _, __) => detailsPage));
            return detailsPage;
      },
      tappable: false,
      closedBuilder: closedBuilder,
    );
  }
}
