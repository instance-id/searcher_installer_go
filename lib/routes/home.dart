import 'package:eventsubscriber/eventsubscriber.dart';
import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:null_widget/null_widget.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:sized_context/sized_context.dart';

import '../data/events/expansion_event.dart';
import '../routes/widgets/change_log_list.dart';
import '../routes/widgets/news_main_home.dart';
import '../services/service_locator.dart';

const appTitle = "Searcher : Installer";
bool startCompleted = false;

enum ExpandTarget { NONE, NEWS, CLOG }

class Home extends StatefulWidget {
  static const routeName = '/home';

  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AnimationMixin {
  final Logger log = new Logger();
  final expListener = sl<ExpansionListener>();
  final expController = sl<ExpansionController>();
  var handler;

  ExpandTarget expTarget;
  bool loadingComplete = false;

  get numOpened => expController.numOpen;

  set numOpened(num) => expController.setNumOpen(num);

  @override
  void initState() {
    handler = (args) => expandController(expListener.value, expListener.type);
    expListener.valueChangedEvent.subscribe(handler);
    expTarget = ExpandTarget.NONE;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
    super.initState();
  }

  expandController(bool value, String type) {
    if (value && type == "changelog") {
      numOpened++;
    } else if (!value && type == "changelog") {
      numOpened--;
    } else if (value && type == "news") {
      numOpened--;
    } else if (!value && type == "news") {
      numOpened++;
    }

    if (numOpened == 0) {
      expController.expandTarget(ExpandTarget.NONE);
    } else if (numOpened > 0) {
      expController.expandTarget(ExpandTarget.CLOG);
    } else if (numOpened < 0) {
      expController.expandTarget(ExpandTarget.NEWS);
    }
    setState(() {});
  }

  @override
  void dispose() {
    expListener.valueChangedEvent.unsubscribe(handler);
    super.dispose();
  }

  Map<ExpandTarget, dynamic> target = {
    ExpandTarget.NONE: {"newsWidth": 50, "spacer": 5, "changeLogWidth": 50},
    ExpandTarget.CLOG: {"newsWidth": 25, "spacer": 1, "changeLogWidth": 79},
    ExpandTarget.NEWS: {"newsWidth": 79, "spacer": 1, "changeLogWidth": 25}
  };

  @override
  Widget build(BuildContext context) {
    var duration = Duration(milliseconds: 150);

    return Material(
      type: MaterialType.transparency,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedContainer(
          duration: duration,
          color: Colors.transparent,
          child: FluidLayout(
            horizontalPadding: FluidValue((_) => 0),
            child: Fluid(
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 22, 0, 30),
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                height: context.heightPx - 122,
                width: context.widthPx,
                child: EventSubscriber(
                    event: expController.valueChangedEvent,
                    handler: (context, args) =>
                        Flex(mainAxisSize: MainAxisSize.max,
                          clipBehavior: Clip.hardEdge,
                          direction: Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            AnimatedContainer(
                              curve: Curves.fastOutSlowIn,
                              height: context.heightPx,
                              width: (((target[expController.target]["newsWidth"]) * 0.1) * (context.widthPx * 0.09)),
                              duration: duration,
                              child: NewsMainHome(),
                            ),
                            (expController.isNone) ? Spacer(flex: target[expController.target]["spacer"]) : NullWidget(),
                            AnimatedContainer(
                              curve: Curves.fastOutSlowIn,
                              height: context.heightPx,
                              alignment: Alignment.center,
                              width: (((target[expController.target]["changeLogWidth"]) * 0.1) * (context.widthPx * 0.09)),
                              duration: duration,
                              child: ChangeLogList(),
                            ),
                          ],
                        )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
