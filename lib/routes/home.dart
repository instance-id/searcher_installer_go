import 'package:eventsubscriber/eventsubscriber.dart';
import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:searcher_installer_go/animations/anim_flex.dart';
import 'package:searcher_installer_go/data/provider/changelog_provider.dart';
import '../data/events/expansion_event.dart';
import 'package:searcher_installer_go/routes/widgets/change_log_list.dart';
import 'package:searcher_installer_go/routes/widgets/news_main_home.dart';

const appTitle = "Searcher : Installer";
bool startCompleted = false;

enum ExpandTarget { NONE, NEWS, CHANGELOG }

final sl = GetIt.instance;

class Home extends StatefulWidget {
  static const routeName = '/home';

  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final Logger log = new Logger();
  final exp = sl<ExpansionListener>();
  final expController = sl<ExpansionController>();

  AnimationController _controller;
  FlexAnimation flexAnimation;
  ExpandTarget expTarget;

  bool loadingComplete = false;
  int numOpened = 0;

  Map<ExpandTarget, dynamic> target = {
    ExpandTarget.NONE: {"newsWidth": 50, "spacer": 5, "changeLogWidth": 50},
    ExpandTarget.CHANGELOG: {"newsWidth": 15, "spacer": 1, "changeLogWidth": 85},
    ExpandTarget.NEWS: {"newsWidth": 85, "spacer": 1, "changeLogWidth": 15}
  };

  @override
  void initState() {
    exp.valueChangedEvent + (args) => expandController(exp.value, exp.type);
    expTarget = ExpandTarget.NONE;
    numOpened = 0;

    _controller = new AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    flexAnimation = FlexAnimation(_controller);
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
      expController.expandTarget(ExpandTarget.CHANGELOG);
    } else if (numOpened < 0) {
      expController.expandTarget(ExpandTarget.NEWS);
    }
  }

  AnimateSize(ChangeLogDataProvider changeLogData) {
    if (!_controller.isAnimating) (changeLogData.getWidth) ? _controller.forward().orCancel : _controller.reverse().orCancel;
    changeLogData.setNeedsExpand(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          color: Colors.transparent,
          child: FluidLayout(
            horizontalPadding: FluidValue((_) => 0),
            child: Fluid(
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 22, 0, 30),
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                height: MediaQuery.of(context).size.height - 122,
                child: EventSubscriber(
                  event: expController.valueChangedEvent,
                  handler: (context, args) => Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Flexible(flex: (target[expController.target]["newsWidth"]), child: NewsMainHome()),
                      Spacer(flex: target[expController.target]["spacer"]),
                      Expanded(flex: (target[expController.target]["changeLogWidth"]), child: ChangeLogList()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
