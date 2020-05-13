import 'package:flutter/material.dart';
import 'package:searcher_installer_go/data/models/changelog_data.dart';

class OverlayWidget {
  static OverlayEntry overlayEntry;

  static void show(
    BuildContext context,
    ChangeLogData cLog, {
    double width = 250,
    double height = 250,
    bool autoDismiss = true,
  }) {
    // if (overlayEntry == null) {
    overlayEntry = buildOverlay(cLog, width: width, height: height);
    // }
    return Overlay.of(context).insert(overlayEntry);
//    if (autoDismiss) Future.delayed(Duration(seconds: 2), dismiss);
  }

  static void dismiss() {
    overlayEntry.remove();
  }

  static buildOverlay(ChangeLogData cLog, {double width, double height}) {
    return OverlayEntry(
        builder: (context) => Center(
              child: Material(
                color: Colors.white.withOpacity(0),
                child: Container(
                  color: Colors.transparent,
//                  child: ChangeLogDetails(
//                    cLog.id,
//                    cLog.project,
//                    cLog.iconData,
//                    80,
//                  ),
                ),
              ),
            ));
  }
}
